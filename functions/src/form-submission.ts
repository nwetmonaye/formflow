import { onDocumentCreated } from "firebase-functions/v2/firestore";
import * as admin from "firebase-admin";

const db = admin.firestore();

interface FormSubmission {
  formId: string;
  data: Record<string, unknown>;
  submitterName?: string;
  submitterEmail?: string;
  submitterId?: string;
}

export const onFormSubmission = onDocumentCreated(
  "submissions/{submissionId}",
  async (event) => {
    const submission = event.data?.data() as FormSubmission;
    const submissionId = event.params.submissionId;

    if (!submission) {
      return;
    }

    try {
      // Update submission with metadata
      await event.data?.ref.update({
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
        status: "pending",
        submissionId: submissionId,
      });

      // Get form details
      const formDoc = await db.collection("forms").doc(submission.formId).get();
      if (!formDoc.exists) {
        console.error("Form not found:", submission.formId);
        return;
      }

      const formData = formDoc.data();

      // Create notification for form owner
      await db.collection("notifications").add({
        userId: formData?.createdBy,
        type: "new_submission",
        title: "New Form Submission",
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

      console.log("Form submission processed successfully:", submissionId);
    } catch (error) {
      console.error("Error processing form submission:", error);
    }
  }
);

async function sendSubmissionEmail(
  formData: Record<string, unknown>,
  submission: FormSubmission
) {
  // This would integrate with your email service
  // For now, we'll just log the intent
  console.log("Email notification would be sent for submission:", {
    formTitle: formData.title,
    formOwner: formData.createdBy,
    submissionData: submission.data,
  });
}
