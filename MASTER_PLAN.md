# Lumluay POS — Master Development Plan

> Production-ready POS system (Loyverse clone) built with Flutter + Serverpod + SQLite/PostgreSQL, targeting all business types with offline-first architecture and SaaS cloud sync.

---

## Environment

| Item | Value |
|------|-------|
| **Flutter** | Latest stable (upgrade from 3.29.2) |
| **Dart** | Latest stable (upgrade from 3.7.2) |
| **macOS** | ARM64 (Apple Silicon) |
| **VPS** | 8GB RAM, 3-core, Docker |
| **Project Path** | `/Users/aphilack/Documents/lumluay-pos` |

---

## Tech Stack

| Layer | Technology |
|-------|-----------|
| **UI Framework** | Flutter + `shadcn_flutter` (84+ components) |
| **State Mgmt** | `riverpod` (code gen) |
| **Routing** | `go_router` |
| **Local DB** | SQLite via `drift` (type-safe ORM) |
| **Backend** | Serverpod (Dart) |
| **Cloud DB** | PostgreSQL (via Serverpod ORM) |
| **Cache** | Redis (via Serverpod) |
| **i18n** | `slang` (type-safe, supports Lao/Thai/EN) |
| **Printing** | `esc_pos_utils` + `esc_pos_bluetooth` |
| **Scanning** | `mobile_scanner` + BLE |
| **PDF** | `pdf` + `printing` |
| **Deploy** | Docker Compose on VPS |

---

## Phase 0 — Project Foundation
> Setup project structure, dependencies, theme, and core architecture

- [x] **0.1** Upgrade Flutter to latest stable (`flutter upgrade`)
- [x] **0.2** Create Flutter project `lumluay_app` with all platforms enabled
- [x] **0.3** Setup Serverpod project (`lumluay_server` + `lumluay_client` + `lumluay_flutter`)
- [x] **0.4** Install & configure core dependencies:
  - `shadcn_flutter`, `drift`, `riverpod`, `go_router`, `slang`
  - `connectivity_plus`, `uuid`, `json_annotation`, `freezed`
- [x] **0.5** Design system setup:
  - shadcn_flutter theme (light + dark mode)
  - Color palette, typography, spacing constants
  - App-wide layout scaffolding (sidebar nav for desktop, bottom nav for mobile)
  - Responsive breakpoints (mobile/tablet/desktop)
- [x] **0.6** i18n setup — Lao (ລາວ), Thai (ไทย), English with `slang`
- [x] **0.7** Drift local database schema v1 (all core tables with migrations)
- [x] **0.8** Core architecture scaffolding:
  - Repository pattern (local + remote data sources)
  - Sync engine skeleton (sync queue table, background isolate)
  - Error handling framework (Result type, AppException)
  - Logging service
  - Audit log service (track all user actions)
- [x] **0.9** Auth module — PIN login per device (offline), account login (online)
- [x] **0.10** App shell — responsive layout with navigation (sidebar/bottom tabs)

---

## Phase 1 — Items & Categories (Product Catalog)
> Full product management: CRUD, variants, modifiers, barcodes, images, CSV import

- [x] **1.1** DB tables: `items`, `categories`, `variants`, `variant_groups`, `modifiers`, `modifier_groups`, `item_images`
- [x] **1.2** Categories screen — CRUD, drag-to-reorder, color/icon picker
- [x] **1.3** Items list screen — grid/list view toggle, search, filter by category, sort
- [x] **1.4** Item create/edit screen:
  - Name, SKU, barcode, price, cost, tax group
  - Category assignment
  - Image upload (camera + gallery)
  - Track stock toggle
  - Sold by weight toggle
- [x] **1.5** Variants system — variant groups (Size, Color) + variant options (S/M/L)
  - Auto-generate variant combinations
  - Per-variant price, SKU, barcode, stock
- [x] **1.6** Modifiers system — modifier groups (Toppings, Extras)
  - Per-modifier price adjustment
  - Min/max selection rules
