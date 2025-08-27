import { onCall } from "firebase-functions/v2/https";
import * as admin from "firebase-admin";
import * as nodemailer from "nodemailer";

const db = admin.firestore();

// Email configuration - supports both Gmail and Resend
const getEmailConfig = () => {
    console.log('🔍 Environment check:');
    console.log('🔍 NODE_ENV:', process.env.NODE_ENV);
    console.log('🔍 FUNCTIONS_EMULATOR:', process.env.FUNCTIONS_EMULATOR);
    console.log('🔍 EMAIL_SERVICE:', process.env.EMAIL_SERVICE);
    console.log('🔍 EMAIL_USER:', process.env.EMAIL_USER ? '***SET***' : 'NOT SET');
    console.log('🔍 RESEND_API_KEY:', process.env.RESEND_API_KEY ? '***SET***' : 'NOT SET');

    // Check for environment variables first (production)
    if (process.env.EMAIL_SERVICE === 'gmail' && process.env.EMAIL_USER && process.env.EMAIL_PASSWORD) {
        console.log('🔍 Using environment variables for Gmail');
        return {
            service: 'gmail',
            user: process.env.EMAIL_USER,
            password: process.env.EMAIL_PASSWORD,
            fromEmail: process.env.FROM_EMAIL || process.env.EMAIL_USER
        };
    }

    if (process.env.RESEND_API_KEY) {
        console.log('🔍 Using environment variables for Resend');
        return {
            service: 'resend',
            apiKey: process.env.RESEND_API_KEY,
            fromEmail: process.env.FROM_EMAIL || 'noreply@formflow.com'
        };
    }

    // Check if we're running in production (not in emulator)
    if (process.env.FUNCTIONS_EMULATOR !== 'true') {
        console.error('❌ No email configuration found in production!');
        console.error('❌ Please set environment variables for production:');
        console.error('❌ EMAIL_SERVICE=gmail');
        console.error('❌ EMAIL_USER=your-email@gmail.com');
        console.error('❌ EMAIL_PASSWORD=your-app-password');
        console.error('❌ Or use Resend API: RESEND_API_KEY=your-key');

        // For now, use hardcoded production values to get emails working
        console.log('🔍 Using hardcoded production Gmail config as fallback');
        return {
            service: 'gmail',
            user: 'nwetmonaye12345@gmail.com',
            password: 'iiezzoujyxokxqbe',
            fromEmail: 'nwetmonaye12345@gmail.com'
        };
    }

    // Development fallback (for testing only - when FUNCTIONS_EMULATOR=true)
    console.log('🔍 Using development Gmail config for testing (emulator mode)');
    return {
        service: 'gmail',
        user: 'nwetmonaye12345@gmail.com',
        password: 'iiezzoujyxokxqbe',
        fromEmail: 'nwetmonaye12345@gmail.com'
    };
};

const emailConfig = getEmailConfig();

console.log('🔍 Email config loaded:');
console.log('🔍 Service:', emailConfig.service);
console.log('🔍 From Email:', emailConfig.fromEmail);

// Create appropriate transporter based on service
const createTransporter = () => {
    if (emailConfig.service === 'resend') {
        console.log('🔍 Creating Resend transporter');
        return nodemailer.createTransport({
            host: "smtp.resend.com",
            port: 587,
            secure: false,
            auth: {
                user: "resend",
                pass: emailConfig.apiKey,
            },
            tls: {
                rejectUnauthorized: false
            }
        });
    } else {
        console.log('🔍 Creating Gmail transporter');
        return nodemailer.createTransport({
            service: 'gmail',
            auth: {
                user: emailConfig.user,
                pass: emailConfig.password
            }
        });
    }
};

