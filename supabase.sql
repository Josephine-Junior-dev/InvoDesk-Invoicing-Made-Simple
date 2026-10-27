-- InvoiceGenerator dedicated tables. Run once in Supabase SQL Editor.
create extension if not exists pgcrypto;
create table if not exists public.ig_businesses (
 id uuid primary key default gen_random_uuid(), owner_id uuid not null unique references auth.users(id) on delete cascade,
 business_name text not null default 'Your Business', email text, phone text, address text,
 invoice_prefix text not null default 'INV', next_invoice_number bigint not null default 1 check(next_invoice_number>0),
 created_at timestamptz not null default now(), updated_at timestamptz not null default now()
);
create table if not exists public.ig_customers (
 id uuid primary key default gen_random_uuid(), owner_id uuid not null references auth.users(id) on delete cascade,
 name text not null, email text, phone text, address text, created_at timestamptz not null default now(), updated_at timestamptz not null default now(), unique(owner_id,id)
);
create table if not exists public.ig_invoices (
 id uuid primary key default gen_random_uuid(), owner_id uuid not null references auth.users(id) on delete cascade,
 business_id uuid not null references public.ig_businesses(id) on delete restrict,
 customer_id uuid, invoice_number text not null,
 invoice_date date not null default current_date, due_date date, currency text not null default 'KES',
 status text not null default 'Unpaid' check(status in ('Draft','Unpaid','Paid')),
 discount numeric(12,2) not null default 0 check(discount>=0), tax_rate numeric(7,3) not null default 0 check(tax_rate>=0 and tax_rate<=100),
 subtotal numeric(12,2) not null default 0 check(subtotal>=0), total numeric(12,2) not null default 0 check(total>=0),
 amount_paid numeric(12,2) not null default 0 check(amount_paid>=0), notes text, terms text,
 created_at timestamptz not null default now(), updated_at timestamptz not null default now(), unique(business_id,invoice_number), unique(owner_id,id), constraint ig_invoices_customer_owner_fkey foreign key(owner_id,customer_id) references public.ig_customers(owner_id,id) on delete set null (customer_id)
);

-- Repair existing installations: keep ONE customer relationship only.
-- The composite foreign key also guarantees the customer belongs to the invoice owner.
DO $
declare
 c record;
begin
 if to_regclass('public.ig_invoices') is not null then
  for c in
   select con.conname
   from pg_constraint con
   join pg_class src on src.oid = con.conrelid
   join pg_namespace ns on ns.oid = src.relnamespace
   join pg_class dst on dst.oid = con.confrelid
   join pg_namespace dns on dns.oid = dst.relnamespace
   where ns.nspname = 'public'
     and src.relname = 'ig_invoices'
     and dns.nspname = 'public'
     and dst.relname = 'ig_customers'
     and con.contype = 'f'
  loop
   execute format('alter table public.ig_invoices drop constraint %I', c.conname);
  end loop;
  alter table public.ig_invoices
   add constraint ig_invoices_customer_owner_fkey
   foreign key (owner_id, customer_id)
   references public.ig_customers(owner_id, id)
   on delete set null (customer_id);
 end if;
END $;

