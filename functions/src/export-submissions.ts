import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import * as express from 'express';
import * as cors from 'cors';

const db = admin.firestore();
const app = express();

// Enable CORS
app.use(cors({ origin: true }));

export const exportSubmissions = functions.https.onRequest(app);

app.post('/export', async (req: express.Request, res: express.Response) => {
    try {
        const { formId, format = 'csv', filters = {} } = req.body;

        // Verify form exists
        const formDoc = await db.collection('forms').doc(formId).get();
        if (!formDoc.exists) {
            res.status(404).json({ error: 'Form not found' });
            return;
        }

        const formData = formDoc.data();

        // Build query for submissions
        let query = db.collection('submissions').where('formId', '==', formId);

        // Apply filters
        if (filters.status) {
            query = query.where('status', '==', filters.status);
        }

        if (filters.dateFrom) {
            query = query.where('createdAt', '>=', new Date(filters.dateFrom));
        }

        if (filters.dateTo) {
            query = query.where('createdAt', '<=', new Date(filters.dateTo));
        }

        const submissionsSnapshot = await query.get();
        const submissions = submissionsSnapshot.docs.map((doc: any) => ({
            id: doc.id,
            ...doc.data(),
        }));

        if (format === 'csv') {
            const csvData = generateCSV(formData, submissions);
            res.setHeader('Content-Type', 'text/csv');
            res.setHeader('Content-Disposition', `attachment; filename="${formData.title}_submissions.csv"`);
            res.send(csvData);
        } else {
            res.json({
                form: formData,
                submissions: submissions,
                count: submissions.length,
            });
        }
    } catch (error) {
        console.error('Error exporting submissions:', error);
        res.status(500).json({ error: 'Failed to export submissions' });
    }
});

function generateCSV(formData: any, submissions: any[]): string {
    if (submissions.length === 0) {
        return 'No submissions found';
    }

    // Get field headers from form structure
    const fieldHeaders = formData.fields?.map((field: any) => field.label) || [];

    // Standard headers
    const standardHeaders = [
        'Submission ID',
        'Submitter Name',
        'Submitter Email',
        'Status',
        'Submitted At',
        'Approved/Rejected At',
        'Comments',
    ];

    // Combine headers
    const headers = [...standardHeaders, ...fieldHeaders];

    // Generate CSV rows
    const rows = submissions.map(submission => {
        const standardData = [
            submission.submissionId || submission.id,
            submission.submitterName || '',
            submission.submitterEmail || '',
            submission.status || 'pending',
            submission.createdAt ? new Date(submission.createdAt.toDate()).toISOString() : '',
            submission.approvedAt ? new Date(submission.approvedAt.toDate()).toISOString() : '',
            submission.comments || '',
        ];

        // Get field values
        const fieldValues = formData.fields?.map((field: any) => {
            return submission.data?.[field.id] || '';
        }) || [];

        return [...standardData, ...fieldValues];
    });

    // Escape CSV values
    const escapeCSV = (value: any) => {
        if (value === null || value === undefined) return '';
        const stringValue = String(value);
        if (stringValue.includes(',') || stringValue.includes('"') || stringValue.includes('\n')) {
            return `"${stringValue.replace(/"/g, '""')}"`;
        }
        return stringValue;
    };

    // Build CSV content
    const csvContent = [
        headers.map(escapeCSV).join(','),
        ...rows.map(row => row.map(escapeCSV).join(','))
    ].join('\n');

    return csvContent;
} 