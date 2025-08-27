import 'package:flutter/material.dart';
import 'package:formflow/constants/style.dart';
import 'package:formflow/models/cohort_model.dart';
import 'package:formflow/services/firebase_service.dart';
import 'package:formflow/models/form_model.dart'; // Added import for FormModel

class CohortCard extends StatefulWidget {
  final CohortModel cohort;
  final VoidCallback onRefresh;

  const CohortCard({
    super.key,
    required this.cohort,
    required this.onRefresh,
  });

  @override
  State<CohortCard> createState() => _CohortCardState();
}

class _CohortCardState extends State<CohortCard> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: KStyle.cWhiteColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Section - Title and Options
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Title
              Expanded(
                child: Text(
                  widget.cohort.name,
                  style: KStyle.heading2TextStyle.copyWith(
                    color: KStyle.cBlackColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              // Options Button
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: KStyle.cEDBlueColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: IconButton(
                  onPressed: () => _showOptionsMenu(context),
                  icon: Icon(
                    Icons.more_horiz,
                    size: 20,
                    color: KStyle.cPrimaryColor,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ),
            ],
          ),

          // Middle Section - Team Members and Count
          // const Spacer(),
          SizedBox(
            height: 80,
          ),
          Row(
            children: [
              // Team Members Icon
              Icon(
                Icons.group_outlined,
                size: 24,
                color: KStyle.c72GreyColor,
              ),
              const SizedBox(width: 12),
              // Member Count Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: KStyle.cDBRedColor,
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Text(
                  '${widget.cohort.recipients.length}',
                  style: KStyle.labelXsRegularTextStyle.copyWith(
                    color: KStyle.cWhiteColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),

          const Spacer(),

          // Bottom Section - Share Form Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _showShareFormDialog(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: KStyle.cSelectedColor,
                foregroundColor: KStyle.cPrimaryColor,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
              child: Text(
                'Share Form',
                style: KStyle.labelTextStyle.copyWith(
                  color: KStyle.cPrimaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showOptionsMenu(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Cohort Options',
            style: KStyle.heading3TextStyle.copyWith(
              color: KStyle.cBlackColor,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Edit Option
              ListTile(
                leading: Icon(Icons.edit_outlined, color: KStyle.cPrimaryColor),
                title: Text(
                  'Edit Cohort',
                  style: KStyle.labelTextStyle.copyWith(
                    color: KStyle.cBlackColor,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _editCohort(context);
                },
              ),
              // Delete Option
              ListTile(
                leading: Icon(Icons.delete_outline, color: KStyle.cDBRedColor),
                title: Text(
                  'Delete Cohort',
                  style: KStyle.labelTextStyle.copyWith(
                    color: KStyle.cDBRedColor,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _deleteCohort(context);
                },
              ),
              // View Members Option
              ListTile(
                leading:
                    Icon(Icons.people_outline, color: KStyle.cPrimaryColor),
                title: Text(
                  'View Members',
                  style: KStyle.labelTextStyle.copyWith(
                    color: KStyle.cBlackColor,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _viewMembers(context);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: KStyle.labelTextStyle.copyWith(
                  color: KStyle.c72GreyColor,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showShareFormDialog(BuildContext context) {
    String? selectedFormId; // Local variable for form selection

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(
                'Share Form with ${widget.cohort.name}',
                style: KStyle.heading3TextStyle.copyWith(
                  color: KStyle.cBlackColor,
                ),
              ),
              content: SizedBox(
                width: 400,
                child: StreamBuilder<List<FormModel>>(
                  stream: FirebaseService.getFormsStream(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    if (snapshot.hasError) {
                      return Text(
                        'Error loading forms: ${snapshot.error}',
                        style: KStyle.labelTextStyle.copyWith(
                          color: KStyle.cDBRedColor,
                        ),
                      );
                    }

                    final allForms = snapshot.data ?? [];
                    // Filter only forms with 'active' status
                    final liveForms = allForms
                        .where((form) => form.status == 'active')
                        .toList();

                    if (liveForms.isEmpty) {
                      return Text(
                        'No live forms available to share.',
                        style: KStyle.labelTextStyle.copyWith(
                          color: KStyle.c72GreyColor,
                        ),
                      );
                    }

                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Select a live form to share with ${widget.cohort.recipients.length} members:',
                          style: KStyle.labelMdRegularTextStyle.copyWith(
                            color: KStyle.c72GreyColor,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ...liveForms
                            .map((form) => RadioListTile<String>(
                                  title: Text(
                                    form.title,
                                    style: KStyle.labelTextStyle.copyWith(
                                      color: KStyle.cBlackColor,
                                    ),
                                  ),
                                  subtitle: Text(
                                    form.description ?? 'No description',
                                    style: KStyle.labelTextStyle.copyWith(
                                      color: KStyle.c72GreyColor,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  value: form.id!,
                                  groupValue: selectedFormId,
                                  onChanged: (String? value) {
                                    setDialogState(() {
                                      selectedFormId = value;
                                    });
                                  },
                                  activeColor: KStyle.cPrimaryColor,
                                ))
                            .toList(),
                      ],
                    );
                  },
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Cancel',
                    style: KStyle.labelTextStyle.copyWith(
                      color: KStyle.c72GreyColor,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: selectedFormId != null
                      ? () {
                          Navigator.pop(context);
                          _showShareConfirmation(context, selectedFormId!);
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: KStyle.cPrimaryColor,
                    foregroundColor: KStyle.cWhiteColor,
                  ),
                  child: Text(
                    'Share',
                    style: KStyle.labelTextStyle.copyWith(
                      color: KStyle.cWhiteColor,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showShareConfirmation(BuildContext context, String formId) {
    // Get the selected form from the current user's forms
    FirebaseService.getFormsStream().first.then((forms) {
      final selectedForm = forms.firstWhere(
        (form) => form.id == formId,
        orElse: () => throw Exception('Form not found'),
      );

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              'Confirm Share',
              style: KStyle.heading3TextStyle.copyWith(
                color: KStyle.cBlackColor,
              ),
            ),
            content: Text(
              'Are you sure to share "${selectedForm.title}" with "${widget.cohort.name}"?\n\nThis will send an email to all ${widget.cohort.recipients.length} members of the cohort.',
              style: KStyle.labelMdRegularTextStyle.copyWith(
                color: KStyle.cBlackColor,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Cancel',
                  style: KStyle.labelTextStyle.copyWith(
                    color: KStyle.c72GreyColor,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _shareFormWithCohort(selectedForm);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: KStyle.cPrimaryColor,
                  foregroundColor: KStyle.cWhiteColor,
                ),
                child: Text(
                  'Yes, Share',
                  style: KStyle.labelTextStyle.copyWith(
                    color: KStyle.cWhiteColor,
                  ),
                ),
              ),
            ],
          );
        },
      );
    });
  }

  Future<void> _shareFormWithCohort(FormModel form) async {
    try {
      // Show loading indicator
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              const SizedBox(width: 16),
              Text('Sharing form with ${widget.cohort.name}...'),
            ],
          ),
          backgroundColor: KStyle.cPrimaryColor,
          duration: const Duration(seconds: 2),
        ),
      );

      // Share the form with the cohort
      final result = await FirebaseService.shareFormWithCohort(
        formId: form.id!,
        cohortId: widget.cohort.id!,
        formTitle: form.title,
        formDescription: form.description,
        formLink: form.shareLink,
      );

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Form "${form.title}" shared with "${widget.cohort.name}" successfully!',
          ),
          backgroundColor: KStyle.cApproveColor,
        ),
      );

      // Reset selection
      // _selectedFormId = null; // This line is removed as per the edit hint
    } catch (e) {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error sharing form: $e',
          ),
          backgroundColor: KStyle.cDBRedColor,
        ),
      );
    }
  }

  void _editCohort(BuildContext context) {
    // TODO: Implement edit cohort functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Edit ${widget.cohort.name} - Coming soon'),
        backgroundColor: KStyle.cPrimaryColor,
      ),
    );
  }

  void _deleteCohort(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Delete Cohort',
            style: KStyle.heading3TextStyle.copyWith(
              color: KStyle.cDBRedColor,
            ),
          ),
          content: Text(
            'Are you sure you want to delete "${widget.cohort.name}"? This action cannot be undone.',
            style: KStyle.labelMdRegularTextStyle.copyWith(
              color: KStyle.cBlackColor,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: KStyle.labelTextStyle.copyWith(
                  color: KStyle.c72GreyColor,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                await _confirmDeleteCohort(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: KStyle.cDBRedColor,
                foregroundColor: KStyle.cWhiteColor,
              ),
              child: Text(
                'Delete',
                style: KStyle.labelTextStyle.copyWith(
                  color: KStyle.cWhiteColor,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _confirmDeleteCohort(BuildContext context) async {
    try {
      if (widget.cohort.id != null && widget.cohort.id!.isNotEmpty) {
        await FirebaseService.deleteCohort(widget.cohort.id!);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${widget.cohort.name} deleted successfully'),
            backgroundColor: KStyle.cE8GreenColor,
          ),
        );
        widget.onRefresh();
      } else {
        throw Exception('Cohort ID is empty or null');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error deleting cohort: $e'),
          backgroundColor: KStyle.cDBRedColor,
        ),
      );
    }
  }

  void _viewMembers(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            '${widget.cohort.name} Members',
            style: KStyle.heading3TextStyle.copyWith(
              color: KStyle.cBlackColor,
            ),
          ),
          content: SizedBox(
            width: 300, // Reduced width for better appearance
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: widget.cohort.recipients.length,
              itemBuilder: (context, index) {
                final recipient = widget.cohort.recipients[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: KStyle.cPrimaryColor.withOpacity(0.1),
                    child: Text(
                      recipient.name.isNotEmpty
                          ? recipient.name[0].toUpperCase()
                          : '?',
                      style: KStyle.labelTextStyle.copyWith(
                        color: KStyle.cPrimaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  title: Text(
                    recipient.name.isNotEmpty ? recipient.name : 'Unnamed',
                    style: KStyle.labelTextStyle.copyWith(
                      color: KStyle.cBlackColor,
                    ),
                  ),
                  subtitle: Text(
                    recipient.email,
                    style: KStyle.labelSmRegularTextStyle.copyWith(
                      color: KStyle.c72GreyColor,
                    ),
                  ),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Close',
                style: KStyle.labelTextStyle.copyWith(
                  color: KStyle.cPrimaryColor,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
