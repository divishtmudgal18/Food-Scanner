# Context: Personalized Packaged Food Scanner App

## 1. Project Overview

We are building a **mobile application using Flutter** for a college **Cloud Computing / Cloud Subject project**. The app helps a user understand packaged foods and snacks by scanning the information printed on the back of the package.

The app should:
1. Scan or capture the back label of a packaged food/snack.
2. Read the product's expiry / best-before date from the label.
3. Extract relevant product and nutrition information when available.
4. Evaluate the food in the context of the individual user's profile and goals.
5. Explain whether the product may be a suitable choice for that user, including clear reasons when it may not be suitable.
6. Use cloud services for appropriate parts of the application, making the cloud component demonstrable for the course.

This file is a handoff document for a new AI coding agent. Treat the requirements below as the current project context. Where a choice is not final, mark it as a proposal and ask before making major architectural changes.

## 2. Main User Journey

1. The user opens the app and signs in or creates an account.
2. The user completes a personal profile, including relevant dietary preferences, health goals, allergies/intolerances, and optional health-related restrictions.
3. The user taps **Scan Product** and points the camera at the back of a food/snack package. The app should support taking a photo and, if practical, selecting an existing image from the gallery.
4. The app detects and reads printed text using OCR.
5. The app attempts to identify:
   - Product name and brand, if visible
   - Expiry date and/or best-before date
   - Ingredients list
   - Nutrition facts (for example, serving size, calories, sugar, sodium, saturated fat, protein, and other values that are legible)
   - Allergen statements and dietary labels, if visible
6. The app displays the extracted information and clearly indicates fields that could not be read confidently. The user must be able to correct the detected expiry date and other incorrect OCR results.
7. The app checks the expiry/best-before information against the current date and explains the result.
8. The app compares the available ingredients and nutrition information with the user's profile and goals.
9. The app presents a personalized result with understandable reasons, such as high sugar relative to the user's stated goal, a listed allergen, high sodium, or a mismatch with a dietary preference.
10. The user can save the scan to their history and view previous scanned products.

## 3. Core Functional Requirements

### FR-1: Account and user profile
- Provide sign-up, sign-in, sign-out, and a way to manage the user's profile.
- Store only the profile information needed for personalization.
- Profile fields should be configurable and may include:
  - Dietary preferences (e.g., vegetarian, vegan, or other preferences)
  - Food allergies and intolerances
  - User-selected goals (e.g., reduce sugar, monitor sodium, increase protein, general balanced eating)
  - Optional dietary restrictions or health considerations that the user chooses to provide
- Do not assume a medical condition or dietary goal that the user has not provided.
- Let the user update or delete profile information.

### FR-2: Package scanning and OCR
- Use the phone camera to capture the back label of a packaged food or snack.
- Use OCR to extract text from the image.
- Handle common issues such as rotated images, blur, glare, low light, and incomplete labels as gracefully as practical.
- Show the original captured image and extracted fields for review when useful.
- Never silently treat uncertain OCR output as verified information.

### FR-3: Expiry-date detection
- Detect expiry-related labels such as **Expiry Date**, **EXP**, **Use By**, **Best Before**, and equivalent formats where feasible.
- Parse common date formats, including formats such as DD/MM/YYYY, DD-MM-YYYY, MM/YYYY, and month/year where unambiguous.
- Be careful with ambiguous dates; ask the user to confirm rather than guessing.
- Distinguish an exact expiry/use-by date from a best-before date. Do not describe them as interchangeable.
- Display the extracted date, confidence/status where available, and whether the date appears to be past, current, or upcoming.
- If the date is missing or unreadable, say so and ask the user to enter it manually.
- A date check alone cannot establish that food is safe. Packaging damage, storage conditions, contamination, and the meaning of the printed date can also matter. Do not guarantee safety based only on the scan.

### FR-4: Ingredient and nutrition extraction
- Extract the ingredients list, nutrition table, serving size, and allergen statements where available.
- Normalize extracted values into structured fields where possible, retaining the original text for reference.
- Record units and serving sizes accurately; avoid comparing values with different serving bases without explaining the conversion.
- If information is absent, unreadable, or not printed on the package, label it as unavailable instead of inventing it.
- Do not assume the front-of-pack marketing claims accurately describe the full nutritional profile.

### FR-5: Personalized food assessment
- Compare extracted label data against the user's explicitly supplied profile and goals.
- Provide a clear, user-specific assessment, such as:
  - **Potentially suitable for your stated goals**
  - **Consider limiting / may not fit your stated goals**
  - **Avoid if this conflicts with a declared allergy or restriction**
  - **Not enough information to assess reliably**
