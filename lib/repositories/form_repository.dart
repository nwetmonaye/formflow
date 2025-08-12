import 'package:formflow/models/form_model.dart';

class FormRepository {
  // Temporary mock data until Firebase is properly set up
  static final List<FormModel> _mockForms = [
    // Sample form for testing
    FormModel(
      id: 'sample-form-1',
      title: 'Sample Survey Form',
      description:
          'This is a sample form for testing purposes. It includes various question types.',
      fields: [
        FormField(
          id: 'name',
          label: 'What is your name?',
          type: 'text',
          required: true,
          placeholder: 'Enter your full name',
        ),
        FormField(
          id: 'email',
          label: 'What is your email address?',
          type: 'text',
          required: true,
          placeholder: 'Enter your email address',
        ),
        FormField(
          id: 'age',
          label: 'What is your age?',
          type: 'number',
          required: false,
          placeholder: 'Enter your age',
        ),
        FormField(
          id: 'favorite_color',
          label: 'What is your favorite color?',
          type: 'multiple_choice',
          required: true,
          options: ['Red', 'Blue', 'Green', 'Yellow', 'Purple', 'Orange'],
        ),
        FormField(
          id: 'hobbies',
          label: 'What are your hobbies? (Select all that apply)',
          type: 'checkbox',
          required: false,
          options: [
            'Reading',
            'Gaming',
            'Sports',
            'Music',
            'Travel',
            'Cooking'
          ],
        ),
        FormField(
          id: 'country',
          label: 'Which country do you live in?',
          type: 'dropdown',
          required: true,
          options: [
            'USA',
            'Canada',
            'UK',
            'Australia',
            'Germany',
            'France',
            'Other'
          ],
        ),
        FormField(
          id: 'birth_date',
          label: 'When is your birthday?',
          type: 'date',
          required: false,
        ),
        FormField(
          id: 'feedback',
          label: 'Any additional feedback or comments?',
          type: 'text',
          required: false,
          placeholder: 'Share your thoughts...',
        ),
      ],
      createdBy: 'mock-user-1',
      createdAt: DateTime.now().subtract(const Duration(days: 7)),
      updatedAt: DateTime.now(),
      isActive: true,
      emailNotifications: false,
      shareLink: '/form/sample-form-1',
      status: 'active',
      colorTheme: 'blue',
      requiresApproval: false,
    ),
    // Another sample form
    FormModel(
      id: 'sample-form-2',
      title: 'Customer Feedback Form',
      description:
          'Help us improve our service by providing your valuable feedback.',
      fields: [
        FormField(
          id: 'customer_name',
          label: 'Customer Name',
          type: 'text',
          required: true,
          placeholder: 'Enter your name',
        ),
        FormField(
          id: 'satisfaction',
          label: 'How satisfied are you with our service?',
          type: 'multiple_choice',
          required: true,
          options: [
            'Very Satisfied',
            'Satisfied',
            'Neutral',
            'Dissatisfied',
            'Very Dissatisfied'
          ],
        ),
        FormField(
          id: 'improvements',
          label: 'What improvements would you suggest?',
          type: 'text',
          required: false,
          placeholder: 'Share your suggestions...',
        ),
      ],
      createdBy: 'mock-user-2',
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
      updatedAt: DateTime.now(),
      isActive: true,
      emailNotifications: true,
      shareLink: '/form/sample-form-2',
      status: 'active',
      colorTheme: 'green',
      requiresApproval: true,
    ),
  ];

  // Get all forms for a user
  Future<List<FormModel>> getUserForms(String userId) async {
    // Mock implementation
    await Future.delayed(const Duration(milliseconds: 500));
    return _mockForms.where((form) => form.createdBy == userId).toList();
  }

  // Create a new form
  Future<String> createForm(FormModel form) async {
    // Mock implementation
    await Future.delayed(const Duration(milliseconds: 500));
    final newForm = FormModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: form.title,
      description: form.description,
      fields: form.fields,
      createdBy: form.createdBy,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      isActive: form.isActive,
      emailNotifications: form.emailNotifications,
      shareLink: form.shareLink,
    );
    _mockForms.add(newForm);
    return newForm.id!;
  }

  // Update a form
  Future<void> updateForm(String formId, FormModel formData) async {
    // Mock implementation
    await Future.delayed(const Duration(milliseconds: 500));
    final index = _mockForms.indexWhere((form) => form.id == formId);
    if (index != -1) {
      _mockForms[index] = FormModel(
        id: formId,
        title: formData.title,
        description: formData.description,
        fields: formData.fields,
        createdBy: formData.createdBy,
        createdAt: _mockForms[index].createdAt,
        updatedAt: DateTime.now(),
        isActive: formData.isActive,
        emailNotifications: formData.emailNotifications,
        shareLink: formData.shareLink,
      );
    }
  }

  // Delete a form
  Future<void> deleteForm(String formId) async {
    // Mock implementation
    await Future.delayed(const Duration(milliseconds: 500));
    _mockForms.removeWhere((form) => form.id == formId);
  }

  // Get form by ID
  Future<FormModel?> getFormById(String formId) async {
    // Mock implementation
    await Future.delayed(const Duration(milliseconds: 500));
    try {
      return _mockForms.firstWhere((form) => form.id == formId);
    } catch (e) {
      return null;
    }
  }

  // Get form submissions (mock implementation)
  Future<List<Map<String, dynamic>>> getFormSubmissions(String formId) async {
    // Mock implementation
    await Future.delayed(const Duration(milliseconds: 500));
    return [];
  }

  // Create a submission (mock implementation)
  Future<String> createSubmission(Map<String, dynamic> submissionData) async {
    // Mock implementation
    await Future.delayed(const Duration(milliseconds: 500));
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  // Update submission status (mock implementation)
  Future<void> updateSubmissionStatus(
    String submissionId,
    String status,
    String? approvedBy,
    String? comments,
  ) async {
    // Mock implementation
    await Future.delayed(const Duration(milliseconds: 500));
    print('Submission $submissionId status updated to $status');
  }
}
