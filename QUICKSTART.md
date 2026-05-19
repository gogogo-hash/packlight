# Packlight - Quick Start Guide

Your Rails application is now ready! Here's how to get it running.

## Prerequisites

✅ Ruby 3.4.9  
✅ PostgreSQL running  
✅ Gems installed (bundle install)  
✅ Databases created (rails db:create)  

## Environment Setup

1. Create a `.env` file in the project root:

```bash
cp .env.example .env
```

2. Update `.env` with your values:

```
# Database
DB_HOST=localhost
DB_USERNAME=postgres
DB_PASSWORD=postgres

# SMB File Server (configure for your setup)
SMB_HOST=\\server\items
SMB_USERNAME=your_username
SMB_PASSWORD=your_password

# Email (get from SendGrid)
SENDGRID_API_KEY=SG.xxxxxx
SENDGRID_USERNAME=apikey
MAIL_FROM=noreply@yourdomain.com

# Claude API
ANTHROPIC_API_KEY=sk-ant-xxxxxx

# Production (optional)
RAILS_HOST=packlight.yoursite.com
RAILS_PROTOCOL=https
```

## Running Locally

```bash
# Start the Rails server
bundle exec rails server

# In another terminal, start the Tailwind CSS watcher
bundle exec rails tailwindcss:watch

# Visit http://localhost:3000
```

## Creating Your First User

1. Create an admin user via Rails console:

```bash
bundle exec rails console

# In the console:
user = User.create!(
  email: "admin@packlight.local",
  password: "changeme123",
  admin: true,
  invitation_accepted_at: Time.current
)
exit
```

2. Visit http://localhost:3000 and log in with that user
3. Go to `/admin/items` to test the file scan

## Testing the LLM Integration

Once you have SMB configured:

1. Place some JPG files in folders on your SMB share:
   ```
   \\server\items\item1\photo1.jpg
   \\server\items\item1\photo2.jpg
   \\server\items\item2\photo1.jpg
   ```

2. Log in as admin and visit `/admin/items`
3. Click "Scan File Server Now"
4. This will:
   - Connect to your SMB share
   - Download photos for each folder
   - Create Item records
   - Queue ProcessItemJob for Claude API processing

## Email Testing (Development)

In development, emails are logged to the console by default. To see them:

```bash
# Watch the Rails console for email output
```

To test email delivery with SendGrid in development, add to `.env`:
```
SENDGRID_API_KEY=your_real_api_key
```

Then uncomment the SMTP settings in `config/environments/development.rb` and set `delivery_method = :smtp`.

## Database Migrations

```bash
# Run pending migrations
bundle exec rails db:migrate

# Rollback last migration
bundle exec rails db:rollback

# Reset database (⚠️ deletes data)
bundle exec rails db:drop db:create db:migrate
```

## Project Structure

```
packlight/
├── app/
│   ├── controllers/        # HTTP handlers
│   │   ├── admin/         # Admin panel controllers
│   │   ├── items_controller.rb
│   │   ├── comments_controller.rb
│   │   └── subscriptions_controller.rb
│   ├── models/            # Database models
│   ├── jobs/              # Background jobs
│   │   ├── process_item_job.rb      # Claude API processing
│   │   └── notify_subscribers_job.rb # Email notifications
│   ├── services/          # Business logic
│   │   └── smb_scanner_service.rb   # File server scanning
│   ├── mailers/           # Email templates
│   ├── views/             # HTML templates
│   │   ├── items/
│   │   ├── admin/items/
│   │   └── comment_mailer/
├── config/
│   ├── initializers/
│   │   ├── action_mailer.rb     # Email config
│   │   └── anthropic.rb         # Claude API config
│   ├── environments/
│   ├── routes.rb
│   └── database.yml
├── db/
│   ├── migrate/           # Database migrations
│   └── schema.rb
└── Gemfile
```

## Key Features

✅ **Invite-only authentication** - Users can only join via invite links  
✅ **Item gallery** - Browse items with photos  
✅ **Comments** - Users can comment on items  
✅ **Email subscriptions** - Users subscribe to item comment notifications  
✅ **Admin panel** - Trigger file server scans  
✅ **Claude AI** - Automatically generates item names, descriptions, and prices  

## Next Steps

1. Configure your SMB share credentials in `.env`
2. Set up SendGrid account and add API key
3. Get Anthropic API key at https://console.anthropic.com
4. Create your first admin user
5. Test the file scan with some sample images
6. Invite other users via email

## Troubleshooting

**"Connection refused" on database?**
```bash
# Make sure PostgreSQL is running
sudo service postgresql start
# Or via Docker:
docker run --name packlight-postgres -e POSTGRES_PASSWORD=postgres -p 5432:5432 -d postgres:16
```

**"bundle: command not found"?**
- Ensure Ruby 3.4.9 is active in WSL: `ruby --version`
- Check rbenv/asdf setup: `which ruby`

**Emails not sending?**
- Check `.env` for SENDGRID_API_KEY
- Check console for errors: `tail -f log/development.log`
- In development, emails are logged, not sent by default

**File scan not working?**
- Verify SMB_HOST is accessible from your machine
- Check SMB username/password
- Check logs: `bundle exec rails log` for errors

---

Questions? Check the plan file: `C:\Users\coryc\.claude\plans\i-m-going-to-be-delegated-sutherland.md`
