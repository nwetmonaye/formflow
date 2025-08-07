import 'package:flutter/material.dart';
import 'dart:async';
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
  List<TextEditingController> _choiceControllers = [];
  bool _isEditing = false;
  Timer? _debounceTimer;

  // Local state to prevent rebuilding during typing
  String _localLabel = '';
  List<String> _localChoices = [];
  String _localPlaceholder = '';

  @override
  void initState() {
    super.initState();
    _localLabel = widget.field.label;
    _localChoices = List<String>.from(widget.field.options ?? ['Choice 1']);
    _localPlaceholder = widget.field.placeholder ?? '';

    _labelController = TextEditingController(text: _localLabel);
    _initializeChoiceControllers();
  }

  void _initializeChoiceControllers() {
    // Dispose existing controllers first
    for (var controller in _choiceControllers) {
      controller.dispose();
    }

    _choiceControllers = _localChoices
        .map((option) => TextEditingController(text: option))
        .toList();
  }

  @override
  void didUpdateWidget(QuestionCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.field.label != widget.field.label && !_isEditing) {
      _localLabel = widget.field.label;
      _labelController.text = _localLabel;
    }
    if (oldWidget.field.options != widget.field.options) {
      _localChoices = List<String>.from(widget.field.options ?? ['Choice 1']);
      _initializeChoiceControllers();
    }
    if (oldWidget.field.placeholder != widget.field.placeholder) {
      _localPlaceholder = widget.field.placeholder ?? '';
    }
  }

  @override
  void dispose() {
    _labelController.dispose();
    for (var controller in _choiceControllers) {
      controller.dispose();
    }
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _debouncedUpdate(String value) {
    _localLabel = value;
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      final updatedField = widget.field.copyWith(label: _localLabel);
      widget.onUpdate(updatedField);
    });
  }

  void _updateChoice(int index, String value) {
    _localChoices[index] = value;
    // Don't update the widget immediately - let user finish typing
  }

  void _saveChoices() {
    final updatedField = widget.field.copyWith(options: _localChoices);
    widget.onUpdate(updatedField);
  }

  void _updatePlaceholder(String value) {
    _localPlaceholder = value;
    // Don't update the widget immediately - let user finish typing
  }

  void _savePlaceholder() {
    final updatedField = widget.field.copyWith(placeholder: _localPlaceholder);
    widget.onUpdate(updatedField);
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
                      child: TextField(
                        controller: _labelController,
                        onChanged: (value) {
                          _debouncedUpdate(value);
                        },
                        textInputAction: TextInputAction.next,
                        keyboardType: TextInputType.text,
                        textCapitalization: TextCapitalization.none,
                        textDirection: TextDirection.ltr,
                        style: KStyle.labelMdRegularTextStyle.copyWith(
                          color: KStyle.cBlackColor,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Type a question*',
                          hintStyle: KStyle.labelMdRegularTextStyle.copyWith(
                            color: KStyle.c72GreyColor,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                          isDense: true,
                        ),
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
                        color: KStyle.cBlackColor,
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
          child: TextField(
            onChanged: (value) {
              _updatePlaceholder(value);
            },
            onEditingComplete: () {
              _savePlaceholder();
            },
            textInputAction: TextInputAction.next,
            keyboardType: widget.field.type == 'number'
                ? TextInputType.number
                : TextInputType.text,
            textCapitalization: TextCapitalization.none,
            textDirection: TextDirection.ltr,
            style: KStyle.labelSmRegularTextStyle.copyWith(
              color: KStyle.cBlackColor,
            ),
            decoration: InputDecoration(
              hintText: 'Your answer',
              hintStyle: KStyle.labelSmRegularTextStyle.copyWith(
                color: KStyle.c72GreyColor,
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
              isDense: true,
            ),
          ),
        );

      case 'multiple_choice':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ..._choiceControllers.asMap().entries.map((entry) {
              final index = entry.key;
              final controller = entry.value;
              return _buildChoiceField(
                  index, controller, Icons.radio_button_checked);
            }).toList(),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () {
                _addChoice();
              },
              child: Row(
                children: [
                  Icon(
                    Icons.add,
                    size: 16,
                    color: KStyle.cPrimaryColor,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Add Choice',
                    style: KStyle.labelSmRegularTextStyle.copyWith(
                      color: KStyle.cPrimaryColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );

      case 'checkbox':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ..._choiceControllers.asMap().entries.map((entry) {
              final index = entry.key;
              final controller = entry.value;
              return _buildChoiceField(index, controller, Icons.check_box);
            }).toList(),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () {
                _addChoice();
              },
              child: Row(
                children: [
                  Icon(
                    Icons.add,
                    size: 16,
                    color: KStyle.cPrimaryColor,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Add Choice',
                    style: KStyle.labelSmRegularTextStyle.copyWith(
                      color: KStyle.cPrimaryColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );

      case 'dropdown':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ..._choiceControllers.asMap().entries.map((entry) {
              final index = entry.key;
              final controller = entry.value;
              return _buildChoiceField(
                  index, controller, Icons.arrow_drop_down);
            }).toList(),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () {
                _addChoice();
              },
              child: Row(
                children: [
                  Icon(
                    Icons.add,
                    size: 16,
                    color: KStyle.cPrimaryColor,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Add Choice',
                    style: KStyle.labelSmRegularTextStyle.copyWith(
                      color: KStyle.cPrimaryColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
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
                child: TextField(
                  onChanged: (value) {
                    _updatePlaceholder(value);
                  },
                  onEditingComplete: () {
                    _savePlaceholder();
                  },
                  textInputAction: TextInputAction.next,
                  keyboardType: TextInputType.text,
                  textCapitalization: TextCapitalization.none,
                  textDirection: TextDirection.ltr,
                  style: KStyle.labelSmRegularTextStyle.copyWith(
                    color: KStyle.cBlackColor,
                  ),
                  decoration: InputDecoration(
                    hintText: 'DD/MM/YYYY',
                    hintStyle: KStyle.labelSmRegularTextStyle.copyWith(
                      color: KStyle.c72GreyColor,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                    isDense: true,
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
          child: TextField(
            onChanged: (value) {
              _updatePlaceholder(value);
            },
            onEditingComplete: () {
              _savePlaceholder();
            },
            textInputAction: TextInputAction.next,
            keyboardType: TextInputType.text,
            textCapitalization: TextCapitalization.none,
            textDirection: TextDirection.ltr,
            style: KStyle.labelSmRegularTextStyle.copyWith(
              color: KStyle.cBlackColor,
            ),
            decoration: InputDecoration(
              hintText: 'Your answer',
              hintStyle: KStyle.labelSmRegularTextStyle.copyWith(
                color: KStyle.c72GreyColor,
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
              isDense: true,
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

  Widget _buildChoiceField(
      int index, TextEditingController controller, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          if (icon !=
              Icons
                  .arrow_drop_down) // Show icon for checkbox and radio, not for dropdown
            Icon(
              icon,
              size: 16,
              color: KStyle.cPrimaryColor,
            ),
          if (icon != Icons.arrow_drop_down) const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: (value) {
                _updateChoice(index, value);
              },
              onEditingComplete: () {
                _saveChoices();
              },
              textInputAction: TextInputAction.next,
              keyboardType: TextInputType.text,
              textCapitalization: TextCapitalization.none,
              textDirection: TextDirection.ltr,
              style: KStyle.labelSmRegularTextStyle.copyWith(
                color: KStyle.cBlackColor,
              ),
              decoration: InputDecoration(
                hintText: 'Choice ${index + 1}',
                hintStyle: KStyle.labelSmRegularTextStyle.copyWith(
                  color: KStyle.c72GreyColor,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                  borderSide: BorderSide(color: KStyle.cE3GreyColor),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                  borderSide: BorderSide(color: KStyle.cE3GreyColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                  borderSide: BorderSide(color: KStyle.cPrimaryColor, width: 2),
                ),
                contentPadding: const EdgeInsets.all(8),
                isDense: true,
              ),
            ),
          ),
        ],
      ),
    );
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
