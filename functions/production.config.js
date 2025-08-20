// Production Environment Configuration
module.exports = {
    NODE_ENV: 'production',

    // Email Configuration
    EMAIL_SERVICE: 'gmail',
    EMAIL_USER: 'your-production-email@gmail.com',
    EMAIL_PASSWORD: 'your-app-specific-password',

    // Resend API (Alternative email service)
    RESEND_API_KEY: 'your-resend-api-key',

    // Firebase Admin Configuration
    FIREBASE_PROJECT_ID: 'your-firebase-project-id',

    // Security Settings
    CORS_ORIGIN: 'https://your-domain.web.app',
    MAX_FILE_SIZE: 10485760, // 10MB
    ALLOWED_FILE_TYPES: ['image/jpeg', 'image/png', 'image/gif', 'application/pdf', 'text/plain'],

    // Rate Limiting
    RATE_LIMIT_WINDOW_MS: 900000, // 15 minutes
    RATE_LIMIT_MAX_REQUESTS: 100,

    // Authentication Settings
    AUTH_REQUIRED: true,
    ALLOW_ANONYMOUS_SUBMISSIONS: true,

    // File Upload Settings
    STORAGE_BUCKET: 'your-project-id.appspot.com',
    MAX_FILE_UPLOADS: 5,

    // Notification Settings
    ENABLE_EMAIL_NOTIFICATIONS: true,
    ENABLE_PUSH_NOTIFICATIONS: false,

    // Export Settings
    ENABLE_CSV_EXPORT: true,
    ENABLE_PDF_EXPORT: false,
    MAX_EXPORT_RECORDS: 10000
};
