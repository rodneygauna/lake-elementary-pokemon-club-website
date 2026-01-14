# SendGrid API Key Setup for Kamal Deployment

## Problem

The Kamal deployment failed because the production environment is trying to read SendGrid credentials that weren't configured properly.

## Solution Applied

I've updated the application to use environment variables instead of Rails credentials for the SendGrid API key. This is more secure and deployment-friendly.

### Changes Made:

1. **Updated production.rb** - Changed from `Rails.application.credentials.sendgrid.api_key` to `ENV["SENDGRID_API_KEY"]`
2. **Updated deploy.yml** - Added `SENDGRID_API_KEY` to the secret environment variables
3. **Updated .kamal/secrets** - Added line to read SendGrid API key from `config/sendgrid-api-key.key`
4. **Created placeholder file** - `config/sendgrid-api-key.key` (gitignored)

## What You Need to Do

### 1. Get Your SendGrid API Key

1. Go to [https://sendgrid.com/](https://sendgrid.com/)
2. Sign up for a free account (100 emails/day)
3. Navigate to **Settings → API Keys**
4. Click **Create API Key**
5. Name it (e.g., "Pokemon Club Production")
6. Select **Mail Send** permissions (Full Access or Restricted Access with Mail Send)
7. Click **Create & View**
8. **IMPORTANT**: Copy the API key immediately - it starts with `SG.` and you can only see it once!

### 2. Add the API Key to Your Config File

```bash
# Replace YOUR_SENDGRID_API_KEY_HERE with your actual key
echo "SG.your_actual_api_key_here" > config/sendgrid-api-key.key
```

**Example:**

```bash
echo "SG.abc123xyz789..." > config/sendgrid-api-key.key
```

### 3. Deploy Again

```bash
kamal deploy
```

## Testing Locally

To test that everything works in production mode locally:

```bash
# Ensure you've added your SendGrid API key first
RAILS_ENV=production bin/rails runner "puts ENV['SENDGRID_API_KEY'] ? 'SendGrid configured' : 'Missing SendGrid key'"
```

## Security Notes

✅ The file `config/sendgrid-api-key.key` is already added to `.gitignore`
✅ The API key will only be passed to your production server via Kamal secrets
✅ Never commit API keys to version control

## Alternative: Use SendGrid from Environment Variable

If you prefer to set the SendGrid API key as a system environment variable instead:

```bash
# On your development machine, add to .kamal/secrets:
export SENDGRID_API_KEY="SG.your_key_here"
```

Then remove the line that reads from the file in `.kamal/secrets`.

## Troubleshooting

**Error: "ActiveSupport::MessageEncryptor::InvalidMessage"**

- This means the RAILS_MASTER_KEY doesn't match the encrypted credentials
- We've moved away from using credentials for SendGrid, so this should be resolved

**Error: "SENDGRID_API_KEY not set"**

- Make sure `config/sendgrid-api-key.key` contains your actual API key
- Verify the key starts with `SG.`
- Check that `.kamal/secrets` is properly configured

**Emails not sending**

- Verify your SendGrid API key has "Mail Send" permissions
- Check SendGrid dashboard for blocked sends
- Review Kamal logs: `kamal app logs`

## Next Steps After Deployment

1. Test email sending from production
2. Monitor SendGrid dashboard for delivery stats
3. Set up SendGrid domain authentication (optional, improves deliverability)
4. Configure sender reputation monitoring
