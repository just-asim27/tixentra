# 🎟️ Tixentra

## 📖 Overview

**Tixentra** is a PostgreSQL database project implementing the **database layer** of a centralized ticketing and anti-scalping system.
The project's focus is making the database itself enforce the rules of the system — data integrity, business logic, and concurrency-safe ticket operations — using constraints, stored procedures, functions, and triggers rather than an application layer.

---

## ✨ Features

- **Schema-Level Constraints**: Regex-validated emails, phone numbers, national IDs, and other field-level rules enforced directly on the tables.
- **Disjoint Subtype Enforcement**: Trigger functions ensure entities like Event (Concert/Sports/Theater) and Transaction (Initial/Resale/Event Payment) stay properly disjoint.
- **Stored Procedures for Business Logic**: Cross-table validations and multi-step workflows — event creation, approvals, bookings, refunds, resale — implemented as procedures.
- **Reusable Query Functions**: Common join queries (browsing events, viewing tickets, checking application status, etc.) wrapped as functions for each actor.
- **Concurrency-Safe Ticket Operations**: Row-level locking (`SELECT ... FOR UPDATE`) on reserving, purchasing resale, and withdrawing tickets to prevent race conditions.
- **Anti-Scalping Controls**: Each buyer is tied to one real identity via national ID, reservations and bookings are capped per event, and resale is only allowed within a per-event profit cap with proceeds split automatically between seller and organization.

---

## ⚙️ How It Works

1. **Setup**: An organization registers and creates an event, then publishes it to accept organizer applications.
2. **Assignment**: Organizers apply to manage the event; the organization approves one and schedules the event.
3. **Sales**: Buyers browse scheduled events and reserve tickets, subject to per-event limits.
4. **Booking**: Buyers complete bookings via payment; refunds can be requested and processed by the organization.
5. **Resale**: If enabled, buyers can list, withdraw, or purchase resold tickets within the event's profit cap.
6. **Completion**: Once the event is completed, the organization pays the organizer and leaves a review; the buyer can also leave a review for the event they attended.

---

## 🚀 How to Run

### Prerequisites
- **PostgreSQL** with **pgAdmin**

### Steps
1. Clone the repository to your local machine.
2. In pgAdmin, right-click **Databases** → **Create** → **Database**, and name it `tixentra`.
3. Right-click the `tixentra` database → **Query Tool**, open `schema/schema.sql`, and run it. Do the same for `schema/data_validation_triggers.sql`.
4. Using the same Query Tool, open and run each module's procedures and functions files, in this order:
   - `organization-module/organization_procedures.sql`, then `organization_functions.sql`
   - `organizer-module/organizer_procedures.sql`, then `organizer_functions.sql`
   - `buyer-module/buyer_ticketing_procedures.sql`, then `buyer_ticketing_functions.sql`
   - `buyer-module/buyer_resale_procedures.sql`, then `buyer_resale_functions.sql`
5. Open `utility/demo.sql` in the Query Tool. It walks through the entire workflow end to end — run it step by step to see the system in action. If you hit an issue partway through, open and run `utility/tables_reset.sql` to reset all tables and start over.

---

## 📂 Repository Structure

```
tixentra/
├── schema/                 [Core tables, constraints, and disjoint-subtype triggers]
├── organization-module/    [Event lifecycle, approvals, payments, refunds]
├── organizer-module/       [Registration and event applications]
├── buyer-module/           [Reservations, bookings, resale]
└── utility/                [Demo data and table reset script]
```

---

## 🔒 Reuse & Contribution

This project is provided publicly **for portfolio and demonstration purposes only**. You may **not copy, modify, redistribute, or use** this code **without explicit permission**.

---

## 👥 Authors

Asim · Husnain · Madifa · Sumaiya
