# DPC: Drug Price Comparison & Healthcare Assistant Platform

> **An Elderly-Friendly, Trivago-Model Drug Price Aggregator & Healthcare Platform for Indian Medicines**  
> Powered by **Django REST Backend**, **MongoDB 9.0 Database**, and a responsive **HTML5/CSS3/Vanilla JS Single-Page Application**.

---

## 📑 Table of Contents
1. [Project Overview](#project-overview)
2. [Dataset & Data Cleaning Pipeline](#dataset--data-cleaning-pipeline)
3. [System Architecture](#system-architecture)
4. [MongoDB Database Schema](#mongodb-database-schema)
5. [Partner Pharmacies & Trivago Aggregator Model](#partner-pharmacies--trivago-aggregator-model)
6. [Django REST API Reference](#django-rest-api-reference)
7. [AI & Elderly Accessibility Features](#ai--elderly-accessibility-features)
8. [Quick Start Guide](#quick-start-guide)
9. [Project Directory Structure](#project-directory-structure)

---

## 1. Project Overview

**DPC (Drug Price Comparison)** is a healthcare web platform that enables patients—especially senior citizens—to search for medicines and compare prices, availability, discounts, and delivery speeds across top licensed Indian pharmacies:
* **Jan Aushadhi Kendra (Govt Initiative)** — 50% to 85% cheaper generic substitutes
* **Apollo Pharmacy** — 2-Hour Express Delivery
* **Tata 1mg** — Same-Day Delivery
* **PharmEasy** — Super Saver Deals
* **Netmeds** — Reliable Pan-India Delivery
* **MedPlus** — Local Pharmacy Network

Like **Trivago**, DPC operates on an aggregator clickout model: users compare prices on DPC and click "View Deal / Buy" to be redirected to the licensed pharmacy partner's official storefront to complete the transaction, with outbound clicks tracked for affiliate analytics.

---

## 2. Dataset & Data Cleaning Pipeline

The raw dataset (`A_Z_medicines_dataset_of_India.csv`) in `archive.zip` contains **253,973 medicines** available in India.

### Data Cleaning Transformations Executed:
1. **Name & Manufacturer Normalization**:
   - Cleaned extra whitespace, trailing punctuation, and inconsistent capitalization across brand names and 7,648 manufacturers.
2. **Composition & Salt Parsing**:
   - Split `short_composition1` and `short_composition2` into structured objects:
     - Example: `"Amoxycillin (500mg)"` $\rightarrow$ `{"salt": "Amoxycillin", "strength": "500mg"}`
     - Example: `"Clavulanic Acid (125mg)"` $\rightarrow$ `{"salt": "Clavulanic Acid", "strength": "125mg"}`
3. **Normalized Generic Matching Key (`salt_key`)**:
   - Extracted active therapeutic salts, sorted alphabetically, and concatenated (e.g. `amoxycillin+clavulanic acid`).
   - Grouped into **2,874 unique chemical equivalent groups**.
4. **Generic Equivalent & Yearly Savings Engine**:
   - For every branded medicine, DPC identifies the cheapest verified chemical substitute sharing the exact `salt_key`.
   - Computes estimated yearly savings for chronic patients:
     $$\text{Yearly Savings} = (\text{Branded MRP} - \text{Generic MRP}) \times 12 \text{ packs/year}$$
5. **Schedule H / Prescription Classifier**:
   - Classifies Schedule H/H1/X drugs (antibiotics, antihypertensives, antidiabetics, sedatives) as `requires_prescription: true` vs OTC remedies (`requires_prescription: false`).
6. **Senior-Friendly Plain Language Explanations**:
   - Generates simple, non-technical 8th-grade reading level explanations of what the drug treats, daily administration tips, and elderly precautions (e.g. rising slowly to avoid dizziness, taking with water after food, glucose monitoring).
7. **MongoDB Bulk Ingestion**:
   - Ingested all **253,973 documents** into MongoDB collection `dpc_db.medicines` with compound text and B-tree indexes for **sub-50ms query latency**.

---

## 3. System Architecture

```text
┌────────────────────────────────────────────────────────┐
│   Frontend Single-Page Application (SPA)               │
│   - Senior Support Toolbar (A/A+/A++, High Contrast)   │
│   - Live Voice Search & Sub-100ms Autocomplete         │
│   - Real-time Price Comparison Table                   │
│   - AI Doctor's Slip / Prescription Scanner            │
│   - Senior Drug Explainer & Web Speech Read-Aloud      │
└───────────────────────────┬────────────────────────────┘
                            │ REST API (JSON / HTTP)
┌───────────────────────────▼────────────────────────────┐
│   Django 6.1 Backend API Server (Port 8000)            │
│   ├── catalog (Search, Autocomplete, Generics, Detail) │
│   ├── pharmacies (Partner Directory, Clickout Logs)    │
│   ├── alerts (Price Drop WhatsApp/SMS Notifications)   │
│   └── ai_assistant (Prescription OCR, Drug Explainer)  │
└───────────────────────────┬────────────────────────────┘
                            │ PyMongo Pool (Port 27017)
┌───────────────────────────▼────────────────────────────┐
│   MongoDB 9.0 Database (`dpc_db`)                      │
│   ├── medicines (253,973 indexed Indian drug records)  │
│   ├── pharmacies (6 certified partner pharmacies)      │
│   ├── pharmacy_listings (live pricing & stock feeds)   │
│   ├── price_alerts (active user price-drop triggers)   │
│   └── click_logs (Trivago affiliate outbound clicks)   │
└────────────────────────────────────────────────────────┘
```

---

## 4. MongoDB Database Schema

* **Database Name**: `dpc_db`
* **Port**: `27017`

### `medicines` Collection Sample:
```json
{
  "id": 1,
  "name": "Augmentin 625 Duo Tablet",
  "mrp": 223.42,
  "is_discontinued": false,
  "manufacturer": "GlaxoSmithKline Pharmaceuticals Ltd",
  "type": "allopathy",
  "pack_size": "strip of 10 tablets",
  "compositions": [
    { "salt": "Amoxycillin", "strength": "500mg" },
    { "salt": "Clavulanic Acid", "strength": "125mg" }
  ],
  "salts": ["Amoxycillin", "Clavulanic Acid"],
  "salt_key": "amoxycillin+clavulanic acid",
  "requires_prescription": true,
  "simple_explanation": "Augmentin 625 contains penicillin-class antibiotic medication. A trusted medicine that fights bacterial infections in chest, throat, ears, or teeth. Always finish the entire course.",
  "cautions": "Complete the full prescribed course even if you feel better earlier. Do not share with others.",
  "generic_equivalent": {
    "name": "Apcil Tablet / Jan Aushadhi Amoxyclav",
    "price": 6.98,
    "manufacturer": "Generic Equivalent",
    "savings_per_year": 2597.28
  }
}
```

---

## 5. Partner Pharmacies & Trivago Aggregator Model

| Pharmacy Partner | Base Delivery Speed | Avg Discount | DPC Badge | Website |
| :--- | :--- | :--- | :--- | :--- |
| **Jan Aushadhi Kendra** | Store Pickup / 24h | 50% – 85% OFF | Govt Generic Best Price | `janaushadhi.gov.in` |
| **Apollo Pharmacy** | 2 Hours (Express) | 10% – 15% OFF | Express Delivery | `apollopharmacy.in` |
| **Tata 1mg** | Same Day (by 6 PM) | 15% – 22% OFF | Tata Trusted Partner | `1mg.com` |
| **MedPlus** | Same Day (4 Hours) | 12% – 19% OFF | Local Pharmacy Network | `medplusmart.com` |
| **PharmEasy** | 1 – 2 Days | 14% – 20% OFF | Super Saver Deals | `pharmeasy.in` |
| **Netmeds** | 1 – 2 Days | 11% – 18% OFF | Pan-India Certified | `netmeds.com` |

---

## 6. Django REST API Reference

All endpoints return standard JSON responses and support CORS.

### 1. Health & Catalog Status
* **Endpoint**: `GET /api/health/`
* **Response**:
```json
{
  "status": "healthy",
  "service": "Drug Price Comparison (DPC) Platform API",
  "version": "1.0.0",
  "database": "MongoDB 9.0",
  "statistics": {
    "total_medicines": 253973,
    "partner_pharmacies": 6
  }
}
```

### 2. Live Typeahead Autocomplete
* **Endpoint**: `GET /api/catalog/autocomplete/?q=Augmentin`
* **Response**: Returns matching medicine names, active salts, and MRPs in $<100\text{ms}$.

### 3. Full Medicine Search & Comparison
* **Endpoint**: `GET /api/catalog/search/?q=Telma&sort=price_asc&speed=all&in_stock=1`
* **Parameters**:
  - `q`: Search query (brand name, active salt, or manufacturer)
  - `sort`: `price_asc` | `price_desc` | `rating`
  - `speed`: `all` | `instant` | `sameday` | `standard`
  - `in_stock`: `1` (only in-stock items)

### 4. Single Medicine Detail & Live Partner Listings
* **Endpoint**: `GET /api/catalog/medicines/<id>/`
* **Response**: Full specifications, generic alternative, and 6-pharmacy comparison table.

### 5. Generic Substitutes Finder
* **Endpoint**: `GET /api/catalog/medicines/<id>/generics/`
* **Response**: List of equivalent generic medicines sharing the same salt composition with savings calculations.

### 6. Partner Pharmacies Directory
* **Endpoint**: `GET /api/pharmacies/`
* **Response**: List of all partner pharmacies with ratings, delivery options, and badges.

### 7. Affiliate Outbound Clickout Tracker
* **Endpoint**: `POST /api/pharmacies/click/`
* **Body**: `{"med_id": 1, "pharmacy_id": 2}`
* **Response**: Logs click event to MongoDB `click_logs` and returns `{"status": "success", "click_id": "..."}`.

### 8. Price Drop Alert Registration
* **Endpoint**: `POST /api/alerts/create/`
* **Body**: `{"med_id": 1, "med_name": "Augmentin 625", "target_price": 180.0, "channel": "WhatsApp"}`

### 9. AI Prescription & Doctor Slip Scanner
* **Endpoint**: `POST /api/ai/scan-prescription/`
* **Body**: `{"prescription_text": "Augmentin 625 Duo Tablet 1 tab BD\nTelma 40 Tablet 1 tab OD"}`
* **Response**: Detects drugs from doctor slip, matches against MongoDB, and calculates total savings.

### 10. Senior Drug Explainer
* **Endpoint**: `GET /api/ai/explain/<id>/`
* **Response**: Non-technical plain explanation, elderly precautions, and speech-ready advice.

---

## 7. AI & Elderly Accessibility Features

1. **Senior Support Mode Toolbar**:
   - **Text Scaling**: One-click toggles for Standard (`A`), Large (`A+`), and Extra Large (`A++`).
   - **High Contrast Mode**: WCAG 2.1 AA compliant black background with bold yellow text and high-visibility borders.
2. **Voice Search**:
   - Elderly users can tap the microphone icon and speak the medicine name naturally using Web Speech Recognition.
3. **Web Speech Audio Read-Aloud**:
   - Reads medicine explanations aloud at a gentle 0.85x speed with natural pauses for seniors with low vision.
4. **"Did You Mean" Typo Tolerance**:
   - Suggests correct medicine names when misspelled (e.g. `dlo` $\rightarrow$ `Dolo`, `paracit` $\rightarrow$ `Paracetamol`).
5. **Doctor's Slip Printable Summary**:
   - Generates a clear comparison slip showing the prescribed brand vs recommended Jan Aushadhi generic that patients can take to their physician to request a generic prescription switch.

---

## 8. Quick Start Guide

### Step 1: Start MongoDB
Ensure MongoDB is running locally on port 27017 (default).

### Step 2: Start Django Backend
Double-click `run_server.bat` OR run via PowerShell:
```powershell
.\run_server.ps1
```
Or manually:
```powershell
C:\Python314\python.exe backend\manage.py runserver 127.0.0.1:8000
```

### Step 3: Open the Web Application
Open your web browser and navigate to:
```
http://127.0.0.1:8000/
```
You can also open `frontend/index.html` directly in VS Code with **Live Server** (`http://127.0.0.1:5500/frontend/index.html`); the app connects automatically to `http://127.0.0.1:8000/api`.

---

## 9. Project Directory Structure

```text
drug_comparison/
├── backend/
│   ├── manage.py
│   ├── db.sqlite3
│   ├── test_api_endpoints.py    # Automated test suite for all 10 REST endpoints
│   ├── dpc_backend/
│   │   ├── settings.py          # Django config with CORS & MongoDB settings
│   │   ├── urls.py              # Central routing & frontend static serving
│   │   ├── mongo.py             # PyMongo database connection pool & helpers
│   │   ├── wsgi.py
│   │   └── asgi.py
│   ├── catalog/                 # Search, autocomplete, details, generics
│   ├── pharmacies/              # Partner directory, listings, click tracker
│   ├── alerts/                  # Price drop notifications
│   ├── ai_assistant/            # Prescription OCR scanner & senior explainer
│   └── scripts/
│       └── clean_and_load_mongo.py # 253,973 record cleaner & MongoDB bulk loader
├── frontend/
│   ├── index.html               # Senior-friendly SPA interface
│   ├── styles.css               # WCAG 2.1 AA accessible styles & themes
│   └── app.js                   # Client module calling Django REST APIs
├── data/
│   └── cleaned/
│       ├── cleaned_medicines_sample_500.json
│       └── dataset_cleaning_report.json
├── docs/                        # Extracted project documentation & UML diagrams
│   ├── SRS.pdf                  # Complete Software Requirements Specification
│   ├── Use Case Diagram.pdf
│   ├── Activity Diagram.pdf
│   ├── Class Diagram.pdf
│   ├── DFD Level - 0.pdf
│   ├── DFD Level - 1.pdf
│   ├── Component Diagram.pdf
│   └── Deployment Diagram.pdf
├── run_server.bat               # Windows one-click server starter
├── run_server.ps1               # PowerShell server starter
└── README.md                    # Project documentation
```
