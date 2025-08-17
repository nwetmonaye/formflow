# Local Email Setup for Firebase Functions

## Step 1: Create Local Environment File

Create a `.env.local` file in the `functions` directory with the following content:

```bash
# Local development environment variables for Firebase Functions
# Copy this file to .env.local and update with your actual values

# Resend API Key (get from https://resend.com/api-keys)
RESEND_API_KEY=re_ax4Ekh5R_M7qwv4KHZfxEK4Rk3eXtPhKs

# Sender email address
FROM_EMAIL=nwetmonaye12345@gmail.com

# Firebase project ID
FIREBASE_PROJECT_ID=formflow-b0484
```

## Step 2: Install dotenv for local development

```bash
cd functions
npm install dotenv
```

## Step 3: Update package.json scripts

Add this to your `package.json` in the functions directory:

```json
{
  "scripts": {
    "serve": "firebase emulators:start --only functions",
    "build": "tsc",
    "build:watch": "tsc --watch",
    "dev": "npm run build:watch & firebase emulators:start --only functions"
  }
}
```

## Step 4: Test the email service locally

1. Start the Firebase emulator:
   ```bash
   cd functions
   npm run serve
   ```

2. Test the email function:
   ```bash
   curl -X POST http://localhost:5001/formflow-b0484/us-central1/sendEmailFromApp \
     -H "Content-Type: application/json" \
     -d '{
       "to": "test@example.com",
       "subject": "Test Email",
       "html": "<p>This is a test email</p>",
       "type": "test"
     }'
   ```

## Step 5: Verify email logs

Check the Firebase emulator console for email logs and any errors.

## Troubleshooting

### Common Issues:

1. **Email not sending**: Check if Resend API key is valid
2. **Authentication failed**: Verify the API key and email configuration
3. **Function not found**: Make sure the function is properly exported in index.ts

### Debug Steps:

1. Check the Firebase emulator console for errors
2. Verify the environment variables are loaded
3. Test the Resend API key separately
4. Check if the email function is properly deployed

## Production Deployment

When deploying to production, use Firebase Functions config:

```bash
firebase functions:config:set resend.api_key="your-resend-api-key"
firebase functions:config:set email.from="noreply@yourdomain.com"
```
