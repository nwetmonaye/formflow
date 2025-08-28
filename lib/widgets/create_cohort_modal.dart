import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:formflow/constants/style.dart';
import 'package:formflow/models/cohort_model.dart';
import 'package:formflow/services/firebase_service.dart';

class CreateCohortModal extends StatefulWidget {
  final Function(CohortModel) onCohortCreated;

  const CreateCohortModal({
    super.key,
    required this.onCohortCreated,
  });

  @override
  State<CreateCohortModal> createState() => _CreateCohortModalState();
}

class _CreateCohortModalState extends State<CreateCohortModal> {
  final TextEditingController _cohortNameController = TextEditingController();
  final List<RecipientField> _recipientFields = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Add initial recipient field
    _addRecipient();
  }

  @override
  void dispose() {
    _cohortNameController.dispose();
    for (var field in _recipientFields) {
      field.nameController.dispose();
      field.emailController.dispose();
    }
    super.dispose();
  }

  void _addRecipient() {
    setState(() {
      _recipientFields.add(RecipientField());
    });
  }

  void _removeRecipient(int index) {
    if (_recipientFields.length > 1) {
      setState(() {
        _recipientFields.removeAt(index);
      });
    }
  }

  bool _validateForm() {
    if (_cohortNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter a cohort name'),
          backgroundColor: KStyle.cDBRedColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
      return false;
    }

    for (var field in _recipientFields) {
      if (field.nameController.text.trim().isEmpty ||
          field.emailController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Please fill in all recipient fields'),
            backgroundColor: KStyle.cDBRedColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
        return false;
      }
    }

    return true;
  }

  Future<void> _saveCohort() async {
    if (!_validateForm()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final recipients = _recipientFields
          .map((field) => CohortRecipient(
                name: field.nameController.text.trim(),
                email: field.emailController.text.trim(),
              ))
          .toList();

      final cohort = CohortModel(
        name: _cohortNameController.text.trim(),
        recipients: recipients,
        createdBy: FirebaseService.currentUser?.uid ?? '',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final savedCohort = await FirebaseService.createCohort(cohort);
      widget.onCohortCreated(savedCohort);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error creating cohort: $e'),
          backgroundColor: KStyle.cDBRedColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 600,
        decoration: BoxDecoration(
          color: KStyle.cWhiteColor,
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'New Cohort',
                  style: KStyle.heading3TextStyle.copyWith(
                    color: KStyle.cBlackColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: Icon(
                    Icons.close,
                    color: KStyle.c72GreyColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Cohort Name Field
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Cohort Name',
                  style: KStyle.labelMdRegularTextStyle.copyWith(
                    color: KStyle.cBlackColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _cohortNameController,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: KStyle.cWhiteColor,
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
                      borderSide: BorderSide(
                        color: KStyle.cPrimaryColor,
                        width: 2,
                      ),
                    ),
                    hintText: 'Cohort Name',
                    hintStyle: KStyle.labelMdRegularTextStyle.copyWith(
                      color: KStyle.c97GreyColor,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Recipients Section
            Text(
              'Recipients',
              style: KStyle.labelMdRegularTextStyle.copyWith(
                color: KStyle.cBlackColor,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),

            // Recipients List
            ..._recipientFields.asMap().entries.map((entry) {
              final index = entry.key;
              final field = entry.value;
              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Recipient Name',
                            style: KStyle.labelSmRegularTextStyle.copyWith(
                              color: KStyle.cBlackColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          TextField(
                            controller: field.nameController,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: KStyle.cWhiteColor,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(6),
                                borderSide:
                                    BorderSide(color: KStyle.cE3GreyColor),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(6),
                                borderSide:
                                    BorderSide(color: KStyle.cE3GreyColor),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(6),
                                borderSide:
                                    BorderSide(color: KStyle.cPrimaryColor),
                              ),
                              hintText: 'Name',
                              hintStyle:
                                  KStyle.labelSmRegularTextStyle.copyWith(
                                color: KStyle.c97GreyColor,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Email',
                            style: KStyle.labelSmRegularTextStyle.copyWith(
                              color: KStyle.cBlackColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          TextField(
                            controller: field.emailController,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: KStyle.cWhiteColor,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(6),
                                borderSide:
                                    BorderSide(color: KStyle.cE3GreyColor),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(6),
                                borderSide:
                                    BorderSide(color: KStyle.cE3GreyColor),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(6),
                                borderSide:
                                    BorderSide(color: KStyle.cPrimaryColor),
                              ),
                              hintText: 'Email',
                              hintStyle:
                                  KStyle.labelSmRegularTextStyle.copyWith(
                                color: KStyle.c97GreyColor,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (_recipientFields.length > 1) ...[
                      const SizedBox(width: 16),
                      // Container(
                      //   decoration: BoxDecoration(
                      //     color: KStyle.cFFOrangeColor,
                      //     borderRadius: BorderRadius.circular(4),
                      //   ),
                      //   child: IconButton(
                      //     onPressed: () => _removeRecipient(index),
                      //     icon: Icon(
                      //       Icons.delete_outline,
                      //       color: KStyle.cRedColor,
                      //       size: 18,
                      //     ),
                      //     style: IconButton.styleFrom(
                      //       padding: const EdgeInsets.all(8),
                      //       minimumSize: const Size(32, 32),
                      //     ),
                      //   ),
                      // ),

                      Padding(
                        padding: const EdgeInsets.only(top: 25),
                        child: Row(
                          children: [
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: KStyle.cFFColor,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: IconButton(
                                onPressed: () => _removeRecipient(index),
                                icon: SvgPicture.asset(
                                  'assets/icons/delete.svg',
                                  width: 17,
                                  height: 17,
                                ),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              );
            }).toList(),

            // Add Recipient Button
            Center(
              child: TextButton.icon(
                onPressed: _addRecipient,
                icon: Icon(
                  Icons.add,
                  color: KStyle.cPrimaryColor,
                  size: 18,
                ),
                label: Text(
                  '+ Add Recipient',
                  style: KStyle.labelMdRegularTextStyle.copyWith(
                    color: KStyle.cPrimaryColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Action Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed:
                      _isLoading ? null : () => Navigator.of(context).pop(),
                  style: TextButton.styleFrom(
                    backgroundColor: KStyle.cEDBlueColor,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                  ),
                  child: Text(
                    'Cancel',
                    style: KStyle.labelMdRegularTextStyle.copyWith(
                      color: KStyle.cPrimaryColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: _isLoading ? null : _saveCohort,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: KStyle.cPrimaryColor,
                    foregroundColor: KStyle.cWhiteColor,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isLoading
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: KStyle.cWhiteColor,
                          ),
                        )
                      : Text(
                          'Save',
                          style: KStyle.labelMdRegularTextStyle.copyWith(
                            color: KStyle.cWhiteColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class RecipientField {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
}