- Explain each assessment with specific evidence from the label and the relevant profile setting.
- Example: “This snack may not fit your goal of reducing sugar because the label lists X g of sugar per serving.” Only use a numeric value if it was actually read and verified.
- Example: “The ingredient/allergen statement appears to include [ingredient], which matches an allergen you listed.” Make uncertainty visible and advise checking the physical label for serious allergies.
- Do not give a generic “healthy/unhealthy” score without explaining the criteria.
- Do not make diagnoses, prescribe treatment, or claim that a food is medically safe for the user. The feature is an informational aid, not a substitute for professional medical or dietetic advice.
- If the label is incomplete, OCR confidence is low, or the user's profile lacks relevant details, state the limitation and avoid a confident conclusion.

### FR-6: Explanation and recommendations
- Explain **why** a product may or may not be suitable for the user in plain language.
- Separate facts read from the label from the app's interpretation.
- Mention relevant positive attributes as well as concerns when supported by the data.
- Give practical, non-medical suggestions when appropriate, such as checking serving size or comparing sugar/sodium per serving with another product.
- Avoid shaming language, fear-based wording, and unsupported health claims.

### FR-7: Scan history
- Let users save a scan and review previous results.
- Each saved scan may include product name, scan date, extracted expiry/best-before date, nutrition/ingredient fields, assessment, and explanation.
- Allow a user to delete individual history entries and, where appropriate, clear their history.
- Do not retain label images longer than needed unless the user chooses to save them and the retention behavior is explained.

### FR-8: Error handling and accessibility
- Show helpful messages for camera permission denial, network failure, OCR failure, missing dates, unsupported images, and cloud-service errors.
- Provide a manual-entry fallback if OCR fails.
- Use readable text, clear status labels, and a simple mobile-first interface.
- Never show a successful scan or a confident assessment when processing failed.

## 4. Cloud Computing Requirements

The project must demonstrate meaningful cloud computing rather than being only a local Flutter app. The final architecture is not yet fixed; the AI agent should propose and document a cost-conscious design suitable for a student project.

Possible cloud responsibilities:
- Authentication and secure user identity
- Backend API for scan processing and personalized assessment
- Secure storage of user profiles and scan history
- Optional image storage for scans the user chooses to retain
- Server-side OCR or processing where appropriate
- Logging, monitoring, and basic error reporting

A proposed AWS-oriented architecture, subject to confirmation:
- **Flutter + Dart**: mobile frontend
- **Amazon Cognito**: authentication, if appropriate for the chosen AWS design
- **Amazon API Gateway + AWS Lambda**: serverless backend endpoints
- **Amazon DynamoDB**: profile and scan-history records, if suitable for the data model
- **Amazon S3**: optional package-image storage, only if needed and protected by appropriate permissions
- **Amazon CloudWatch**: logs and basic monitoring
- **OCR**: compare on-device OCR with a cloud OCR approach; prefer a free or low-cost option suitable for a college demo. Do not assume a paid service is affordable.

These are suggestions, not mandatory decisions. The agent should check current free-tier limits, regional availability, and pricing before recommending deployment. Avoid creating billable cloud resources without explaining likely costs and obtaining the user's approval. Do not put cloud credentials, API keys, tokens, or secrets inside the Flutter app or commit them to source control.

## 5. Suggested Technical Direction

- **Frontend:** Flutter / Dart
- **Camera and image selection:** a maintained Flutter camera package and/or image picker
- **OCR:** evaluate an on-device OCR library first for cost control and privacy; compare alternatives if recognition quality is inadequate
- **Backend:** AWS serverless API is a candidate because this is a cloud-subject project; a different stack may be proposed with clear reasoning
- **Database:** cloud database for user profile and scan history
- **Authentication:** managed authentication or a secure backend-managed alternative
- **Source control:** Git/GitHub, with secrets excluded from commits

The agent must verify current package APIs and service pricing before implementation. Keep the frontend, OCR/extraction, personalization logic, and cloud persistence modular so they can be tested independently.

## 6. Suggested Data Model (Initial Proposal)

### UserProfile
- `userId`
- `dietaryPreferences` (list)
- `allergiesAndIntolerances` (list)
- `goals` (list)
- `optionalRestrictions` (list)
- `createdAt`
- `updatedAt`

Do not store sensitive health information unless it is necessary, explicitly provided, and protected appropriately.

### ProductScan
- `scanId`
- `userId`
- `productName` (nullable)
- `brand` (nullable)
- `capturedAt`
- `expiryDate` (nullable)
- `dateType` (expiry, use-by, best-before, unknown)
- `dateConfidence` or `dateNeedsConfirmation`
- `ingredientsText` (nullable)
- `nutritionFacts` (structured values with units and serving basis, nullable)
- `allergenText` (nullable)
- `ocrText` (optional; retain only if needed)
- `assessmentCategory`
- `assessmentReasons` (list of evidence-based reasons)
- `imageReference` (optional; do not store the image by default unless the user opts in)
- `createdAt`

