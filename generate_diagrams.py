#!/usr/bin/env python3
"""
Generate high-quality images of FormFlow diagrams
"""

import requests
import base64
import json
import os

def generate_mermaid_image(mermaid_code, filename, theme="default", format="png"):
    """
    Generate image from Mermaid code using Mermaid Live Editor API
    """
    # Mermaid Live Editor API endpoint
    url = "https://mermaid.ink/img/"
    
    # Encode the Mermaid code
    encoded_code = base64.b64encode(mermaid_code.encode()).decode()
    
    # Create the full URL
    full_url = f"{url}{encoded_code}?type={format}&theme={theme}"
    
    print(f"Generating {filename}.{format}...")
    print(f"URL: {full_url}")
    
    # Download the image
    try:
        response = requests.get(full_url)
        response.raise_for_status()
        
        # Save the image
        with open(f"{filename}.{format}", "wb") as f:
            f.write(response.content)
        
        print(f"✅ Successfully generated {filename}.{format}")
        return True
        
    except Exception as e:
        print(f"❌ Error generating {filename}: {e}")
        return False

def main():
    # Use Case Diagram
    use_case_mermaid = '''
graph TB
    %% Actors
    User((👤 User))
    Admin((👑 Admin))
    ExternalUser((🌐 External User))
    
    %% Use Cases - Core Features
    subgraph "🔐 Authentication & Profile"
        Login[🟦 Login]
        Signup[🟦 Signup]
        Logout[🟦 Logout]
        ViewProfile[🟦 View Profile]
        EditProfile[🟦 Edit Profile<br/>🔄 Coming Soon]
        ChangePassword[🟦 Change Password<br/>🔄 Coming Soon]
    end
    
    subgraph "📝 Form Management"
        CreateForm[🟩 Create Form]
        EditForm[🟩 Edit Form]
        DeleteForm[🟩 Delete Form]
        DuplicateForm[🟩 Duplicate Form]
        PreviewForm[🟩 Preview Form]
        PublishForm[🟩 Publish Form]
        CloseForm[🟩 Close Form]
        ShareForm[🟩 Share Form]
        ExportForm[🟩 Export Form]
    end
    
    subgraph "📊 Form Building"
        AddQuestion[🟨 Add Question]
        EditQuestion[🟨 Edit Question]
        DeleteQuestion[🟨 Delete Question]
        ReorderQuestions[🟨 Reorder Questions]
        SetQuestionType[🟨 Set Question Type]
        ConfigureValidation[🟨 Configure Validation]
        SetFormSettings[🟨 Set Form Settings]
    end
    
    subgraph "📥 Form Submission"
        SubmitForm[🟪 Submit Form]
        ViewSubmission[🟪 View Submission]
        EditSubmission[🟪 Edit Submission]
        DeleteSubmission[🟪 Delete Submission]
        ApproveSubmission[🟪 Approve Submission]
        RejectSubmission[🟪 Reject Submission]
    end
    
    subgraph "🔔 Notifications"
        ViewNotifications[🟥 View Notifications]
        MarkAsRead[🟥 Mark as Read]
        EmailNotifications[🟥 Email Notifications]
    end
    
    subgraph "👥 User Management"
        ManageUsers[🟫 Manage Users]
        ViewCohorts[🟫 View Cohorts<br/>🔄 Coming Soon]
        ManageCohorts[🟫 Manage Cohorts<br/>🔄 Coming Soon]
    end
    
    subgraph "📈 Analytics & Reports"
        ViewAnalytics[🟦 View Analytics]
        GenerateReports[🟦 Generate Reports]
        ExportData[🟦 Export Data]
    end
    
    %% Relationships
    User --> Login
    User --> Signup
    User --> Logout
    User --> ViewProfile
    User --> EditProfile
    User --> ChangePassword
    User --> CreateForm
    User --> EditForm
    User --> DeleteForm
    User --> DuplicateForm
    User --> PreviewForm
    User --> PublishForm
    User --> CloseForm
    User --> ShareForm
    User --> ExportForm
    User --> AddQuestion
    User --> EditQuestion
    User --> DeleteQuestion
    User --> ReorderQuestions
    User --> SetQuestionType
    User --> ConfigureValidation
    User --> SetFormSettings
    User --> ViewSubmission
    User --> EditSubmission
    User --> DeleteSubmission
    User --> ApproveSubmission
    User --> RejectSubmission
    User --> ViewNotifications
    User --> MarkAsRead
    User --> ViewAnalytics
    User --> GenerateReports
    User --> ExportData
    
    Admin --> ManageUsers
    Admin --> ViewCohorts
    Admin --> ManageCohorts
    
    ExternalUser --> SubmitForm
    ExternalUser --> ViewSubmission
    
    %% Include relationships
    CreateForm -.->|includes| AddQuestion
    CreateForm -.->|includes| SetFormSettings
    EditForm -.->|includes| EditQuestion
    EditForm -.->|includes| SetFormSettings
    PublishForm -.->|includes| PreviewForm
    SubmitForm -.->|includes| ViewSubmission
    
    %% Styling
    classDef actor fill:#FFE6E6,stroke:#FF6B6B,stroke-width:3px
    classDef core fill:#E6F3FF,stroke:#4A90E2,stroke-width:2px
    classDef form fill:#E6FFE6,stroke:#4CAF50,stroke-width:2px
    classDef builder fill:#FFF2E6,stroke:#FF9800,stroke-width:2px
    classDef submission fill:#F3E6FF,stroke:#9C27B0,stroke-width:2px
    classDef notification fill:#FFE6E6,stroke:#F44336,stroke-width:2px
    classDef userMgmt fill:#F5E6FF,stroke:#673AB7,stroke-width:2px
    classDef analytics fill:#E6F3FF,stroke:#2196F3,stroke-width:2px
    
    class User,Admin,ExternalUser actor
    class Login,Signup,Logout,ViewProfile,EditProfile,ChangePassword core
    class CreateForm,EditForm,DeleteForm,DuplicateForm,PreviewForm,PublishForm,CloseForm,ShareForm,ExportForm form
    class AddQuestion,EditQuestion,DeleteQuestion,ReorderQuestions,SetQuestionType,ConfigureValidation,SetFormSettings builder
    class SubmitForm,ViewSubmission,EditSubmission,DeleteSubmission,ApproveSubmission,RejectSubmission submission
    class ViewNotifications,MarkAsRead,EmailNotifications notification
    class ManageUsers,ViewCohorts,ManageCohorts userMgmt
    class ViewAnalytics,GenerateReports,ExportData analytics
    '''

    # ER Diagram
    er_mermaid = '''
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
    '''

    print("🚀 Generating FormFlow Diagrams...")
    print("=" * 50)
    
    # Generate Use Case Diagram
    generate_mermaid_image(use_case_mermaid, "formflow_use_case_diagram", "default", "png")
    
    # Generate ER Diagram
    generate_mermaid_image(er_mermaid, "formflow_er_diagram", "default", "png")
    
    print("\n" + "=" * 50)
    print("🎉 Diagram generation complete!")
    print("\nGenerated files:")
    print("📊 formflow_use_case_diagram.png")
    print("🏗️ formflow_er_diagram.png")
    print("\nThese images are ready for use in presentations!")

if __name__ == "__main__":
    main()

