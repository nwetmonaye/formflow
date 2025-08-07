import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'dart:async';
import 'package:formflow/constants/style.dart';
import 'package:formflow/models/form_model.dart' as form_model;
import 'package:intl/intl.dart';

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
  late TextEditingController _placeholderController;
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
    _placeholderController = TextEditingController(text: _localPlaceholder);
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
    if (oldWidget.field.label != widget.field.label) {
      _localLabel = widget.field.label;
      _labelController.text = _localLabel;
    }
    if (oldWidget.field.options != widget.field.options) {
      _localChoices = List<String>.from(widget.field.options ?? ['Choice 1']);
      _initializeChoiceControllers();
    }
    if (oldWidget.field.placeholder != widget.field.placeholder) {
      _localPlaceholder = widget.field.placeholder ?? '';
      _placeholderController.text = _localPlaceholder;
    }
  }

  @override
  void dispose() {
    _labelController.dispose();
    _placeholderController.dispose();
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
    // Save immediately to ensure data persistence
    _saveChoices();
  }

  void _saveChoices() {
    final updatedField = widget.field.copyWith(options: _localChoices);
    widget.onUpdate(updatedField);
  }

  void _updatePlaceholder(String value) {
    _localPlaceholder = value;
    // Save immediately to ensure data persistence
    _savePlaceholder();
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
            border: Border.all(
              color: widget.isSelected
                  ? KStyle.cPrimaryColor
                  : KStyle.cE3GreyColor,
              width: widget.isSelected ? 2 : 1,
            ),
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
                    Expanded(
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
                    IconButton(
                      onPressed: widget.onDuplicate,
                      icon: SvgPicture.asset(
                        'assets/icons/plus.svg',
                        width: 17,
                        height: 17,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    const SizedBox(width: 16),
                    IconButton(
                      onPressed: widget.onDelete,
                      icon: SvgPicture.asset(
                        'assets/icons/delete.svg',
                        width: 17,
                        height: 17,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
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
            controller: _placeholderController,
            onChanged: (value) {
              _updatePlaceholder(value);
            },
            textInputAction: TextInputAction.next,
            keyboardType: widget.field.type == 'number'
                ? TextInputType.number
                : TextInputType.text,
            textCapitalization: TextCapitalization.none,
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
            GestureDetector(
              onTap: () {
                _showDatePicker();
              },
              child: Icon(
                Icons.calendar_today,
                size: 16,
                color: KStyle.c72GreyColor,
              ),
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
                  controller: _placeholderController,
                  onChanged: (value) {
                    _updatePlaceholder(value);
                  },
                  onEditingComplete: () {
                    _formatDateInput();
                  },
                  textInputAction: TextInputAction.next,
                  keyboardType: TextInputType.text,
                  textCapitalization: TextCapitalization.none,
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
            controller: _placeholderController,
            onChanged: (value) {
              _updatePlaceholder(value);
            },
            textInputAction: TextInputAction.next,
            keyboardType: TextInputType.text,
            textCapitalization: TextCapitalization.none,
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

  void _showDatePicker() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: KStyle.cPrimaryColor,
              onPrimary: KStyle.cWhiteColor,
              surface: KStyle.cWhiteColor,
              onSurface: KStyle.cBlackColor,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final formattedDate = DateFormat('dd/MM/yyyy').format(picked);
      _placeholderController.text = formattedDate;
      _updatePlaceholder(formattedDate);
    }
  }

  void _formatDateInput() {
    final text = _placeholderController.text.trim();
    if (text.isNotEmpty) {
      try {
        // Try to parse various date formats
        DateTime? parsedDate;

        // Try DD/MM/YYYY format
        if (text.contains('/')) {
          final parts = text.split('/');
          if (parts.length == 3) {
            final day = int.tryParse(parts[0]);
            final month = int.tryParse(parts[1]);
            final year = int.tryParse(parts[2]);

            if (day != null && month != null && year != null) {
              parsedDate = DateTime(year, month, day);
            }
          }
        }

        // Try DD-MM-YYYY format
        if (parsedDate == null && text.contains('-')) {
          final parts = text.split('-');
          if (parts.length == 3) {
            final day = int.tryParse(parts[0]);
            final month = int.tryParse(parts[1]);
            final year = int.tryParse(parts[2]);

            if (day != null && month != null && year != null) {
              parsedDate = DateTime(year, month, day);
            }
          }
        }

        // If we successfully parsed a date, format it properly
        if (parsedDate != null) {
          final formattedDate = DateFormat('dd/MM/yyyy').format(parsedDate);
          _placeholderController.text = formattedDate;
          _updatePlaceholder(formattedDate);
        }
      } catch (e) {
        // If parsing fails, keep the original text
        print('Date parsing error: $e');
      }
    }
  }

  void _addChoice() {
    final currentOptions = List<String>.from(_localChoices);
    final newChoiceNumber = currentOptions.length + 1;
    currentOptions.add('Choice $newChoiceNumber');

    setState(() {
      _localChoices = currentOptions;
      _initializeChoiceControllers();
    });

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
              textInputAction: TextInputAction.next,
              keyboardType: TextInputType.text,
              textCapitalization: TextCapitalization.none,
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
