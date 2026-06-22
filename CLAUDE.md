# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Is

Packlight is an invite-only community garage sale platform. The core feature is an AI-assisted listing pipeline: photos dropped into a watched folder (local, SMB, or Google Drive) are auto-scanned, then sent to an LLM which generates the item title, description, and price. Listings appear in a private community feed where members can comment and subscribe to updates.

## Commands

```bash
# Development (run in separate terminals)
bin/rails server
bin/rails tailwindcss:watch

# Tests
bin/rails test                          # all tests
bin/rails test test/models/item_test.rb # single file
bin/rails test test/models/item_test.rb:15 # single test by line

# Database
bin/rails db:migrate
bin/rails db:rollback
bin/rails db:drop db:create db:migrate  # full reset

# Console
bin/rails console
```

## Architecture

### AI Listing Pipeline

The ingestion flow is: **file source → ScannerService → ProcessItemJob → Gemini API → Item record**.

1. Admin triggers a scan from `/admin/items` (POST `/admin/items/scan`), specifying a `file_source_type` (`local`, `smb`, or `google_drive`).
2. `ScannerService` ([app/services/scanner_service.rb](app/services/scanner_service.rb)) instantiates the appropriate `FileSourceAdapters::*Adapter` and calls `scan_items`, which returns an array of hashes (`folder_name`, `file_folder_path`, `photos`).
3. `ScannerService#create_or_update_item` upserts `Item` and `Photo` records. Any new or changed items are enqueued as `ProcessItemJob`.
4. `ProcessItemJob` ([app/jobs/process_item_job.rb](app/jobs/process_item_job.rb)) sends all photos for an item to Gemini 2.5 Flash Lite (via Vertex AI) along with the prompt in `script/TestPrompt`. The response is a JSON object; the job parses it and writes `name`, `description`, `price`, and `status` back to the `Item`.

The AI prompt lives at `script/TestPrompt` — edit it there to change what Gemini returns. The expected JSON schema is: `title`, `category`, `condition`, `description`, `price_cad`, `price_confidence`, `price_reasoning`, `tags`, `flags`.

### File Source Adapters

All adapters live in `app/services/file_source_adapters/` and share the same contract: `scan_items` returns `Array<Hash>`. Add new sources by implementing this interface and registering in `ScannerService::VALID_FILE_SOURCES`.

- `LocalDirectoryAdapter` — scans a local path; images >2 MB are compressed via MiniMagick before storing.
- `SmbAdapter` — SMB/CIFS file share (currently disabled in `create_adapter`, redirects to local).
- `GoogleDriveAdapter` — authenticates via per-user OAuth2 tokens stored on `User`; scans a target folder ID.

### Photo Storage

Photos are stored as raw binary blobs (`image_data bytea`) directly in the `photos` table — not in Active Storage. `GeminiImageProcessor` validates MIME type before ingestion. The `thumbnail` column on `items` is also a binary blob.

### Background Jobs

Solid Queue is used for background processing (`bin/jobs` in production). `ProcessItemJob` is the only job with real workload. `NotifySubscribersJob` handles comment notification emails.

### Frontend

Hotwire/Turbo with Tailwind CSS — no SPA or build step needed beyond `tailwindcss:watch`. The admin edit modal uses a Turbo Frame (`modal`) and responds with `turbo_stream` to replace the item row in-place without a full page reload.

### Auth

Devise with `devise_invitable`. Users can only register via invite link. Google OAuth2 is also supported (used primarily to authorize Google Drive access). Admin status is a boolean `admin` column on `User`.

### Key Environment Variables

| Variable | Purpose |
|---|---|
| `FILE_SOURCE_PATH` | Local directory path for `local` scan type |
| `SMB_HOST` / `SMB_USERNAME` / `SMB_PASSWORD` | SMB credentials |
| `GOOGLE_CLIENT_ID` / `GOOGLE_CLIENT_SECRET` | Google OAuth2 |
| `GCP_PROJECT_ID` | Vertex AI project for Gemini |
| `GOOGLE_CREDENTIALS_JSON` | Service account JSON (overrides the file at repo root) |
| `ANTHROPIC_API_KEY` | Claude API (wired up, not yet used in the pipeline) |
| `SENDGRID_API_KEY` | Transactional email |

The file `gen-lang-client-0677189465-4e8a9ac5b341.json` at the repo root is the fallback Google service account key used by `ProcessItemJob` when `GOOGLE_CREDENTIALS_JSON` is not set.
