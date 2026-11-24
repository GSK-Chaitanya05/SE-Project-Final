# DPC Platform: Comprehensive Software Testing Guide

> **Project Location:** `D:\SE Project Final\`  
> **Backend Framework:** Django 6.1 (Python 3.14)  
> **Database:** MongoDB 9.0 (`dpc_db` on port 27017)  
> **Architecture:** Decoupled REST API + Responsive Single-Page Application (SPA)

---

## 📍 Where to Test This Software

You have **3 main environments** to test every part of the system:

| Testing Environment | Tool / URL | What It Tests |
| :--- | :--- | :--- |
| **1. Web Browser (Frontend & End-to-End)** | **`http://127.0.0.1:8000/`** | The complete user interface: live search across 253,973 medicines, price comparisons across 6 partner pharmacies, generic savings calculations, elderly accessibility toolbar, and AI prescription scanner. |
| **2. Automated Test Suite (CLI)** | **`run_tests.bat`** in `D:\SE Project Final\` | Runs 10 automated test cases verifying all Django REST endpoints, PyMongo connection pool, query speeds, and click trackers. |
| **3. Database Layer (MongoDB Compass / Shell)** | **`mongodb://localhost:27017/`** | Database collections: `medicines` (253,973 docs), `pharmacies` (6 partner stores), `price_alerts`, and `click_logs`. |

---

## 🧪 How to Test: Step-by-Step Test Scenarios

### Test 1: Run the One-Click Automated Test Suite
* **How to run:** Double-click `run_tests.bat` in `D:\SE Project Final\`  
  *(Or run `C:\Python314\python.exe "D:\SE Project Final\backend\test_api_endpoints.py"` in terminal)*
* **Expected Result:** All 10 tests pass:
  1. `GET /api/health/` -> Status 200 (Total medicines > 200,000)
  2. `GET /api/catalog/autocomplete/?q=Augmentin` -> Returns rapid suggestions
  3. `GET /api/catalog/search/?q=Telma` -> Returns matching medicine results
  4. `GET /api/catalog/medicines/1/` -> Generates live 6-pharmacy comparison table
  5. `GET /api/catalog/medicines/1/generics/` -> Returns verified generic equivalents
  6. `GET /api/pharmacies/` -> Returns all 6 partner pharmacies
  7. `POST /api/pharmacies/click/` -> Logs Trivago-style affiliate redirect clickout
  8. `POST /api/alerts/create/` -> Registers price drop alert in MongoDB
  9. `POST /api/ai/scan-prescription/` -> Parses prescription slip and calculates yearly savings
  10. `GET /api/ai/explain/1/` -> Returns senior-friendly non-technical drug explanation

---

### Test 2: Live Search & Typeahead Autocomplete
1. Open your browser at **`http://127.0.0.1:8000/`**.
2. Click the search box in the hero banner.
3. Start typing a medicine name:
   * Try **`Augmentin`** $\rightarrow$ See instant suggestions (e.g. *Augmentin 625 Duo Tablet*).
   * Try **`Dolo`** $\rightarrow$ See *Dolo 650 Tablet*.
   * Try a salt name like **`Paracetamol`** or **`Azithral`**.
4. Click any medicine from the dropdown list.
5. **Expected Result:** The page smoothly scrolls down to `#medicineHeaderCard`, flashes a blue highlight pulse, and displays the full comparison table across 6 partner pharmacies.

---

### Test 3: Typo Tolerance ("Did you mean...?")
1. In the search box, intentionally misspell a medicine:
   * Type **`dlo`** or **`paracit`** or **`agumentin`**.
2. Notice the yellow suggestion banner appears:
   * *"💡 Did you mean: Dolo / Paracetamol 650mg / Augmentin?"*
3. Click the suggestion button.
4. **Expected Result:** The corrected medicine is selected, loaded, and displayed automatically.

---

### Test 4: Trivago-Style 6-Pharmacy Price Comparison
1. With any medicine selected (e.g. *Augmentin 625 Duo Tablet*):
2. Review the comparison cards for all 6 partner pharmacies:
   * **Jan Aushadhi Kendra (Govt):** Up to 85% cheaper generic substitute.
   * **Apollo Pharmacy:** 2-Hour Express Delivery.
   * **Tata 1mg:** Same-Day Delivery.
   * **PharmEasy:** Super Saver Deals.
   * **Netmeds:** Standard Pan-India Delivery.
   * **MedPlus:** Local Store Network (Same Day).
