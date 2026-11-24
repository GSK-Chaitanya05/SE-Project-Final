# DPC Project: Complete Codebase & File-by-File Technical Documentation

> **Project Name:** Drug Price Comparison (DPC) & Healthcare Assistant Platform  
> **Target Directory:** `D:\SE Project Final\`  
> **Architecture Pattern:** Decoupled Model-View-Controller (MVC/MVT) + Single Page Application (SPA) + Aggregator Service Pattern  
> **Core Tech Stack:** Django 6.1 (Python 3.14), MongoDB 9.0 (PyMongo 4.20), HTML5, CSS3, Vanilla ES6+ JavaScript

---

## 📑 Architectural Module Breakdown

The codebase is organized into **6 primary modules**:
1. **Root Launchers & Orchestration**: Scripts to boot servers, automate testing, and execute processes.
2. **Backend Configuration (`backend/dpc_backend/`)**: Global Django routing, CORS policy, and PyMongo connection pooling.
3. **Domain Business Apps (`backend/`)**:
   - `accounts`: User authentication, session management, and profile storage.
   - `catalog`: Medicine master index, typeahead autocomplete, fuzzy search, and generic substitution engine.
   - `pharmacies`: 6-partner pharmacy directory, live listings generator, and Trivago clickout affiliate logging.
   - `alerts`: Price-drop notification subscriptions and target threshold tracking.
   - `ai_assistant`: Prescription OCR entity extraction, drug-drug interaction checker, and senior drug explainer.
4. **Data Engineering (`data/` & `backend/scripts/`)**: Master 253,973 record dataset, cleaning transformations, and MongoDB loaders.
5. **Software Engineering Documentation & UML (`docs/`)**: IEEE 830-1998 SRS and all 7 formal UML design diagrams.
6. **Accessible Frontend (`frontend/`)**: Responsive SPA with WCAG 2.1 AA Senior Citizen accessibility controls.

---

## 📂 1. Root Level Launchers & Operational Scripts

### `run_server.bat`
* **Purpose**: One-click Windows Command Prompt launcher for the Django web application.
* **How It Works**:
  - Automatically locates the correct Python 3.14 interpreter (`C:\Python314\python.exe` or system PATH).
  - Verifies prerequisite Python packages (`django`, `pymongo`, `django-cors-headers`, `pypdf`).
  - Launches the Django ASGI/WSGI HTTP server on `127.0.0.1:8000`.
  - Asynchronously opens the user's default browser after a 2-second buffer.
  - Keeps the terminal window open upon unexpected exit to display diagnostic tracebacks.

### `run_server.ps1`
* **Purpose**: Native PowerShell alternative launcher for Windows power users.
* **How It Works**:
  - Automatically resolves the interpreter path using `Get-Command`.
  - Spawns a background browser opening job (`Start-Job`).
  - Executes `manage.py runserver 127.0.0.1:8000` using the script's root path (`$PSScriptRoot`).

### `run_tests.bat`
* **Purpose**: One-click automated test runner executing the complete backend verification suite.
* **How It Works**:
  - Invokes `backend/test_api_endpoints.py` directly using Python 3.14.
  - Prints the status of all 12 test cases to the terminal with color-coded success markers.
  - Pauses execution on completion so evaluators can inspect results.

### `start_app.py`
* **Purpose**: Cross-platform Python bootstrapper.
* **How It Works**:
  - Uses standard library `subprocess` and `webbrowser` modules.
  - Spawns a background thread to launch `http://127.0.0.1:8000/`.
  - Boots `manage.py runserver 127.0.0.1:8000` in the main thread with clean `KeyboardInterrupt` shutdown handling.

### `README.md`
* **Purpose**: The primary project documentation and quickstart reference.
* **Contents**: High-level system overview, dataset cleaning metrics, MongoDB schema definitions, partner pharmacy matrices, and quickstart instructions.

### `TESTING_GUIDE.md`
* **Purpose**: Step-by-step software verification handbook.
* **Contents**: Detailed test plans for evaluators, covering 9 manual and automated testing scenarios (Search, Autocomplete, Typo correction, Trivago comparisons, Doctor slip print, AI Rx Scanner, Senior contrast modes, Price alerts, and User registration/login).

### `run_load_test.bat`
* **Purpose**: One-click launcher for Apache JMeter 5.6.3 non-GUI automated load testing.
* **How It Works**:
  - Automatically loads OpenJDK 17 LTS and Apache JMeter binaries into PATH.
  - Verifies that the Django backend on `http://127.0.0.1:8000/api/health/` is active.
  - Prompts evaluator for test tier (5, 50, 200, or 500 concurrent users).
  - Executes test plan in non-GUI CLI mode, saves `.jtl` transaction logs, compiles the official HTML performance dashboard to `docs/load_test_report/`, and opens it in the default browser.

