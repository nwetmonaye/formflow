import 'package:flutter/material.dart';
import 'package:formflow/constants/style.dart';
import 'package:formflow/models/cohort_model.dart';
import 'package:formflow/models/form_model.dart';
import 'package:formflow/services/firebase_service.dart';

class ShareWithCohortsModal extends StatefulWidget {
  final FormModel form;
  final VoidCallback? onShared;

  const ShareWithCohortsModal({
    super.key,
    required this.form,
    this.onShared,
  });

  @override
  State<ShareWithCohortsModal> createState() => _ShareWithCohortsModalState();
}

class _ShareWithCohortsModalState extends State<ShareWithCohortsModal> {
  List<CohortModel> cohorts = [];
  CohortModel? selectedCohort;
  bool isLoading = true;
  bool isSharing = false;

  @override
  void initState() {
    super.initState();
    _loadCohorts();
  }

  Future<void> _loadCohorts() async {
    try {
      setState(() {
        isLoading = true;
      });

      final loadedCohorts = await FirebaseService.getCohorts();
      setState(() {
        cohorts = loadedCohorts;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading cohorts: $e'),
          backgroundColor: KStyle.cDBRedColor,
        ),
      );
    }
  }

  void _selectCohort(CohortModel cohort) {
    setState(() {
      selectedCohort = selectedCohort?.id == cohort.id ? null : cohort;
    });
  }

  Future<void> _shareFormWithCohort() async {
    if (selectedCohort == null) return;

    setState(() {
      isSharing = true;
    });

    try {
      // Call the Firebase function to share form with cohort
      final formLink = widget.form.shareLink ??
          'https://formflow.com/form/${widget.form.id}';

      final response = await FirebaseService.shareFormWithCohort(
        formId: widget.form.id!,
        cohortId: selectedCohort!.id!,
        formTitle: widget.form.title,
        formDescription: widget.form.description,
        formLink: formLink,
      );

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Form "${widget.form.title}" shared with "${selectedCohort!.name}" successfully'),
          backgroundColor: KStyle.cE8GreenColor,
        ),
      );

      // Close modal and notify parent
      Navigator.of(context).pop();
      widget.onShared?.call();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error sharing form: $e'),
          backgroundColor: KStyle.cDBRedColor,
        ),
      );
    } finally {
      setState(() {
        isSharing = false;
      });
    }
  }

  Future<void> _shareForm() async {
    if (selectedCohort == null) return;

    setState(() {
      isSharing = true;
    });

    try {
      // Call the Firebase function to share form with cohort
      final formLink = widget.form.shareLink ??
          'https://formflow.com/form/${widget.form.id}';

      final response = await FirebaseService.shareFormWithCohort(
        formId: widget.form.id!,
        cohortId: selectedCohort!.id!,
        formTitle: widget.form.title,
        formDescription: widget.form.description,
        formLink: formLink,
      );

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Form "${widget.form.title}" shared with "${selectedCohort!.name}" successfully'),
          backgroundColor: KStyle.cE8GreenColor,
        ),
      );

      // Close modal and notify parent
      Navigator.of(context).pop();
      widget.onShared?.call();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error sharing form: $e'),
          backgroundColor: KStyle.cDBRedColor,
        ),
      );
    } finally {
      setState(() {
        isSharing = false;
      });
    }
  }

  void _showConfirmationDialog() {
    if (selectedCohort == null) return;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Confirm Share',
            style: KStyle.heading3TextStyle.copyWith(
              color: KStyle.cBlackColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Text(
            'Are you sure to share "${widget.form.title}" with "${selectedCohort!.name}"?',
            style: KStyle.labelMdRegularTextStyle.copyWith(
              color: KStyle.cBlackColor,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: KStyle.labelMdRegularTextStyle.copyWith(
                  color: KStyle.c72GreyColor,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _shareFormWithCohort();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: KStyle.cPrimaryColor,
                foregroundColor: KStyle.cWhiteColor,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Yes, Sure',
                style: KStyle.labelMdRegularTextStyle.copyWith(
                  color: KStyle.cWhiteColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        width: 500,
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
                  'Share with Cohorts',
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

            // Content
            if (isLoading)
              Center(
                child: CircularProgressIndicator(
                  color: KStyle.cPrimaryColor,
                ),
              )
            else if (cohorts.isEmpty)
              _buildEmptyState()
            else
              _buildCohortsList(),

            const SizedBox(height: 24),

            // Action Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    'Cancel',
                    style: KStyle.labelMdRegularTextStyle.copyWith(
                      color: KStyle.c72GreyColor,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: (selectedCohort != null && !isSharing)
                      ? _showConfirmationDialog
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: KStyle.cPrimaryColor,
                    foregroundColor: KStyle.cWhiteColor,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: isSharing
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: KStyle.cWhiteColor,
                          ),
                        )
                      : Text(
                          'Share',
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

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        children: [
          Icon(
            Icons.people_outline,
            size: 48,
            color: KStyle.c72GreyColor,
          ),
          const SizedBox(height: 16),
          Text(
            'No cohorts',
            style: KStyle.heading4TextStyle.copyWith(
              color: KStyle.cBlackColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create a cohort first to share forms with groups of recipients',
            style: KStyle.labelMdRegularTextStyle.copyWith(
              color: KStyle.c72GreyColor,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildCohortsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select a cohort to share with:',
          style: KStyle.labelMdRegularTextStyle.copyWith(
            color: KStyle.cBlackColor,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 16),
        ...cohorts
            .map((cohort) => Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: InkWell(
                    onTap: () => _selectCohort(cohort),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: selectedCohort?.id == cohort.id
                            ? KStyle.cSelectedColor
                            : KStyle.cWhiteColor,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: selectedCohort?.id == cohort.id
                              ? KStyle.cPrimaryColor
                              : KStyle.cE3GreyColor,
                          width: selectedCohort?.id == cohort.id ? 2 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            selectedCohort?.id == cohort.id
                                ? Icons.radio_button_checked
                                : Icons.radio_button_unchecked,
                            color: selectedCohort?.id == cohort.id
                                ? KStyle.cPrimaryColor
                                : KStyle.c72GreyColor,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  cohort.name,
                                  style:
                                      KStyle.labelMdRegularTextStyle.copyWith(
                                    color: KStyle.cBlackColor,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  '${cohort.recipients.length} recipient${cohort.recipients.length == 1 ? '' : 's'}',
                                  style:
                                      KStyle.labelSmRegularTextStyle.copyWith(
                                    color: KStyle.c72GreyColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ))
            .toList(),
      ],
    );
  }
}
