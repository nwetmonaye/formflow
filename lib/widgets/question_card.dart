import 'package:flutter/material.dart';
import 'package:formflow/constants/style.dart';
import 'package:formflow/models/form_model.dart' as form_model;

class QuestionCard extends StatefulWidget {
  final form_model.FormField field;
  final bool isSelected;
  final Color themeColor;
  final Function(dynamic) onUpdate;
  final VoidCallback onDelete;
  final VoidCallback onDuplicate;

  const QuestionCard({
    super.key,
    required this.field,
    required this.isSelected,
    required this.themeColor,
    required this.onUpdate,
    required this.onDelete,
    required this.onDuplicate,
  });

  @override
  State<QuestionCard> createState() => _QuestionCardState();
}

class _QuestionCardState extends State<QuestionCard> {
  late TextEditingController _labelController;
  late TextEditingController _placeholderController;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _labelController = TextEditingController(text: widget.field.label);
    _placeholderController =
        TextEditingController(text: widget.field.placeholder ?? '');
  }

  @override
  void didUpdateWidget(QuestionCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.field.label != widget.field.label && !_isEditing) {
      _labelController.text = widget.field.label;
    }
    if (oldWidget.field.placeholder != widget.field.placeholder) {
      _placeholderController.text = widget.field.placeholder ?? '';
    }
  }

  @override
  void dispose() {
    _labelController.dispose();
    _placeholderController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: KStyle.cWhiteColor,
            border: Border.all(color: KStyle.cE3GreyColor),
            borderRadius: BorderRadius.circular(8),
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
              // Question Input Area
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: _isEditing
                          ? TextField(
                              controller: _labelController,
                              onChanged: (value) {
                                final updatedField =
                                    widget.field.copyWith(label: value);
                                widget.onUpdate(updatedField);
                              },
                              onSubmitted: (value) {
                                setState(() {
                                  _isEditing = false;
                                });
                              },
                              autofocus: true,
                              style: KStyle.labelMdRegularTextStyle.copyWith(
                                color: KStyle.cBlackColor,
                              ),
                              decoration: const InputDecoration(
                                hintText: 'Type a question',
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.zero,
                              ),
                            )
                          : GestureDetector(
                              onTap: () {
                                setState(() {
                                  _isEditing = true;
                                });
                              },
                              child: Text(
                                widget.field.label,
                                style: KStyle.labelMdRegularTextStyle.copyWith(
                                  color: KStyle.cBlackColor,
                                ),
                              ),
                            ),
                    ),
                    if (widget.field.required)
                      Text(
                        '*',
                        style: KStyle.labelMdRegularTextStyle.copyWith(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: widget.onDuplicate,
                      icon: Icon(
                        Icons.copy,
                        size: 16,
                        color: KStyle.c72GreyColor,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    IconButton(
                      onPressed: widget.onDelete,
                      icon: Icon(
                        Icons.delete,
                        size: 16,
                        color: KStyle.cDBRedColor,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),

              // Answer Input Area
              Padding(
                padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
                child: _buildAnswerInput(),
              ),

              // Required Toggle
              Padding(
                padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
                child: Row(
                  children: [
                    Text(
                      'Required',
                      style: KStyle.labelSmRegularTextStyle.copyWith(
                        color: KStyle.c72GreyColor,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Switch(
                      value: widget.field.required,
                      onChanged: (value) {
                        final updatedField =
                            widget.field.copyWith(required: value);
                        widget.onUpdate(updatedField);
                      },
                      activeColor: KStyle.cPrimaryColor,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Question Type Label (Yellow badge) - positioned at top right
        Positioned(
          top: 8,
          right: 8,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFFFD700),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              _getQuestionTypeName(widget.field.type),
              style: KStyle.labelXsRegularTextStyle.copyWith(
                color: KStyle.cBlackColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAnswerInput() {
    switch (widget.field.type) {
      case 'text':
      case 'number':
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(color: KStyle.cE3GreyColor),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            'Your answer',
            style: KStyle.labelSmRegularTextStyle.copyWith(
              color: KStyle.c72GreyColor,
            ),
          ),
        );

      case 'multiple_choice':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ...(widget.field.options ?? ['Choice 1'])
                .asMap()
                .entries
                .map((entry) {
              final index = entry.key;
              final choice = entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Icon(
                      Icons.radio_button_checked,
                      size: 16,
                      color: KStyle.cPrimaryColor,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      choice,
                      style: KStyle.labelSmRegularTextStyle.copyWith(
                        color: KStyle.cBlackColor,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          border: Border.all(color: KStyle.cE3GreyColor),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '',
                          style: KStyle.labelSmRegularTextStyle.copyWith(
                            color: KStyle.cBlackColor,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () {
                _addChoice();
              },
              child: Text(
                '+ Add Choice',
                style: KStyle.labelSmRegularTextStyle.copyWith(
                  color: KStyle.cPrimaryColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        );

      case 'checkbox':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ...(widget.field.options ?? ['Choice 1'])
                .asMap()
                .entries
                .map((entry) {
              final index = entry.key;
              final choice = entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Icon(
                      Icons.check_box,
                      size: 16,
                      color: KStyle.cPrimaryColor,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      choice,
                      style: KStyle.labelSmRegularTextStyle.copyWith(
                        color: KStyle.cBlackColor,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          border: Border.all(color: KStyle.cE3GreyColor),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '',
                          style: KStyle.labelSmRegularTextStyle.copyWith(
                            color: KStyle.cBlackColor,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () {
                _addChoice();
              },
              child: Text(
                '+ Add Choice',
                style: KStyle.labelSmRegularTextStyle.copyWith(
                  color: KStyle.cPrimaryColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        );

      case 'dropdown':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ...(widget.field.options ?? ['Choice 1'])
                .asMap()
                .entries
                .map((entry) {
              final index = entry.key;
              final choice = entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Text(
                      choice,
                      style: KStyle.labelSmRegularTextStyle.copyWith(
                        color: KStyle.cBlackColor,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          border: Border.all(color: KStyle.cE3GreyColor),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '',
                          style: KStyle.labelSmRegularTextStyle.copyWith(
                            color: KStyle.cBlackColor,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () {
                _addChoice();
              },
              child: Text(
                '+ Add Choice',
                style: KStyle.labelSmRegularTextStyle.copyWith(
                  color: KStyle.cPrimaryColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        );

      case 'date':
        return Row(
          children: [
            Icon(
              Icons.calendar_today,
              size: 16,
              color: KStyle.c72GreyColor,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: KStyle.cE3GreyColor),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'DD/MM/YYYY',
                  style: KStyle.labelSmRegularTextStyle.copyWith(
                    color: KStyle.c72GreyColor,
                  ),
                ),
              ),
            ),
          ],
        );

      case 'file_upload':
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            border: Border.all(
                color: KStyle.cE3GreyColor, style: BorderStyle.solid),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              Icon(
                Icons.cloud_upload,
                size: 32,
                color: KStyle.cPrimaryColor,
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
                'Size limit: 10 MB',
                style: KStyle.labelSmRegularTextStyle.copyWith(
                  color: KStyle.c72GreyColor,
                ),
              ),
            ],
          ),
        );

      default:
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(color: KStyle.cE3GreyColor),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            'Your answer',
            style: KStyle.labelSmRegularTextStyle.copyWith(
              color: KStyle.c72GreyColor,
            ),
          ),
        );
    }
  }

  void _addChoice() {
    final currentOptions = List<String>.from(widget.field.options ?? []);
    final newChoiceNumber = currentOptions.length + 1;
    currentOptions.add('Choice $newChoiceNumber');

    final updatedField = widget.field.copyWith(options: currentOptions);
    widget.onUpdate(updatedField);
  }

  String _getQuestionTypeName(String type) {
    switch (type) {
      case 'text':
        return 'Text, Number';
      case 'number':
        return 'Text, Number';
      case 'multiple_choice':
        return 'Multiple Choice';
      case 'checkbox':
        return 'Checkboxes';
      case 'dropdown':
        return 'Dropdown';
      case 'date':
        return 'Date';
      case 'file_upload':
        return 'File Upload';
      default:
        return 'Unknown';
    }
  }
}
