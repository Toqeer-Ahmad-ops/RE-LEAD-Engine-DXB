# 📱🏙️ RE-LEAD-Engine-DXB-Prod – Enterprise Dubai Real Estate WhatsApp Lead Engine

![n8n](https://img.shields.io/badge/n8n-2.39.8-FF6B6B) ![Gemini](https://img.shields.io/badge/Gemini-3.5_Flash-4285F4) ![Groq](https://img.shields.io/badge/Groq-Whisper_Large--v3-000) ![Supabase](https://img.shields.io/badge/Supabase-Postgres-3ECF8E) ![HubSpot](https://img.shields.io/badge/HubSpot-CRM-FF7A59) ![SLA](https://img.shields.io/badge/SLA-Monitor_Cron-00C853)

Production-grade WhatsApp RE-LEAD Engine — Voice + Text + Button Clicks → Bot Language Tags → Transcription → RAG → **Lead Intake, Qualification, 【entity-HubSpot¦canonical_name=HubSpot】 Sync, Owner Alert, Voice Reply & SLA Monitoring**

> Day 9/23 of 23-Day AI Sprint | SLA Monitor Cron Live | HubSpot Contact + Deal Automation | Voice Reply + Rename Voice | Paused/Spam Guard | 91.4% grounded carry-over from Day 8 | Audit Logging

---

## ✨ Features – Day 9 Upgrade (vs Day 8)

- ⏸️ **Pause & Spam Guard** – `Check If Paused` → `Is Lead Paused?` → `Parse Button` → `If-Skip Check?` → `Io_Language_Tags` → `Paused-Stop` + `Pattern & Filter Spam` – prevents duplicate processing on paused leads
- 🔘 **Button Click Router** – `Is Button Click?` branch for WhatsApp interactive buttons
- 🎙️ **Voice Pipeline** – `Is Voice?` → `Download Voice` → `Download Audio File` → `Transcribe` (Groq Whisper) → `Set Question` → `Normalize & Detect Language` – same as text path
- 🧠 **Intent Router v2** – `Route INFO vs LEAD` – INFO → RAG API | LEAD → Validation + HubSpot
- ✅ **Lead Validation & Persistence** – `Validate_Extraction` → `Find Existing Lead` (phone unique) → `Lead Exists?` → `Update Existing Lead` (merge-preserve) / `Create New Lead`
- 📊 **Deterministic Qualification** – `Is Qualified?` JS Node `bedrooms && location && budget_max>=1M` – not LLM hallucination
- 🔎 **【entity-HubSpot¦canonical_name=HubSpot】 CRM Sync – NEW Day 9** – `HubSpot-Search Contact by Phone` → `IF-Contact Exists?` → `Create or update a contact` → `Create a deal` → `Code-Owner Message` → `WhatsApp-Owner Alert with Buttons`
- 🗣️ **Voice Reply – NEW** – `Is Voice Input?` → `Voice Reply` → `Rename Voice` → `Whapi Send Voice` + `Send WhatsApp Reply`
- 🛡️ **Reliability** – `Check Idempotency` → `Already Processed?` → `Mark Processing Before Call RAG API` → `Call RAG API` → `Is Quota Error?` → `Fallback Reply` / `Format Professional Answer`
- ⏰ **SLA Monitor Cron – NEW** – `Schedule Trigger` → `Get Overdue Leads` (Supabase getAll:row) → `IF / Validation` → `Send Whapi Alert` – catches leads not contacted in SLA window
- 📊 **Full Observability** – `Mark Completed` + `Log Audit Success` / `Mark Failed` + `Log Audit Failed` / `Log Audit Duplicate` + `Respond to Webhook` → `Format_Ask_Missing`

---

## 🏗️ Architecture – Day 9

```mermaid
flowchart TD
    A[WhatsApp Webhook] --> B[Check If Paused]
    B --> C[Is Lead Paused?]
    C -->|Yes| D[Io_Language_Tags + Paused-Stop]
    C -->|No| E[Is Button Click?]
    E --> F[Pattern & Filter Spam]
    F --> G[Parse Button / Is Voice?]
    G -->|Voice| H[Download Voice + Audio + Transcribe]
    G -->|Text| I[Normalize WhatsApp + Is Text Message?]
    H --> I
    I --> J[Normalize & Detect Language]
    J --> K[Route INFO vs LEAD]
    K -->|INFO| L[Check Idempotency -> Call RAG API -> Is Quota Error? -> Format Answer]
    K -->|LEAD| M[Validate_Extraction -> Find Existing Lead -> Lead Exists?]
    M -->|Yes| N[Update Existing Lead]
    M -->|No| O[Create New Lead]
    N --> P[Format_Lead_Response -> Code Routing + Supabase Update]
    O --> P
    P --> Q[Is Qualified?]
    Q --> R[HubSpot Search Contact]
    R --> S[IF-Contact Exists? -> Create/Update Contact -> Create Deal]
    S --> T[Code Owner Message -> WhatsApp Owner Alert]
    L --> U[Is Voice Input? -> Voice Reply -> Rename Voice -> Whapi Send Voice -> Send Reply]
    T --> U
    U --> V[Mark Completed -> Log Audit Success/Duplicate + Respond to Webhook]

    W[SLA Monitor Cron] --> X[Schedule Trigger -> Get Overdue Leads -> IF Validation -> Send Whapi Alert]
```

