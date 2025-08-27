/**
 * Import function triggers from their respective submodules:
 *
 * import {onCall} from "firebase-functions/v2/https";
 * import {onDocumentWritten} from "firebase-functions/v2/firestore";
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */

import * as admin from "firebase-admin";

// Initialize Firebase Admin
admin.initializeApp();

// Import all functions - adding back one by one
export { onFormApproval } from "./form-approval";
export { generateFormLink, validateFormAccess } from "./form-links";
export { onFormSubmission } from "./form-submission";
export { testFunction } from "./test-function";

// Enable email functionality
export { sendEmailHttp } from "./send-email";

// Export submissions functionality
export { exportSubmissions } from "./export-submissions";

// Share form with cohort functionality
export { shareFormWithCohort } from "./share-form-cohort";

// Start writing functions
// https://firebase.google.com/docs/functions/get-started

// Note: Global options are not supported in Firebase Functions v2
// Each function should be configured individually with its own options

// Global error handler for uncaught exceptions
process.on('uncaughtException', (error) => {
    console.error('Uncaught Exception:', error);
    // In production, you might want to send this to a logging service
});

process.on('unhandledRejection', (reason, promise) => {
    console.error('Unhandled Rejection at:', promise, 'reason:', reason);
    // In production, you might want to send this to a logging service
});