- [x] **1.7** Barcode generation + label printing (item labels with price/barcode)
- [x] **1.8** CSV import/export for bulk item management
- [x] **1.9** Item search — full-text search + barcode scan lookup

---

## Phase 2 — Sales Screen (Core POS)
> The main point-of-sale screen: product grid, cart, discounts, notes

- [x] **2.1** Sales screen layout:
  - Left: product grid/list (categories tabs on top, items below)
  - Right: cart/ticket panel
  - Responsive: full-screen cart on mobile, side-by-side on tablet/desktop
- [x] **2.2** Product selection:
  - Tap to add item to cart
  - Variant picker dialog (if item has variants)
  - Modifier picker dialog (if item has modifiers)
  - Quick quantity adjustment (+/- buttons, direct input)
- [x] **2.3** Cart functionality:
  - Edit quantity, remove items
  - Per-item discount (% or fixed amount)
  - Per-item notes/comments
  - Whole-ticket discount
- [x] **2.4** Barcode scanning:
  - Camera scanner (`mobile_scanner`)
  - Bluetooth scanner input (auto-detect HID)
  - Weight barcode parsing (EAN-13 with embedded weight)
- [x] **2.5** Tax calculation engine:
  - Multiple tax rates per item
  - Tax-inclusive vs tax-exclusive pricing
  - Configurable per-country tax rules
- [x] **2.6** Multi-currency support:
  - Primary currency (₭ LAK) + secondary currencies (฿ THB, $ USD)
  - Configurable exchange rates
  - Display totals in selected currency
  - Payment accepted in any enabled currency
- [x] **2.7** Customer assignment to ticket
- [x] **2.8** Hold ticket (save as open ticket, continue later)
- [x] **2.9** Dining options selector: Dine-in / Take-out / Delivery

---

## Phase 3 — Payment & Receipts
> Process payments (cash, QR, split), print thermal receipts, receipt history

- [x] **3.1** Payment screen:
  - Display total, tax breakdown, discount summary
  - Cash payment — enter amount tendered, auto-calculate change
  - QR payment — display QR / mark as paid
  - Split payment — multiple payment methods on one ticket (e.g., half cash + half QR)
  - Multi-currency payment — pay in ₭, ฿, or mixed
- [x] **3.2** Payment completion flow:
  - Generate receipt number (sequential per store per day)
  - Save receipt + receipt_items + payments to DB
  - Update inventory (decrement stock)
  - Award loyalty points (if customer assigned)
  - Open cash drawer (ESC/POS kick pulse command, if enabled)
  - Write audit log entry
- [x] **3.3** Thermal receipt printing:
  - ESC/POS protocol (Bluetooth, USB, WiFi printers)
  - Receipt template: store name, items, taxes, totals, payment method, date/time, barcode
  - Auto-print on payment completion (configurable)
  - Multi-printer support (different printers per store)
- [x] **3.4** PDF receipt generation — for email/share
- [x] **3.5** Receipt history screen:
  - List all receipts, search by date/number/customer
  - Receipt detail view
  - Reprint receipt
- [x] **3.6** Refund flow:
  - Full refund or partial (select items to refund)
  - Refund reason (required)
  - Stock restoration
  - Refund receipt printing
  - Audit log: who refunded, when, why

---

## Phase 4 — Inventory Management
> Stock tracking, low stock alerts, adjustments, counts, purchase orders, transfers

- [x] **4.1** DB tables: `inventory_levels`, `stock_adjustments`, `inventory_counts`, `inventory_count_items`, `purchase_orders`, `purchase_order_items`, `transfer_orders`, `transfer_order_items`, `suppliers`
- [x] **4.2** Inventory dashboard — stock levels overview, low stock alerts
- [x] **4.3** Stock adjustment screen — reason codes (damaged, lost, correction), quantity +/-
- [x] **4.4** Inventory count (stock take):
  - Create count session
  - Scan or manually enter counted quantities
  - Compare expected vs counted
  - Apply adjustments
