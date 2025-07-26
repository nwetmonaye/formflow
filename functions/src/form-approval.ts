import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

const db = admin.firestore();

export const onFormApproval = functions.firestore
    .document('submissions/{submissionId}')
    .onUpdate(async (change: functions.Change<functions.firestore.DocumentSnapshot>, context: functions.EventContext) => {
        const before = change.before.data();
        const after = change.after.data();
        const submissionId = context.params.submissionId;

        // Only process if status changed
        if (before.status === after.status) {
            return;
        }

        try {
            // Get form details
            const formDoc = await db.collection('forms').doc(after.formId).get();
            if (!formDoc.exists) {
                console.error('Form not found:', after.formId);
                return;
            }

            const formData = formDoc.data();

            // Update submission with approval metadata
            await change.after.ref.update({
                updatedAt: admin.firestore.FieldValue.serverTimestamp(),
                approvedBy: after.approvedBy,
                approvedAt: after.status === 'approved' || after.status === 'rejected'
                    ? admin.firestore.FieldValue.serverTimestamp()
                    : null,
                comments: after.comments || '',
            });

            // Create notification for submitter
            if (after.submitterEmail) {
                await db.collection('notifications').add({
                    userId: after.submitterId,
                    type: 'submission_decision',
                    title: `Submission ${after.status === 'approved' ? 'Approved' : 'Rejected'}`,
                    message: `Your submission for "${formData?.title}" has been ${after.status}.`,
                    submissionId: submissionId,
                    formId: after.formId,
                    status: after.status,
                    read: false,
                    createdAt: admin.firestore.FieldValue.serverTimestamp(),
                });
            }

            // Send email notification
            if (formData?.emailNotifications && after.submitterEmail) {
                await sendApprovalEmail(formData, after);
            }

            console.log('Form approval processed successfully:', submissionId);
        } catch (error) {
            console.error('Error processing form approval:', error);
        }
    });

async function sendApprovalEmail(formData: any, submission: any) {
    console.log('Approval email would be sent:', {
        formTitle: formData.title,
        submitterEmail: submission.submitterEmail,
        status: submission.status,
        comments: submission.comments,
    });
} 