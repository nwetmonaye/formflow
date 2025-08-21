# Notification Feature Documentation

## Overview
The notification feature provides real-time notifications for form submissions, approvals, and rejections. It integrates with Firebase Firestore to store and retrieve notifications in real-time.

## Features

### 1. Real-time Notifications
- Notifications are automatically created when forms are submitted
- Real-time updates using Firestore streams
- Unread notification count displayed in navigation

### 2. Notification Types
- **Form Submission**: When someone submits a form
- **Form Approved**: When a form is approved by an admin
- **Form Rejected**: When a form is rejected with optional reason

### 3. UI Components
- Notification screen with modern card-based design
- Unread indicators with colored borders
- Action buttons for form submissions (View, Approve, Reject)
- Mark all as read functionality
- Time-ago formatting (e.g., "2h ago", "1d ago")

## Implementation Details

### Models
- `NotificationModel`: Represents a notification with all necessary fields
- Factory methods for different notification types

### Firebase Service Methods
- `getNotificationsStream()`: Real-time stream of user notifications
- `getUnreadNotificationsCountStream()`: Stream of unread count
- `markNotificationAsRead()`: Mark individual notification as read
- `markAllNotificationsAsRead()`: Mark all notifications as read
- `createNotification()`: Create a new notification
- `createFormSubmissionNotification()`: Create submission notification
- `createFormStatusNotification()`: Create approval/rejection notification

### Database Structure
Notifications are stored in the `notifications` collection with the following structure:
```json
{
  "userId": "user_id",
  "type": "form_submission",
  "title": "New Form Submission",
  "message": "John Doe submitted a response to Contact Form",
  "formId": "form_id",
  "submissionId": "submission_id",
  "submitterName": "John Doe",
  "submitterEmail": "john@example.com",
  "createdAt": "timestamp",
  "isRead": false,
  "actionUrl": "optional_url",
  "metadata": {}
}
```

## Usage

### 1. Viewing Notifications
- Navigate to the Notifications screen from the sidebar
- Notifications are displayed in chronological order (newest first)
- Unread notifications have a blue border and indicator dot

### 2. Managing Notifications
- Tap a notification to mark it as read
- Use "Mark all as read" button to clear all unread notifications
- Action buttons appear for form submission notifications

### 3. Creating Test Notifications
- Use the floating action button (+) on the notification screen
- This creates a test notification for demonstration purposes

### 4. Automatic Notification Creation
- Form submissions automatically create notifications for form owners
- Notifications are created when forms are approved/rejected

## Integration Points

### Form Submission
When a form is submitted, a notification is automatically created for the form owner:
```dart
await FirebaseService.createFormSubmissionNotification(
  formId: formId,
  submissionId: submissionId,
  submitterName: submitterName,
  submitterEmail: submitterEmail,
  formTitle: formTitle,
  formOwnerId: formOwnerId,
);
```

### Navigation Integration
The notification count is displayed in the sidebar navigation:
```dart
StreamBuilder<int>(
  stream: FirebaseService.getUnreadNotificationsCountStream(),
  builder: (context, snapshot) {
    final unreadCount = snapshot.data ?? 0;
    return _buildNavItem(
      icon: Icons.notifications_outlined,
      title: 'Notifications',
      notificationCount: unreadCount > 0 ? unreadCount : null,
      // ... other properties
    );
  },
)
```

## Styling

The notification UI follows the existing design system:
- Uses `KStyle` constants for colors and typography
- Responsive design with proper spacing
- Card-based layout with shadows and borders
- Color-coded icons for different notification types

## Future Enhancements

1. **Push Notifications**: Integrate with Firebase Cloud Messaging
2. **Email Notifications**: Send email summaries of notifications
3. **Notification Preferences**: Allow users to customize notification types
4. **Bulk Actions**: Select and manage multiple notifications
5. **Search and Filter**: Search notifications by content or type
6. **Notification Templates**: Customizable notification messages

## Troubleshooting

### Common Issues
1. **Notifications not appearing**: Check if user is authenticated
2. **Real-time updates not working**: Verify Firestore connection
3. **Permission errors**: Ensure proper Firestore security rules

### Debug Information
- Check console logs for notification creation/deletion
- Verify Firestore collection structure
- Test with the floating action button for test notifications

## Security Rules

Ensure your Firestore security rules allow authenticated users to read/write their own notifications:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /notifications/{notificationId} {
      allow read, write: if request.auth != null && 
        request.auth.uid == resource.data.userId;
    }
  }
}
```
