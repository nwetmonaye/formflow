# FormFlow Email Setup Guide

## Overview

FormFlow now includes comprehensive email notifications for:
- Form owners when they receive submissions
- External users when their submissions are approved/rejected
- Form publication confirmations

## Email Service Configuration

### Option 1: Resend (Recommended for Production)

Resend is a modern email service with excellent deliverability and developer experience.

1. Sign up at [resend.com](https://resend.com)
2. Get your API key from the dashboard
3. Set environment variables in Firebase Functions:

```bash
firebase functions:config:set resend.api_key="your-api-key"
firebase functions:config:set email.from="noreply@yourdomain.com"
```

### Option 2: Gmail (Development/Testing)

For development and testing, you can use Gmail:

1. Enable 2-factor authentication on your Gmail account
2. Generate an App Password
3. Set environment variables:

```bash
firebase functions:config:set gmail.user="your-email@gmail.com"
firebase functions:config:set gmail.password="your-app-password"
firebase functions:config:set email.from="your-email@gmail.com"
```

## New Features Implemented

### 1. Email Field in Form Header

- Forms now include an email field for external users
- This email is required and validated
- Form owners receive notifications at this email address

### 2. Enhanced Submission Data Structure

- Submissions now store both question labels and answers
- Backward compatibility with old submissions (null safety)
- Structured data display in submission details

### 3. Email Notifications

#### For Form Owners:
- Receive emails when new submissions arrive
- Email includes submitter details and form responses
- Professional HTML email templates

#### For External Users:
- Receive approval/rejection emails
- Includes form title and decision details
- Optional comments from reviewers

### 4. Email Templates

All emails use professional HTML templates with:
- Responsive design
- Branded headers
- Clear information hierarchy
- Professional styling

## Environment Variables

Set these in your Firebase Functions configuration:

```bash
# For Resend
firebase functions:config:set resend.api_key="your-api-key"
firebase functions:config:set email.from="noreply@yourdomain.com"

# For Gmail
firebase functions:config:set gmail.user="your-email@gmail.com"
firebase functions:config:set gmail.password="your-app-password"
firebase functions:config:set email.from="your-email@gmail.com"
```

## Deployment

1. Install dependencies:
```bash
cd functions
npm install
```

2. Build the functions:
```bash
npm run build
```

3. Deploy to Firebase:
```bash
firebase deploy --only functions
```

## Testing

1. Create a form with an email field
2. Submit the form as an external user
3. Check that the form owner receives a notification email
4. Approve/reject the submission
5. Verify the external user receives the decision email

## Troubleshooting

### Common Issues

1. **Emails not sending**: Check environment variables and API keys
2. **Authentication errors**: Verify Firebase Functions permissions
3. **Email delivery**: Check spam folders and email service logs

### Debug Mode

Enable debug logging in Firebase Functions:

```bash
firebase functions:log --only sendEmailFromApp
```

## Security Considerations

- Email addresses are validated before sending
- Rate limiting is implemented (max 10 instances)
- CORS is properly configured for web access
- All email operations are logged for audit purposes

## Support

For issues or questions:
1. Check Firebase Functions logs
2. Verify environment variable configuration
3. Test email service connectivity
4. Review email service documentation
