# Personalized Packaged-Food Scanner & Nutrition Evaluator
> **College Cloud Computing Subject Project**  
> Built with **Flutter (Client)** & **AWS Serverless Architecture (Cloud Backend)**.

---

## 1. Project Overview

This mobile application helps consumers understand packaged foods and snacks by scanning the back of product packaging. The system:
1. **Reads Expiry & Best-Before Dates** using on-device OCR and heuristic date parsing, distinguishing food-safety thresholds (*Use By / Expiry*) from quality thresholds (*Best Before*).
2. **Flags Ambiguous Dates** (e.g. `05/06/2026`) and provides a manual date-picker correction fallback.
3. **Extracts Nutrition & Ingredients**: Reads sugars, sodium, protein, calories, ingredients, and allergen warnings.
4. **Delivers Explainable Assessments**: Evaluates food strictly against the user's explicit profile (dietary preferences, allergies, and health goals) with concrete evidence citations (e.g., *"Contains 19g sugar per serving, exceeding your <10g target"*).
5. **Demonstrates Serverless Cloud Computing**: Utilizes AWS Cognito, API Gateway, AWS Lambda, Amazon DynamoDB, and Amazon CloudWatch with $0.00 / month Free-Tier cost.

---

## 2. Cloud Architecture

```
 ┌────────────────────────────────────────────────────────────────────────┐
 │                           Flutter Mobile Client                        │
 │  ┌───────────────────────┐  ┌─────────────────┐  ┌──────────────────┐  │
 │  │ Camera / Image Picker │  │  On-Device OCR  │  │ Expiry Extractor │  │
 │  │    (Gallery/Camera)   │──│ (Google ML Kit) │──│ & Date Normalizer│  │
 │  └───────────────────────┘  └─────────────────┘  └──────────────────┘  │
 │                                                            │           │
 │  ┌───────────────────────┐  ┌─────────────────┐            │           │
 │  │ Assessment & History  │  │ Review & Manual │◀───────────┘           │
 │  │        Screens        │  │ Correction UI   │                        │
 │  └───────────────────────┘  └─────────────────┘                        │
 └────────────────────────────────────▲───────────────────────────────────┘
                                      │ HTTPS (JWT Authenticated)
 ┌────────────────────────────────────▼───────────────────────────────────┐
 │                               AWS Cloud                                │
 │                                                                        │
 │   ┌──────────────────────┐           ┌─────────────────────────────┐   │
 │   │    Amazon Cognito    │           │     Amazon API Gateway      │   │
 │   │ (User Pools & Auth)  │           │         (HTTP API)          │   │
 │   └──────────┬───────────┘           └──────────────┬──────────────┘   │
 │              │ JWT Token                            │ Proxy            │
 │              ▼                                      ▼                  │
 │   ┌────────────────────────────────────────────────────────────────┐   │
 │   │                       AWS Lambda Backend                       │   │
 │   │    - Profile Manager (/profile)                                │   │
 │   │    - Evaluation Engine (/assess)                               │   │
 │   │    - Scan History Manager (/scans)                             │   │
 │   └───────────────────┬────────────────────────────┬───────────────┘   │
 │                       │ Read/Write                 │ Metrics & Logs    │
 │                       ▼                            ▼                   │
 │   ┌────────────────────────────────┐  ┌────────────────────────────┐   │
 │   │        Amazon DynamoDB         │  │      Amazon CloudWatch     │   │
 │   │  - UsersTable & ScansTable     │  │  - Invocation & Error logs │   │
 │   │  - Row-Level Access Security   │  │  - Latency dashboard (Demo)│   │
 │   └────────────────────────────────┘  └────────────────────────────┘   │
 └────────────────────────────────────────────────────────────────────────┘
```

### Cloud Component Rationale & Free-Tier Cost Analysis

| Component | AWS Service | Purpose | Monthly Cost (Free Tier) |
| :--- | :--- | :--- | :--- |
| **Authentication** | Amazon Cognito User Pools | Multi-tenant user login & JWT token issuance | **$0.00** (50,000 MAUs always free) |
| **API Management** | Amazon API Gateway (HTTP API v2) | Lightweight REST endpoints with JWT Authorizer | **$0.00** (1M free calls/month) |
| **Serverless Compute** | AWS Lambda (Python 3.11) | Stateless execution of rules & DynamoDB CRUD | **$0.00** (1M requests & 3.2M sec compute) |
| **NoSQL Database** | Amazon DynamoDB | Profiles (`userId`) & Scans (`userId` + `scanId`) | **$0.00** (25 GB storage always free) |
| **Monitoring & Logs** | Amazon CloudWatch | Request tracing, execution metrics, and latency | **$0.00** (5 GB log ingestion free) |
| **On-Device OCR** | Google ML Kit | Zero cloud vision API cost & works offline | **$0.00** (Free on device) |
| **Total Cost** | | | **$0.00 / month** |

