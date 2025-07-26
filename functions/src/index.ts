import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

// Initialize Firebase Admin
admin.initializeApp();

// Import function modules
export { onFormSubmission } from './form-submission';
export { onFormApproval } from './form-approval';
export { sendEmailNotification } from './email-notifications';
export { generateFormLink } from './form-links';
export { exportSubmissions } from './export-submissions'; 