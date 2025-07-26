# Form Flow Cloud Functions

This directory contains Firebase Cloud Functions for the Form Flow project, providing backend services for form submission handling, approval workflows, email notifications, and data export.

## Features

- **Form Submission Processing**: Automatically processes new form submissions and creates notifications
- **Approval Workflows**: Handles form approval/rejection with email notifications
- **Email Notifications**: Sends email notifications using Nodemailer
- **Form Link Generation**: Creates shareable form links with access control
- **Data Export**: Exports form submissions to CSV format
- **Real-time Notifications**: Creates in-app notifications for users

## Setup Instructions

### Prerequisites

1. Install Node.js (version 18 or higher)
2. Install Firebase CLI: `npm install -g firebase-tools`
3. Login to Firebase: `firebase login`

### Installation

1. Navigate to the functions directory:
   ```bash
   cd functions
   ```

2. Install dependencies:
   ```bash
   npm install
   ```

3. Build the TypeScript code:
   ```bash
   npm run build
   ```

### Configuration

1. Set up Firebase configuration:
   ```bash
   firebase functions:config:set email.user="your-email@gmail.com"
   firebase functions:config:set email.password="your-app-password"
   firebase functions:config:set app.base_url="https://your-app.com"
   ```

2. For Gmail, you'll need to:
   - Enable 2-factor authentication
   - Generate an App Password
   - Use the App Password in the configuration

### Deployment

1. Deploy all functions:
   ```bash
   firebase deploy --only functions
   ```

2. Deploy specific functions:
   ```bash
   firebase deploy --only functions:onFormSubmission
   firebase deploy --only functions:onFormApproval
   firebase deploy --only functions:sendEmailNotification
   ```

## Function Details

### onFormSubmission
- **Trigger**: Firestore document creation in `submissions` collection
- **Purpose**: Processes new form submissions
- **Actions**:
  - Updates submission metadata
  - Creates notification for form owner
  - Sends email notification (if configured)

### onFormApproval
- **Trigger**: Firestore document update in `submissions` collection
- **Purpose**: Handles approval/rejection decisions
- **Actions**:
  - Updates submission with approval metadata
  - Creates notification for submitter
  - Sends email notification

### sendEmailNotification
- **Type**: Callable function
- **Purpose**: Sends email notifications
- **Features**:
  - Email templates for different scenarios
  - Email logging for tracking
  - Error handling and retry logic

### generateFormLink
- **Type**: Callable function
- **Purpose**: Creates shareable form links
- **Features**:
  - Unique link generation
  - Access control and expiration
  - Link analytics tracking

### validateFormAccess
- **Type**: Callable function
- **Purpose**: Validates form access via shareable links
- **Features**:
  - Link expiration checking
  - Access count tracking
  - Form data retrieval

### exportSubmissions
- **Type**: HTTP function
- **Purpose**: Exports form submissions
- **Features**:
  - CSV export format
  - Filtering options
  - Proper CSV escaping

## Database Schema

### Collections

#### forms
```typescript
{
  id: string;
  title: string;
  description: string;
  fields: FormField[];
  createdBy: string;
  createdAt: Timestamp;
  updatedAt: Timestamp;
  isActive: boolean;
  emailNotifications: boolean;
  shareLink?: string;
}
```

#### submissions
```typescript
{
  id: string;
  formId: string;
  data: Record<string, any>;
  submitterName: string;
  submitterEmail: string;
  submitterId?: string;
  status: 'pending' | 'approved' | 'rejected';
  createdAt: Timestamp;
  updatedAt?: Timestamp;
  approvedBy?: string;
  approvedAt?: Timestamp;
  comments?: string;
}
```

#### notifications
```typescript
{
  id: string;
  userId: string;
  type: 'new_submission' | 'submission_decision' | 'form_published';
  title: string;
  message: string;
  formId?: string;
  submissionId?: string;
  read: boolean;
  createdAt: Timestamp;
}
```

#### formLinks
```typescript
{
  id: string;
  formId: string;
  linkId: string;
  formLink: string;
  isPublic: boolean;
  createdBy: string;
  createdAt: Timestamp;
  expiresAt?: Timestamp;
  isActive: boolean;
  accessCount: number;
  submissionCount: number;
}
```

## Email Templates

The functions include pre-built email templates for:
- New form submissions
- Submission approval/rejection
- Form publication notifications

## Security Rules

Make sure to set up appropriate Firestore security rules:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Forms - users can only access their own forms
    match /forms/{formId} {
      allow read, write: if request.auth != null && request.auth.uid == resource.data.createdBy;
    }
    
    // Submissions - form owners can read all submissions for their forms
    match /submissions/{submissionId} {
      allow read, write: if request.auth != null && 
        (request.auth.uid == resource.data.submitterId || 
         request.auth.uid == get(/databases/$(database)/documents/forms/$(resource.data.formId)).data.createdBy);
    }
    
    // Notifications - users can only access their own notifications
    match /notifications/{notificationId} {
      allow read, write: if request.auth != null && request.auth.uid == resource.data.userId;
    }
  }
}
```

## Testing

1. Run functions locally:
   ```bash
   npm run serve
   ```

2. Test with Firebase Emulator:
   ```bash
   firebase emulators:start
   ```

## Monitoring

Monitor function performance and errors in the Firebase Console:
- Go to Functions > Logs
- Set up alerts for function failures
- Monitor execution times and memory usage

## Troubleshooting

### Common Issues

1. **Email not sending**: Check email configuration and app passwords
2. **Function timeouts**: Increase timeout limits for complex operations
3. **Memory issues**: Optimize function code and consider splitting large functions
4. **Permission errors**: Verify Firestore security rules and authentication

### Logs

View function logs:
```bash
firebase functions:log
```

## Support

For issues and questions:
1. Check the Firebase documentation
2. Review function logs in Firebase Console
3. Test functions locally with emulators 