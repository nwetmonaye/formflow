import { onCall } from "firebase-functions/v2/https";
import * as admin from "firebase-admin";
import * as nodemailer from "nodemailer";
import { emailTemplates } from "./email-notifications";
import * as functions from "firebase-functions";

const db = admin.firestore();

// Email configuration - using Resend (better than Gmail for production)
// For local development, use environment variables
// For production, use Firebase Functions config
const getEmailConfig = () => {
    // Check for local environment variables first
    const localApiKey = process.env.RESEND_API_KEY;
    const localFromEmail = process.env.FROM_EMAIL;

    if (localApiKey && localFromEmail) {
        console.log('Using local environment variables for email config');
        return {
            apiKey: localApiKey,
            fromEmail: localFromEmail
        };
    }

    // Fall back to Firebase Functions config
    console.log('Using Firebase Functions config for email config');
    return {
        apiKey: functions.config().resend?.api_key || "your-resend-api-key",
        fromEmail: functions.config().email?.from || "noreply@formflow.com"
    };
};

const emailConfig = getEmailConfig();

console.log('🔍 Email config loaded:');
console.log('🔍 API Key:', emailConfig.apiKey ? `${emailConfig.apiKey.substring(0, 10)}...` : 'undefined');
console.log('🔍 From Email:', emailConfig.fromEmail);

// Resend transporter (commented out for now since we're using Gmail for testing)
// const resendTransporter = nodemailer.createTransport({
//     host: "smtp.resend.com",
//     port: 587,
//     secure: false,
//     auth: {
//         user: "resend", // Resend uses "resend" as the username
//         pass: emailConfig.apiKey, // API key as password
//     },
//     tls: {
//         rejectUnauthorized: false
//     }
// });

// Fallback Gmail transporter for testing (uncomment if Resend fails)
const gmailTransporter = nodemailer.createTransport({
    service: 'gmail',
    auth: {
        user: 'nwetmonaye12345@gmail.com', // Use your Gmail
        pass: 'iiezzoujyxokxqbe'     // Replace with Gmail app password
    }
});

// Function to get the appropriate transporter
const getTransporter = () => {
    // For now, use Gmail for testing since Resend has issues
    console.log('🔍 Using Gmail transporter for testing');
    return gmailTransporter;

    // Uncomment this when Resend is working:
    // return resendTransporter;
};

interface EmailRequest {
    to: string;
    subject: string;
    html: string;
    type: string;
    formTitle?: string;
    submitterName?: string;
    submitterEmail?: string;
    status?: string;
    comments?: string;
    formOwnerEmail?: string; // <-- add this
}