create table if not exists public.ig_invoice_items (
 id uuid primary key default gen_random_uuid(), owner_id uuid not null references auth.users(id) on delete cascade,
 invoice_id uuid not null references public.ig_invoices(id) on delete cascade, description text not null,
 quantity numeric(12,3) not null check(quantity>0), unit_price numeric(12,2) not null default 0 check(unit_price>=0),
 line_total numeric(12,2) not null default 0, created_at timestamptz not null default now(), foreign key(owner_id,invoice_id) references public.ig_invoices(owner_id,id) on delete cascade
);
create index if not exists ig_customers_owner_idx on public.ig_customers(owner_id);
create index if not exists ig_invoices_owner_created_idx on public.ig_invoices(owner_id,created_at desc);
create index if not exists ig_items_invoice_idx on public.ig_invoice_items(invoice_id);
alter table public.ig_businesses enable row level security;
alter table public.ig_customers enable row level security;
alter table public.ig_invoices enable row level security;
alter table public.ig_invoice_items enable row level security;
drop policy if exists ig_businesses_owner on public.ig_businesses;
create policy ig_businesses_owner on public.ig_businesses for all to authenticated using(owner_id=(select auth.uid())) with check(owner_id=(select auth.uid()));
drop policy if exists ig_customers_owner on public.ig_customers;
create policy ig_customers_owner on public.ig_customers for all to authenticated using(owner_id=(select auth.uid())) with check(owner_id=(select auth.uid()));
drop policy if exists ig_invoices_owner on public.ig_invoices;
create policy ig_invoices_owner on public.ig_invoices for all to authenticated using(owner_id=(select auth.uid())) with check(owner_id=(select auth.uid()));
drop policy if exists ig_items_owner on public.ig_invoice_items;
create policy ig_items_owner on public.ig_invoice_items for all to authenticated using(owner_id=(select auth.uid())) with check(owner_id=(select auth.uid()));
grant usage on schema public to authenticated;
grant select,insert,update,delete on public.ig_businesses,public.ig_customers,public.ig_invoices,public.ig_invoice_items to authenticated;
create or replace function public.ig_create_invoice(p_customer_id uuid,p_invoice_date date,p_due_date date,p_currency text,p_discount numeric,p_tax_rate numeric,p_notes text,p_terms text,p_items jsonb)
returns uuid language plpgsql security definer set search_path=public,pg_temp as $$
declare v_uid uuid:=auth.uid(); v_business public.ig_businesses%rowtype; v_id uuid; v_number text; v_sub numeric(12,2); v_disc numeric(12,2); v_tax numeric(12,2); v_total numeric(12,2); x jsonb;
begin
 if v_uid is null then raise exception 'Please sign in first.'; end if;
 if p_items is null or jsonb_typeof(p_items)<>'array' or jsonb_array_length(p_items)<1 then raise exception 'At least one invoice item is required.'; end if;
 insert into public.ig_businesses(owner_id) values(v_uid) on conflict(owner_id) do nothing;
 select * into v_business from public.ig_businesses where owner_id=v_uid for update;
 if p_customer_id is not null and not exists(select 1 from public.ig_customers where id=p_customer_id and owner_id=v_uid) then raise exception 'Customer not found in your account.'; end if;
 if exists(select 1 from jsonb_array_elements(p_items) a where coalesce(trim(a->>'description'),'')='' or coalesce((a->>'quantity')::numeric,0)<=0 or coalesce((a->>'unit_price')::numeric,-1)<0) then raise exception 'Invalid item description, quantity or price.'; end if;
 select coalesce(sum((a->>'quantity')::numeric*(a->>'unit_price')::numeric),0)::numeric(12,2) into v_sub from jsonb_array_elements(p_items) a;
 v_disc:=least(v_sub,greatest(coalesce(p_discount,0),0)); v_tax:=(greatest(v_sub-v_disc,0)*greatest(coalesce(p_tax_rate,0),0)/100)::numeric(12,2); v_total:=greatest(v_sub-v_disc+v_tax,0)::numeric(12,2);
 v_number:=coalesce(nullif(trim(v_business.invoice_prefix),''),'INV')||'-'||lpad(v_business.next_invoice_number::text,5,'0');
 update public.ig_businesses set next_invoice_number=next_invoice_number+1,updated_at=now() where id=v_business.id;
 insert into public.ig_invoices(owner_id,business_id,customer_id,invoice_number,invoice_date,due_date,currency,status,discount,tax_rate,subtotal,total,notes,terms)
 values(v_uid,v_business.id,p_customer_id,v_number,coalesce(p_invoice_date,current_date),p_due_date,coalesce(nullif(p_currency,''),'KES'),'Unpaid',v_disc,greatest(coalesce(p_tax_rate,0),0),v_sub,v_total,p_notes,p_terms) returning id into v_id;
 for x in select value from jsonb_array_elements(p_items) loop
 insert into public.ig_invoice_items(owner_id,invoice_id,description,quantity,unit_price,line_total) values(v_uid,v_id,trim(x->>'description'),(x->>'quantity')::numeric,(x->>'unit_price')::numeric,((x->>'quantity')::numeric*(x->>'unit_price')::numeric)::numeric(12,2));
 end loop; return v_id;
end $$;
revoke all on function public.ig_create_invoice(uuid,date,date,text,numeric,numeric,text,text,jsonb) from public,anon;
grant execute on function public.ig_create_invoice(uuid,date,date,text,numeric,numeric,text,text,jsonb) to authenticated;

-- Dedicated payment and receipt tables for InvoiceGenerator.
-- These are separate from any existing InvoDesk or garage tables.
create table if not exists public.ig_payments (
 id uuid primary key default gen_random_uuid(),
 owner_id uuid not null references auth.users(id) on delete cascade,
 invoice_id uuid not null,
 amount numeric(12,2) not null check(amount>0),
 payment_date date not null default current_date,
 payment_method text,
 reference text,
 notes text,
 created_at timestamptz not null default now(),
 foreign key(owner_id,invoice_id) references public.ig_invoices(owner_id,id) on delete cascade,
 unique(owner_id,id)
);
create index if not exists ig_payments_owner_invoice_idx on public.ig_payments(owner_id,invoice_id);

create table if not exists public.ig_receipts (
 id uuid primary key default gen_random_uuid(),
 owner_id uuid not null references auth.users(id) on delete cascade,
 payment_id uuid not null,
 receipt_number text not null,
 issued_at timestamptz not null default now(),
 notes text,
 created_at timestamptz not null default now(),
 unique(owner_id,receipt_number),
 foreign key(owner_id,payment_id) references public.ig_payments(owner_id,id) on delete cascade
);
create index if not exists ig_receipts_owner_issued_idx on public.ig_receipts(owner_id,issued_at desc);

alter table public.ig_payments enable row level security;
alter table public.ig_receipts enable row level security;

drop policy if exists ig_payments_owner on public.ig_payments;
create policy ig_payments_owner on public.ig_payments
 for all to authenticated using(owner_id=(select auth.uid()))
 with check(owner_id=(select auth.uid()));

drop policy if exists ig_receipts_owner on public.ig_receipts;
create policy ig_receipts_owner on public.ig_receipts
 for all to authenticated using(owner_id=(select auth.uid()))
 with check(owner_id=(select auth.uid()));

grant select,insert,update,delete on public.ig_payments,public.ig_receipts to authenticated;
