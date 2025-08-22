# FormFlow - Entity Relationship Diagram

```mermaid
erDiagram
    %% User Management
    USERS {
        string uid PK "🔑 Primary Key"
        string email "📧 Email Address"
        string displayName "👤 Display Name"
        string photoURL "🖼️ Profile Photo"
        boolean emailVerified "✅ Email Verified"
        datetime createdAt "📅 Created Date"
        datetime lastSignInAt "🕐 Last Sign In"
        string role "👑 User Role"
        string status "📊 Account Status"
    }
    
    %% Form Management
    FORMS {
        string id PK "🔑 Primary Key"
        string title "📝 Form Title"
        string description "📄 Form Description"
        string createdBy FK "👤 Created By User"
        datetime createdAt "📅 Created Date"
        datetime updatedAt "🔄 Updated Date"
        boolean isActive "✅ Active Status"
        boolean emailNotifications "📧 Email Notifications"
        string shareLink "🔗 Share Link"
        string status "📊 Form Status"
        string colorTheme "🎨 Color Theme"
        boolean requiresApproval "⏳ Requires Approval"
        string emailField "📧 Email Field ID"
        string formOwnerEmail "👤 Owner Email"
        boolean isPublic "🌐 Public Access"
    }
    
    %% Form Fields/Questions
    FORM_FIELDS {
        string id PK "🔑 Primary Key"
        string formId FK "📝 Form ID"
        string label "🏷️ Field Label"
        string type "📋 Field Type"
        boolean required "⚠️ Required Field"
        string placeholder "💡 Placeholder Text"
        string validation "✅ Validation Rules"
        int order "🔢 Field Order"
        json options "⚙️ Field Options"
        string defaultValue "📝 Default Value"
    }
    
    %% Form Submissions
    SUBMISSIONS {
        string id PK "🔑 Primary Key"
        string formId FK "📝 Form ID"
        string submitterName "👤 Submitter Name"
        string submitterEmail "📧 Submitter Email"
        datetime createdAt "📅 Submission Date"
        string status "📊 Submission Status"
        string reviewedBy FK "👤 Reviewed By"
        datetime reviewedAt "📅 Review Date"
        string reviewNotes "📝 Review Notes"
    }
    
    %% Submission Data
    SUBMISSION_DATA {
        string id PK "🔑 Primary Key"
        string submissionId FK "📥 Submission ID"
        string fieldId FK "📋 Field ID"
        string value "💾 Field Value"
        string questionLabel "🏷️ Question Label"
        string questionAnswer "✍️ Question Answer"
    }
    
    %% Notifications
    NOTIFICATIONS {
        string id PK "🔑 Primary Key"
        string type "🔔 Notification Type"
        string title "📢 Notification Title"
        string message "💬 Notification Message"
        string formId FK "📝 Form ID"
        string submissionId FK "📥 Submission ID"
        string userId FK "👤 User ID"
        datetime createdAt "📅 Created Date"
        boolean isRead "👁️ Read Status"
        string actionUrl "🔗 Action URL"
        json metadata "📊 Additional Data"
    }
    
    %% Cohorts (Coming Soon)
    COHORTS {
        string id PK "🔑 Primary Key"
        string name "👥 Cohort Name"
        string description "📄 Cohort Description"
        string createdBy FK "👤 Created By"
        datetime createdAt "📅 Created Date"
        datetime updatedAt "🔄 Updated Date"
        string status "📊 Cohort Status"
        int memberCount "👥 Member Count"
        json permissions "🔐 Cohort Permissions"
    }
    
    %% Cohort Members (Coming Soon)
    COHORT_MEMBERS {
        string id PK "🔑 Primary Key"
        string cohortId FK "👥 Cohort ID"
        string userId FK "👤 User ID"
        string role "👑 Member Role"
        datetime joinedAt "📅 Joined Date"
        string status "📊 Member Status"
        json permissions "🔐 Member Permissions"
    }
    
    %% Form Approvals (Coming Soon)
    FORM_APPROVALS {
        string id PK "🔑 Primary Key"
        string formId FK "📝 Form ID"
        string approverId FK "👤 Approver ID"
        string status "📊 Approval Status"
        datetime requestedAt "📅 Request Date"
        datetime approvedAt "✅ Approval Date"
        string comments "💬 Approval Comments"
        string approvalLevel "📊 Approval Level"
    }
    
    %% Relationships
    USERS ||--o{ FORMS : "creates"
    USERS ||--o{ SUBMISSIONS : "submits"
    USERS ||--o{ NOTIFICATIONS : "receives"
    USERS ||--o{ COHORT_MEMBERS : "belongs_to"
    USERS ||--o{ FORM_APPROVALS : "approves"
    
    FORMS ||--o{ FORM_FIELDS : "contains"
    FORMS ||--o{ SUBMISSIONS : "receives"
    FORMS ||--o{ NOTIFICATIONS : "triggers"
    FORMS ||--o{ FORM_APPROVALS : "requires"
    
    FORM_FIELDS ||--o{ SUBMISSION_DATA : "collects"
    
    SUBMISSIONS ||--o{ SUBMISSION_DATA : "contains"
    SUBMISSIONS ||--o{ NOTIFICATIONS : "generates"
    
    COHORTS ||--o{ COHORT_MEMBERS : "includes"
    COHORTS ||--o{ FORMS : "shares"
    
    %% Styling
    classDef users fill:#FFE6E6,stroke:#FF6B6B,stroke-width:3px
    classDef forms fill:#E6FFE6,stroke:#4CAF50,stroke-width:3px
    classDef fields fill:#FFF2E6,stroke:#FF9800,stroke-width:3px
    classDef submissions fill:#F3E6FF,stroke:#9C27B0,stroke-width:3px
    classDef notifications fill:#FFE6E6,stroke:#F44336,stroke-width:3px
    classDef cohorts fill:#F5E6FF,stroke:#673AB7,stroke-width:3px
    classDef approvals fill:#E6F3FF,stroke:#2196F3,stroke-width:3px
    
    class USERS users
    class FORMS forms
    class FORM_FIELDS fields
    class SUBMISSIONS,SUBMISSION_DATA submissions
    class NOTIFICATIONS notifications
    class COHORTS,COHORT_MEMBERS cohorts
    class FORM_APPROVALS approvals
```

