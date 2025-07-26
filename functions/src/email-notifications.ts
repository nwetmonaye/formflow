import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import * as nodemailer from 'nodemailer';

const db = admin.firestore();

// Email configuration
const transporter = nodemailer.createTransporter({
    service: 'gmail', // or your preferred email service
    auth: {
        user: functions.config().email?.user || 'your-email@gmail.com',
        pass: functions.config().email?.password || 'your-app-password',
    },
});

export const sendEmailNotification = functions.https.onCall(async (data: any, context: functions.https.CallableContext) => {
    // Verify user is authenticated
    if (!context.auth) {
        throw new functions.https.HttpsError('unauthenticated', 'User must be authenticated');
    }

    const { to, subject, html, type } = data;

    try {
        const mailOptions = {
            from: functions.config().email?.user || 'noreply@formflow.com',
            to: to,
            subject: subject,
            html: html,
        };

        const result = await transporter.sendMail(mailOptions);

        // Log email sent
        await db.collection('emailLogs').add({
            type: type,
            to: to,
            subject: subject,
            sentAt: admin.firestore.FieldValue.serverTimestamp(),
            success: true,
            messageId: result.messageId,
        });

        return { success: true, messageId: result.messageId };
    } catch (error) {
        console.error('Error sending email:', error);

        // Log failed email
        await db.collection('emailLogs').add({
            type: type,
            to: to,
            subject: subject,
            sentAt: admin.firestore.FieldValue.serverTimestamp(),
            success: false,
            error: error instanceof Error ? error.message : 'Unknown error',
        });

        throw new functions.https.HttpsError('internal', 'Failed to send email');
    }
});

// Email templates
export const emailTemplates = {
    newSubmission: (formTitle: string, submitterName: string, submissionData: any) => ({
        subject: `New Submission: ${formTitle}`,
        html: `
      <h2>New Form Submission</h2>
      <p><strong>Form:</strong> ${formTitle}</p>
      <p><strong>Submitter:</strong> ${submitterName}</p>
      <p><strong>Submitted:</strong> ${new Date().toLocaleString()}</p>
      <hr>
      <h3>Submission Details:</h3>
      <pre>${JSON.stringify(submissionData, null, 2)}</pre>
    `,
    }),

    submissionDecision: (formTitle: string, status: string, comments: string) => ({
        subject: `Submission ${status === 'approved' ? 'Approved' : 'Rejected'}: ${formTitle}`,
        html: `
      <h2>Submission ${status === 'approved' ? 'Approved' : 'Rejected'}</h2>
      <p><strong>Form:</strong> ${formTitle}</p>
      <p><strong>Status:</strong> ${status}</p>
      ${comments ? `<p><strong>Comments:</strong> ${comments}</p>` : ''}
      <p><strong>Decision Date:</strong> ${new Date().toLocaleString()}</p>
    `,
    }),

    formPublished: (formTitle: string, formLink: string) => ({
        subject: `Form Published: ${formTitle}`,
        html: `
      <h2>Form Published Successfully</h2>
      <p><strong>Form:</strong> ${formTitle}</p>
      <p><strong>Share Link:</strong> <a href="${formLink}">${formLink}</a></p>
      <p><strong>Published:</strong> ${new Date().toLocaleString()}</p>
    `,
    }),
}; 