### `LOAD_TEST_REPORT.md`
* **Purpose**: Comprehensive technical load and stress audit report.
* **Contents**: Performance metrics across 4 concurrency tiers up to 500 virtual threads, detailed 13-endpoint latency percentiles (p50, p90, p95, max), documentation of the 5 database & concurrency bugs identified and fixed, and formal compliance verification against SRS NFR-1.1 & NFR-1.2.

### `tests/load_testing/dpc_load_test_plan.jmx`
* **Purpose**: Complete Apache JMeter 5.6.3 Test Plan XML specification.
* **Contents**: End-to-end user journey across 13 REST API endpoints with HTTP Defaults, Header Managers, Loop Controllers, Response Assertions, and configurable Thread Group properties (`threads`, `loops`, `rampup`).

---

## 📂 2. Backend Core Configuration (`backend/dpc_backend/`)

### `backend/manage.py`
* **Purpose**: Django’s command-line management utility.
* **Functions**: Manages database migrations, server launches (`runserver`), and unit test runners. Configures `DJANGO_SETTINGS_MODULE = 'dpc_backend.settings'`.

### `backend/db.sqlite3`
* **Purpose**: Standard relational SQLite storage.
* **Usage**: Reserved exclusively for Django internal components (Django Admin sessions, auth permission tables, content types). The high-volume medicine catalog (253,973 medicines) resides in MongoDB.

### `backend/dpc_backend/__init__.py`
* **Purpose**: Python package initializer identifying `dpc_backend` as an importable module.

### `backend/dpc_backend/settings.py`
* **Purpose**: Master Django project configuration file.
* **Key Components**:
  - `INSTALLED_APPS`: Registers Django built-ins plus custom domain apps (`accounts`, `catalog`, `pharmacies`, `alerts`, `ai_assistant`, `corsheaders`).
  - `MIDDLEWARE`: Configures `CorsMiddleware` at the topmost level to allow client requests from any port or Live Server origin.
  - `MONGO_SETTINGS`: Defines MongoDB host (`127.0.0.1`), port (`27017`), database name (`dpc_db`), and connection timeouts.
  - `STATIC_URL` & `STATICFILES_DIRS`: Maps `/static/` and root URLs directly to the `frontend/` folder.
  - `CORS_ALLOW_ALL_ORIGINS = True`: Permits decoupled frontend clients.

### `backend/dpc_backend/mongo.py`
* **Purpose**: Centralized MongoDB connection pool and document serialization layer.
* **Key Functions**:
  - `get_mongo_client()`: Singleton thread-safe connection pooling to `mongodb://127.0.0.1:27017/`.
  - `get_db()`: Returns handle to the `dpc_db` database instance.
  - `get_collection(name)`: Returns a specific MongoDB collection handle (`medicines`, `pharmacies`, `users`, `price_alerts`, `click_logs`).
  - `serialize_mongo(doc)`: Recursive helper function converting BSON `ObjectId` and Python `datetime` instances into JSON-serializable strings.

### `backend/dpc_backend/urls.py`
* **Purpose**: Root URL routing table mapping HTTP paths to app-specific URL routers.
* **Endpoints Configured**:
  - `/` $\rightarrow$ `home_view`: Serves `frontend/index.html`.
  - `/api/health/` $\rightarrow$ `api_health`: Returns system uptime, active MongoDB version, and real-time medicine counts.
  - `/api/auth/` $\rightarrow$ Delegated to `accounts.urls`.
  - `/api/catalog/` $\rightarrow$ Delegated to `catalog.urls`.
  - `/api/pharmacies/` $\rightarrow$ Delegated to `pharmacies.urls`.
  - `/api/alerts/` $\rightarrow$ Delegated to `alerts.urls`.
  - `/api/ai/` $\rightarrow$ Delegated to `ai_assistant.urls`.
  - `/styles.css` & `/app.js` $\rightarrow$ Serves frontend static assets directly from root.
  - `/favicon.ico` $\rightarrow$ Returns 204 No Content to prevent 404 console noise.

### `backend/dpc_backend/wsgi.py` & `asgi.py`
* **Purpose**: Web Server Gateway Interface (WSGI) and Asynchronous Server Gateway Interface (ASGI) entry points used by production application servers (such as Gunicorn, uWSGI, or Daphne).

