import { onRequest } from "firebase-functions/v2/https";
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

// Main email function - now public HTTP endpoint
export const sendEmailHttp = onRequest(
    {
        maxInstances: 10,
        timeoutSeconds: 300, // 5 minutes
        memory: '256MiB',
        region: 'us-central1'
    },
    async (req, res) => {
        // Enable CORS
        res.set('Access-Control-Allow-Origin', '*');
        res.set('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
        res.set('Access-Control-Allow-Headers', 'Content-Type, Authorization');

        if (req.method === 'OPTIONS') {
            res.status(204).send('');
            return;
        }

        if (req.method !== 'POST') {
            res.status(405).json({
                error: 'Method not allowed. Use POST.',
                method: req.method
            });
            return;
        }

        try {
            const { to, subject, html, type, formTitle, submitterName, submitterEmail, status, comments, formOwnerEmail } = req.body;

            console.log('🔍 sendEmailFromApp: Function called');
            console.log('🔍 sendEmailFromApp: Request data:', req.body);
            console.log('🔍 sendEmailFromApp: Function type: onRequest (HTTP)');

            // Validate required fields
            if (!to || !subject || !html) {
                console.error('❌ Missing required email fields:', { to, subject, html });
                res.status(400).json({
                    error: 'Missing required email fields',
                    required: ['to', 'subject', 'html'],
                    received: { to, subject, html }
                });
                return;
            }

            // SAFETY: Prevent sending approve/reject to form owner
            if (type === 'submission_decision' && formOwnerEmail && to && to.toLowerCase() === formOwnerEmail.toLowerCase()) {
                console.log('🔍 sendEmailFromApp: Skipping approve/reject email to form owner:', to);
                res.status(200).json({
                    success: true,
                    message: 'Skipped sending approve/reject email to form owner',
                    skipped: true
                });
                return;
            }

            // Create transporter
            const transporter = createTransporter();

            // Verify transporter connection
            try {
                await transporter.verify();
                console.log('🔍 Email transporter verified successfully');
            } catch (verifyError) {
                console.error('❌ Email transporter verification failed:', verifyError);
                const errorMessage = verifyError instanceof Error ? verifyError.message : 'Unknown verification error';
                res.status(500).json({
                    error: 'Email service not available',
                    details: errorMessage
                });
                return;
            }

            // Prepare email options
            const mailOptions = {
                from: emailConfig.fromEmail,
                to: to,
                subject: subject,
                html: html,
                headers: {
                    'X-FormFlow-Type': type,
                    'X-FormFlow-Form': formTitle || 'Unknown'
                }
            };

            console.log('🔍 Sending email to:', to);
            console.log('🔍 Email subject:', subject);
            console.log('🔍 Email type:', type);

            // Send email
            const info = await transporter.sendMail(mailOptions);

            console.log('✅ Email sent successfully');
            console.log('🔍 Message ID:', info.messageId);
            console.log('🔍 Response:', info.response);

            // Log email to Firestore for tracking
            try {
                await db.collection('emailLogs').add({
                    to: to,
                    subject: subject,
                    type: type || 'unknown',
                    formTitle: formTitle || 'No Form Title',
                    submitterName: submitterName || 'Unknown',
                    submitterEmail: submitterEmail || 'No Email',
                    status: status || 'sent',
                    comments: comments || '',
                    sentAt: new Date(),
                    success: true,
                    service: emailConfig.service,
                    fromEmail: emailConfig.fromEmail
                });
                console.log('✅ Email logged to Firestore successfully');
            } catch (logError) {
                console.error('⚠️ Failed to log email to Firestore:', logError);
                // Don't fail the email send if logging fails
            }

            res.status(200).json({
                success: true,
                message: 'Email sent successfully',
                messageId: info.messageId,
                response: info.response
            });

        } catch (error) {
            console.error('❌ sendEmailFromApp: Error occurred:', error);

            // Log error to Firestore
            try {
                const errorMessage = error instanceof Error ? error.message : 'Unknown error';
                const errorStack = error instanceof Error ? error.stack : undefined;

                await db.collection('emailLogs').add({
                    to: req.body?.to || 'unknown',
                    subject: req.body?.subject || 'unknown',
                    type: req.body?.type || 'unknown',
                    error: errorMessage,
                    errorStack: errorStack,
                    failedAt: new Date(),
                    success: false
                });
            } catch (logError) {
                console.warn('⚠️ Failed to log error to Firestore:', logError);
            }

            const errorMessage = error instanceof Error ? error.message : 'Unknown error';
            res.status(500).json({
                error: 'Failed to send email',
                details: errorMessage
            });
        }
    }
);
