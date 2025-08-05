import 'package:flutter/material.dart';
import 'package:formflow/constants/style.dart';
import 'package:formflow/models/form_model.dart' as form_model;
import 'package:formflow/services/firebase_service.dart';
import 'package:uuid/uuid.dart';

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
  form_model.FormModel? _form;
  bool _isLoading = true;
  bool _isSubmitting = false;
  final Map<String, dynamic> _responses = {};
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _loadForm();
  }

  Future<void> _loadForm() async {
    try {
      final form = await FirebaseService.getForm(widget.formId);
      setState(() {
        _form = form;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading form: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      final submission = {
        'formId': widget.formId,
        'submissionId': const Uuid().v4(),
        'data': _responses,
        'status': _form!.requiresApproval ? 'pending' : 'approved',
        'createdAt': DateTime.now(),
        'submitterName': _responses['submitterName'] ?? 'Anonymous',
        'submitterEmail': _responses['submitterEmail'] ?? '',
      };

      await FirebaseService.firestore!
          .collection('submissions')
          .add(submission);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Form submitted successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      // Navigate back or show success screen
      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error submitting form: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  Color _getThemeColor() {
    if (_form == null) return KStyle.cPrimaryColor;

    switch (_form!.colorTheme) {
      case 'green':
        return const Color(0xFF10B981);
      case 'orange':
        return const Color(0xFFF59E0B);
      case 'red':
        return const Color(0xFFEF4444);
      default:
        return KStyle.cPrimaryColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: KStyle.cBgColor,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_form == null) {
      return Scaffold(
        backgroundColor: KStyle.cBgColor,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'Form not found',
                style: KStyle.heading3TextStyle.copyWith(
                  color: KStyle.cBlackColor,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: KStyle.cBgColor,
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: KStyle.cWhiteColor,
                  border: Border(
                    left: BorderSide(
                      color: _getThemeColor(),
                      width: 4,
                    ),
                    right: BorderSide(color: KStyle.cE3GreyColor),
                    top: BorderSide(color: KStyle.cE3GreyColor),
                    bottom: BorderSide(color: KStyle.cE3GreyColor),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _form!.title,
                      style: KStyle.heading2TextStyle.copyWith(
                        color: KStyle.cBlackColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _form!.description,
                      style: KStyle.bodyMdRegularTextStyle.copyWith(
                        color: KStyle.c72GreyColor,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Form Fields
              ..._form!.fields
                  .map((field) => Padding(
                        padding: const EdgeInsets.only(bottom: 24),
                        child: _buildFieldWidget(field),
                      ))
                  .toList(),

              // Submit Button
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _getThemeColor(),
                    foregroundColor: KStyle.cWhiteColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(
                          'Submit Form',
                          style: KStyle.labelMdRegularTextStyle.copyWith(
                            color: KStyle.cWhiteColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFieldWidget(form_model.FormField field) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: KStyle.cWhiteColor,
        border: Border.all(color: KStyle.cE3GreyColor),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${field.label}${field.required ? ' *' : ''}',
            style: KStyle.labelMdRegularTextStyle.copyWith(
              color: KStyle.cBlackColor,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          _buildInputWidget(field),
        ],
      ),
    );
  }

  Widget _buildInputWidget(form_model.FormField field) {
    switch (field.type) {
      case 'text':
        return TextFormField(
          decoration: InputDecoration(
            hintText: field.placeholder ?? 'Your answer',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: KStyle.cE3GreyColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: KStyle.cE3GreyColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: _getThemeColor()),
            ),
          ),
          validator: field.required
              ? (value) {
                  if (value == null || value.isEmpty) {
                    return 'This field is required';
                  }
                  return null;
                }
              : null,
          onChanged: (value) {
            _responses[field.id] = value;
          },
        );

      case 'number':
        return TextFormField(
          decoration: InputDecoration(
            hintText: field.placeholder ?? 'Your answer',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: KStyle.cE3GreyColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: KStyle.cE3GreyColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: _getThemeColor()),
            ),
          ),
          keyboardType: TextInputType.number,
          validator: field.required
              ? (value) {
                  if (value == null || value.isEmpty) {
                    return 'This field is required';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                }
              : null,
          onChanged: (value) {
            _responses[field.id] = value;
          },
        );

      case 'multiple_choice':
        return Column(
          children: (field.options ?? []).map((option) {
            return RadioListTile<String>(
              title: Text(option),
              value: option,
              groupValue: _responses[field.id],
              onChanged: (value) {
                setState(() {
                  _responses[field.id] = value;
                });
              },
              activeColor: _getThemeColor(),
            );
          }).toList(),
        );

      case 'checkbox':
        return Column(
          children: (field.options ?? []).map((option) {
            return CheckboxListTile(
              title: Text(option),
              value:
                  (_responses[field.id] as List<dynamic>?)?.contains(option) ??
                      false,
              onChanged: (value) {
                setState(() {
                  if (_responses[field.id] == null) {
                    _responses[field.id] = <String>[];
                  }
                  final list = List<String>.from(_responses[field.id] ?? []);
                  if (value == true) {
                    list.add(option);
                  } else {
                    list.remove(option);
                  }
                  _responses[field.id] = list;
                });
              },
              activeColor: _getThemeColor(),
            );
          }).toList(),
        );

      case 'dropdown':
        return DropdownButtonFormField<String>(
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: KStyle.cE3GreyColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: KStyle.cE3GreyColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: _getThemeColor()),
            ),
          ),
          value: _responses[field.id],
          items: (field.options ?? []).map((option) {
            return DropdownMenuItem<String>(
              value: option,
              child: Text(option),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _responses[field.id] = value;
            });
          },
          validator: field.required
              ? (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select an option';
                  }
                  return null;
                }
              : null,
        );

      case 'date':
        return TextFormField(
          decoration: InputDecoration(
            hintText: 'DD/MM/YYYY',
            prefixIcon: Icon(Icons.calendar_today, color: KStyle.c72GreyColor),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: KStyle.cE3GreyColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: KStyle.cE3GreyColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: _getThemeColor()),
            ),
          ),
          readOnly: true,
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime(1900),
              lastDate: DateTime(2100),
            );
            if (date != null) {
              setState(() {
                _responses[field.id] = date.toIso8601String();
              });
            }
          },
          validator: field.required
              ? (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a date';
                  }
                  return null;
                }
              : null,
        );

      case 'file_upload':
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            border: Border.all(
                color: KStyle.cE3GreyColor, style: BorderStyle.solid),
            borderRadius: BorderRadius.circular(8),
            color: KStyle.cF4GreyColor,
          ),
          child: Column(
            children: [
              Icon(
                Icons.upload_file,
                size: 32,
                color: _getThemeColor(),
              ),
              const SizedBox(height: 8),
              Text(
                'Upload a file',
                style: KStyle.labelMdRegularTextStyle.copyWith(
                  color: KStyle.cBlackColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Size limit: ${field.maxFileSize ?? 10} MB',
                style: KStyle.labelSmRegularTextStyle.copyWith(
                  color: KStyle.c72GreyColor,
                ),
              ),
            ],
          ),
        );

      default:
        return const SizedBox.shrink();
    }
  }
}
