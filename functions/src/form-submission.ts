import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

const db = admin.firestore();

export const onFormSubmission = functions.firestore
    .document('submissions/{submissionId}')
    .onCreate(async (snap: functions.Change<functions.firestore.DocumentSnapshot>, context: functions.EventContext) => {
        const submission = snap.data();
        const submissionId = context.params.submissionId;

        try {
            // Update submission with metadata
            await snap.ref.update({
                createdAt: admin.firestore.FieldValue.serverTimestamp(),
                status: 'pending',
                submissionId: submissionId,
            });

            // Get form details
            const formDoc = await db.collection('forms').doc(submission.formId).get();
            if (!formDoc.exists) {
                console.error('Form not found:', submission.formId);
                return;
            }

            const formData = formDoc.data();

            // Create notification for form owner
            await db.collection('notifications').add({
                userId: formData?.createdBy,
                type: 'new_submission',
                title: 'New Form Submission',
                message: `You have a new submission for "${formData?.title}"`,
                submissionId: submissionId,
                formId: submission.formId,
                read: false,
                createdAt: admin.firestore.FieldValue.serverTimestamp(),
            });

            // Send email notification if configured
            if (formData?.emailNotifications) {
                await sendSubmissionEmail(formData, submission);
            }

            console.log('Form submission processed successfully:', submissionId);
        } catch (error) {
            console.error('Error processing form submission:', error);
        }
    });

async function sendSubmissionEmail(formData: any, submission: any) {
    // This would integrate with your email service
    // For now, we'll just log the intent
    console.log('Email notification would be sent for submission:', {
        formTitle: formData.title,
        formOwner: formData.createdBy,
        submissionData: submission.data,
    });
} 