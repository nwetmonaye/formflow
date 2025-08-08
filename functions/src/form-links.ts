import { onCall } from "firebase-functions/v2/https";
import * as admin from "firebase-admin";
import { v4 as uuidv4 } from "uuid";

const db = admin.firestore();

interface FormLinkData {
  formId: string;
  isPublic?: boolean;
  expiresAt?: string;
}

interface ValidateFormAccessData {
  linkId: string;
}

export const generateFormLink = onCall<FormLinkData>(
  { maxInstances: 10 },
  async (request) => {
    // Verify user is authenticated
    if (!request.auth) {
      throw new Error("User must be authenticated");
    }

    const { formId, isPublic = false, expiresAt = null } = request.data;

    try {
      // Verify form exists and user has access
      const formDoc = await db.collection("forms").doc(formId).get();
      if (!formDoc.exists) {
        throw new Error("Form not found");
      }

      const formData = formDoc.data();
      if (formData?.createdBy !== request.auth.uid) {
        throw new Error("Access denied");
      }

      // Generate unique link ID
      const linkId = uuidv4();
      const baseUrl = process.env.BASE_URL || "https://your-app.com";
      const formLink = `${baseUrl}/form/${linkId}`;

      // Store link in database
      await db.collection("formLinks").doc(linkId).set({
        formId: formId,
        linkId: linkId,
        formLink: formLink,
        isPublic: isPublic,
        createdBy: request.auth.uid,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
        expiresAt: expiresAt ? new Date(expiresAt) : null,
        isActive: true,
        accessCount: 0,
        submissionCount: 0,
      });

      // Update form with link reference
      await db.collection("forms").doc(formId).update({
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
      console.error("Error generating form link:", error);
      throw new Error("Failed to generate form link");
    }
  }
);

// Function to validate form access
export const validateFormAccess = onCall<ValidateFormAccessData>(
  { maxInstances: 10 },
  async (request) => {
    const { linkId } = request.data;

    try {
      const linkDoc = await db.collection("formLinks").doc(linkId).get();
      if (!linkDoc.exists) {
        throw new Error("Form link not found");
      }

      const linkData = linkDoc.data();

      // Check if link is active
      if (!linkData?.isActive) {
        throw new Error("Form link is inactive");
      }

      // Check if link has expired
      if (linkData?.expiresAt && new Date() > linkData.expiresAt.toDate()) {
        throw new Error("Form link has expired");
      }

      // Get form data
      const formDoc = await db.collection("forms").doc(linkData.formId).get();
      if (!formDoc.exists) {
        throw new Error("Form not found");
      }

      const formData = formDoc.data();

      // Update access count
      await db.collection("formLinks").doc(linkId).update({
        accessCount: admin.firestore.FieldValue.increment(1),
        lastAccessed: admin.firestore.FieldValue.serverTimestamp(),
      });

      return {
        success: true,
        formData: formData,
        linkData: linkData,
      };
    } catch (error) {
      console.error("Error validating form access:", error);
      throw new Error("Failed to validate form access");
    }
  }
);
