import 'package:formflow/models/form_model.dart';

class FormRepository {
  // Temporary mock data until Firebase is properly set up
  static final List<FormModel> _mockForms = [];

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
