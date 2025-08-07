import 'package:flutter/material.dart';
import 'package:formflow/constants/style.dart';
import 'package:formflow/models/form_model.dart' as form_model;
import 'package:formflow/widgets/question_type_dialog.dart';
import 'package:formflow/widgets/question_card.dart';
import 'package:formflow/services/firebase_service.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_svg/flutter_svg.dart';

class FormBuilderScreen extends StatefulWidget {
  final form_model.FormModel? form; // If null, create new form

  const FormBuilderScreen({super.key, this.form});

  @override
  State<FormBuilderScreen> createState() => _FormBuilderScreenState();
}

class _FormBuilderScreenState extends State<FormBuilderScreen> {
  late form_model.FormModel _form;
  final _uuid = const Uuid();
  bool _isSaving = false;
  bool _isPublishing = false;
  bool _canShare = false;
  late TextEditingController _titleController;
  bool _isEditingTitle = false;

  @override
  void initState() {
    super.initState();
    _form = widget.form ??
        form_model.FormModel(
          title: 'Untitled',
          description: 'Form Description',
          fields: [],
          createdBy: FirebaseService.currentUser?.uid ?? 'anonymous',
        );
    _titleController = TextEditingController(text: _form.title);
  }

  void _updateForm(form_model.FormModel updatedForm) {
    setState(() {
      _form = updatedForm;
    });
    if (!_isEditingTitle) {
      _titleController.text = _form.title;
    }
    _autoSave();
  }

