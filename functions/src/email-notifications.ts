// Email templates
export const emailTemplates = {
  newSubmission: (
    formTitle: string,
    submitterName: string,
    submitterEmail: string,
    submissionData: Record<string, unknown>
  ) => ({
    subject: `New Submission: ${formTitle}`,
    html: `
      <!DOCTYPE html>
      <html>
      <head>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>New Form Submission</title>
        <style>
          body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }
          .container { max-width: 600px; margin: 0 auto; padding: 20px; }
          .header { background: #2563eb; color: white; padding: 20px; border-radius: 8px 8px 0 0; }
          .content { background: #f8fafc; padding: 20px; border-radius: 0 0 8px 8px; }
          .field { margin-bottom: 15px; }
          .label { font-weight: bold; color: #1e293b; }
          .value { color: #475569; }
          .footer { text-align: center; margin-top: 20px; color: #64748b; font-size: 14px; }
        </style>
      </head>
      <body>
        <div class="container">
          <div class="header">
            <h1>New Form Submission</h1>
          </div>
          <div class="content">
            <p>You have received a new submission for your form: <strong>${formTitle}</strong></p>
            
            <h3>Submitter Details:</h3>
            <div class="field">
              <span class="label">Name:</span>
              <span class="value">${submitterName}</span>
            </div>
            <div class="field">
              <span class="label">Email:</span>
              <span class="value">${submitterEmail}</span>
            </div>
            
            <h3>Submission Details:</h3>
            ${Object.entries(submissionData)
        .filter(([key]) => !['name', 'email'].includes(key))
        .map(([key, value]) => `
                <div class="field">
                  <span class="label">${key}:</span>
                  <span class="value">${value}</span>
                </div>
              `).join('')}
          </div>
          <div class="footer">
            <p>This email was sent automatically by FormFlow</p>
          </div>
        </div>
      </body>
      </html>
    `
  }),

  submissionDecision: (
    formTitle: string,
    status: string,
    comments: string,
    submitterName: string
  ) => ({
    subject: `Submission ${status}: ${formTitle}`,
    html: `
      <!DOCTYPE html>
      <html>
      <head>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Submission ${status}</title>
        <style>
          body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }
          .container { max-width: 600px; margin: 0 auto; padding: 20px; }
          .header { background: ${status === 'approved' ? '#10b981' : '#ef4444'}; color: white; padding: 20px; border-radius: 8px 8px 0 0; }
          .content { background: #f8fafc; padding: 20px; border-radius: 0 0 8px 8px; }
          .status { font-size: 24px; font-weight: bold; margin-bottom: 20px; }
          .footer { text-align: center; margin-top: 20px; color: #64748b; font-size: 14px; }
        </style>
      </head>
      <body>
        <div class="container">
          <div class="header">
            <h1>Submission ${status.charAt(0).toUpperCase() + status.slice(1)}</h1>
          </div>
          <div class="content">
            <div class="status">
              Your submission for <strong>${formTitle}</strong> has been <strong>${status}</strong>
            </div>
            
            ${comments ? `
              <h3>Comments:</h3>
              <p>${comments}</p>
            ` : ''}
            
            <p>Thank you for your submission!</p>
          </div>
          <div class="footer">
            <p>This email was sent automatically by FormFlow</p>
          </div>
        </div>
      </body>
      </html>
    `
  }),

  formPublished: (
    formTitle: string,
    shareLink: string
  ) => ({
    subject: `Form Published: ${formTitle}`,
    html: `
      <!DOCTYPE html>
      <html>
      <head>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Form Published</title>
        <style>
          body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }
          .container { max-width: 600px; margin: 0 auto; padding: 20px; }
          .header { background: #2563eb; color: white; padding: 20px; border-radius: 8px 8px 0 0; }
          .content { background: #f8fafc; padding: 20px; border-radius: 0 0 8px 8px; }
          .link { background: #e2e8f0; padding: 10px; border-radius: 4px; word-break: break-all; }
          .footer { text-align: center; margin-top: 20px; color: #64748b; font-size: 14px; }
        </style>
      </head>
      <body>
        <div class="container">
          <div class="header">
            <h1>Form Published Successfully!</h1>
          </div>
          <div class="content">
            <p>Your form <strong>${formTitle}</strong> has been published and is now ready to collect responses.</p>
            
            ${shareLink ? `
              <h3>Share Link:</h3>
              <div class="link">${shareLink}</div>
            ` : ''}
            
            <p>You can now share this form with others to start collecting responses.</p>
          </div>
          <div class="footer">
            <p>This email was sent automatically by FormFlow</p>
          </div>
        </div>
      </body>
      </html>
    `
  })
};