### `backend/test_api_endpoints.py`
* **Purpose**: Complete automated test harness containing 12 programmatic test cases.
* **Assertions Tested**:
  1. Health check & database connectivity.
  2. Sub-100ms autocomplete suggestion generation.
  3. Catalog search with price range aggregations.
  4. Single medicine detail with 6-pharmacy comparison matrix.
  5. Bioequivalent generic alternative lookup.
  6. Partner pharmacies directory retrieval.
  7. Trivago affiliate redirect click logging.
  8. Price drop alert registration.
  9. AI prescription slip parsing & savings calculation.
  10. Senior-tailored plain language explanation retrieval.
  11. User registration with input validation.
  12. User authentication (standard password check & 1-click demo login).

---

## 📂 3. Domain Business Apps (`backend/`)

### Module 3.1: Accounts App (`backend/accounts/`)
* **Purpose**: Implements SRS Section 3.1 (User Registration & Authentication, FR-1.1 & FR-1.2).
* **Files**:
  - `accounts/__init__.py`: Package marker.
  - `accounts/apps.py`: Declares `AccountsConfig` Django app configuration.
  - `accounts/urls.py`: Maps `/register/`, `/login/`, `/logout/`, and `/me/`.
  - `accounts/views.py`:
    - `register_view()`: Validates name, email/mobile, and password. Checks for duplicates in MongoDB `users` collection. Hashes passwords using PBKDF2 (`make_password`).
    - `login_view()`: Authenticates users via email or mobile number using `check_password`. Includes a 1-click demo login handler (`is_demo: true`) for testing as *Ramesh Kumar (Senior Citizen)*.
    - `logout_view()`: Handles session invalidation.
    - `get_profile_view()`: Returns user metadata, registration date, and count of active saved alerts.

### Module 3.2: Catalog App (`backend/catalog/`)
* **Purpose**: Implements SRS Section 3.2, 3.3, and 3.4 (Medicine Search, Autocomplete, Comparison, Generic Alternatives).
* **Files**:
  - `catalog/__init__.py`, `apps.py`, `models.py`, `admin.py`, `tests.py`: Standard Django app scaffolding.
  - `catalog/urls.py`: Routes catalog requests to controller views.
  - `catalog/services.py`:
    - `get_autocomplete(query, limit)`: Performs ultra-fast prefix regex matching against B-Tree indexed `name` and `salts` fields in MongoDB ($< 50\text{ms}$).
    - `check_did_you_mean(query)`: Fuzzy matching engine using sequence matcher to correct common misspellings (e.g. `dlo` $\rightarrow$ `Dolo`, `paracit` $\rightarrow$ `Paracetamol`).
    - `search_medicines(...)`: Full-text search supporting multi-field regex, stock filters, delivery speed filters, price sorting, and pagination.
    - `get_medicine_detail(med_id)`: Fetches a single medicine document and attaches live 6-pharmacy pricing listings.
    - `get_generic_substitutes(med_id)`: Queries medicines sharing the same normalized `salt_key` and computes yearly patient savings.
  - `catalog/views.py`: HTTP controller layer wrapping `services.py` logic in JSON responses (`autocomplete_view`, `search_view`, `medicine_detail_view`, `generic_alternatives_view`, `did_you_mean_view`).

### Module 3.3: Pharmacies App (`backend/pharmacies/`)
* **Purpose**: Implements SRS Section 3.5 & FR-3.4 (Partner Directory, Trivago Clickout Redirect Model).
* **Files**:
  - `pharmacies/__init__.py`, `apps.py`, `models.py`, `admin.py`, `tests.py`: Standard Django structure.
  - `pharmacies/urls.py`: Maps `/`, `/<id>/`, `/click/`, and `/analytics/`.
  - `pharmacies/partner_service.py`:
    - `get_all_pharmacies()`: Retrieves the 6 certified partner pharmacies (Apollo, 1mg, PharmEasy, Netmeds, Jan Aushadhi, MedPlus) sorted by rating.
    - `generate_medicine_listings(med_doc)`: Deterministically computes store-specific prices, discounts, stock availability, and delivery speeds for any of the 253,973 medicines. Constructs licensed affiliate storefront redirect URLs.
    - `log_redirect_click(med_id, pharmacy_id, user_ip, user_agent)`: Records outbound "View Deal" clicks in MongoDB `click_logs` collection for affiliate commission tracking and conversion audits.
    - `get_click_analytics()`: Aggregates outbound click volume and popular store distribution.
  - `pharmacies/views.py`: Exposes REST endpoints (`list_pharmacies`, `pharmacy_detail`, `track_click`, `analytics`).