// Main function for sharing forms with cohorts
export const shareFormWithCohort = onCall(
    {
        maxInstances: 10,
        timeoutSeconds: 300, // 5 minutes
        memory: '256MiB',
        region: 'us-central1'
    },
    async (request) => {
        try {
            const { formId, cohortId, formTitle, formDescription, formLink } = request.data;

            console.log('🔍 shareFormWithCohort: Function called');
            console.log('🔍 shareFormWithCohort: Request data:', request.data);

            // Validate required fields
            if (!formId || !cohortId || !formTitle) {
                console.error('❌ Missing required fields:', { formId, cohortId, formTitle });
                throw new Error('Missing required fields: formId, cohortId, formTitle');
            }

            // Validate field types
            if (typeof formId !== 'string' || typeof cohortId !== 'string' || typeof formTitle !== 'string') {
                console.error('❌ Invalid field types:', {
                    formId: typeof formId,
                    cohortId: typeof cohortId,
                    formTitle: typeof formTitle
                });
                throw new Error('Invalid field types: formId, cohortId, and formTitle must be strings');
            }

            console.log('🔍 shareFormWithCohort: Field validation passed');

            // Get cohort data
            const cohortDoc = await db.collection('cohorts').doc(cohortId).get();
            if (!cohortDoc.exists) {
                console.error('❌ Cohort not found:', cohortId);
                throw new Error(`Cohort not found: ${cohortId}`);
            }

            const cohortData = cohortDoc.data()!;
            const recipients = cohortData.recipients || [];

            console.log('🔍 shareFormWithCohort: Cohort data retrieved');
            console.log('🔍 shareFormWithCohort: Cohort name:', cohortData.name);
            console.log('🔍 shareFormWithCohort: Recipients count:', recipients.length);

            if (recipients.length === 0) {
                console.log('🔍 Cohort has no recipients');
                return {
                    success: true,
                    message: 'Cohort has no recipients to share with',
                    recipientsCount: 0
                };
            }

            console.log('🔍 shareFormWithCohort: Recipients data:', recipients);

            // Create transporter
            const transporter = createTransporter();

            // Verify transporter connection
            try {
                await transporter.verify();
                console.log('🔍 Email transporter verified successfully');
            } catch (verifyError) {
                console.error('❌ Email transporter verification failed:', verifyError);
                const errorMessage = verifyError instanceof Error ? verifyError.message : 'Unknown verification error';
                throw new Error(`Email service not available: ${errorMessage}`);
            }

            // Send emails to all recipients
            let successCount = 0;
            let failureCount = 0;

            for (const recipient of recipients) {
                try {
                    const emailHtml = `
                        <!DOCTYPE html>
                        <html>
                        <head>
                            <meta charset="utf-8">
                            <title>FormFlow - New Form Shared</title>
                        </head>
                        <body style="font-family: Arial, sans-serif; line-height: 1.6; color: #333; max-width: 600px; margin: 0 auto; padding: 20px;">
                            <div style="background: linear-gradient(135deg, #356BF8 0%, #4F7973 100%); padding: 30px; border-radius: 12px; margin-bottom: 30px;">
                                <h1 style="color: white; margin: 0; font-size: 28px; text-align: center;">
                                    form<span style="background: white; width: 10px; height: 10px; border-radius: 50%; display: inline-block; margin-left: 8px;"></span>flow
                                </h1>
                            </div>
                            
                            <h2 style="color: #356BF8; margin-bottom: 20px;">Hello ${recipient.name}!</h2>
                            
                            <p style="font-size: 16px; margin-bottom: 20px;">
                                A new form has been shared with you via FormFlow.
                            </p>
                            
                            <div style="background: #f8f9fa; padding: 20px; border-radius: 8px; border-left: 4px solid #356BF8; margin-bottom: 30px;">
                                <h3 style="margin-top: 0; color: #333;">${formTitle}</h3>
                                <p style="margin-bottom: 20px; color: #666;">${formDescription || 'No description provided'}</p>
                                <a href="${formLink || `https://formflow.com/form/${formId}`}" style="background: #356BF8; color: white; padding: 12px 24px; text-decoration: none; border-radius: 6px; display: inline-block; font-weight: 500;">
                                    Fill Out Form
                                </a>
                            </div>
                            
                            <p style="font-size: 14px; color: #666; margin-bottom: 10px;">
                                If you have any questions, please contact the form creator.
                            </p>
                            
                            <hr style="border: none; border-top: 1px solid #eee; margin: 30px 0;">
                            <p style="text-align: center; color: #999; font-size: 12px;">
                                This email was sent from FormFlow. Please do not reply to this email.
                            </p>
                        </body>
                        </html>
                    `;

                    const mailOptions = {
                        from: emailConfig.fromEmail,
                        to: recipient.email,
                        subject: `FormFlow: New Form Shared - ${formTitle}`,
                        html: emailHtml,
                        headers: {
                            'X-FormFlow-Type': 'form_shared',
                            'X-FormFlow-Form': formTitle,
                            'X-FormFlow-Cohort': cohortData.name
                        }
                    };

                    console.log('🔍 Sending email to:', recipient.email);
                    const info = await transporter.sendMail(mailOptions);
                    console.log('✅ Email sent successfully to:', recipient.email);
                    successCount++;

                    // Log email to Firestore for tracking
                    try {
                        await db.collection('emailLogs').add({
                            to: recipient.email,
                            subject: mailOptions.subject,
                            type: 'form_shared',
                            formTitle: formTitle,
                            formId: formId,
                            cohortId: cohortId,
                            cohortName: cohortData.name,
                            recipientName: recipient.name,
                            sentAt: new Date(),
                            success: true,
                            service: emailConfig.service,
                            fromEmail: emailConfig.fromEmail,
                            messageId: info.messageId
                        });
                    } catch (logError) {
                        console.error('⚠️ Failed to log email to Firestore:', logError);
                    }

                } catch (emailError) {
                    console.error('❌ Failed to send email to:', recipient.email, emailError);
                    failureCount++;

                    // Log error to Firestore
                    try {
                        await db.collection('emailLogs').add({
                            to: recipient.email,
                            subject: `FormFlow: New Form Shared - ${formTitle}`,
                            type: 'form_shared',
                            formTitle: formTitle,
                            formId: formId,
                            cohortId: cohortId,
                            cohortName: cohortData.name,
                            recipientName: recipient.name,
                            error: emailError instanceof Error ? emailError.message : 'Unknown error',
                            failedAt: new Date(),
                            success: false
                        });
                    } catch (logError) {
                        console.warn('⚠️ Failed to log error to Firestore:', logError);
                    }
                }
            }

            console.log('✅ Form sharing completed. Success:', successCount, 'Failures:', failureCount);

            return {
                success: true,
                message: 'Form shared with cohort successfully',
                recipientsCount: recipients.length,
                successCount: successCount,
                failureCount: failureCount,
                cohortName: cohortData.name
            };

        } catch (error) {
            console.error('❌ shareFormWithCohort: Error occurred:', error);

            // Log error to Firestore
            try {
                const errorMessage = error instanceof Error ? error.message : 'Unknown error';
                const errorStack = error instanceof Error ? error.stack : undefined;

                await db.collection('emailLogs').add({
                    type: 'form_shared',
                    error: errorMessage,
                    errorStack: errorStack,
                    failedAt: new Date(),
                    success: false
                });
            } catch (logError) {
                console.warn('⚠️ Failed to log error to Firestore:', logError);
            }

            const errorMessage = error instanceof Error ? error.message : 'Unknown error';
            throw new Error(`Failed to share form with cohort: ${errorMessage}`);
        }
    }
);
