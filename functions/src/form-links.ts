import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import { v4 as uuidv4 } from 'uuid';

const db = admin.firestore();

interface FormLinkData {
    formId: string;
    isPublic?: boolean;
    expiresAt?: string;
}

interface ValidateFormAccessData {
    linkId: string;
}

export const generateFormLink = functions.https.onCall(async (data: FormLinkData, context: functions.https.CallableContext) => {
    // Verify user is authenticated
    if (!context.auth) {
        throw new functions.https.HttpsError('unauthenticated', 'User must be authenticated');
    }

    const { formId, isPublic = false, expiresAt = null } = data;

    try {
        // Verify form exists and user has access
        const formDoc = await db.collection('forms').doc(formId).get();
        if (!formDoc.exists) {
            throw new functions.https.HttpsError('not-found', 'Form not found');
        }

        const formData = formDoc.data();
        if (formData?.createdBy !== context.auth.uid) {
            throw new functions.https.HttpsError('permission-denied', 'Access denied');
        }

        // Generate unique link ID
        const linkId = uuidv4();
        const baseUrl = functions.config().app?.base_url || 'https://your-app.com';
        const formLink = `${baseUrl}/form/${linkId}`;

        // Store link in database
        await db.collection('formLinks').doc(linkId).set({
            formId: formId,
            linkId: linkId,
            formLink: formLink,
            isPublic: isPublic,
            createdBy: context.auth.uid,
            createdAt: admin.firestore.FieldValue.serverTimestamp(),
            expiresAt: expiresAt ? new Date(expiresAt) : null,
            isActive: true,
            accessCount: 0,
            submissionCount: 0,
        });

        // Update form with link reference
        await db.collection('forms').doc(formId).update({
            shareLink: formLink,
            lastUpdated: admin.firestore.FieldValue.serverTimestamp(),
        });

        return {
            success: true,
            linkId: linkId,
            formLink: formLink,
            isPublic: isPublic,
        };
    } catch (error) {
        console.error('Error generating form link:', error);
        throw new functions.https.HttpsError('internal', 'Failed to generate form link');
    }
});

// Function to validate form access
export const validateFormAccess = functions.https.onCall(async (data: ValidateFormAccessData, context: functions.https.CallableContext) => {
    const { linkId } = data;

    try {
        const linkDoc = await db.collection('formLinks').doc(linkId).get();
        if (!linkDoc.exists) {
            throw new functions.https.HttpsError('not-found', 'Form link not found');
        }

        const linkData = linkDoc.data();

        // Check if link is active
        if (!linkData?.isActive) {
            throw new functions.https.HttpsError('permission-denied', 'Form link is inactive');
        }

        // Check if link has expired
        if (linkData?.expiresAt && new Date() > linkData.expiresAt.toDate()) {
            throw new functions.https.HttpsError('permission-denied', 'Form link has expired');
        }

        // Get form data
        const formDoc = await db.collection('forms').doc(linkData.formId).get();
        if (!formDoc.exists) {
            throw new functions.https.HttpsError('not-found', 'Form not found');
        }

        const formData = formDoc.data();

        // Update access count
        await linkDoc.ref.update({
            accessCount: admin.firestore.FieldValue.increment(1),
            lastAccessed: admin.firestore.FieldValue.serverTimestamp(),
        });

        return {
            success: true,
            formData: formData,
            linkData: linkData,
        };
    } catch (error) {
        console.error('Error validating form access:', error);
        throw new functions.https.HttpsError('internal', 'Failed to validate form access');
    }
}); 