## 🏗️ Database Schema Overview

### 🔐 **Core Entities**

#### **USERS** - User Management
- **Primary Key**: `uid` (Firebase Auth UID)
- **Core Fields**: email, displayName, photoURL, emailVerified
- **Timestamps**: createdAt, lastSignInAt
- **Status**: role, status

#### **FORMS** - Form Management
- **Primary Key**: `id` (Auto-generated)
- **Core Fields**: title, description, createdBy, status
- **Settings**: isActive, emailNotifications, requiresApproval
- **Access Control**: isPublic, shareLink
- **Timestamps**: createdAt, updatedAt

#### **FORM_FIELDS** - Question Structure
- **Primary Key**: `id` (Auto-generated)
- **Foreign Key**: `formId` → FORMS.id
- **Core Fields**: label, type, required, order
- **Configuration**: validation, options, defaultValue

#### **SUBMISSIONS** - Form Responses
- **Primary Key**: `id` (Auto-generated)
- **Foreign Keys**: `formId` → FORMS.id, `reviewedBy` → USERS.uid
- **Core Fields**: submitterName, submitterEmail, status
- **Timestamps**: createdAt, reviewedAt

#### **SUBMISSION_DATA** - Individual Responses
- **Primary Key**: `id` (Auto-generated)
- **Foreign Keys**: `submissionId` → SUBMISSIONS.id, `fieldId` → FORM_FIELDS.id
- **Data**: value, questionLabel, questionAnswer

#### **NOTIFICATIONS** - System Alerts
- **Primary Key**: `id` (Auto-generated)
- **Foreign Keys**: `formId`, `submissionId`, `userId`
- **Core Fields**: type, title, message, isRead
- **Metadata**: actionUrl, additional data

### 🔄 **Coming Soon Entities**

#### **COHORTS** - User Grouping
- **Primary Key**: `id` (Auto-generated)
- **Foreign Key**: `createdBy` → USERS.uid
- **Core Fields**: name, description, status, memberCount
- **Features**: permissions, member management

#### **COHORT_MEMBERS** - Cohort Membership
- **Primary Key**: `id` (Auto-generated)
- **Foreign Keys**: `cohortId` → COHORTS.id, `userId` → USERS.uid
- **Core Fields**: role, status, permissions

#### **FORM_APPROVALS** - Approval Workflow
- **Primary Key**: `id` (Auto-generated)
- **Foreign Keys**: `formId` → FORMS.id, `approverId` → USERS.uid
- **Core Fields**: status, approvalLevel, comments

### 🎨 **Color Coding**
- 🔴 **Red**: User Management
- 🟢 **Green**: Form Management
- 🟡 **Yellow**: Form Fields/Questions
- 🟣 **Purple**: Submissions & Data
- 🔴 **Red**: Notifications
- 🟫 **Brown**: Cohorts & Groups
- 🔵 **Blue**: Approval Workflows

### 🔗 **Key Relationships**
1. **One-to-Many**: User → Forms (one user creates many forms)
2. **One-to-Many**: Form → Fields (one form has many questions)
3. **One-to-Many**: Form → Submissions (one form receives many responses)
4. **One-to-Many**: Submission → Data (one submission contains many answers)
5. **Many-to-Many**: Users ↔ Cohorts (through COHORT_MEMBERS)
6. **One-to-Many**: Form → Approvals (one form may require multiple approvals)

---

*This ER diagram represents the complete database structure for FormFlow, including current and planned features.*
