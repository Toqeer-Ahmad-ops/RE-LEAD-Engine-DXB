# REVISED 7-STAGE TRACKER + REAL TIME SCHEDULE – Today 12 Oct 2026 GST (Dubai)

> Project: **RE-LEAD-Engine-DXB-Prod** | n8n v2.42.7 (latest) | Model: `gemini-3.5-flash-lite` | Workflow ID: `mr5YkOdb77HzM1Yb`

## Objective
Ship Day 9: 【entity-HubSpot¦canonical_name=HubSpot】 Primary Sync + Human Takeover + Observability with outbox pattern + 6 tests. Portfolio-ready.

---

| Stage | Time GST | What | Implementation Details | Evidence |
| :--- | :--- | :--- | :--- | :--- |
| **S1** | 09:15-10:30 | **Schema + Mapper Contract** (corrected to 3.5 Flash, outbox pattern) | `hubspot_outbox` (pending/processing/done/failed), `bot_pause_flags` (phone PK, paused_until +2h), `leads` add cols: hubspot_contact_id, hubspot_deal_id, agent_assigned, routing_reason, idempotency_key. Mapper: `supabase/mapper.json` v=day9-revised-gemini-3.5-flash-lite-outbox | SQL success screenshot + `mapper.json` screenshot + Table Editor RLS enabled |
| **S2** | 10:45-12:30 | **【entity-HubSpot¦canonical_name=HubSpot】 Primary Sync + Idempotency** | n8n: Supabase trigger → mapper → 【entity-HubSpot¦canonical_name=HubSpot】 find-or-create contact by phone → create deal → store IDs back to `leads` + `hubspot_outbox`. Idempotency key = phone_correlation_id. Retry handling: 429 exponential backoff (1s,2s,4s), 401 fail → alert | 【entity-HubSpot¦canonical_name=HubSpot】 contact + deal ID proof screenshot |
| Lunch/Dhuhr | 12:30-13:30 | BREAK | | |
| **S3** | 13:30-14:30 | **Routing + Agent Allocation** | Deterministic rule: HIGH (budget > 1M or intent = investor) → `agent_palm`, STANDARD AR (language=ar) → `agent_ar`, else round-robin. Save `agent_assigned` + `routing_reason` in Supabase | Routing test table screenshot |
| Break | 14:30-14:45 | | | |
| **S4** | 14:45-15:45 | **Owner WhatsApp Alert (after persistence)** | After 【entity-HubSpot¦canonical_name=HubSpot】 success: Whapi alert EN/AR with QR buttons: TAKEOVER / MARK LOST only. Must be after `hubspot_outbox.status=done` | Owner WhatsApp screenshot with QR |
| Break Asr | 15:45-16:00 | | | |
| **S5** | 16:00-17:00 | **Human Takeover Pause 2h DB-backed** | At Webhook start: check `bot_pause_flags` → if `paused_until > now()` → stop bot, log. TAKEOVER action sets `paused_until = now()+2h` | Pause flag proof: `select * from bot_pause_flags` |
| Break | 17:00-17:15 | | | |
| **S6** | 17:15-18:15 | **SLA Monitor Cron** | Second workflow: Cron every 15m → `hubspot_outbox where status=pending and created_at < now()-15m` → escalation alert to owner | Cron execution proof |
| Dinner/Maghrib | 18:15-19:00 | BREAK | | |
| **S7** | 19:00-21:00 | **Observability + 6 Tests + Portfolio** | 6 tests: 1) new lead 2) duplicate (idempotency) 3) Arabic 4) 429 retry 5) 401 fail 6) overdue SLA. Final: stitched 4K green nodes, README Stage 9, LinkedIn post | 10 screenshots 4K + README + LinkedIn link |

---

### S1 Completed – 12 Oct Evening
- [x] SQL: `hubspot_outbox` + `bot_pause_flags` created, RLS enabled, policies created
- [x] Mapper: `supabase/mapper.json` v=day9-revised-gemini-3.5-flash-lite-outbox
- [x] Model: `Message a model` → `models/gemini-3.5-flash-lite`
- [x] Repo: `Toqeer-Ahmad-ops/RE-LEAD-Engine-DXB` – `n8n/RE-LEAD-Engine-DXB-Prod.json` pushed
- [x] Evidence: Supabase screenshots

### Stack
- n8n Latest 2.42.7 + Agents (Preview)
- Supabase: Retail-SOP Project PRODUCTION
- 【entity-HubSpot¦canonical_name=HubSpot】, Whapi, Gemini 3.5 Flash Lite, Groq
- Outbox Pattern + Idempotency + DB-backed Pause

---
**Status: S1 DONE → Moving to S2**
