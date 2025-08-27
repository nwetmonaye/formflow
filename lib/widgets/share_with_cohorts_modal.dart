import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:formflow/constants/style.dart';
import 'package:formflow/models/cohort_model.dart';
import 'package:formflow/models/form_model.dart';
import 'package:formflow/services/firebase_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
      print('🔍 ShareWithCohortsModal: Starting to load cohorts...');
      setState(() {
        isLoading = true;
      });

      // First try to get user-specific cohorts
      var loadedCohorts = await FirebaseService.getCohorts();
      print(
          '🔍 ShareWithCohortsModal: User-specific cohorts loaded: ${loadedCohorts.length}');

      // If no user-specific cohorts found, try to get all cohorts
      if (loadedCohorts.isEmpty) {
        print(
            '🔍 ShareWithCohortsModal: No user-specific cohorts found, trying to load all cohorts...');
        loadedCohorts = await FirebaseService.getAllCohorts();
        print(
            '🔍 ShareWithCohortsModal: All cohorts loaded: ${loadedCohorts.length}');
      }

      if (loadedCohorts.isNotEmpty) {
        print(
            '🔍 ShareWithCohortsModal: Final cohort names: ${loadedCohorts.map((c) => c.name).join(', ')}');
      } else {
        print(
            '🔍 ShareWithCohortsModal: No cohorts loaded - this might be the issue');
      }

      setState(() {
        cohorts = loadedCohorts;
        isLoading = false;
      });
    } catch (e) {
      print('🔍 ShareWithCohortsModal: Error loading cohorts: $e');
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
      print('🔍 ShareWithCohortsModal: Starting to share form with cohort');
      print('🔍 ShareWithCohortsModal: Form ID: ${widget.form.id}');
      print('🔍 ShareWithCohortsModal: Cohort ID: ${selectedCohort!.id}');
      print('🔍 ShareWithCohortsModal: Form Title: ${widget.form.title}');
      print('🔍 ShareWithCohortsModal: Cohort Name: ${selectedCohort!.name}');
      print(
          '🔍 ShareWithCohortsModal: Recipients count: ${selectedCohort!.recipients.length}');

      // Call the Firebase function to share form with cohort
      final formLink = widget.form.shareLink ??
          'https://formflow.com/form/${widget.form.id}';

      print('🔍 ShareWithCohortsModal: Form link: $formLink');

      final response = await FirebaseService.shareFormWithCohort(
        formId: widget.form.id!,
        cohortId: selectedCohort!.id!,
        formTitle: widget.form.title,
        formDescription: widget.form.description,
        formLink: formLink,
      );

      print('🔍 ShareWithCohortsModal: Firebase function response: $response');

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
      print('🔍 ShareWithCohortsModal: Error sharing form: $e');
      print('🔍 ShareWithCohortsModal: Error type: ${e.runtimeType}');

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
                  'Share',
                  style: KStyle.heading3TextStyle.copyWith(
                    color: KStyle.cBlackColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      onPressed: _loadCohorts,
                      icon: Icon(
                        Icons.refresh,
                        color: KStyle.cPrimaryColor,
                      ),
                      tooltip: 'Refresh cohorts',
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
              ],
            ),
            const SizedBox(height: 24),

            // Copy and Share Section
            _buildCopyAndShareSection(),

            const SizedBox(height: 24),

            // Share with Cohorts Section
            _buildShareWithCohortsSection(),

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
                    backgroundColor: selectedCohort != null
                        ? KStyle.cPrimaryColor
                        : Colors.grey,
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
                      : Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.share,
                              size: 20,
                              color: KStyle.cWhiteColor,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Share',
                              style: KStyle.labelMdRegularTextStyle.copyWith(
                                color: KStyle.cWhiteColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCopyAndShareSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Copy and Share',
          style: KStyle.labelMdRegularTextStyle.copyWith(
            color: KStyle.cBlackColor,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => _copyFormLink(),
            style: ElevatedButton.styleFrom(
              backgroundColor: KStyle.cEDBlueColor,
              foregroundColor: KStyle.cPrimaryColor,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 0,
            ),
            icon: Icon(Icons.link, size: 20),
            label: Text(
              'Copy Form Link',
              style: KStyle.labelTextStyle.copyWith(
                color: KStyle.cPrimaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildShareWithCohortsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Share with Cohorts',
          style: KStyle.labelMdRegularTextStyle.copyWith(
            color: KStyle.cBlackColor,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),

        // Debug button to test getting all cohorts
        // if (cohorts.isEmpty)
        //   Column(
        //     children: [
        //       ElevatedButton(
        //         onPressed: _debugLoadAllCohorts,
        //         style: ElevatedButton.styleFrom(
        //           backgroundColor: Colors.orange,
        //           foregroundColor: Colors.white,
        //         ),
        //         child: Text('Debug: Load All Cohorts'),
        //       ),
        //       const SizedBox(height: 16),
        //     ],
        //   ),

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
      ],
    );
  }

  Future<void> _debugLoadAllCohorts() async {
    try {
      print('🔍 ShareWithCohortsModal: Debug loading all cohorts...');

      // First, let's check the current user
      final currentUser = FirebaseAuth.instance.currentUser;
      print('🔍 ShareWithCohortsModal: Current user ID: ${currentUser?.uid}');
      print(
          '🔍 ShareWithCohortsModal: Current user email: ${currentUser?.email}');

      final allCohorts = await FirebaseService.getAllCohorts();
      print(
          '🔍 ShareWithCohortsModal: All cohorts loaded: ${allCohorts.length}');

      if (allCohorts.isNotEmpty) {
        setState(() {
          cohorts = allCohorts;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Debug: Loaded ${allCohorts.length} cohorts (all cohorts)'),
            backgroundColor: Colors.orange,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Debug: No cohorts found in database'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('🔍 ShareWithCohortsModal: Debug error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Debug error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _copyFormLink() {
    final formLink =
        widget.form.shareLink ?? 'https://formflow.com/form/${widget.form.id}';

    Clipboard.setData(ClipboardData(text: formLink));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Form link copied to clipboard'),
        backgroundColor: KStyle.cE8GreenColor,
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        children: [
          Icon(
            Icons.group_outlined,
            size: 48,
            color: KStyle.cEDBlueColor,
          ),
          const SizedBox(height: 16),
          Text(
            'No cohorts yet',
            style: KStyle.heading4TextStyle.copyWith(
              color: KStyle.cBlackColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create a cohort to share this form with a group of people by email.',
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
                            ? KStyle.cEDBlueColor
                            : KStyle.cWhiteColor,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: selectedCohort?.id == cohort.id
                              ? KStyle.cPrimaryColor
                              : KStyle.cE3GreyColor,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            selectedCohort?.id == cohort.id
                                ? Icons.check_box
                                : Icons.check_box_outline_blank,
                            color: selectedCohort?.id == cohort.id
                                ? KStyle.cPrimaryColor
                                : KStyle.c72GreyColor,
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              cohort.name,
                              style: KStyle.labelMdRegularTextStyle.copyWith(
                                color: selectedCohort?.id == cohort.id
                                    ? KStyle.cPrimaryColor
                                    : KStyle.cBlackColor,
                                fontWeight: FontWeight.w500,
                              ),
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