### Module 3.4: Alerts App (`backend/alerts/`)
* **Purpose**: Implements SRS Section 3.6 (Price-Drop Alerts & Saved Searches, FR-6.1).
* **Files**:
  - `alerts/__init__.py`, `apps.py`, `models.py`, `admin.py`, `tests.py`: Standard Django structure.
  - `alerts/urls.py`: Routes `/`, `/create/`, and `/<id>/`.
  - `alerts/views.py`:
    - `list_alerts()`: Returns active alert subscriptions from MongoDB `price_alerts`.
    - `create_alert()`: Subscribes a user to price-drop notifications on a specific drug with a target price and channel (WhatsApp, SMS, Email).
    - `delete_alert()`: Removes an alert trigger by its BSON `ObjectId`.

### Module 3.5: AI Assistant App (`backend/ai_assistant/`)
* **Purpose**: Implements SRS AI features (Prescription Slip Parser, Drug Explainer, Interaction Checker).
* **Files**:
  - `ai_assistant/__init__.py`, `apps.py`, `models.py`, `admin.py`, `tests.py`: Standard Django structure.
  - `ai_assistant/urls.py`: Routes `/scan-prescription/`, `/check-interactions/`, and `/explain/<id>/`.
  - `ai_assistant/views.py`:
    - `scan_prescription()`: Tokenizes prescription text, eliminates clinical stop-words (`OD`, `BD`, `TDS`, `Tab`), matches candidate strings against the 253,973 MongoDB medicine catalog, and aggregates immediate and annual generic savings.
    - `check_interactions()`: Scans drug salt combinations against known contraindication matrices (e.g., dual NSAID liver burdens, combined antihypertensive drops).
    - `explain_medicine()`: Formulates simplified, 8th-grade reading level explanations of active salts, indications, missed dose instructions, and senior precautions.

---

## 📂 4. Data Engineering & Migration (`data/` & `backend/scripts/`)

### `backend/scripts/clean_and_load_mongo.py`
* **Purpose**: Standalone data engineering pipeline script that cleans the raw 253,973-row CSV and populates MongoDB `dpc_db`.
* **Execution Logic**:
  1. Connects to `mongodb://127.0.0.1:27017/`.
  2. Seeds partner pharmacies collection with baseline discount rates, review counts, and fulfillment speeds.
  3. **Pass 1 (Sanitization & Normalization)**:
     - Parses `short_composition1` and `short_composition2` into structured `salt` and `strength` dictionaries.
     - Generates alphabetical `salt_key` strings grouping 2,874 chemical families.
     - Sanitizes invalid/negative prices.
     - Classifies Schedule H / prescription status.
     - Attaches senior-friendly usage explanations and cautions.
  4. **Pass 2 (Generic Substitution Mapping & Bulk Ingestion)**:
     - Computes the cheapest generic equivalent for each salt group.
     - Inserts documents into MongoDB in 5,000-record batches.
  5. **Indexing**: Creates text search indexes on `name`, `salts`, `manufacturer`, and B-Tree indexes on `salt_key`, `mrp`, and `is_discontinued`.

### `data/raw/A_Z_medicines_dataset_of_India.csv` & `archive.zip`
* **Purpose**: The master raw dataset containing 253,973 rows of Indian medicines across all manufacturers, pack sizes, and compositions (32 MB uncompressed).

### `data/cleaned/cleaned_medicines_sample_500.json`
* **Purpose**: Standalone JSON export of 500 fully sanitized medicine records with structured generic equivalents and senior cautions for rapid review.

### `data/cleaned/dataset_cleaning_report.json`
* **Purpose**: Machine-readable audit report detailing records cleaned, unique salt families, Schedule H distributions, and data transformations.

---

## 📂 5. Software Engineering Documentation & UML (`docs/`)

* **`docs/SRS.pdf`**: Complete 14-page IEEE Std 830-1998 compliant Software Requirements Specification covering Functional Requirements (FR-1 through FR-8), Interface Specifications, Non-Functional Requirements (Performance, Security, Usability), and Database Designs.
* **`docs/SRS_extracted.txt`**: Plaintext extraction of the complete SRS for searchability.
* **`docs/Use Case Diagram.pdf`**: UML diagram modeling interactions across Guest Users, Registered Patients, Pharmacy Partners, and Platform Admins.
* **`docs/Activity Diagram.pdf`**: UML diagram modeling the search-to-compare and affiliate clickout workflows.
* **`docs/Class Diagram.pdf`**: UML structural diagram defining domain entities (`User`, `Medicine`, `Pharmacy`, `PharmacyListing`, `PriceAlert`, `ClickLog`).
* **`docs/DFD Level - 0.pdf`**: Context-level Data Flow Diagram modeling external entities and boundary data exchanges.
* **`docs/DFD Level - 1.pdf`**: Detailed Data Flow Diagram showing internal process decomposition (Search, Aggregation, Recommendation, Clickout).
* **`docs/Component Diagram.pdf`**: High-level component decomposition illustrating frontend, DRF controllers, Celery async workers, and MongoDB.
* **`docs/Deployment Diagram.pdf`**: Physical deployment layout detailing web clients, Nginx/Gunicorn servers, application nodes, and database servers.