- [x] **4.5** Low stock notifications — configurable threshold per item, in-app alert
- [x] **4.6** Purchase orders:
  - Create PO → select supplier, add items + quantities + cost
  - PO statuses: draft → ordered → partially received → received
  - Receive stock — update inventory on receive
  - Multi-currency cost tracking (cost in supplier's currency)
- [x] **4.7** Transfer orders (multi-store):
  - Transfer stock between stores
  - Statuses: pending → in-transit → received
- [x] **4.8** Inventory history — log all stock movements with timestamp + reason
- [x] **4.9** Inventory valuation report — total stock value (cost-based)
- [x] **4.10** Production / composite items:
  - Recipe: finished item = list of ingredients with quantities
  - Produce: decrement ingredients, increment finished item

---

## Phase 5 — Customers & Loyalty
> Customer database, loyalty points, purchase history

- [x] **5.1** DB tables: `customers`, `loyalty_transactions`, `loyalty_settings`
- [x] **5.2** Customer list screen — search, filter, sort
- [x] **5.3** Customer create/edit — name, phone, email, address, notes, birthday
- [x] **5.4** Customer detail — purchase history, total spend, loyalty balance
- [x] **5.5** Loyalty program:
  - Points per currency spent (configurable ratio)
  - Redeem points as discount
  - Points history
- [x] **5.6** Assign customer to sale (quick search popup on sales screen)

---

## Phase 6 — Employee Management
> Staff accounts, access rights, time clock, sales tracking per employee

- [x] **6.1** DB tables: `employees`, `employee_roles`, `time_entries`, `role_permissions`
- [x] **6.2** Roles & permissions:
  - Admin: full access
  - Manager: reports, inventory, items, employees (no settings)
  - Cashier: sales only
  - Custom roles with granular permissions
- [x] **6.3** Employee list screen — CRUD
- [x] **6.4** PIN-based employee switching (quick switch on POS screen)
- [x] **6.5** Time clock — clock in/out, view timecard, calculate hours
- [x] **6.6** Sales by employee report

---

## Phase 7 — Cash Management & Shifts
> Cash drawer tracking, shift open/close, cash in/out

- [x] **7.1** DB tables: `shifts`, `cash_movements`
- [x] **7.2** Open shift — set starting cash amount
- [x] **7.3** Cash in/out — record reason + amount during shift
- [x] **7.4** Close shift — enter counted cash, system calculates expected vs actual, show discrepancy
- [x] **7.5** Shift summary report — sales breakdown by payment method, refunds, cash movements
- [x] **7.6** Shift history — view past shifts with full detail

---

## Phase 8 — Reports & Analytics
> Sales trends, popular items, tax report, P&L, export

- [x] **8.1** Reports dashboard — quick stats (today's sales, items sold, avg ticket)
- [x] **8.2** Sales summary — by day/week/month/custom range, with charts
- [x] **8.3** Sales by item — top sellers, revenue per item
- [x] **8.4** Sales by category
- [x] **8.5** Sales by employee
- [x] **8.6** Sales by payment method
- [x] **8.7** Sales by hour (heatmap for peak hours)
- [x] **8.8** Tax report — tax collected by rate, by period
- [x] **8.9** Discount report — total discounts given
- [x] **8.10** Customer report — top customers, visit frequency
- [x] **8.11** Inventory reports — stock levels, valuation, low stock
- [x] **8.12** Expense tracking — record business expenses (rent, utilities, supplies, etc.)
- [x] **8.13** Profit & Loss report — revenue - COGS - expenses = net profit, by period
- [x] **8.14** Export all reports to CSV / PDF

---

## Phase 9 — Multi-Store
> Multiple store locations under one account

- [x] **9.1** DB tables: `stores`, `store_settings`
- [x] **9.2** Store CRUD — name, address, phone, tax settings, receipt header
- [x] **9.3** Store selector — switch between stores
- [x] **9.4** Per-store inventory (stock tracked per location)
- [x] **9.5** Reports — filter by store or view combined
- [x] **9.6** Per-store receipt templates & printer configs
- [x] **9.7** Per-store currency settings (primary + accepted currencies)

---

## Phase 10 — Settings & Configuration
> App settings, tax, currency, receipt template, printers, language

- [x] **10.1** General settings — store name, address, phone, logo, currency
- [x] **10.2** Tax settings — CRUD tax rates, assign to items/categories, inclusive/exclusive
- [x] **10.3** Receipt template settings — header text, footer text, show/hide fields
- [x] **10.4** Printer management — add/test/remove printers (Bluetooth/WiFi/USB)
- [x] **10.5** Cash drawer settings — enable/disable auto-open
- [x] **10.6** Payment method settings — enable/disable cash, QR, custom methods
- [x] **10.7** Currency settings — primary currency, exchange rates, accepted currencies
- [x] **10.8** Language selector (Lao/Thai/English)
- [x] **10.9** Theme selector (Light/Dark)
- [x] **10.10** Audit log viewer — searchable log of all system actions
- [x] **10.11** Backup & restore — export/import local database
- [x] **10.12** About screen — app version, licenses

---

## Phase 11 — Serverpod Backend & Cloud Sync
> Backend API, cloud database, offline sync engine, SaaS subscription

- [x] **11.1** Serverpod data models — mirror all local tables
- [x] **11.2** API endpoints:
  - Auth: register, login, token refresh
  - Items: CRUD + bulk sync
  - Categories, Modifiers: CRUD + sync
  - Receipts: upload + query
  - Inventory: sync stock levels
  - Customers: CRUD + sync
  - Employees: CRUD + sync
  - Reports: server-side aggregation queries
  - Stores: CRUD
  - Expenses: CRUD + sync
  - Audit logs: upload + query
- [x] **11.3** Sync engine (client-side):
  - Sync queue table in SQLite (action, table, row_id, payload, status, retry_count)
  - Background isolate — process queue when online
  - Pull: fetch server changes since last sync timestamp
  - Push: upload local changes from queue
  - Conflict resolution: server timestamp wins, with merge for non-conflicting fields
  - Delta sync (only changed records)
- [x] **11.4** Sync engine (server-side):
  - Track `updated_at` on all tables
  - Provide `/sync/pull?since=<timestamp>` endpoint
  - Provide `/sync/push` endpoint with batch operations
  - Conflict detection + resolution
- [x] **11.5** SaaS subscription management:
  - Subscription model: free tier (1 store, basic) / paid (multi-store, advanced)
  - Admin manually activates subscriptions (no payment gateway)
  - Expiry check on app launch
- [x] **11.6** Admin panel (web):
  - View all accounts
  - Activate/deactivate subscriptions
  - Set expiry dates
  - View usage stats

---

## Phase 12 — Restaurant Features (Add-on)
> Open tickets, table management, KDS, kitchen printer, dining options

- [x] **12.1** Open tickets system:
  - Multiple open tickets simultaneously
  - Assign ticket to table
  - Merge tickets
  - Split ticket (move items between tickets)
- [x] **12.2** Table management:
  - Floor plan editor (drag & drop tables)
  - Table status: available / occupied / reserved
  - Table → ticket assignment
- [x] **12.3** Kitchen Display System (KDS):
  - Separate Flutter app/screen
  - Real-time order display (via WebSocket or LAN)
  - Multiple KDS stations (kitchen, bar, dessert)
  - Item routing by category → station
  - Color-coded by wait time (green → yellow → red)
  - Mark items/orders as complete
  - Sound alert for new orders
  - Recall completed orders
  - Dark mode
- [x] **12.4** Kitchen printer:
  - Route items to specific printers by category
  - Kitchen ticket format (large font, modifiers, comments)
- [x] **12.5** Dining options — Dine-in / Take-out / Delivery with per-option settings

---

## Phase 13 — Additional Features
> Customer display, web dashboard, API, label printing

- [x] **13.1** Customer Display System (CDS):
  - Separate screen/device showing current ticket to customer
  - Display items being added, total, payment status
- [x] **13.2** Web Dashboard:
  - Real-time sales analytics (accessible from any browser)
  - Inventory overview
  - Employee management
- [x] **13.3** Public REST API + Webhooks:
  - API key authentication
  - Webhooks: ORDER_CREATED, ITEM_UPDATED, INVENTORY_CHANGED
  - Rate limiting
- [x] **13.4** Label printing:
  - Price labels with barcode
  - Shelf labels
  - Custom label templates

---

## Phase 14 — Production Hardening
> Testing, security, performance, deployment

- [x] **14.1** Unit tests — all business logic (tax calc, discount, stock, loyalty, currency)
- [x] **14.2** Widget tests — critical screens (sales, payment, items)
- [x] **14.3** Integration tests — full sale flow, sync flow
- [x] **14.4** Security:
  - PIN encryption (bcrypt)
  - API token rotation
  - Input validation on all endpoints
  - SQL injection prevention (Drift parameterized queries)
  - Secure storage for sensitive data (`flutter_secure_storage`)
- [x] **14.5** Performance:
  - Lazy loading for large item lists
  - Database indexing (frequently queried columns)
  - Image caching + compression
  - Isolate-based heavy computation (reports, sync)
- [x] **14.6** Error tracking — Sentry or similar crash reporting
- [x] **14.7** VPS deployment:
  - Docker Compose: Serverpod + PostgreSQL + Redis + Nginx
  - SSL via Let’s Encrypt
  - Automated backups (PostgreSQL pg_dump cron)
  - Monitoring (uptime + resource usage)
- [x] **14.8** App builds:
  - Android APK/AAB (signed release)
  - iOS IPA (requires Apple Developer account)
  - macOS / Windows / Linux desktop builds
  - Web build (for dashboard)
- [x] **14.9** CI/CD pipeline (optional) — GitHub Actions for automated builds

---

## Database Schema Overview

### Core Tables (Local SQLite + Cloud PostgreSQL)

```
stores                    - id, name, address, phone, currency, timezone, logo,
                           secondary_currencies (JSON), exchange_rates (JSON)
categories                - id, store_id, name, color, icon, sort_order
items                     - id, store_id, category_id, name, sku, barcode, price, cost,
                           tax_group_id, track_stock, sold_by_weight, image_path, active
variant_groups            - id, item_id, name (e.g., "Size")
variants                  - id, variant_group_id, item_id, name, sku, barcode, price, cost
modifier_groups           - id, store_id, name, min_select, max_select
modifiers                 - id, modifier_group_id, name, price_adjustment
item_modifier_groups      - item_id, modifier_group_id (many-to-many)

customers                 - id, store_id, name, phone, email, address, notes,
                           loyalty_points, total_spent, visit_count, birthday
loyalty_settings          - id, store_id, points_per_currency, currency_per_point

employees                 - id, store_id, name, pin_hash, role_id, active
employee_roles            - id, store_id, name, permissions (JSON)
time_entries              - id, employee_id, clock_in, clock_out

receipts                  - id, store_id, receipt_number, employee_id, customer_id,
                           subtotal, discount_total, tax_total, total,
                           currency, exchange_rate, dining_option, status, created_at
receipt_items             - id, receipt_id, item_id, variant_id, name, quantity,
                           unit_price, discount, tax, total, modifiers (JSON), notes
payments                  - id, receipt_id, method, amount, currency, reference

shifts                    - id, store_id, employee_id, opened_at, closed_at,
                           opening_cash, closing_cash, expected_cash
cash_movements            - id, shift_id, type (in/out), amount, reason, created_at

inventory_levels          - id, item_id, variant_id, store_id, quantity, low_stock_threshold
stock_adjustments         - id, store_id, item_id, variant_id, quantity_change, reason,
                           employee_id, created_at
inventory_counts          - id, store_id, status, created_at, completed_at
inventory_count_items     - id, count_id, item_id, variant_id, expected_qty, counted_qty

purchase_orders           - id, store_id, supplier_id, status, total, currency, created_at
purchase_order_items      - id, po_id, item_id, variant_id, quantity, cost
suppliers                 - id, store_id, name, phone, email, address

transfer_orders           - id, from_store_id, to_store_id, status, created_at
transfer_order_items      - id, transfer_id, item_id, variant_id, quantity

tax_rates                 - id, store_id, name, rate, is_inclusive, is_default, country
item_tax_rates            - item_id, tax_rate_id

expenses                  - id, store_id, category, description, amount, currency,
                           date, employee_id, receipt_image_path, created_at
expense_categories        - id, store_id, name, icon

audit_logs                - id, store_id, employee_id, action, entity_type, entity_id,
                           old_values (JSON), new_values (JSON), ip_address, created_at

settings                  - id, store_id, key, value (JSON)

sync_queue                - id, table_name, row_id, action (create/update/delete),
                           payload (JSON), status, retry_count, created_at
sync_log                  - id, last_sync_at, direction (push/pull), records_synced
```

### Cloud-Only Tables (PostgreSQL)

```
accounts                  - id, email, password_hash, name, created_at
subscriptions             - id, account_id, plan, status, activated_at, expires_at,
                           activated_by_admin
account_stores            - account_id, store_id
api_keys                  - id, account_id, key_hash, name, permissions, active
webhooks                  - id, account_id, url, events (JSON), active
```

---

## Implementation Order Summary

| Order | Phase | Estimated Time | Priority | Status |
|-------|-------|---------------|----------|--------|
| 1 | Phase 0: Foundation | 2 weeks | CRITICAL | ✅ DONE |
| 2 | Phase 1: Items & Categories | 2 weeks | CRITICAL | ✅ DONE |
| 3 | Phase 2: Sales Screen | 2 weeks | CRITICAL | ✅ DONE |
| 4 | Phase 3: Payment & Receipts | 2 weeks | CRITICAL | ✅ DONE |
| 5 | Phase 7: Cash Mgmt & Shifts | 1 week | CRITICAL | ✅ DONE |
| 6 | Phase 4: Inventory | 2 weeks | HIGH | ✅ DONE |
| 7 | Phase 5: Customers & Loyalty | 1 week | HIGH | ✅ DONE |
| 8 | Phase 6: Employees | 1 week | HIGH | ✅ DONE |
| 9 | Phase 8: Reports & P&L | 2 weeks | HIGH | ✅ DONE |
| 10 | Phase 9: Multi-Store | 1 week | HIGH | ✅ DONE |
| 11 | Phase 10: Settings | 1 week | HIGH | ✅ DONE |
| 12 | Phase 11: Backend & Sync | 3 weeks | HIGH | ✅ DONE |
| 13 | Phase 12: Restaurant | 2 weeks | MEDIUM | ✅ DONE |
| 14 | Phase 13: Additional | 2 weeks | MEDIUM | ✅ DONE |
| 15 | Phase 14: Hardening | 2 weeks | CRITICAL | ✅ DONE |
| **Total** | | **~26 weeks (6.5 months)** | | **ALL COMPLETE** |

---

## Loyverse Feature Coverage (46/46 = 100%)

All Loyverse features are covered. Additionally, we add: **Full offline-first**, **LAN sync**, **Self-hosted VPS**, **Multi-language (Lao)**, **Desktop native app**, **Split payment**, **Floor plan editor**, **Audit log**, **Expense tracking + P&L**, **Multi-currency (₭/฿/$)**.