import { onDocumentUpdated } from "firebase-functions/v2/firestore";
import * as admin from "firebase-admin";

const db = admin.firestore();

interface FormSubmission {
  formId: string;
  status: string;
  submitterEmail?: string;
  submitterName?: string;
  submitterId?: string;
  approvedBy?: string;
  comments?: string;
}

export const onFormApproval = onDocumentUpdated(
  "submissions/{submissionId}",
  async (event) => {
    const before = event.data?.before.data() as FormSubmission;
    const after = event.data?.after.data() as FormSubmission;
    const submissionId = event.params.submissionId;

    if (!before || !after) {
      return;
    }

    // Only process if status changed
    if (before.status === after.status) {
      return;
    }

    try {
      // Get form details
      const formDoc = await db.collection("forms").doc(after.formId).get();
      if (!formDoc.exists) {
        console.error("Form not found:", after.formId);
        return;
      }

      const formData = formDoc.data();

      // Update submission with approval metadata
      await event.data?.after.ref.update({
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        approvedBy: after.approvedBy,
        approvedAt: after.status === "approved" || after.status === "rejected" ?
          admin.firestore.FieldValue.serverTimestamp() :
          null,
        comments: after.comments || "",
      });

      // Create notification for submitter
      if (after.submitterEmail) {
        await db.collection("notifications").add({
          userId: after.submitterId,
          type: "submission_decision",
          title: `Submission ${after.status === "approved" ? "Approved" : "Rejected"}`,
          message: `Your submission for "${formData?.title}" has been ${after.status}.`,
          submissionId: submissionId,
          formId: after.formId,
          status: after.status,
          read: false,
          createdAt: admin.firestore.FieldValue.serverTimestamp(),
        });
      }

      // Log approval for email processing (will be handled by separate email function)
      if (formData?.emailNotifications && after.submitterEmail) {
        console.log("Approval email needed:", {
          to: after.submitterEmail,
          formTitle: formData.title,
          status: after.status,
          submitterName: after.submitterName,
          comments: after.comments
        });
      }

      console.log("Form approval processed successfully:", submissionId);
    } catch (error) {
      console.error("Error processing form approval:", error);
    }
  }
);