---

## 📂 6. Frontend Single-Page Application (`frontend/`)

### `frontend/index.html`
* **Purpose**: The single-page semantic markup structure of the entire client application.
* **Key Sections**:
  - **Accessibility Toolbar**: Text scaling buttons (`A`, `A+`, `A++`), High-Contrast mode toggle, and toll-free emergency helpline.
  - **Header & Navigation**: Brand identity, view tabs, and dynamic user profile badge (`👤 Sign In / Register` $\leftrightarrow$ `👤 [Name] (Sign Out)`).
  - **View 1: Search & Comparison (`searchView`)**:
    - Search input, live voice search microphone, and autocomplete dropdown list.
    - Misspelling suggestion banner ("Did you mean...").
    - Medicine header card with prescription status and price range tags.
    - AI Senior Explainer card with Web Speech API audio read-aloud.
    - Generic alternative savings card with doctor slip print trigger.
    - Interactive sort/filter bar (delivery speed, in-stock status, price sorting).
    - Pharmacy comparison cards grid with Trivago-style "View Deal / Buy →" buttons.
  - **View 2: AI Prescription Scanner (`aiPrescriptionView`)**: Drag-and-drop prescription uploader, sample slip triggers, OCR table, and total prescription savings calculator.
  - **View 3: Verified Pharmacies (`pharmaciesView`)**: 6-pharmacy partner directory with fulfillment ratings.
  - **View 4: Saved Alerts (`savedAlertsView`)**: Table of user price-drop subscriptions.
  - **View 5: Admin & Partner Feed Portal (`adminPortalView`)**: Ingestion pipeline telemetry and conversion metrics.
  - **Modals**:
    - `#doctorSlipModal`: Side-by-side generic switch recommendation note for doctor visits.
    - `#authModal`: Accessible Sign In, New Account registration, and 1-Click Demo login dialog.

### `frontend/styles.css`
* **Purpose**: Production stylesheet supporting responsive typography and WCAG 2.1 AA accessibility.
* **Core Style Modules**:
  - CSS Custom Properties (`:root`): Design tokens for colors, typography scaling, shadows, and borders.
  - Accessible Typography: Body classes `.font-large` and `.font-xlarge`.
  - High Contrast Theme (`body.high-contrast`): High-visibility black backgrounds with `#ffeb3b` (yellow) typography and high-contrast borders.
  - Layout Grids: Responsive Flexbox and Grid layouts adapting to mobile, tablet, and desktop breakpoints.
  - Keyframe Animations: `.highlight-pulse` glow effect highlighting the medicine comparison card upon selection.
  - Modal dialog styling and form input focus rings.

### `frontend/app.js`
* **Purpose**: Modular JavaScript controller (IIFE module pattern) governing all client-side logic.
* **Key Sub-Modules**:
  - `App.api`: Async HTTP client communicating with Django REST endpoints (`/catalog/`, `/pharmacies/`, `/alerts/`, `/ai/`, `/auth/`).
  - `App.data`: Client-side cache and fallback datasets ensuring zero-downtime offline operation.
  - `App.router`: Tab navigation switching active views without page reloads.
  - `App.accessibility`: Binds font scaling and contrast toggles to DOM body classes.
  - `App.search`:
    - Debounced typeahead query handler ($150\text{ms}$).
    - `mousedown` event listener on autocomplete items ensuring instant selection before input blur.
    - Smooth auto-scroll to `#medicineHeaderCard` with visual highlight pulse upon medicine selection.
    - Interactive sorting and filtering engine for pharmacy comparison listings.
    - Web Speech Recognition voice input handler.
  - `App.aiScanner`: Prescription text parser extracting drug names and computing prescription-wide savings.
  - `App.aiExplainer`: Interfaces with the browser’s Web Speech Synthesis API (`SpeechSynthesisUtterance`) to read drug advice aloud at a senior-friendly 0.85x speed.
  - `App.auth`: User authentication controller managing sign-in, account creation, 1-click demo login, local storage persistence, and header UI states.
  - `App.init`: Application bootstrapper executed on `DOMContentLoaded`.
