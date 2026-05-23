
# 📦 Packlight

> An invite-only, community-based garage sale platform with an AI-assisted listing pipeline.

Drop a photo into a folder. The app generates the title, description, and price.
Listings go live in a private community feed. That's it.

Built with Ruby on Rails. Designed around a model-agnostic AI layer (Gemini, Claude, OpenAI).

---

## ✨ Why Packlight?

After years of accumulating "useful stuff," my garage became a storage dungeon.
The engineer's solution: spend two weeks building an app instead of three days cleaning.

The premise is simple — most people don't sell their unused stuff because **listing it is the friction**. Photos, prices, descriptions, platforms. Packlight removes all of that:

1. Drop a photo into watched cloud storage
2. AI generates a draft listing (title, description, price)
3. You approve, edit, or auto-publish to your invite-only community

The goal is to turn a weekend of work into a few minutes.

---

## 🛠 Tech Stack

| Layer | Choice | Notes |
|---|---|---|
| Framework | Ruby on Rails 7 | Chosen for velocity on solo build |
| Database | PostgreSQL | Standard Rails pairing |
| Auth | Devise | Email + password, invite-gated signup |
| Storage | Active Storage | Cloud-backed for ingestion pipeline |
| AI Layer | Gemini 2.5 Flash (primary), Claude + OpenAI (planned) | Model-agnostic provider interface |
| Frontend | Hotwire / Turbo / Stimulus | Rails-native, no SPA overhead |
| Deployment | TBD (likely Fly.io or Render) | Containerized via Docker |

---

## 🧠 AI Listing Pipeline

The core of Packlight is the AI listing generator. The architecture is intentionally **model-agnostic** — providers are swappable behind a common interface.

See Quickstart and Setup guides for technical implementation details