3. Test the interactive filters:
   * **Sort by:** Select *"Highest Price First"* or *"Pharmacy Rating"*.
   * **Delivery Speed:** Filter by *"Instant (2 Hours)"* or *"Same Day"*.
   * **In-Stock Only:** Check the checkbox to hide out-of-stock stores.
4. Click **"View Deal / Buy →"** on any pharmacy card.
5. **Expected Result:** Opens the official store page in a new tab and logs the affiliate clickout to MongoDB `click_logs`.

---

### Test 5: Generic Substitute & Yearly Savings Calculator
1. Look at the green card on the right: **"Switch to [Generic Name]"**.
2. Notice the calculated yearly savings (e.g. *Save ₹2,500+ / year*).
3. Click **"Print Doctor's Consultation Slip"**.
4. **Expected Result:** A modal window opens displaying a side-by-side slip showing the prescribed brand vs the Jan Aushadhi generic alternative that patients can take to their doctor.

---

### Test 6: AI Prescription / Doctor's Slip Scanner
1. Click **"📸 AI Rx Scanner"** in the top navigation bar.
2. Under "Test With Real Prescription Samples":
   * Click **"Prescription Sample #814 - Cardiology"**  
     *(Or "Diabetes & Infection Sample #204")*.
3. Watch the simulated OCR scanner process the doctor's slip.
4. **Expected Result:**
   * Detects medicines from the slip (e.g. *Telma 40mg*, *Glycomet 500 SR*).
   * Displays detected dosages, instructions, and savings per pack.
   * Computes **Total Generic Savings** right now and estimated yearly savings.
   * Click **"Compare Prices →"** to jump straight to that medicine's live price comparison.

---

### Test 7: Senior Support Mode (Accessibility & Audio Read-Aloud)
1. In the black accessibility toolbar at the top:
   * Click **`A+`** $\rightarrow$ Text enlarges for easy elderly reading.
   * Click **`A++`** $\rightarrow$ Text scales to extra large.
   * Click **`A`** $\rightarrow$ Resets to standard size.
   * Click **`High Contrast Mode`** $\rightarrow$ Toggles WCAG 2.1 AA black and yellow high-contrast view.
2. In the medicine summary card, click **"🤖 Explain This Medicine (AI)"**.
3. Read the plain-language explanation of what the medicine does and its senior precautions.
4. Click **"🔊 Read Aloud (Audio)"**.
5. **Expected Result:** The browser's speech synthesizer speaks the explanation aloud at a slow, clear pace tailored for elderly patients.

---

### Test 8: Price-Drop Alerts
1. On any medicine, click **"🔔 Set Price-Drop Alert"**.
2. Button changes to **"✅ Price-Drop Alert Active"**.
3. Click **"🔔 Price Alerts"** in the top navigation bar.
4. **Expected Result:** Your active alert is listed in the alerts table showing target price, current lowest price, and notification channel.

---

### Test 9: Patient & Senior Citizen Login / Registration (SRS FR-1.1 & FR-1.2)
1. In the top navigation bar, click the **"👤 Sign In / Register"** button.
2. The accessible **Patient & Senior Account** modal opens:
   * **Test 1-Click Instant Demo Login:** Click **"⚡ 1-Click Sign In (Demo Senior Patient)"**.
     * **Expected Result:** Instantly signs in as *Ramesh Kumar (Senior Citizen)*. The header updates to show `👤 Ramesh Kumar` with a `Sign Out` button.
   * **Test New Registration:**
     * Click the **"New Account"** tab.
     * Fill in Name, Email or Mobile Number, Password, and check *"Enable Senior Support Mode"*.
     * Click **"Create Free Account"** $\rightarrow$ Creates user account with secure password hashing in MongoDB `users` collection and signs in immediately.
   * **Test Sign Out:** Click **"Sign Out"** next to your name $\rightarrow$ Clears session and returns to guest mode.
