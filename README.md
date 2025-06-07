# Property Management Data Warehouse

**A turnkey, SQL-powered data warehouse for managing and analyzing residential property operations and performance.**

---

## 📖 Project Overview

This project implements a full end-to-end data warehouse for a property management business, built on a classic star schema design. It combines:

- **Operational Database**: Raw transactional tables capturing leases, maintenance requests, inspections, staff assignments, apartments, corporate clients, etc.
- **Analytical Data Warehouse**: A curated star schema (fact & dimension tables) optimized for fast, slice-and-dice analytics and historical trend analysis.

## 🛠️ Key Features

1. **Star Schema Design**  
   - Central **FactLease** and **FactMaintenance** tables  
   - Dimension tables for **Date**, **Property**, **Tenant**, **Staff**, **Unit**, **Client**  

2. **ETL & Incremental Loads**  
   - Python-driven ETL scripts (or pure SQL procedures) to extract from operational sources, transform & clean, then load into the warehouse.  
   - **Type 2 Slowly Changing Dimensions** on Property ↔ Manager assignments to track historical changes.

3. **Data Quality & Validation**  
   - Referential-integrity checks before load  
   - Row-count and checksum validations post-load  

4. **Analytics-Ready**  
   - Pre-built views for occupancy rates, maintenance turnaround times, revenue trends  
   - Example SQL queries/dashboards for portfolio performance and staffing efficiency  