Treat this as an initial model; refine it after selecting the backend and defining data-retention rules.

## 7. Non-Functional Requirements

- **Privacy:** collect the minimum data required, explain what is stored, and provide deletion options.
- **Security:** use authenticated and authorized requests, secure transport, least-privilege cloud permissions, and per-user access controls so users cannot read each other's records.
- **Reliability:** handle partial OCR, missing data, connectivity problems, and backend failures without losing the user's ability to correct fields manually.
- **Performance:** show progress during image processing and avoid blocking the UI unnecessarily.
- **Scalability:** use a cloud design that can scale beyond a single demo user without requiring a permanently running server, if feasible.
- **Cost control:** prefer free-tier or low-cost services and monitor cloud usage. Clearly identify any potentially chargeable components.
- **Maintainability:** separate UI, data models, services, OCR, date parsing, assessment logic, and backend integration.
- **Testability:** test date parsing, OCR field mapping, personalization rules, permissions, and error states.
- **Transparency:** show the evidence used for each result and flag uncertain or missing information.

## 8. Safety, Accuracy, and Trust Rules

- Never fabricate an expiry date, ingredient, nutrition value, allergen, or product identity.
- OCR is fallible. Users must be able to verify important extracted fields.
- If a date format is ambiguous, ask for confirmation.
- If an expiry/use-by date appears to have passed, clearly warn the user not to rely on the app alone to determine safety. Do not guarantee food is safe or unsafe from the date alone.
- Best-before wording generally concerns quality, while use-by/expiry wording may have different safety or regulatory meanings depending on the product and jurisdiction. Preserve the exact wording detected and avoid overgeneralizing.
- For serious allergies, tell the user to verify the physical package and manufacturer information; OCR should not be treated as a guarantee that an allergen is absent.
- The assessment must be based on extracted label facts and the user's declared preferences/goals. Explain missing data and uncertainty.
- This is an informational wellness tool, not a medical diagnostic system.

## 9. MVP Scope and Priorities

Build in this order unless the project team changes the priority:

1. Flutter project setup and basic navigation.
2. User profile and personalization settings.
3. Camera/gallery capture for a package's back label.
4. OCR and a review/edit screen.
5. Expiry/best-before extraction, date parsing, and manual correction.
6. Ingredient/nutrition/allergen extraction where possible.
7. Rule-based personalized assessment with evidence-based explanations.
8. Cloud authentication, database persistence, and scan history.
9. Cloud logging/monitoring and a clear demonstration of the cloud architecture.
10. Testing, error handling, UI polish, and project documentation.

For a reliable MVP, use transparent rule-based assessment first. An LLM or external AI service is optional, not required. If added, it must not invent label values and should receive only the minimum necessary data.

## 10. Expected Screens

- Splash / onboarding
- Sign up / sign in
- Home dashboard
- Personal profile and goals
- Scan instructions / camera capture
- OCR review and correction screen
- Product result screen: date status, ingredients/nutrition, personalized assessment, reasons, and uncertainty notes
- Scan history and saved scan detail
- Settings, privacy, and account/data deletion

## 11. Acceptance Criteria

The MVP can be considered successful when:
- A user can create an account or use the agreed demo authentication flow.
- A user can enter and edit personalization preferences.
- A user can capture or select a package-label image.
- The app extracts readable text and identifies a date when the date is legible, or clearly requests manual input when it cannot.
- The user can correct the date and extracted information before relying on the result.
- The app distinguishes expiry/use-by from best-before when the label makes this clear.
- The app shows an evidence-based, personalized assessment and explains the reasons in plain language.
- Missing or uncertain data is clearly marked; the app does not fabricate facts.
- Scans and profile data are stored in the chosen cloud backend with appropriate user-level access control.
- A user can view and delete saved scan history according to the implemented retention policy.
- The team can explain and demonstrate the cloud architecture, security choices, and cost considerations.

## 12. Guidance for the Next AI Agent

Start by turning this context into a concise implementation plan and proposed architecture. Identify decisions that still need confirmation, especially:
- Whether the cloud platform must be AWS or can be any provider
- Whether OCR should run on-device or in the cloud
- Which authentication/database services to use
- Whether scan images should be stored or processed and discarded
- The exact personalization settings and assessment rules
- Whether the app is for a prototype/demo or a production-ready release

Then implement incrementally. Explain setup commands and file changes clearly, keep code beginner-friendly, and provide run/test instructions for Flutter. Prioritize a working end-to-end MVP over adding unnecessary AI features. Keep cloud costs low, protect user data, and never commit secrets.
