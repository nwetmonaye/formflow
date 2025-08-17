import 'package:flutter/material.dart';
import 'package:formflow/constants/style.dart';
import 'package:formflow/models/form_model.dart' as form_model;
import 'package:formflow/services/firebase_service.dart';
import 'package:formflow/models/submission_model.dart';

class FormSubmissionScreen extends StatefulWidget {
  final String formId;

  const FormSubmissionScreen({
    super.key,
    required this.formId,
  });

  @override
  State<FormSubmissionScreen> createState() => _FormSubmissionScreenState();
}

class _FormSubmissionScreenState extends State<FormSubmissionScreen> {
  form_model.FormModel? form;
  bool isLoading = true;
  bool isError = false;
  String errorMessage = '';
  final Map<String, dynamic> _responses = {};
  final _formKey = GlobalKey<FormState>();
  bool _showSuccessCard = false;

  @override
  void initState() {
    super.initState();
    _loadForm();
  }

  Future<void> _loadForm() async {
    try {
      print('🔍 Loading form with ID: ${widget.formId}');

      // Try Firebase first
      form_model.FormModel? loadedForm;

      try {
        // Check if Firebase is available
        if (await FirebaseService.ensureInitialized()) {
          print('🔍 Firebase is available, trying to load from Firebase');
          loadedForm = await FirebaseService.getForm(widget.formId);
          if (loadedForm != null) {
            print('🔍 Form loaded successfully from Firebase');
          }
        }
      } catch (e) {
        print('🔍 Firebase error: $e');
      }

      if (loadedForm != null) {
        setState(() {
          form = loadedForm;
          isLoading = false;
        });
        print(
            '🔍 Form loaded: ${loadedForm.title} with ${loadedForm.fields.length} fields');
        print('🔍 Form status: ${loadedForm.status}');
        print('🔍 Form email field: ${loadedForm.emailField}');
        print('🔍 Form email field is null: ${loadedForm.emailField == null}');
        print(
            '🔍 Form email field is empty: ${loadedForm.emailField?.isEmpty}');
      } else {
        setState(() {
          isError = true;
          errorMessage =
              'Form not found. Please check the URL or try again later.';
          isLoading = false;
        });
        print('🔍 Form not found in Firebase');
      }
    } catch (e) {
      print('🔍 Error loading form: $e');
      setState(() {
        isError = true;
        errorMessage = 'Error loading form: $e';
        isLoading = false;
      });
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      print('🔍 Submitting form with responses: $_responses');

      // Create maps for question labels and answers
      final Map<String, String> questionLabels = {};
      final Map<String, String> questionAnswers = {};

      // Process each field to extract labels and answers
      for (final field in form!.fields) {
        final fieldId = field.id;
        final label = field.label;
        final answer = _responses[fieldId]?.toString() ?? '';

        questionLabels[fieldId] = label;
        questionAnswers[fieldId] = answer;
      }

      // Create submission with proper data structure
      final submission = SubmissionModel(
        formId: widget.formId,
        data: _responses,
        questionLabels: questionLabels,
        questionAnswers: questionAnswers,
        status: 'pending',
        createdAt: DateTime.now(),
        submitterName: _responses['name'] ?? 'Anonymous',
        submitterEmail: _responses['email'] ?? 'anonymous@example.com',
      );

      print('🔍 Creating submission for form: ${widget.formId}');
      print('🔍 Submission data: ${submission.toMap()}');

      // Save to Firebase
      if (await FirebaseService.ensureInitialized()) {
        final submissionId = await FirebaseService.createSubmission(submission);
        print('🔍 Submission created with ID: $submissionId');

        // Send notification email to form owner
        if (form!.formOwnerEmail != null && form!.formOwnerEmail!.isNotEmpty) {
          try {
            print(
                '🔍 Sending new submission email to form owner: ${form!.formOwnerEmail}');
            await FirebaseService.sendEmail(
              to: form!
                  .formOwnerEmail!, // Send to form owner's email stored in form
              subject: 'New Form Submission: ${form!.title}',
              html: '<p>You have received a new form submission!</p>',
              type: 'new_submission',
              formTitle: form!.title,
              submitterName: submission.submitterName,
              submitterEmail: submission.submitterEmail,
            );
            print('🔍 New submission email sent successfully to form owner');
          } catch (emailError) {
            print('Error sending notification email: $emailError');
            // Don't fail the submission if email fails
          }
        } else {
          print('🔍 Form owner email not found, skipping email notification');
          print('🔍 Form owner email: ${form!.formOwnerEmail}');
        }

        setState(() {
          _showSuccessCard = true;
        });
        return;
      } else {
        throw Exception('Firebase not available');
      }
    } catch (e) {
      print('🔍 Error submitting form: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error submitting form: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _clearForm() {
    setState(() {
      _responses.clear();
    });
    _formKey.currentState?.reset();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        backgroundColor: KStyle.cBgColor,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 24),
              Text(
                'Loading form...',
                style: KStyle.heading3TextStyle.copyWith(
                  color: KStyle.cBlackColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Form ID: ${widget.formId}',
                style: KStyle.labelMdRegularTextStyle.copyWith(
                  color: KStyle.c72GreyColor,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (isError) {
      return Scaffold(
        backgroundColor: KStyle.cBgColor,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: KStyle.cDBRedColor,
                ),
                const SizedBox(height: 16),
                Text(
                  'Form Not Found',
                  style: KStyle.heading2TextStyle.copyWith(
                    color: KStyle.cBlackColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  errorMessage,
                  style: KStyle.labelMdRegularTextStyle.copyWith(
                    color: KStyle.c72GreyColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: KStyle.cPrimaryColor,
                    foregroundColor: KStyle.cWhiteColor,
                  ),
                  child: const Text('Go Back'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (form == null) {
      return Scaffold(
        backgroundColor: KStyle.cBgColor,
        body: const Center(
          child: Text('Form not found'),
        ),
      );
    }

    return Scaffold(
      backgroundColor: KStyle.cBgColor,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (_showSuccessCard)
                Center(
                  child: Container(
                    width: 700,
                    margin: const EdgeInsets.only(bottom: 24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Top border
                        Container(
                          height: 10,
                          decoration: BoxDecoration(
                            color: KStyle.cPrimaryColor,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(12),
                              topRight: Radius.circular(12),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(32),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                form!.title.isNotEmpty
                                    ? form!.title
                                    : 'Untitled form',
                                style: KStyle.heading2TextStyle.copyWith(
                                  color: KStyle.cBlackColor,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 32,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Your response has been recorded.',
                                style: KStyle.labelMdRegularTextStyle.copyWith(
                                  color: KStyle.c72GreyColor,
                                ),
                              ),
                              const SizedBox(height: 24),
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _showSuccessCard = false;
                                    _clearForm();
                                  });
                                },
                                child: Text(
                                  'Submit another response',
                                  style:
                                      KStyle.labelMdRegularTextStyle.copyWith(
                                    color: KStyle.cPrimaryColor,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else ...[
                Center(
                  child: Container(
                    width: 700,
                    margin: const EdgeInsets.only(bottom: 24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                      border: Border(
                        left: BorderSide(
                          color: KStyle.cPrimaryColor,
                          width: 5,
                        ),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            form!.title.isNotEmpty ? form!.title : 'Untitled',
                            style: KStyle.heading2TextStyle.copyWith(
                              color: KStyle.cBlackColor,
                              fontWeight: FontWeight.w700,
                              fontSize: 32,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            form!.description.isNotEmpty
                                ? form!.description
                                : 'Form Description',
                            style: KStyle.labelMdRegularTextStyle.copyWith(
                              color: KStyle.c72GreyColor,
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Email Field Display - Always show for external users
                          Row(
                            children: [
                              Text(
                                'Email*',
                                style: KStyle.labelMdRegularTextStyle.copyWith(
                                  color: KStyle.cBlackColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '(Required)',
                                style: KStyle.labelMdRegularTextStyle.copyWith(
                                  color: Colors.red[200],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: KStyle.cE3GreyColor,
                                  width: 1,
                                ),
                              ),
                            ),
                            child: TextFormField(
                              decoration: InputDecoration(
                                hintText: 'Valid Email',
                                border: InputBorder.none,
                                hintStyle:
                                    KStyle.labelMdRegularTextStyle.copyWith(
                                  color: KStyle.c72GreyColor,
                                ),
                              ),
                              onChanged: (value) {
                                _responses['email'] = value;
                              },
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Email is required';
                                }
                                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                                    .hasMatch(value)) {
                                  return 'Please enter a valid email';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            '* Indicates required question',
                            style: KStyle.labelMdRegularTextStyle.copyWith(
                              color: Colors.red[200],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Center(
                  child: Container(
                    width: 700,
                    child: Column(
                      children: [
                        if (form!.fields.isNotEmpty) ...[
                          Form(
                            key: _formKey,
                            child: Column(
                              children: form!.fields
                                  .map((field) => _buildFormField(field))
                                  .toList(),
                            ),
                          ),
                        ] else ...[
                          Center(
                            child: Column(
                              children: [
                                Icon(
                                  Icons.description_outlined,
                                  size: 64,
                                  color: KStyle.c72GreyColor,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No questions added yet',
                                  style: KStyle.heading3TextStyle.copyWith(
                                    color: KStyle.c72GreyColor,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'This form is still being set up',
                                  style:
                                      KStyle.labelMdRegularTextStyle.copyWith(
                                    color: KStyle.c72GreyColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        const SizedBox(height: 32),
                        Row(
                          children: [
                            SizedBox(
                              width: 160,
                              height: 48,
                              child: ElevatedButton(
                                onPressed: _submitForm,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: KStyle.cPrimaryColor,
                                  foregroundColor: KStyle.cWhiteColor,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  elevation: 0,
                                ),
                                child: Text(
                                  'Submit',
                                  style: KStyle.labelMdBoldTextStyle.copyWith(
                                    color: KStyle.cWhiteColor,
                                  ),
                                ),
                              ),
                            ),
                            const Spacer(),
                            TextButton(
                              onPressed: _clearForm,
                              child: Text(
                                'Clear form',
                                style: KStyle.labelMdRegularTextStyle.copyWith(
                                  color: KStyle.cPrimaryColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),
              ]
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFormField(form_model.FormField field) {
    return Center(
      child: Container(
        width: 700,
        margin: const EdgeInsets.only(bottom: 24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Question text
              Row(
                children: [
                  Expanded(
                    child: Text(
                      field.label,
                      style: KStyle.heading3TextStyle.copyWith(
                        color: KStyle.cBlackColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  if (field.required)
                    Text(
                      ' *',
                      style: KStyle.heading3TextStyle.copyWith(
                        color: Colors.red,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              // Question input based on type
              _buildFieldInput(field),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFieldInput(form_model.FormField field) {
    switch (field.type) {
      case 'text':
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: KStyle.cE3GreyColor,
                width: 1,
              ),
            ),
          ),
          child: TextFormField(
            decoration: InputDecoration(
              hintText: field.placeholder ?? 'Your answer',
              border: InputBorder.none,
              hintStyle: KStyle.labelMdRegularTextStyle.copyWith(
                color: KStyle.c72GreyColor,
              ),
            ),
            onChanged: (value) {
              _responses[field.id] = value;
            },
            validator: (value) {
              if (field.required && (value == null || value.isEmpty)) {
                return 'This field is required';
              }
              return null;
            },
          ),
        );

      case 'number':
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: KStyle.cE3GreyColor,
                width: 1,
              ),
            ),
          ),
          child: TextFormField(
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: field.placeholder ?? 'Enter a number',
              border: InputBorder.none,
              hintStyle: KStyle.labelMdRegularTextStyle.copyWith(
                color: KStyle.c72GreyColor,
              ),
            ),
            onChanged: (value) {
              _responses[field.id] = double.tryParse(value);
            },
            validator: (value) {
              if (field.required && (value == null || value.isEmpty)) {
                return 'This field is required';
              }
              return null;
            },
          ),
        );

      case 'date':
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: KStyle.cE3GreyColor,
                width: 1,
              ),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextFormField(
                  readOnly: true,
                  decoration: InputDecoration(
                    hintText: field.placeholder ?? 'mm/dd/yyyy',
                    border: InputBorder.none,
                    hintStyle: KStyle.labelMdRegularTextStyle.copyWith(
                      color: KStyle.c72GreyColor,
                    ),
                  ),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(1900),
                      lastDate: DateTime(2100),
                    );
                    if (date != null) {
                      setState(() {
                        _responses[field.id] = date;
                      });
                    }
                  },
                  validator: (value) {
                    if (field.required && (value == null || value.isEmpty)) {
                      return 'This field is required';
                    }
                    return null;
                  },
                ),
              ),
              Icon(
                Icons.calendar_today,
                color: KStyle.c72GreyColor,
                size: 20,
              ),
            ],
          ),
        );

      case 'multiple_choice':
        if (field.options != null && field.options!.isNotEmpty) {
          return Column(
            children: field.options!
                .map((option) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        children: [
                          Radio<String>(
                            value: option,
                            groupValue: _responses[field.id],
                            onChanged: (value) {
                              setState(() {
                                _responses[field.id] = value;
                              });
                            },
                            activeColor: KStyle.cPrimaryColor,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            option,
                            style: KStyle.labelMdRegularTextStyle.copyWith(
                              color: KStyle.cBlackColor,
                            ),
                          ),
                        ],
                      ),
                    ))
                .toList(),
          );
        }
        break;

      case 'checkbox':
        if (field.options != null && field.options!.isNotEmpty) {
          return Column(
            children: field.options!
                .map((option) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        children: [
                          Checkbox(
                            value:
                                _responses[field.id]?.contains(option) ?? false,
                            onChanged: (value) {
                              setState(() {
                                if (value!) {
                                  _responses[field.id] = List<String>.from(
                                      _responses[field.id] ?? <String>[]);
                                  _responses[field.id]!.add(option);
                                } else {
                                  _responses[field.id] = List<String>.from(
                                          _responses[field.id] ?? <String>[])
                                      .where((item) => item != option)
                                      .toList();
                                }
                              });
                            },
                            activeColor: KStyle.cPrimaryColor,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            option,
                            style: KStyle.labelMdRegularTextStyle.copyWith(
                              color: KStyle.cBlackColor,
                            ),
                          ),
                        ],
                      ),
                    ))
                .toList(),
          );
        }
        break;

      case 'dropdown':
        if (field.options != null && field.options!.isNotEmpty) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: KStyle.cE3GreyColor,
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      hint: Text(
                        field.placeholder ?? 'Select an option',
                        style: KStyle.labelMdRegularTextStyle.copyWith(
                          color: KStyle.c72GreyColor,
                        ),
                      ),
                      items: field.options!
                          .map((option) => DropdownMenuItem(
                                value: option,
                                child: Text(option),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _responses[field.id] = value;
                        });
                      },
                      value: _responses[field.id],
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_drop_down,
                  color: KStyle.c72GreyColor,
                  size: 20,
                ),
              ],
            ),
          );
        }
        break;

      case 'file_upload':
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(
              color: KStyle.cE3GreyColor,
              width: 1,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(
                Icons.upload_file,
                color: KStyle.c72GreyColor,
                size: 20,
              ),
              const SizedBox(width: 12),
              Text(
                'Click to upload file',
                style: KStyle.labelMdRegularTextStyle.copyWith(
                  color: KStyle.c72GreyColor,
                ),
              ),
            ],
          ),
        );
        break;
    }

    // Default fallback
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: KStyle.cE3GreyColor,
            width: 1,
          ),
        ),
      ),
      child: TextFormField(
        decoration: InputDecoration(
          hintText: field.placeholder ?? 'Your answer',
          border: InputBorder.none,
          hintStyle: KStyle.labelMdRegularTextStyle.copyWith(
            color: KStyle.c72GreyColor,
          ),
        ),
        onChanged: (value) {
          _responses[field.id] = value;
        },
        validator: (value) {
          if (field.required && (value == null || value.isEmpty)) {
            return 'This field is required';
          }
          return null;
        },
      ),
    );
  }
}
