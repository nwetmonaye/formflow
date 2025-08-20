# FormFlow Production Deployment Guide

This guide will walk you through deploying your FormFlow application to Firebase hosting with all necessary permissions and configurations for production use.

## Prerequisites

1. **Firebase CLI installed**: `npm install -g firebase-tools`
2. **Firebase account and project created**
3. **Flutter SDK installed and configured**
4. **Node.js 18+ installed**

## Step 1: Firebase Project Setup

### 1.1 Login to Firebase
```bash
firebase login
```

### 1.2 Initialize Firebase in your project (if not already done)
```bash
firebase init
```

Select the following services:
- ✅ Hosting
- ✅ Functions
- ✅ Firestore
- ✅ Storage (if you need file uploads)

### 1.3 Select your Firebase project
Choose your existing project or create a new one.

## Step 2: Configure Production Environment

### 2.1 Update Firebase Configuration
Your `firebase.json` is already configured with:
- Hosting configuration for Flutter web
- Security headers
- Proper routing for SPA
- Functions deployment settings

### 2.2 Environment Variables
Update `functions/production.config.js` with your actual values:

```javascript
// Replace these with your actual values
EMAIL_USER: 'your-production-email@gmail.com',
EMAIL_PASSWORD: 'your-app-specific-password',
RESEND_API_KEY: 'your-resend-api-key',
FIREBASE_PROJECT_ID: 'your-actual-project-id',
CORS_ORIGIN: 'https://your-domain.web.app',
STORAGE_BUCKET: 'your-project-id.appspot.com'
```

### 2.3 Email Service Configuration

#### Option A: Gmail (with App Password)
1. Enable 2-factor authentication on your Gmail account
2. Generate an App Password: Google Account → Security → App Passwords
3. Use the generated password in your config

#### Option B: Resend (Recommended for production)
1. Sign up at [resend.com](https://resend.com)
2. Get your API key
3. Update the config with your Resend API key

## Step 3: Security Rules Configuration

### 3.1 Firestore Rules
Your `firestore.rules` is configured with:
- ✅ User authentication required for most operations
- ✅ Users can only access their own data
- ✅ Public form submissions allowed
- ✅ Proper data isolation

### 3.2 Storage Rules (if using file uploads)
Create `storage.rules`:
```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /forms/{formId}/{allPaths=**} {
      allow read: if true; // Public read for form attachments
      allow write: if request.auth != null && 
        request.auth.uid == get(/databases/$(database)/documents/forms/$(formId)).data.createdBy;
    }
    
    match /submissions/{submissionId}/{allPaths=**} {
      allow read, write: if request.auth != null && 
        (request.auth.uid == resource.metadata.submitterId || 
         request.auth.uid == get(/databases/$(database)/documents/forms/$(resource.metadata.formId)).data.createdBy);
    }
  }
}
```

## Step 4: Build and Deploy

### 4.1 Build Flutter Web App
```bash
flutter build web --release
```

### 4.2 Install and Build Functions
```bash
cd functions
npm install
npm run build
cd ..
```

### 4.3 Deploy to Firebase
```bash
firebase deploy --only hosting,functions,firestore:rules,storage
```

Or use the provided script:
```bash
# Windows PowerShell
.\deploy-production.ps1

# Linux/Mac
chmod +x deploy-production.sh
./deploy-production.sh
```

## Step 5: Production Permissions & Settings

### 5.1 Firebase Console Configuration

#### Authentication
1. Go to Firebase Console → Authentication → Sign-in method
2. Enable Email/Password authentication
3. Add your domain to authorized domains
4. Configure password reset emails

#### Firestore
1. Go to Firebase Console → Firestore Database
2. Create database if not exists
3. Choose production mode (locked down)
4. Deploy security rules

#### Functions
1. Go to Firebase Console → Functions
2. Ensure all functions are deployed
3. Check function logs for errors
4. Set up monitoring and alerts

#### Storage (if using)
1. Go to Firebase Console → Storage
2. Create bucket if not exists
3. Deploy storage rules
4. Configure CORS if needed

### 5.2 Domain Configuration

#### Custom Domain (Optional)
1. Go to Firebase Console → Hosting
2. Add custom domain
3. Update DNS records
4. Update CORS origins in functions

#### SSL Certificate
- Firebase automatically provides SSL certificates
- Custom domains require domain verification

## Step 6: Testing Production Deployment

### 6.1 Test Authentication
- ✅ User registration
- ✅ User login
- ✅ Password reset
- ✅ Email verification

### 6.2 Test Core Functionality
- ✅ Form creation
- ✅ Form submission
- ✅ Form sharing
- ✅ Data export
- ✅ Email notifications

### 6.3 Test Security
- ✅ Unauthorized access blocked
- ✅ Data isolation working
- ✅ File upload restrictions
- ✅ Rate limiting

## Step 7: Monitoring and Maintenance

### 7.1 Firebase Console Monitoring
- **Functions**: Monitor execution times, errors, and costs
- **Firestore**: Monitor read/write operations
- **Authentication**: Monitor sign-in attempts
- **Hosting**: Monitor traffic and performance

### 7.2 Set Up Alerts
1. Go to Firebase Console → Functions → Logs
2. Set up error rate alerts
3. Monitor function execution costs
4. Set up Firestore usage alerts

### 7.3 Performance Optimization
- Monitor function cold starts
- Optimize Firestore queries
- Implement caching strategies
- Monitor bundle sizes

## Troubleshooting Common Issues

### Build Errors
```bash
# Clear Flutter build cache
flutter clean
flutter pub get
flutter build web --release
```

### Function Deployment Errors
```bash
# Check function logs
firebase functions:log

# Test functions locally
firebase emulators:start --only functions
```

### Permission Errors
- Verify Firestore rules are deployed
- Check function service account permissions
- Ensure proper authentication setup

### Email Issues
- Verify email service credentials
- Check function logs for email errors
- Test email templates locally

## Security Checklist

- ✅ Authentication enabled and configured
- ✅ Firestore security rules deployed
- ✅ Storage rules configured (if applicable)
- ✅ Functions properly secured
- ✅ CORS origins restricted
- ✅ Rate limiting implemented
- ✅ Input validation in place
- ✅ Error handling configured
- ✅ Logging and monitoring set up

## Cost Optimization

### Functions
- Set appropriate `maxInstances` limits
- Use `timeoutSeconds` to prevent long-running functions
- Monitor execution times and optimize

### Firestore
- Implement proper indexing
- Use pagination for large datasets
- Monitor read/write operations

### Storage
- Implement file size limits
- Use appropriate storage classes
- Clean up unused files

## Support and Resources

- [Firebase Documentation](https://firebase.google.com/docs)
- [Flutter Web Deployment](https://docs.flutter.dev/deployment/web)
- [Firebase Pricing](https://firebase.google.com/pricing)
- [Firebase Status](https://status.firebase.google.com)

---

**Important Notes:**
- Always test in staging environment first
- Keep your API keys and credentials secure
- Monitor your Firebase usage and costs
- Set up proper backup and disaster recovery
- Keep your dependencies updated
