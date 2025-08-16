import 'package:flutter/material.dart';
import 'package:formflow/constants/style.dart';

class QuestionTypeDialog extends StatelessWidget {
  final Function(String) onQuestionTypeSelected;

  const QuestionTypeDialog({
    super.key,
    required this.onQuestionTypeSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        width: 300,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header with title and close button
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: KStyle.cWhiteColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
                border: Border(
                  bottom: BorderSide(
                    color: KStyle.cE3GreyColor,
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Add Question',
                    style: KStyle.heading4TextStyle.copyWith(
                      color: KStyle.cBlackColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(
                      Icons.close,
                      color: KStyle.c72GreyColor,
                      size: 20,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),

            // Question type options
            Container(
              decoration: BoxDecoration(
                color: KStyle.cWhiteColor,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
              ),
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                children: [
                  _buildQuestionTypeOption(
                      context, 'text', 'Text', Icons.text_fields),
                  _buildQuestionTypeOption(
                      context, 'number', 'Number', Icons.numbers),
                  _buildQuestionTypeOption(context, 'multiple_choice',
                      'Multiple Choice', Icons.format_list_bulleted),
                  _buildQuestionTypeOption(
                      context, 'checkbox', 'Checkbox', Icons.check_box),
                  _buildQuestionTypeOption(context, 'dropdown', 'Dropdown',
                      Icons.keyboard_arrow_down),
                  _buildQuestionTypeOption(
                      context, 'date', 'Date', Icons.calendar_today),
                  _buildQuestionTypeOption(
                      context, 'file_upload', 'File Upload', Icons.file_upload),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionTypeOption(
    BuildContext context,
    String type,
    String title,
    IconData icon,
  ) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pop();
        onQuestionTypeSelected(type);
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Icon(
              icon,
              color: KStyle.cPrimaryColor,
              size: 20,
            ),
            const SizedBox(width: 16),
            Text(
              title,
              style: KStyle.labelMdRegularTextStyle.copyWith(
                color: KStyle.cBlackColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
