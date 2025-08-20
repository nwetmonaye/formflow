import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:formflow/constants/style.dart';
import 'package:formflow/models/form_model.dart' as form_model;
import 'package:formflow/services/firebase_service.dart';
import 'package:formflow/models/submission_model.dart';
import 'package:formflow/widgets/form_header.dart';

class FormSubmissionScreen extends StatefulWidget {
  final String formId;
  final String? accessToken;

  const FormSubmissionScreen({
    super.key,
    required this.formId,
    this.accessToken,
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
  bool _isSubmitting = false; // Track submit button state

  @override
  void initState() {
    super.initState();
    _loadForm();
  }

  Future<void> _loadForm() async {
    try {
      print('🔍 Loading form with ID: ${widget.formId}');

      // First validate form access
      bool hasAccess = false;
      try {
        if (await FirebaseService.ensureInitialized()) {
          // Check if form is publicly accessible or validate access token
          if (widget.accessToken != null) {
            hasAccess = await FirebaseService.validateFormAccess(widget.formId,
                accessToken: widget.accessToken);
            print('🔍 Form access check with token: $hasAccess');
          } else {
            hasAccess =
                await FirebaseService.isFormPubliclyAccessible(widget.formId);
            print('🔍 Form access check (public): $hasAccess');
          }
        }
      } catch (e) {
        print('🔍 Error checking form access: $e');
      }

      if (!hasAccess) {
        setState(() {
          isError = true;
          errorMessage =
              'This form is not publicly accessible or has been removed.';
          isLoading = false;
        });
        print('🔍 Form access denied: ${widget.formId}');
        return;
      }

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
    setState(() {
      _isSubmitting = true;
    });
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

            // Create better email template
            final emailHtml = '''
              <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
                <h2 style="color: #2563eb;">New Form Submission Received!</h2>
                <p>You have received a new submission for your form: <strong>${form!.title}</strong></p>
                
                <div style="background: #f8fafc; padding: 20px; border-radius: 8px; margin: 20px 0;">
                  <h3 style="color: #1e293b; margin-top: 0;">Submitter Details:</h3>
                  <p><strong>Name:</strong> ${submission.submitterName}</p>
                  <p><strong>Email:</strong> ${submission.submitterEmail}</p>
                  <p><strong>Submitted:</strong> ${DateTime.now().toString()}</p>
                </div>
                
                <p>You can review this submission in your FormFlow dashboard.</p>
                
                <div style="text-align: center; margin-top: 30px;">
                  <a href="https://formflow-b0484.web.app" style="background: #2563eb; color: white; padding: 12px 24px; text-decoration: none; border-radius: 6px; display: inline-block;">View Dashboard</a>
                </div>
              </div>
            ''';

            // Send email using HTTP function
            final emailSent = await FirebaseService.sendEmail(
              to: form!.formOwnerEmail!,
              subject: 'New Form Submission - ${form!.title}',
              html: emailHtml,
              type: 'new_submission',
              formTitle: form!.title,
              submitterName: submission.submitterName,
              submitterEmail: submission.submitterEmail,
            );

            if (emailSent) {
              print('✅ New submission email sent successfully to form owner');
            } else {
              print('❌ Failed to send new submission email to form owner');
            }
          } catch (e) {
            print('❌ Failed to send new submission email to form owner: $e');
          }
        } else {
          print('⚠️ No form owner email found, skipping notification email');
        }

        setState(() {
          _showSuccessCard = true;
          _isSubmitting = false;
        });
        return;
      } else {
        throw Exception('Firebase not available');
      }
    } catch (e) {
      setState(() {
        _isSubmitting = false;
      });
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
      _isSubmitting = false;
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
      backgroundColor: KStyle.cWhiteColor,
      body: SingleChildScrollView(
        child: Container(
          decoration: BoxDecoration(
            color: KStyle.cWhiteColor,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (_showSuccessCard)
                Center(
                  child: Container(
                    width: 500,
                    margin: const EdgeInsets.only(bottom: 12),
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
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Top border/accent
                        Container(
                          height: 6,
                          decoration: BoxDecoration(
                            color: KStyle.cPrimaryColor,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(12),
                              topRight: Radius.circular(12),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Checkmark in colored circle
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: KStyle.cSelectedColor,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: IconButton(
                              onPressed: () {},
                              icon: Container(
                                width: 24,
                                height: 24,
                                child: SvgPicture.asset(
                                  'assets/icons/check.svg',
                                  width: 17,
                                  height: 17,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Your submission is successful!',
                          style: KStyle.heading2TextStyle.copyWith(
                            color: KStyle.c3BGreyColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 20,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          form!.title.isNotEmpty
                              ? form!.title
                              : 'Untitled Form',
                          style: KStyle.labelTextStyle.copyWith(
                            color: KStyle.c3BGreyColor,
                            fontWeight: FontWeight.w400,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          form!.description.isNotEmpty
                              ? form!.description
                              : 'Form Description is the description of the form to describe more about the form.',
                          style: KStyle.labelTextStyle.copyWith(
                            color: KStyle.c3BGreyColor,
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        // Optionally, add a button to submit another response
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'form',
                              style: KStyle.labelTextStyle.copyWith(
                                  color: KStyle.cBlackColor, fontSize: 20),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              margin: const EdgeInsets.only(top: 10),
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: KStyle.cPrimaryColor,
                                borderRadius: BorderRadius.circular(50),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 32),
                      ],
                    ),
                  ),
                )
              else ...[
                Center(
                  child: Container(
                    width: 700,
                    margin: const EdgeInsets.only(bottom: 24),
                    child: FormHeader(
                      title: form!.title,
                      description: form!.description,
                      showEditIcon: false,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                'Email',
                                style: KStyle.labelMdRegularTextStyle.copyWith(
                                  color: KStyle.cBlackColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                ' *',
                                style: KStyle.labelMdRegularTextStyle.copyWith(
                                  color: KStyle.cRedColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            initialValue: _responses['email'] ?? '',
                            decoration: InputDecoration(
                              hintText: 'Valid Email',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(6),
                                borderSide: BorderSide(
                                  color: KStyle.cE3GreyColor,
                                  width: 1,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(6),
                                borderSide: BorderSide(
                                  color: KStyle.cE3GreyColor,
                                  width: 1,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(6),
                                borderSide: BorderSide(
                                  color: KStyle.cPrimaryColor,
                                  width: 2,
                                ),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 12),
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
                              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4} 0$')
                                  .hasMatch(value)) {
                                return 'Please enter a valid email';
                              }
                              return null;
                            },
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
                                onPressed: _isSubmitting ? null : _submitForm,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _isSubmitting
                                      ? KStyle.cE3GreyColor
                                      : KStyle.cPrimaryColor,
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
              if (field.type == 'text' || field.type == 'number')
                TextFormField(
                  decoration: InputDecoration(
                    hintText: field.placeholder ?? 'Your answer',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                      borderSide: BorderSide(
                        color: KStyle.cE3GreyColor,
                        width: 1,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                      borderSide: BorderSide(
                        color: KStyle.cE3GreyColor,
                        width: 1,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                      borderSide: BorderSide(
                        color: KStyle.cPrimaryColor,
                        width: 2,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    hintStyle: KStyle.labelMdRegularTextStyle.copyWith(
                      color: KStyle.c72GreyColor,
                    ),
                  ),
                  keyboardType: field.type == 'number'
                      ? TextInputType.number
                      : TextInputType.text,
                  onChanged: (value) {
                    _responses[field.id] =
                        field.type == 'number' ? double.tryParse(value) : value;
                  },
                  validator: (value) {
                    if (field.required && (value == null || value.isEmpty)) {
                      return 'This field is required';
                    }
                    return null;
                  },
                )
              else
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
        final selectedDate = _responses[field.id];
        String displayDate = field.placeholder ?? 'mm/dd/yyyy';
        if (selectedDate is DateTime) {
          displayDate =
              '${selectedDate.month.toString().padLeft(2, '0')}/${selectedDate.day.toString().padLeft(2, '0')}/${selectedDate.year}';
        }
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
                  controller: TextEditingController(text: displayDate),
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
                      initialDate: selectedDate is DateTime
                          ? selectedDate
                          : DateTime.now(),
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