---

## 3. Project Structure

```
Cloud Project/
├── context.md                          # Project specifications
├── README.md                           # Cloud documentation and setup guide
├── backend/                            # AWS Cloud Backend
│   ├── template.yaml                   # AWS SAM CloudFormation infrastructure template
│   ├── requirements.txt                # Python dependencies (boto3, pydantic, pytest)
│   ├── handlers/
│   │   ├── lambda_function.py          # Serverless Lambda handler & API router
│   │   └── assessment_engine.py       # Python rule-based evaluation engine
│   └── tests/
│       └── test_assessment.py          # Python backend unit tests
│
└── food_scanner_app/                   # Flutter Mobile Client
    ├── pubspec.yaml
    ├── test/
    │   ├── expiry_parser_test.dart     # 7 unit tests for dates, ambiguity, statuses
    │   ├── assessment_rules_test.dart  # 5 unit tests for allergens, sugar, vegetarian
    │   └── widget_test.dart            # Widget rendering test
    └── lib/
        ├── main.dart                   # MultiProvider & theme bootstrap
        ├── core/
        │   ├── constants/app_colors.dart
        │   └── theme/app_theme.dart
        └── features/
            ├── home/screens/home_screen.dart
            ├── profile/
            │   ├── models/user_profile.dart
            │   ├── screens/profile_screen.dart
            │   └── services/profile_provider.dart
            ├── scan/
            │   ├── models/expiry_date_result.dart
            │   ├── models/nutrition_facts.dart
            │   ├── screens/review_and_edit_screen.dart
            │   └── services/
            │       ├── ocr_scanner_service.dart
            │       └── demo_samples.dart
            ├── parsing/
            │   ├── expiry_parser.dart
            │   └── nutrition_parser.dart
            ├── assessment/
            │   ├── models/product_assessment.dart
            │   ├── screens/assessment_result_screen.dart
            │   └── services/assessment_engine.dart
            ├── history/
            │   ├── models/product_scan.dart
            │   ├── screens/history_screen.dart
            │   └── services/history_provider.dart
            └── cloud/screens/cloud_demo_screen.dart
```

---

## 4. How to Run and Test

### A. Run Flutter Unit Tests
Verify that all 13 test cases pass:
```bash
cd food_scanner_app
flutter test
```
**Tests Covered:**
- Unambiguous `DD/MM/YYYY` with `USE BY`
- Named months (e.g., `15-OCT-2027` with `BEST BEFORE`)
- Ambiguous dates detection (e.g., `05/06/2026` flags confirmation needed)
- Expired products detection
- Expiring soon (<7 days) products detection
- Month/Year only extraction (`MM/YYYY`)
- Direct allergen conflict (Peanuts, Gluten, Dairy)
- Vegetarian mismatch detection (Gelatin, Rennet, Carmine)
- Sugar reduction goal exceeding threshold (>10g)
- Incomplete label data fallback handling

### B. Run Python Cloud Backend Tests
```bash
python backend/tests/test_assessment.py
```

### C. Run the Flutter Mobile App
Launch on connected Android device or emulator:
```bash
cd food_scanner_app
flutter run
```

### D. Testing on Simulators / Without Physical Food Packaging
Inside the app:
1. Tap **"Or Try Built-in Demo Samples (Instant Test)"** on the Home screen.
2. Select any sample:
   - **Sample 1: Oat & Almond Granola Bar** (Suitable, valid Best Before, low sugar, high protein).
   - **Sample 2: Berry Gummy Candies** (High sugar conflict + Gelatin non-vegetarian mismatch).
   - **Sample 3: Crunchy Peanut Butter Cups** (Triggers strict allergen alert for peanut allergy).
   - **Sample 4: Fresh Greek Yogurt** (Triggers "Expiring Soon" within 3 days).
   - **Sample 5: Organic Black Beans** (Triggers "Past Printed Date / Expired").
   - **Sample 6: Ambiguous Date Chips** (Triggers manual date confirmation dialog).
3. The app opens the **Review & Verify Screen**, letting you edit numbers or change the date via the calendar before calculating the explainable personalized assessment!

---

## 5. Deploying to AWS (Cloud Computing Submission)

To deploy the backend to AWS using the AWS Serverless Application Model (SAM):
```bash
# 1. Navigate to backend directory
cd backend

# 2. Build SAM application
sam build

# 3. Deploy to AWS Free Tier
sam deploy --guided
```
SAM will provision:
- The Cognito User Pool (`FoodScannerUserPool`)
- The DynamoDB tables (`FoodScannerProfiles` & `FoodScannerHistory`)
- The HTTP API Gateway with JWT Authorizer
- The Python 3.11 Lambda backend function
- CloudWatch log groups for monitoring and tracing