  Future<void> _autoSave() async {
    if (_isSaving) return;

    setState(() {
      _isSaving = true;
    });

    try {
      if (_form.id != null) {
        await FirebaseService.updateForm(_form.id!, _form);
      } else {
        final formId = await FirebaseService.createForm(_form);
        setState(() {
          _form = _form.copyWith(id: formId);
        });
      }
    } catch (e) {
      print('Error auto-saving: $e');
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  Future<void> _publishForm() async {
    if (_form.fields.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text('Please add at least one question before publishing')),
      );
      return;
    }

    // Debug: Check authentication status
    final currentUser = FirebaseService.currentUser;
    print('🔍 Current user: ${currentUser?.uid}');
    print('🔍 Form createdBy: ${_form.createdBy}');
    print('🔍 Form ID: ${_form.id}');

    setState(() {
      _isPublishing = true;
    });

    try {
      // First save the form if it hasn't been saved yet
      if (_form.id == null) {
        final formId = await FirebaseService.createForm(_form);
        _form = _form.copyWith(id: formId);
      }

      // Publish form (updates status and generates share link)
      await FirebaseService.publishForm(_form.id!);

      // Refresh form data to get the updated share link
      final refreshedForm = await FirebaseService.getForm(_form.id!);
      if (refreshedForm != null) {
        setState(() {
          _form = refreshedForm;
          _canShare = true;
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Form published successfully!')),
      );
    } catch (e) {
      String errorMessage = 'Error publishing form';
      if (e.toString().contains('permission-denied')) {
        errorMessage = 'Permission denied. Please check your Firebase rules.';
      } else if (e.toString().contains('not-found')) {
        errorMessage = 'Form not found. Please try saving the form first.';
      } else if (e.toString().contains('unavailable')) {
        errorMessage =
            'Firebase service unavailable. Please check your internet connection.';
      } else {
        errorMessage = 'Error publishing form: ${e.toString()}';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isPublishing = false;
      });
    }
  }

  void _addQuestion() {
    showDialog(
      context: context,
      builder: (context) => QuestionTypeDialog(
        onQuestionTypeSelected: (type) {
          final newField = form_model.FormField(
            id: _uuid.v4(),
            label: 'Type a question',
            type: type,
            required: true,
            options: type == 'multiple_choice' ||
                    type == 'checkbox' ||
                    type == 'dropdown'
                ? ['Choice 1']
                : null,
            placeholder:
                type == 'file_upload' ? 'Upload a file' : 'Your answer',
            maxFileSize: type == 'file_upload' ? 10 : null,
          );

          final updatedForm = _form.copyWith(
            fields: [..._form.fields, newField],
          );
          _updateForm(updatedForm);
        },
      ),
    );
  }

  void _updateField(int index, form_model.FormField field) {
    final updatedFields = List<form_model.FormField>.from(_form.fields);
    updatedFields[index] = field;
    final updatedForm = _form.copyWith(fields: updatedFields);
    _updateForm(updatedForm);
  }

  void _deleteField(int index) {
    final updatedFields = List<form_model.FormField>.from(_form.fields);
    updatedFields.removeAt(index);
    final updatedForm = _form.copyWith(fields: updatedFields);
    _updateForm(updatedForm);
  }

  void _duplicateField(int index) {
    final fieldToDuplicate = _form.fields[index];
    final duplicatedField = fieldToDuplicate.copyWith(id: _uuid.v4());
    final updatedFields = List<form_model.FormField>.from(_form.fields);
    updatedFields.insert(index + 1, duplicatedField);
    final updatedForm = _form.copyWith(fields: updatedFields);
    _updateForm(updatedForm);
  }

  void _updateColorTheme(String color) {
    final updatedForm = _form.copyWith(colorTheme: color);
    _updateForm(updatedForm);
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KStyle.cBgColor,
      body: Container(
        color: KStyle.cWhiteColor,
        child: Column(
          children: [
            // Top Toolbar
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: KStyle.cWhiteColor,
                border: Border(
                  bottom: BorderSide(
                    color: KStyle.cE3GreyColor,
                    width: 1,
                  ),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Breadcrumbs
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).pop();
                        },
                        child: Text(
                          'My Forms',
                          style: KStyle.labelSmRegularTextStyle.copyWith(
                            color: KStyle.c13BlackColor,
                          ),
                        ),
                      ),
                      Text(
                        ' / ',
                        style: KStyle.labelSmRegularTextStyle.copyWith(
                          color: KStyle.c72GreyColor,
                        ),
                      ),
                      Text(
                        _form.title,
                        style: KStyle.labelSmRegularTextStyle.copyWith(
                          color: KStyle.c72GreyColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Main header row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Text(
                              _form.title,
                              style: KStyle.headingTextStyle.copyWith(
                                color: KStyle.cBlackColor,
                                fontSize: 24,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 16),
                            if (_isSaving) ...[
                              const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.green),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Saving...',
                                style: KStyle.labelSmRegularTextStyle.copyWith(
                                  color: Colors.green,
                                ),
                              ),
                            ] else ...[
                              const Icon(
                                Icons.check_circle,
                                color: Colors.green,
                                size: 16,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Saved changes',
                                style: KStyle.labelSmRegularTextStyle.copyWith(
                                  color: Colors.green,
                                ),
                              ),
                            ],
                            const SizedBox(width: 16),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: KStyle.cF4GreyColor,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'Draft',
                                style: KStyle.labelSmRegularTextStyle.copyWith(
                                  color: KStyle.c72GreyColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            onPressed: () {
                              // TODO: Implement approval settings
                            },
                            icon: Container(
                              width: 24,
                              height: 24,
                              child: SvgPicture.asset(
                                'assets/icons/settings.svg',
                                width: 17,
                                height: 17,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          IconButton(
                            onPressed: () {
                              // TODO: Implement preview
                            },
                            icon: Container(
                              width: 24,
                              height: 24,
                              child: SvgPicture.asset(
                                'assets/icons/eye.svg',
                                width: 17,
                                height: 17,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          IconButton(
                            onPressed: _canShare
                                ? () {
                                    if (_form.shareLink != null) {
                                      // Copy to clipboard
                                      // TODO: Implement clipboard functionality
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(
                                              'Link copied: ${_form.shareLink}'),
                                        ),
                                      );
                                    }
                                  }
                                : null,
                            icon: Container(
                              width: 22,
                              height: 22,
                              child: SvgPicture.asset(
                                'assets/icons/copy.svg',
                                width: 17,
                                height: 17,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton.icon(
                            onPressed: _canShare
                                ? () {
                                    if (_form.shareLink != null) {
                                      // Copy to clipboard
                                      // TODO: Implement clipboard functionality
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(
                                              'Link copied: ${_form.shareLink}'),
                                        ),
                                      );
                                    }
                                  }
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _canShare
                                  ? KStyle.cPrimaryColor.withOpacity(0.1)
                                  : KStyle.cE3GreyColor,
                              foregroundColor: _canShare
                                  ? KStyle.cPrimaryColor
                                  : KStyle.c72GreyColor,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            icon: const Icon(Icons.people, size: 16),
                            label: Text(
                              'Share',
                              style: KStyle.labelSmRegularTextStyle,
                            ),
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton.icon(
                            onPressed: _isPublishing ? null : _publishForm,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: KStyle.cPrimaryColor,
                              foregroundColor: KStyle.cWhiteColor,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            icon: _isPublishing
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          Colors.white),
                                    ),
                                  )
                                : const Icon(Icons.arrow_upward, size: 16),
                            label: Text(
                              _isPublishing ? 'Publishing...' : 'Publish',
                              style: KStyle.labelSmRegularTextStyle.copyWith(
                                color: KStyle.cWhiteColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Form Builder Area
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    // Custom Title Field
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: KStyle.cWhiteColor,
                        border: Border(
                          left: BorderSide(
                            color: KStyle.cPrimaryColor,
                            width: 4,
                          ),
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Expanded(
                            child: _isEditingTitle
                                ? TextField(
                                    controller: _titleController,
                                    onChanged: (value) {
                                      final updatedForm =
                                          _form.copyWith(title: value);
                                      _updateForm(updatedForm);
                                    },
                                    onSubmitted: (value) {
                                      setState(() {
                                        _isEditingTitle = false;
                                      });
                                    },
                                    autofocus: true,
                                    style: KStyle.heading3TextStyle.copyWith(
                                      color: KStyle.cBlackColor,
                                    ),
                                    decoration: const InputDecoration(
                                      hintText: 'Enter form title',
                                      border: InputBorder.none,
                                      contentPadding: EdgeInsets.zero,
                                    ),
                                  )
                                : GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _isEditingTitle = true;
                                      });
                                    },
                                    child: Text(
                                      _form.title,
                                      style: KStyle.heading3TextStyle.copyWith(
                                        color: KStyle.cBlackColor,
                                      ),
                                    ),
                                  ),
                          ),
                          const SizedBox(width: 8),
                          SvgPicture.asset(
                            'assets/icons/edit.svg',
                            width: 17,
                            height: 17,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Questions
                    ..._form.fields.asMap().entries.map((entry) {
                      final index = entry.key;
                      final field = entry.value;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: QuestionCard(
                          field: field,
                          isSelected: false, // TODO: Implement selection
                          themeColor: _getThemeColor(),
                          onUpdate: (updatedField) => _updateField(
                              index, updatedField as form_model.FormField),
                          onDelete: () => _deleteField(index),
                          onDuplicate: () => _duplicateField(index),
                        ),
                      );
                    }).toList(),

                    const SizedBox(height: 24),

                    // Add Question Button
                    Center(
                      child: ElevatedButton.icon(
                        onPressed: _addQuestion,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: KStyle.cSelectedColor,
                          foregroundColor: KStyle.cPrimaryColor,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        icon: Container(
                          width: 20,
                          height: 20,
                          child: SvgPicture.asset(
                            'assets/icons/plus_blank.svg',
                            width: 20,
                            height: 20,
                          ),
                        ),
                        label: Text(
                          'Add Question',
                          style: KStyle.labelMdRegularTextStyle.copyWith(
                            color: KStyle.cPrimaryColor,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildColorOption(String colorName, Color color) {
    final isSelected = _form.colorTheme == colorName;
    return GestureDetector(
      onTap: () => _updateColorTheme(colorName),
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? KStyle.cBlackColor : Colors.transparent,
            width: 2,
          ),
        ),
      ),
    );
  }

  Color _getThemeColor() {
    switch (_form.colorTheme) {
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
}
