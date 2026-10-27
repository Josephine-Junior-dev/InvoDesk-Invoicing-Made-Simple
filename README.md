# InvoDesk — Invoicing Made Simple

InvoDesk is a mobile-friendly invoice and receipt generator for freelancers and small businesses worldwide.

## Starter features
- Responsive dashboard with invoiced, paid, outstanding and invoice-count summaries.
- Create invoices with line items, quantities, unit prices, discounts, configurable tax rates and currency selection.
- Search and filter invoices by status.
- Record full or partial payments and automatically create receipts.
- Customer records that can be reused on invoices.
- Print invoices and receipts or choose **Save as PDF** in the browser print dialog.
- Automatic invoice and receipt numbering.

## Run it
Open `index.html` in a browser, or deploy the repository as a static site on Netlify.

## Important current limitations
This is the first frontend prototype. Records are saved in the current browser using localStorage. They do not sync between devices, and clearing browser storage can remove them. There are no user accounts, cloud database, online subscription payments, automated emails or real payment processing yet. Do not use this starter version as the sole storage location for important business records.

Tax is manually configurable and the app does not certify compliance with any country's invoicing or tax laws. Users should confirm local requirements.

## Planned next steps
1. Connect Supabase authentication and a dedicated InvoDesk database schema with Row Level Security.
2. Add business profile settings and a way to manage invoice numbering.
3. Add export/backup and stronger validation.
4. Add subscription billing only after the core product and security have been tested.

## Tech
HTML, CSS and vanilla JavaScript.
