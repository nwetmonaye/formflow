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
  List<CohortModel> _cohorts = [];
  bool _isLoading = true;
  String? _error;
  Set<String> _selectedCohortIds =
      {}; // Changed from single selection to multiple
  bool _isSharing = false;

  @override
  void initState() {
    super.initState();
    _loadCohorts();
  }

  Future<void> _loadCohorts() async {
    try {
      print('🔍 ShareWithCohortsModal: Starting to load cohorts...');
      setState(() {
        _isLoading = true;
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
        _cohorts = loadedCohorts;
        _isLoading = false;
      });
    } catch (e) {
      print('🔍 ShareWithCohortsModal: Error loading cohorts: $e');
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading cohorts: $e'),
          backgroundColor: KStyle.cDBRedColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
    }
  }

  void _selectCohort(CohortModel cohort) {
    setState(() {
      if (_selectedCohortIds.contains(cohort.id!)) {
        _selectedCohortIds.remove(cohort.id!);
      } else {
        _selectedCohortIds.add(cohort.id!);
      }
    });
  }

  Future<void> _shareFormWithCohort() async {
    if (_selectedCohortIds.isEmpty) return;

    setState(() {
      _isSharing = true;
    });

    try {
      print('🔍 ShareWithCohortsModal: Starting to share form with cohort');
      print('🔍 ShareWithCohortsModal: Form ID: ${widget.form.id}');
      print(
          '🔍 ShareWithCohortsModal: Cohort IDs: ${_selectedCohortIds.join(', ')}');
      print('🔍 ShareWithCohortsModal: Form Title: ${widget.form.title}');
      print(
          '🔍 ShareWithCohortsModal: Cohort Names: ${_selectedCohortIds.map((id) => _cohorts.firstWhere((c) => c.id == id).name).join(', ')}');
      print(
          '🔍 ShareWithCohortsModal: Recipients count: ${_selectedCohortIds.length}');

      // Validate required fields before calling Firebase function
      if (widget.form.id == null || widget.form.id!.isEmpty) {
        throw Exception('Form ID is null or empty');
      }

      if (_selectedCohortIds.isEmpty) {
        throw Exception('No cohorts selected for sharing');
      }

      if (widget.form.title == null || widget.form.title.isEmpty) {
        throw Exception('Form title is null or empty');
      }

      print(
          '🔍 ShareWithCohortsModal: All required fields validated successfully');

      // Call the Firebase function to share form with cohort
      final formLink = widget.form.shareLink ??
          'https://formflow.com/form/${widget.form.id}';

      print('🔍 ShareWithCohortsModal: Form link: $formLink');

      final response = await FirebaseService.shareFormWithCohort(
        formId: widget.form.id!,
        cohortIds: _selectedCohortIds.toList(),
        formTitle: widget.form.title,
        formDescription: widget.form.description,
        formLink: formLink,
      );

      print('🔍 ShareWithCohortsModal: Firebase function response: $response');

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Form "${widget.form.title}" shared with "${_selectedCohortIds.length} cohorts" successfully'),
          backgroundColor: KStyle.cApproveColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
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
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
    } finally {
      setState(() {
        _isSharing = false;
      });
    }
  }

  Future<void> _shareForm() async {
    if (_selectedCohortIds.isEmpty) return;

    setState(() {
      _isSharing = true;
    });

    try {
      // Call the Firebase function to share form with cohort
      final formLink = widget.form.shareLink ??
          'https://formflow.com/form/${widget.form.id}';

      final response = await FirebaseService.shareFormWithCohort(
        formId: widget.form.id!,
        cohortIds: _selectedCohortIds.toList(),
        formTitle: widget.form.title,
        formDescription: widget.form.description,
        formLink: formLink,
      );

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Form "${widget.form.title}" shared with "${_selectedCohortIds.length} cohorts" successfully'),
          backgroundColor: KStyle.cE8GreenColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
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
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
    } finally {
      setState(() {
        _isSharing = false;
      });
    }
  }

  void _showConfirmationDialog() {
    if (_selectedCohortIds.isEmpty) return;

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
            'Are you sure to share "${widget.form.title}" with ${_selectedCohortIds.length} cohort${_selectedCohortIds.length == 1 ? '' : 's'}?\n\n${_selectedCohortIds.map((id) => _cohorts.firstWhere((c) => c.id == id).name).join(', ')}',
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
      child: Container(
        width: 500,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: KStyle.cWhiteColor,
          borderRadius: BorderRadius.circular(12),
        ),
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
                  onPressed: (_selectedCohortIds.isNotEmpty && !_isSharing)
                      ? _showConfirmationDialog
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _selectedCohortIds.isNotEmpty
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
                  child: _isSharing
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
              backgroundColor: KStyle.cSelectedColor,
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

        // Debug information section
        // if (selectedCohort != null)
        //   Column(
        //     children: [
        //       Container(
        //         padding: const EdgeInsets.all(12),
        //         decoration: BoxDecoration(
        //           color: Colors.blue.shade50,
        //           borderRadius: BorderRadius.circular(8),
        //           border: Border.all(color: Colors.blue.shade200),
        //         ),
        //         child: Column(
        //           crossAxisAlignment: CrossAxisAlignment.start,
        //           children: [
        //             Text(
        //               'Debug Info:',
        //               style: TextStyle(
        //                 fontWeight: FontWeight.bold,
        //                 color: Colors.blue.shade800,
        //               ),
        //             ),
        //             const SizedBox(height: 8),
        //             Text('Form ID: ${widget.form.id ?? "NULL"}'),
        //             Text('Form Title: ${widget.form.title ?? "NULL"}'),
        //             Text('Cohort ID: ${selectedCohort!.id ?? "NULL"}'),
        //             Text('Cohort Name: ${selectedCohort!.name ?? "NULL"}'),
        //             Text('Recipients: ${selectedCohort!.recipients.length}'),
        //           ],
        //         ),
        //       ),
        //       const SizedBox(height: 16),
        //       ElevatedButton(
        //         onPressed: _testFirebaseFunction,
        //         style: ElevatedButton.styleFrom(
        //           backgroundColor: Colors.purple,
        //           foregroundColor: Colors.white,
        //         ),
        //         child: Text('Test Firebase Function'),
        //       ),
        //       const SizedBox(height: 8),
        //       ElevatedButton(
        //         onPressed: _testFirebaseFunctionsConnection,
        //         style: ElevatedButton.styleFrom(
        //           backgroundColor: Colors.blue,
        //           foregroundColor: Colors.white,
        //         ),
        //         child: Text('Test Firebase Functions Connection'),
        //       ),
        //       const SizedBox(height: 8),
        //       ElevatedButton(
        //         onPressed: _testSpecificFunction,
        //         style: ElevatedButton.styleFrom(
        //           backgroundColor: Colors.indigo,
        //           foregroundColor: Colors.white,
        //         ),
        //         child: Text('Test shareFormWithCohort Function'),
        //       ),
        //       const SizedBox(height: 8),
        //       ElevatedButton(
        //         onPressed: _checkFirebaseFunctionsStatus,
        //         style: ElevatedButton.styleFrom(
        //           backgroundColor: Colors.teal,
        //           foregroundColor: Colors.white,
        //         ),
        //         child: Text('Check Firebase Functions Status'),
        //       ),
        //       const SizedBox(height: 8),
        //       ElevatedButton(
        //         onPressed: _fixCohortId,
        //         style: ElevatedButton.styleFrom(
        //           backgroundColor: Colors.red,
        //           foregroundColor: Colors.white,
        //         ),
        //         child: Text('Fix Cohort ID (if corrupted)'),
        //       ),
        //     ],
        //   ),

        if (_isLoading)
          Center(
            child: CircularProgressIndicator(
              color: KStyle.cPrimaryColor,
            ),
          )
        else if (_cohorts.isEmpty)
          _buildEmptyState()
        else
          _buildCohortsList(),
      ],
    );
  }

  // Future<void> _debugLoadAllCohorts() async {
  //   try {
  //     print('🔍 ShareWithCohortsModal: Debug loading all cohorts...');

  //     // First, let's check the current user
  //     final currentUser = FirebaseAuth.instance.currentUser;
  //     print('🔍 ShareWithCohortsModal: Current user ID: ${currentUser?.uid}');
  //     print(
  //         '🔍 ShareWithCohortsModal: Current user email: ${currentUser?.email}');

  //     final allCohorts = await FirebaseService.getAllCohorts();
  //     print(
  //         '🔍 ShareWithCohortsModal: All cohorts loaded: ${allCohorts.length}');

  //     // Debug: Show all cohort details
  //     for (final cohort in allCohorts) {
  //       print('🔍 ShareWithCohortsModal: Cohort Details:');
  //       print('🔍   ID: "${cohort.id}" (length: ${cohort.id?.length})');
  //       print('🔍   Name: "${cohort.name}"');
  //       print('🔍   CreatedBy: "${cohort.createdBy}"');
  //       print('🔍   Recipients: ${cohort.recipients.length}');
  //       print('🔍   Raw ID bytes: ${cohort.id?.codeUnits}');
  //     }

  //     if (allCohorts.isNotEmpty) {
  //       setState(() {
  //         cohorts = allCohorts;
  //       });

  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //           content: Text(
  //               'Debug: Loaded ${allCohorts.length} cohorts (all cohorts)'),
  //           backgroundColor: Colors.orange,
  //         ),
  //       );
  //     } else {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //           content: Text('Debug: No cohorts found in database'),
  //           backgroundColor: Colors.red,
  //         ),
  //       );
  //     }
  //   } catch (e) {
  //     print('🔍 ShareWithCohortsModal: Debug error: $e');
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: Text('Debug error: $e'),
  //         backgroundColor: Colors.red,
  //       ),
  //     );
  //   }
  // }

  // Future<void> _testFirebaseFunction() async {
  //   try {
  //     print('🔍 ShareWithCohortsModal: Testing Firebase function...');

  //     // Test with minimal data
  //     final testData = {
  //       'formId': widget.form.id ?? 'test-form-id',
  //       'cohortId': selectedCohort!.id ?? 'test-cohort-id',
  //       'formTitle': widget.form.title ?? 'Test Form',
  //       'formDescription': widget.form.description ?? 'Test Description',
  //       'formLink': 'https://test.com/form',
  //     };

  //     print('🔍 ShareWithCohortsModal: Test data: $testData');

  //     final response = await FirebaseService.shareFormWithCohort(
  //       formId: testData['formId']!,
  //       cohortId: testData['cohortId']!,
  //       formTitle: testData['formTitle']!,
  //       formDescription: testData['formDescription'],
  //       formLink: testData['formLink'],
  //     );

  //     print('🔍 ShareWithCohortsModal: Test successful: $response');

  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: Text('Firebase function test successful!'),
  //         backgroundColor: Colors.green,
  //       ),
  //     );
  //   } catch (e) {
  //     print('🔍 ShareWithCohortsModal: Test failed: $e');

  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: Text('Test failed: $e'),
  //         backgroundColor: Colors.red,
  //       ),
  //     );
  //   }
  // }

  // Future<void> _testFirebaseFunctionsConnection() async {
  //   try {
  //     print(
  //         '🔍 ShareWithCohortsModal: Testing Firebase Functions connection...');
  //     final response = await FirebaseService.testFirebaseFunctionsConnection();
  //     print(
  //         '🔍 ShareWithCohortsModal: Firebase Functions connection test successful: $response');
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: Text('Firebase Functions connection test successful!'),
  //         backgroundColor: Colors.green,
  //       ),
  //     );
  //   } catch (e) {
  //     print(
  //         '🔍 ShareWithCohortsModal: Firebase Functions connection test failed: $e');
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: Text('Firebase Functions connection test failed: $e'),
  //         backgroundColor: Colors.red,
  //       ),
  //     );
  //   }
  // }

  // Future<void> _testSpecificFunction() async {
  //   try {
  //     print(
  //         '🔍 ShareWithCohortsModal: Testing shareFormWithCohort function specifically...');

  //     // Test if the specific function exists
  //     final result =
  //         await FirebaseService.testSpecificFunction('shareFormWithCohort');

  //     if (result) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //           content: Text('shareFormWithCohort function is accessible!'),
  //           backgroundColor: Colors.green,
  //         ),
  //       );
  //     } else {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //           content: Text('shareFormWithCohort function is NOT accessible!'),
  //           backgroundColor: Colors.red,
  //         ),
  //       );
  //     }
  //   } catch (e) {
  //     print('🔍 ShareWithCohortsModal: Specific function test failed: $e');
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: Text('Function test failed: $e'),
  //         backgroundColor: Colors.red,
  //       ),
  //     );
  //   }
  // }

  // Future<void> _checkFirebaseFunctionsStatus() async {
  //   try {
  //     print('🔍 ShareWithCohortsModal: Checking Firebase Functions status...');
  //     final status = await FirebaseService.checkFirebaseFunctionsStatus();
  //     print('🔍 ShareWithCohortsModal: Firebase Functions status: $status');

  //     final isAccessible = status['functionsAccessible'] as bool? ?? false;
  //     final deployedFunctions =
  //         status['deployedFunctions'] as List<String>? ?? [];
  //     final errors = status['errors'] as List<String>? ?? [];

  //     String message;
  //     Color backgroundColor;

  //     if (isAccessible) {
  //       message =
  //           '✅ Firebase Functions are accessible!\nDeployed: ${deployedFunctions.join(', ')}';
  //       backgroundColor = Colors.green;
  //     } else {
  //       message =
  //           '❌ Firebase Functions are NOT accessible!\nErrors: ${errors.join(', ')}';
  //       backgroundColor = Colors.red;
  //     }

  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: Text(message),
  //         backgroundColor: backgroundColor,
  //         duration: const Duration(seconds: 5),
  //       ),
  //     );
  //   } catch (e) {
  //     print(
  //         '🔍 ShareWithCohortsModal: Error checking Firebase Functions status: $e');
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: Text('Error checking Firebase Functions status: $e'),
  //         backgroundColor: Colors.red,
  //       ),
  //     );
  //   }
  // }

  // Future<void> _fixCohortId() async {
  //   try {
  //     print('🔍 ShareWithCohortsModal: Attempting to fix cohort ID...');

  //     // The correct ID from your Firestore console
  //     const correctId = 'p3KrNjXWVoyVDBf910eR';

  //     print(
  //         '🔍 ShareWithCohortsModal: Current corrupted ID: "${selectedCohort!.id}"');
  //     print('🔍 ShareWithCohortsModal: Correct ID should be: "$correctId"');

  //     // Create a corrected cohort object
  //     final correctedCohort = selectedCohort!.copyWith(id: correctId);

  //     // Update the selected cohort
  //     setState(() {
  //       selectedCohort = correctedCohort;
  //     });

  //     print(
  //         '🔍 ShareWithCohortsModal: Cohort ID fixed to: "${correctedCohort.id}"');

  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: Text('Cohort ID fixed! Try sharing again.'),
  //         backgroundColor: Colors.green,
  //       ),
  //     );
  //   } catch (e) {
  //     print('🔍 ShareWithCohortsModal: Error fixing cohort ID: $e');

  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: Text('Error fixing cohort ID: $e'),
  //         backgroundColor: Colors.red,
  //       ),
  //     );
  //   }
  // }

  void _copyFormLink() {
    final formLink =
        widget.form.shareLink ?? 'https://formflow.com/form/${widget.form.id}';

    Clipboard.setData(ClipboardData(text: formLink));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Form link copied to clipboard'),
        backgroundColor: KStyle.cE8GreenColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
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
        ..._cohorts
            .map((cohort) => Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: InkWell(
                    onTap: () => _selectCohort(cohort),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: _selectedCohortIds.contains(cohort.id!)
                            ? KStyle.cEDBlueColor
                            : KStyle.cWhiteColor,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: _selectedCohortIds.contains(cohort.id!)
                              ? KStyle.cPrimaryColor
                              : KStyle.cE3GreyColor,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _selectedCohortIds.contains(cohort.id!)
                                ? Icons.check_box
                                : Icons.check_box_outline_blank,
                            color: _selectedCohortIds.contains(cohort.id!)
                                ? KStyle.cPrimaryColor
                                : KStyle.c72GreyColor,
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              cohort.name,
                              style: KStyle.labelMdRegularTextStyle.copyWith(
                                color: _selectedCohortIds.contains(cohort.id!)
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
