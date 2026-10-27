# InvoiceGenerator

A mobile-friendly invoice generator built with HTML, CSS, JavaScript and Supabase.

## Features
- Email/password sign-up and sign-in through Supabase Auth.
- Cloud-saved business profile, customers, invoices and invoice line items.
- Per-account data isolation using Row Level Security.
- Automatic invoice numbers using a business prefix and sequential counter. Editing keeps the number; deleted invoice numbers are not reused.
- Currency selection, item quantities and prices, discount, tax, notes and payment terms.
- Invoice search, status filter, customer management, edit, print and save as PDF.

## One-time Supabase setup
1. Open the Supabase project connected in config.js.
2. Go to SQL Editor, paste the full contents of the supabase.sql file, and run it.
3. Ensure Email sign-in is enabled under Authentication > Providers.
4. Open the app and create an account or sign in. If email confirmation is enabled, confirm your email first.

The SQL creates dedicated ig_ tables. It does not modify Garage Operations Pro tables or existing id_ tables. The invoice number counter is incremented inside a database transaction with a row lock.

Only the Supabase publishable browser key belongs in config.js. Never put a service-role or secret key in frontend code. Tax is user-configured; verify local tax requirements before issuing official invoices.