export const sendEmailFromApp = onCall(
    { maxInstances: 10 },
    async (request) => {
        console.log('🔍 sendEmailFromApp: Function called');
        console.log('🔍 sendEmailFromApp: Request data:', request.data);
        console.log('🔍 sendEmailFromApp: Function type: onCall (callable)');

        try {
            const { to, subject, html, type, formTitle, submitterName, submitterEmail, status, comments, formOwnerEmail } = request.data as EmailRequest;

            // SAFETY: Prevent sending approve/reject to form owner
            if (type === 'submission_decision' && formOwnerEmail && to && to.toLowerCase() === formOwnerEmail.toLowerCase()) {
                console.log('🔍 sendEmailFromApp: Skipping approve/reject email to form owner:', to);
                return {
                    success: true,
                    message: 'Skipped sending approve/reject email to form owner',
                };
            }

            console.log('🔍 sendEmailFromApp: Processing email request');
            console.log('🔍 sendEmailFromApp: To:', to);
            console.log('🔍 sendEmailFromApp: Subject:', subject);
            console.log('🔍 sendEmailFromApp: Type:', type);
            console.log('🔍 sendEmailFromApp: Form title:', formTitle);
            console.log('🔍 sendEmailFromApp: Submitter name:', submitterName);
            console.log('🔍 sendEmailFromApp: Submitter email:', submitterEmail);

            // Test case for debugging
            if (type === 'test') {
                console.log('🔍 sendEmailFromApp: Test email requested');

                // Test the email configuration
                try {
                    console.log('🔍 sendEmailFromApp: Testing email configuration...');
                    console.log('🔍 sendEmailFromApp: Transporter configured successfully');
                    console.log('🔍 sendEmailFromApp: From email:', emailConfig.fromEmail);

                    // Verify the transporter
                    const activeTransporter = getTransporter();
                    await activeTransporter.verify();
                    console.log('🔍 sendEmailFromApp: Email transporter verified successfully');

                    return {
                        success: true,
                        messageId: 'test-message-id',
                        message: 'Test email function working correctly - transporter verified',
                        config: {
                            fromEmail: emailConfig.fromEmail,
                            apiKeyConfigured: !!emailConfig.apiKey,
                            transporter: 'Gmail (testing)'
                        }
                    };
                } catch (verifyError) {
                    console.error('🔍 sendEmailFromApp: Email transporter verification failed:', verifyError);
                    return {
                        success: false,
                        error: 'Email transporter verification failed',
                        details: verifyError instanceof Error ? verifyError.message : 'Unknown error'
                    };
                }
            }

            if (!to || !subject || !html) {
                console.log('🔍 sendEmailFromApp: Missing required fields');
                throw new Error('Missing required fields: to, subject, html');
            }

            let emailContent: { subject: string; html: string };

            // Generate email content based on type
            switch (type) {
                case 'new_submission':
                    if (!formTitle || !submitterName || !submitterEmail) {
                        console.log('🔍 sendEmailFromApp: Missing required fields for new submission email');
                        throw new Error('Missing required fields for new submission email');
                    }
                    emailContent = emailTemplates.newSubmission(formTitle, submitterName, submitterEmail, {});
                    break;

                case 'submission_decision':
                    if (!formTitle || !status || !submitterName) {
                        console.log('🔍 sendEmailFromApp: Missing required fields for submission decision email');
                        throw new Error('Missing required fields for submission decision email');
                    }
                    emailContent = emailTemplates.submissionDecision(formTitle, status, comments || '', submitterName);
                    break;

                case 'form_published':
                    if (!formTitle) {
                        console.log('🔍 sendEmailFromApp: Missing required fields for form published email');
                        throw new Error('Missing required fields for form published email');
                    }
                    emailContent = emailTemplates.formPublished(formTitle, '');
                    break;

                default:
                    // Use provided subject and html
                    emailContent = { subject, html };
            }

            console.log('🔍 sendEmailFromApp: Email content generated:', emailContent);

            const mailOptions = {
                from: emailConfig.fromEmail,
                to: to,
                subject: emailContent.subject,
                html: emailContent.html,
            };

            console.log('🔍 sendEmailFromApp: Mail options:', mailOptions);
            console.log('🔍 sendEmailFromApp: Attempting to send email...');
            console.log('🔍 sendEmailFromApp: Email type:', type);
            console.log('🔍 sendEmailFromApp: Recipient (to):', to);
            console.log('🔍 sendEmailFromApp: From email:', emailConfig.fromEmail);

            const activeTransporter = getTransporter();
            const result = await activeTransporter.sendMail(mailOptions);

            console.log('🔍 sendEmailFromApp: Email sent successfully:', result.messageId);

            // Log email sent
            try {
                await db.collection("emailLogs").add({
                    type: type,
                    to: to,
                    subject: emailContent.subject,
                    sentAt: new Date(),
                    success: true,
                    messageId: result.messageId,
                });
                console.log('🔍 sendEmailFromApp: Email logged to database');
            } catch (logError) {
                console.error('🔍 sendEmailFromApp: Error logging successful email:', logError);
                // Don't fail the email sending if logging fails
            }

            return {
                success: true,
                messageId: result.messageId,
                message: 'Email sent successfully'
            };
        } catch (error) {
            console.error("🔍 sendEmailFromApp: Error sending email:", error);

            // Log failed email
            try {
                await db.collection("emailLogs").add({
                    type: request.data?.type || 'unknown',
                    to: request.data?.to || 'unknown',
                    subject: request.data?.subject || 'unknown',
                    sentAt: new Date(),
                    success: false,
                    error: error instanceof Error ? error.message : "Unknown error",
                });
            } catch (logError) {
                console.error("🔍 sendEmailFromApp: Error logging failed email:", logError);
            }

            throw new Error(`Failed to send email: ${error instanceof Error ? error.message : "Unknown error"}`);
        }
    }
);
