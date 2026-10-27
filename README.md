<div align="center">

# InvoDesk

### Invoicing made simple.

A clean, mobile-friendly invoice and receipt workspace for freelancers, independent professionals, and small businesses.

**Create invoices · Track payments · Issue receipts**

</div>

---

## Overview

InvoDesk is an early-stage web application designed to make everyday billing easier. It brings invoice creation, customer details, payment recording, and printable receipts into one straightforward interface that works on phones and desktop browsers.

The project is being developed incrementally, starting with a usable browser-based prototype and progressing toward secure cloud storage and optional premium features.

## Current features

- **Dashboard overview** — view invoiced totals, payments received, outstanding balances, and invoice counts.
- **Invoice creation** — add customers, invoice and due dates, item descriptions, quantities, unit prices, discounts, and a configurable tax rate.
- **Currency selection** — create invoices in supported currencies, including USD, EUR, GBP, KES, CAD, AUD, INR, ZAR, NGN, UGX, and TZS.
- **Invoice search and filters** — search by invoice or customer and filter by payment status.
- **Customer directory** — save customer contact details and reuse them when preparing invoices.
- **Payment tracking** — record full or partial payments against an invoice.
- **Receipt generation** — create a receipt when a payment is recorded.
- **Print and PDF** — print invoices and receipts or use the browser's print dialog to save them as PDF.
- **Responsive interface** — layouts adapt to mobile screens and larger displays.

## Technology

| Technology | Purpose |
| --- | --- |
| HTML5 | Application structure |
| CSS3 | Responsive layout and visual design |
| Vanilla JavaScript | Invoice calculations, interface interactions, and record handling |
| Browser local storage | Saves prototype data on the current device |

The current version does not require a JavaScript framework or package installation.

## Getting started

### Run locally

1. Download or clone this repository.
2. Open `index.html` in a modern web browser.
3. Create a customer or open **New invoice** to begin.
4. Record a payment from an unpaid invoice to generate a receipt.
5. Use **Print / PDF** to print a document or save it as a PDF.

The application is built as a static frontend and can also be deployed to a static hosting service.

## Current project status

**Status: Early prototype — active development**

The main invoice, customer, payment, and receipt workflows are implemented in the frontend. InvoDesk is not yet a complete hosted business service.

### Important limitations

- Records are stored in the browser on the current device using local storage.
- Records do not automatically sync between browsers or devices.
- Clearing browser storage may permanently remove saved records.
- User accounts, cloud database storage, and cross-device synchronisation are not yet connected.
- Online subscription billing, automated emails, and payment-provider integrations are not implemented.
- Tax rates are entered by the user. InvoDesk does not currently determine or certify tax compliance for any country.

**Please keep independent backups of important business records.** Do not rely on this prototype as the only copy of financial information.

## Roadmap

Planned work, subject to testing and user feedback:

- [ ] Connect secure user authentication.
- [ ] Add a dedicated cloud database with row-level access controls.
- [ ] Add business profile settings, branding, and logo support.
- [ ] Improve data export, backup, and validation.
- [ ] Expand invoice and receipt customisation.
- [ ] Evaluate premium features and subscription billing.
- [ ] Test usability and local invoicing requirements with early users.

## Product principles

- **Clarity:** keep everyday billing tasks straightforward.
- **Accessibility:** make the core workflow comfortable on a phone as well as a computer.
- **Privacy:** protect customer and business records as cloud features are introduced.
- **Transparency:** clearly distinguish available features from planned functionality.

## Contributing and feedback

Feedback, usability suggestions, and reports of incorrect calculations are welcome. When reporting an issue, include the steps to reproduce it and describe what you expected to happen. Do not include real customer details, financial records, passwords, or secret keys in reports.

## Disclaimer

InvoDesk is an independent software project in development. It is not an accounting, tax, or legal service. Users are responsible for checking that invoices, tax settings, and records meet the requirements that apply to their business and location.

---

<div align="center">

**InvoDesk** · Invoicing made simple.

Built with HTML, CSS, and JavaScript.

</div>
