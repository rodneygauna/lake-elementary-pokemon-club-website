# Email Testing Configuration Guide for Lake Elementary Pokémon Club

## 1. FILE DELIVERY (Current - Recommended for Development)

Saves emails as files in tmp/mails/ directory

```ruby
config.action_mailer.delivery_method = :file
config.action_mailer.file_settings = { location: Rails.root.join('tmp', 'mails') }
```

### File Delivery Benefits

- ✅ No SMTP setup required
- ✅ Easy to inspect email content
- ✅ Files persist between restarts
- ✅ Perfect for debugging templates

### File Delivery Usage

- Check tmp/mails/ directory after triggering notifications
- Each email saved as a separate file
- View with: `cat tmp/mails/filename`

## 2. TEST DELIVERY (Good for Automated Testing)

Stores emails in memory array

```ruby
config.action_mailer.delivery_method = :test
```

### Test Delivery Benefits

- ✅ Fast for automated tests
- ✅ Access via ActionMailer::Base.deliveries
- ✅ Automatically cleared between tests

### Test Delivery Usage

```ruby
ActionMailer::Base.deliveries.clear  # Clear previous
# ... trigger email
ActionMailer::Base.deliveries.size   # Count emails
ActionMailer::Base.deliveries.last   # Get latest email
```

## 3. LETTER OPENER (Best for Visual Inspection)

Opens emails in browser automatically

Add to Gemfile (development group):

```ruby
gem 'letter_opener'
```

```ruby
config.action_mailer.delivery_method = :letter_opener
config.action_mailer.perform_deliveries = true
```

### Letter Opener Benefits

- ✅ Opens emails in browser automatically
- ✅ Perfect HTML rendering
- ✅ Great for design verification
- ✅ Shows email exactly as recipients see it

## 4. LOG DELIVERY (Minimal for Basic Verification)

Logs email details to Rails log

```ruby
config.action_mailer.delivery_method = :test
config.action_mailer.perform_deliveries = true
config.action_mailer.logger = Rails.logger
```

### Log Delivery Benefits

- ✅ No files created
- ✅ Quick verification in logs
- ✅ Good for CI/CD pipelines

## 5. SMTP with MAILTRAP (Production-like Testing)

Use Mailtrap.io for safe SMTP testing

```ruby
config.action_mailer.delivery_method = :smtp
config.action_mailer.smtp_settings = {
  user_name: ENV['MAILTRAP_USERNAME'],
  password: ENV['MAILTRAP_PASSWORD'],
  address: 'sandbox.smtp.mailtrap.io',
  domain: 'sandbox.smtp.mailtrap.io',
  port: 2525,
  authentication: :cram_md5
}
```

### SMTP Benefits

- ✅ Tests actual SMTP delivery
- ✅ Safe inbox (doesn't send to real emails)
- ✅ Web interface to view emails
- ✅ Tests full email delivery pipeline

## RECOMMENDATION FOR THIS PROJECT

- **DEVELOPMENT**: File delivery (current setup)
- **TESTING**: Test delivery with ActionMailer::Base.deliveries
- **VISUAL INSPECTION**: Letter opener gem
- **STAGING**: Mailtrap SMTP
- **PRODUCTION**: Real SMTP (Gmail, SendGrid, etc.)

## QUICK VERIFICATION COMMANDS

### Check current delivery method

```bash
rails runner "puts ActionMailer::Base.delivery_method"
```

### Test attendance notification

```bash
ruby script/test_file_delivery.rb
```

### View saved emails

```bash
ls -la tmp/mails/
cat tmp/mails/[email_file]
```

### Clear saved emails

```bash
rm tmp/mails/*
```
