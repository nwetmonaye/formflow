import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:formflow/constants/style.dart';
import 'package:formflow/models/submission_model.dart';
import 'package:formflow/services/firebase_service.dart';
import 'package:formflow/screens/form_builder_screen.dart';
import 'package:formflow/screens/notification_screen.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:formflow/screens/home_screen.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:url_launcher/url_launcher.dart';
import 'package:formflow/screens/form_preview_screen.dart';
import 'package:formflow/models/form_model.dart' as form_model;

class FormDetailScreen extends StatefulWidget {
  final form_model.FormModel? form;
  final String? formId;

  const FormDetailScreen({super.key, this.form, this.formId})
      : assert(form != null || formId != null,
            'Either form or formId must be provided');

  @override
  State<FormDetailScreen> createState() => _FormDetailScreenState();
}

class _FormDetailScreenState extends State<FormDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String selectedStatusFilter = 'All';
  final List<String> statusFilters = ['All', 'Pending', 'Approved', 'Rejected'];
  List<SubmissionModel> selectedSubmissions = [];
  int selectedNavItem = 0; // 0 = My Forms, 1 = Cohorts, 2 = Notifications
  form_model.FormModel? _form;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _initializeForm();
  }

  Future<void> _initializeForm() async {
    if (widget.form != null) {
      _form = widget.form;
    } else if (widget.formId != null) {
      setState(() {
        _isLoading = true;
      });

      try {
        final loadedForm = await FirebaseService.getForm(widget.formId!);
        if (loadedForm != null) {
          setState(() {
            _form = loadedForm;
            _isLoading = false;
          });
        } else {
          setState(() {
            _isLoading = false;
          });
          // Show error or navigate back
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Form not found'),
                backgroundColor: Colors.red,
              ),
            );
            Navigator.of(context).pop();
          }
        }
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error loading form: $e'),
              backgroundColor: Colors.red,
            ),
          );
          Navigator.of(context).pop();
        }
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Show loading state while form is being loaded
    if (_isLoading || _form == null) {
      return Scaffold(
        backgroundColor: KStyle.cBgColor,
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: KStyle.cBgColor,
      body: Row(
        children: [
          // Left Sidebar
          Container(
            width: 280,
            decoration: BoxDecoration(
              color: KStyle.cWhiteColor,
              border: Border(
                right: BorderSide(
                  color: KStyle.cE3GreyColor,
                  width: 1,
                ),
              ),
            ),
            child: Column(
              children: [
                // Logo
                Container(
                  padding: const EdgeInsets.all(24),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        'form',
                        style: KStyle.heading2TextStyle.copyWith(
                          color: KStyle.cBlackColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        margin: const EdgeInsets.only(top: 10),
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: KStyle.cPrimaryColor,
                          borderRadius: BorderRadius.circular(50),
                        ),
                      ),
                    ],
                  ),
                ),

                // Navigation Menu
                Expanded(
                  child: Column(
                    children: [
                      _buildNavItem(
                        icon: Icons.description_outlined,
                        title: 'My Forms',
                        isSelected: selectedNavItem == 0,
                        onTap: () {
                          setState(() {
                            selectedNavItem = 0;
                          });
                          Navigator.of(context).pop();
                        },
                      ),
                      _buildNavItem(
                        icon: Icons.group_outlined,
                        title: 'Cohorts',
                        isSelected: selectedNavItem == 1,
                        onTap: () {
                          setState(() {
                            selectedNavItem = 1;
                          });
                        },
                      ),
                      _buildNavItem(
                        icon: Icons.notifications_outlined,
                        title: 'Notifications',
                        isSelected: selectedNavItem == 2,
                        notificationCount: 5,
                        onTap: () {
                          setState(() {
                            selectedNavItem = 2;
                          });
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const NotificationScreen(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),

                // User Profile
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(
                        color: KStyle.cE3GreyColor,
                        width: 1,
                      ),
                    ),
                  ),
                  child: GestureDetector(
                    onTap: () {
                      _showUserMenu(context);
                    },
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: KStyle.cPrimaryColor,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Icon(
                            Icons.person,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'User Profile',
                                style: KStyle.labelMdRegularTextStyle.copyWith(
                                  color: KStyle.cBlackColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                'View Profile',
                                style: KStyle.labelSmRegularTextStyle.copyWith(
                                  color: KStyle.c72GreyColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.keyboard_arrow_down,
                          color: KStyle.c72GreyColor,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Main Content Area
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: KStyle.cWhiteColor,
                border: Border(
                  right: BorderSide(
                    color: KStyle.cE3GreyColor,
                    width: 1,
                  ),
                ),
              ),
              child: Column(
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: KStyle.cWhiteColor,
                      // border: Border(
                      //   bottom: BorderSide(
                      //     color: KStyle.cE3GreyColor,
                      //     width: 1,
                      //   ),
                      // ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Breadcrumbs
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => const HomeScreen(),
                                  ),
                                );
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
                            GestureDetector(
                              onTap: () {
                                Navigator.of(context).pop();
                              },
                              child: Text(
                                _form!.title,
                                style: KStyle.labelSmRegularTextStyle.copyWith(
                                  color: KStyle.c72GreyColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        // Title and Actions Row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                _form!.title,
                                style: KStyle.heading2TextStyle.copyWith(
                                  color: KStyle.cBlackColor,
                                  fontSize: 24,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            Row(
                              children: [
                                IconButton(
                                  onPressed: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            FormPreviewScreen(form: _form!),
                                      ),
                                    );
                                  },
                                  icon: Container(
                                    width: 24,
                                    height: 24,
                                    child: SvgPicture.asset(
                                      'assets/icons/eye.svg',
                                      width: 24,
                                      height: 24,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                IconButton(
                                  onPressed: _copyShareLink,
                                  icon: Container(
                                    width: 22,
                                    height: 22,
                                    child: SvgPicture.asset(
                                      'assets/icons/copy.svg',
                                      width: 22,
                                      height: 22,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                ElevatedButton.icon(
                                  onPressed: () async {
                                    // Create a sample form if none exists
                                    if (_form!.fields.isEmpty) {}
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            FormBuilderScreen(form: _form!),
                                      ),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: KStyle.cWhiteColor,
                                    foregroundColor: KStyle.cPrimaryColor,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 12,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    elevation: 0,
                                    side:
                                        BorderSide(color: KStyle.cPrimaryColor),
                                  ),
                                  icon: const Icon(Icons.edit, size: 20),
                                  label: Text(
                                    'Edit Form',
                                    style: KStyle.labelMdBoldTextStyle.copyWith(
                                      color: KStyle.cPrimaryColor,
                                    ),
                                  ),
                                ),
                                // const SizedBox(width: 12),
                                // ElevatedButton.icon(
                                //   onPressed: () {
                                //     Navigator.of(context).push(
                                //       MaterialPageRoute(
                                //         builder: (context) =>
                                //             FormSubmissionScreen(
                                //                 formId: _form!.id!),
                                //       ),
                                //     );
                                //   },
                                //   style: ElevatedButton.styleFrom(
                                //     backgroundColor: KStyle.cPrimaryColor,
                                //     foregroundColor: KStyle.cWhiteColor,
                                //     padding: const EdgeInsets.symmetric(
                                //       horizontal: 20,
                                //       vertical: 12,
                                //     ),
                                //     shape: RoundedRectangleBorder(
                                //       borderRadius: BorderRadius.circular(8),
                                //     ),
                                //     elevation: 0,
                                //   ),
                                //   icon: const Icon(Icons.add, size: 20),
                                //   label: Text(
                                //     'Fill Form',
                                //     style: KStyle.labelMdBoldTextStyle.copyWith(
                                //       color: KStyle.cWhiteColor,
                                //     ),
                                //   ),
                                // ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Tab Bar
                  Container(
                    decoration: BoxDecoration(
                      color: KStyle.cWhiteColor,
                      border: Border(
                        bottom: BorderSide(
                          color: KStyle.cE3GreyColor,
                          width: 1,
                        ),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 16),
                      child: Row(
                        children: [
                          _buildTabItem('Submissions', 0),
                          _buildTabItem('Share', 1),
                          _buildTabItem('Settings', 2),
                        ],
                      ),
                    ),
                  ),

                  // Tab Content
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _buildSubmissionsTab(),
                        _buildShareTab(),
                        _buildSettingsTab(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String title,
    required bool isSelected,
    int? notificationCount,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: () {
        print('Nav item tapped: $title'); // Debug print
        onTap();
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? KStyle.cSelectedColor : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  icon,
                  size: 20,
                  color:
                      isSelected ? KStyle.cPrimaryColor : KStyle.c72GreyColor,
                ),
                if (notificationCount != null)
                  Positioned(
                    right: -6,
                    top: -6,
                    child: CircleAvatar(
                      radius: 8,
                      backgroundColor: KStyle.cNotiColor,
                      child: Center(
                        child: Text(
                          notificationCount.toString(),
                          style: KStyle.labelXsRegularTextStyle.copyWith(
                            color: KStyle.cWhiteColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: KStyle.labelMdRegularTextStyle.copyWith(
                color: isSelected ? KStyle.cPrimaryColor : KStyle.c72GreyColor,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabItem(String title, int index) {
    bool isSelected = _tabController.index == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _tabController.animateTo(index);
        });
      },
      child: Container(
        margin: const EdgeInsets.only(right: 32),
        child: Column(
          children: [
            Text(
              title,
              style: KStyle.labelMdRegularTextStyle.copyWith(
                color: isSelected ? KStyle.cPrimaryColor : KStyle.c72GreyColor,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
            const SizedBox(height: 8),
            if (isSelected)
              Container(
                width: 20,
                height: 2,
                decoration: BoxDecoration(
                  color: KStyle.cPrimaryColor,
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmissionsTab() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: KStyle.cWhiteColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: KStyle.cWhiteColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Filter and Download Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Status Filter
                GestureDetector(
                  onTap: _showStatusFilterDialog,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      border: Border.all(color: KStyle.cE3GreyColor),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Status: $selectedStatusFilter',
                          style: KStyle.labelMdRegularTextStyle.copyWith(
                            color: KStyle.cBlackColor,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          Icons.keyboard_arrow_down,
                          color: KStyle.c72GreyColor,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 50),

                // Download CSV Button
                ElevatedButton.icon(
                  onPressed: () {
                    // TODO: Implement CSV download
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('CSV download coming soon!'),
                        backgroundColor: Colors.blue,
                      ),
                    );
                  },
                  icon: const Icon(Icons.download, size: 20),
                  label: Text(
                    'Download CSV',
                    style: KStyle.labelMdRegularTextStyle.copyWith(
                      color: KStyle.cWhiteColor,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: KStyle.cPrimaryColor,
                    foregroundColor: KStyle.cWhiteColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                // const SizedBox(width: 16),
                // Test Submission Button
                // ElevatedButton.icon(
                //   onPressed: _createTestSubmission,
                //   icon: const Icon(Icons.add, size: 20),
                //   label: Text(
                //     'Add Test Submission',
                //     style: KStyle.labelMdRegularTextStyle.copyWith(
                //       color: KStyle.cWhiteColor,
                //     ),
                //   ),
                //   style: ElevatedButton.styleFrom(
                //     backgroundColor: KStyle.c00GreenColor,
                //     foregroundColor: KStyle.cWhiteColor,
                //     shape: RoundedRectangleBorder(
                //       borderRadius: BorderRadius.circular(8),
                //     ),
                //   ),
                // ),
                // const SizedBox(width: 16),
                // Debug Button
                // ElevatedButton.icon(
                //   onPressed: _debugSubmissions,
                //   icon: const Icon(Icons.bug_report, size: 20),
                //   label: Text(
                //     'Debug Submissions',
                //     style: KStyle.labelMdRegularTextStyle.copyWith(
                //       color: KStyle.cWhiteColor,
                //     ),
                //   ),
                //   style: ElevatedButton.styleFrom(
                //     backgroundColor: KStyle.c72GreyColor,
                //     foregroundColor: KStyle.cWhiteColor,
                //     shape: RoundedRectangleBorder(
                //       borderRadius: BorderRadius.circular(8),
                //     ),
                //   ),
                // ),
                // const SizedBox(width: 16),
                // Refresh Button
                // ElevatedButton.icon(
                //   onPressed: () {
                //     setState(() {
                //       // This will trigger a rebuild and reload submissions
                //     });
                //   },
                //   icon: const Icon(Icons.refresh, size: 20),
                //   label: Text(
                //     'Refresh',
                //     style: KStyle.labelMdRegularTextStyle.copyWith(
                //       color: KStyle.cWhiteColor,
                //     ),
                //   ),
                //   style: ElevatedButton.styleFrom(
                //     backgroundColor: KStyle.c72GreyColor,
                //     foregroundColor: KStyle.cWhiteColor,
                //     shape: RoundedRectangleBorder(
                //       borderRadius: BorderRadius.circular(8),
                //     ),
                //   ),
                // ),
              ],
            ),

            const SizedBox(height: 24),

            // Bulk Actions Bar
            if (selectedSubmissions.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: KStyle.cSelectedColor,
                  borderRadius: BorderRadius.circular(8),
                  border:
                      Border.all(color: KStyle.cPrimaryColor.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: KStyle.cPrimaryColor,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '${selectedSubmissions.length} submission${selectedSubmissions.length == 1 ? '' : 's'} selected',
                      style: KStyle.labelMdRegularTextStyle.copyWith(
                        color: KStyle.cPrimaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    if (selectedSubmissions
                        .any((s) => s.status == 'pending')) ...[
                      // ElevatedButton.icon(
                      //   onPressed: () => _bulkApproveSubmissions(),
                      //   style: ElevatedButton.styleFrom(
                      //     backgroundColor: KStyle.cPrimaryColor,
                      //     foregroundColor: KStyle.cWhiteColor,
                      //     padding: const EdgeInsets.symmetric(
                      //         horizontal: 16, vertical: 8),
                      //     shape: RoundedRectangleBorder(
                      //       borderRadius: BorderRadius.circular(6),
                      //     ),
                      //   ),
                      //   icon: const Icon(Icons.check, size: 16),
                      //   label: Text(
                      //     'Approve All',
                      //     style: KStyle.labelSmRegularTextStyle.copyWith(
                      //       color: KStyle.cWhiteColor,
                      //     ),
                      //   ),
                      // ),
                      // const SizedBox(width: 12),
                      // ElevatedButton.icon(
                      //   onPressed: () => _bulkRejectSubmissions(),
                      //   style: ElevatedButton.styleFrom(
                      //     backgroundColor: KStyle.cDBRedColor,
                      //     foregroundColor: KStyle.cWhiteColor,
                      //     padding: const EdgeInsets.symmetric(
                      //         horizontal: 16, vertical: 8),
                      //     shape: RoundedRectangleBorder(
                      //       borderRadius: BorderRadius.circular(6),
                      //     ),
                      //   ),
                      //   icon: const Icon(Icons.close, size: 16),
                      //   label: Text(
                      //     'Reject All',
                      //     style: KStyle.labelSmRegularTextStyle.copyWith(
                      //       color: KStyle.cWhiteColor,
                      //     ),
                      //   ),
                      // ),
                      // const SizedBox(width: 12),
                    ],
                    // ElevatedButton.icon(
                    //   onPressed: () => _bulkDeleteSubmissions(),
                    //   style: ElevatedButton.styleFrom(
                    //     backgroundColor: KStyle.cDBRedColor,
                    //     foregroundColor: KStyle.cWhiteColor,
                    //     padding: const EdgeInsets.symmetric(
                    //         horizontal: 16, vertical: 8),
                    //     shape: RoundedRectangleBorder(
                    //       borderRadius: BorderRadius.circular(6),
                    //     ),
                    //   ),
                    //   icon: const Icon(Icons.delete, size: 16),
                    //   label: Text(
                    //     'Delete All',
                    //     style: KStyle.labelSmRegularTextStyle.copyWith(
                    //       color: KStyle.cWhiteColor,
                    //     ),
                    //   ),
                    // ),
                    const SizedBox(width: 12),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          selectedSubmissions.clear();
                        });
                      },
                      child: Text(
                        'Clear Selection',
                        style: KStyle.labelSmRegularTextStyle.copyWith(
                          color: KStyle.c72GreyColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Submissions List
            Expanded(
              child: FutureBuilder<List<SubmissionModel>>(
                future: FirebaseService.getSubmissionsForForm(_form!.id!),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Error loading submissions: ${snapshot.error}',
                        style: KStyle.labelMdRegularTextStyle.copyWith(
                          color: Colors.red,
                        ),
                      ),
                    );
                  }

                  final allSubmissions = snapshot.data ?? [];
                  final submissions = _filterSubmissions(allSubmissions);

                  print(
                      '🔍 Submissions loaded: ${allSubmissions.length} total, ${submissions.length} filtered');
                  for (final submission in allSubmissions) {
                    print(
                        '🔍 Submission: ${submission.submitterName} - ${submission.status} - ${submission.id}');
                  }

                  if (submissions.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.inbox_outlined,
                            size: 64,
                            color: KStyle.c72GreyColor,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            selectedStatusFilter == 'All'
                                ? 'No submissions yet'
                                : 'No $selectedStatusFilter submissions',
                            style: KStyle.heading3TextStyle.copyWith(
                              color: KStyle.c72GreyColor,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            selectedStatusFilter == 'All'
                                ? 'When users submit this form, their responses will appear here'
                                : 'No submissions match the selected status filter',
                            style: KStyle.labelMdRegularTextStyle.copyWith(
                              color: KStyle.c72GreyColor,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  }

                  return Column(
                    children: [
                      // Table Header
                      Row(
                        children: [
                          SizedBox(
                            width: 24,
                            child: Checkbox(
                              value: selectedSubmissions.isNotEmpty &&
                                  selectedSubmissions.length ==
                                      submissions.length,
                              onChanged: (value) {
                                setState(() {
                                  if (value == true) {
                                    selectedSubmissions.clear();
                                    selectedSubmissions.addAll(submissions);
                                  } else {
                                    selectedSubmissions.clear();
                                  }
                                });
                              },
                              activeColor: KStyle.cPrimaryColor,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            flex: 2,
                            child: Text(
                              'Submitter & Time',
                              style: KStyle.labelTextStyle.copyWith(
                                color: KStyle.c89GreyColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Row(
                              children: [
                                Text(
                                  'Status',
                                  style: KStyle.labelTextStyle.copyWith(
                                    color: KStyle.c89GreyColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Text(
                                  '',
                                  style: KStyle.labelTextStyle.copyWith(
                                    color: KStyle.c89GreyColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Divider
                      Container(
                        height: 1,
                        color: KStyle.cE3GreyColor,
                      ),

                      const SizedBox(height: 16),

                      // Submissions List
                      Expanded(
                        child: ListView.builder(
                          itemCount: submissions.length,
                          itemBuilder: (context, index) {
                            final submission = submissions[index];
                            return _buildSubmissionRow(submission);
                          },
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShareTab() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Share Form',
            style: KStyle.heading3TextStyle.copyWith(
              color: KStyle.cBlackColor,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Share this link with others to collect responses:',
            style: KStyle.labelMdRegularTextStyle.copyWith(
              color: KStyle.c72GreyColor,
            ),
          ),
          const SizedBox(height: 24),

          // Share link card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: KStyle.cWhiteColor,
              border: Border.all(color: KStyle.cE3GreyColor),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        _form!.shareLink ?? 'No share link available',
                        style: KStyle.labelMdRegularTextStyle.copyWith(
                          color: KStyle.cPrimaryColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton.icon(
                      onPressed:
                          _form!.shareLink != null ? _copyShareLink : null,
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
                      icon: const Icon(Icons.copy, size: 16),
                      label: Text(
                        'Copy Link',
                        style: KStyle.labelSmRegularTextStyle.copyWith(
                          color: KStyle.cWhiteColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 16,
                      color: KStyle.c72GreyColor,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Form status: ${_form!.status}',
                      style: KStyle.labelSmRegularTextStyle.copyWith(
                        color: KStyle.c72GreyColor,
                      ),
                    ),
                  ],
                ),
                Switch(
                  value: _form!.requiresApproval,
                  onChanged: _toggleApproval,
                  activeColor: KStyle.cPrimaryColor,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTab() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Form Settings',
            style: KStyle.heading3TextStyle.copyWith(
              color: KStyle.cBlackColor,
            ),
          ),
          const SizedBox(height: 24),

          // Approval toggle
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: KStyle.cWhiteColor,
              border: Border.all(color: KStyle.cE3GreyColor),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Require Approval',
                      style: KStyle.labelMdBoldTextStyle.copyWith(
                        color: KStyle.cBlackColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Submissions will be marked as pending until approved',
                      style: KStyle.labelSmRegularTextStyle.copyWith(
                        color: KStyle.c72GreyColor,
                      ),
                    ),
                  ],
                ),
                Switch(
                  value: _form!.requiresApproval,
                  onChanged: _toggleApproval,
                  activeColor: KStyle.cPrimaryColor,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmissionRow(SubmissionModel submission) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          SizedBox(
            width: 24,
            child: Checkbox(
              value: selectedSubmissions.contains(submission),
              onChanged: (value) {
                setState(() {
                  if (value == true) {
                    selectedSubmissions.add(submission);
                  } else {
                    selectedSubmissions.remove(submission);
                  }
                });
              },
              activeColor: KStyle.cPrimaryColor,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  submission.submitterName,
                  style: KStyle.labelMdBoldTextStyle.copyWith(
                    color: KStyle.cBlackColor,
                  ),
                ),
                Text(
                  submission.submitterEmail,
                  style: KStyle.labelSmRegularTextStyle.copyWith(
                    color: KStyle.c72GreyColor,
                  ),
                ),
                Text(
                  _formatDate(submission.createdAt),
                  style: KStyle.labelXsRegularTextStyle.copyWith(
                    color: KStyle.c72GreyColor,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Row(
              children: [
                _buildStatusChip(
                    _form!.requiresApproval ? submission.status : '-'),
                SizedBox(width: 10),
                Row(
                  children: [
                    IconButton(
                      onPressed: () => _showSubmissionDetails(submission),
                      icon: Icon(
                        Icons.visibility_outlined,
                        color: KStyle.c72GreyColor,
                        size: 20,
                      ),
                    ),
                    IconButton(
                      onPressed: () => _deleteSubmission(submission),
                      icon: Icon(
                        Icons.delete_outline,
                        color: KStyle.cDBRedColor,
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color backgroundColor;
    Color textColor;
    String statusText;

    switch (status) {
      case 'pending':
        backgroundColor = const Color(0xFFFFF3CD);
        textColor = const Color(0xFF856404);
        statusText = 'Pending';
        break;
      case 'approved':
        backgroundColor = KStyle.cE8GreenColor;
        textColor = KStyle.c25GreenColor;
        statusText = 'Approved';
        break;
      case 'rejected':
        backgroundColor = KStyle.cFF3Color;
        textColor = KStyle.cDBRedColor;
        statusText = 'Rejected';
        break;
      default:
        backgroundColor = Colors.transparent;
        textColor = KStyle.c72GreyColor;
        statusText = '-';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        statusText,
        style: KStyle.labelXsRegularTextStyle.copyWith(
          color: textColor,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  List<SubmissionModel> _filterSubmissions(List<SubmissionModel> submissions) {
    switch (selectedStatusFilter) {
      case 'Pending':
        return submissions.where((s) => s.status == 'pending').toList();
      case 'Approved':
        return submissions.where((s) => s.status == 'approved').toList();
      case 'Rejected':
        return submissions.where((s) => s.status == 'rejected').toList();
      default:
        return submissions;
    }
  }

  String _formatDate(DateTime date) {
    return '${_getMonthName(date.month)} ${date.day}, ${date.year}, ${_formatTime(date)}';
  }

  String _getMonthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return months[month - 1];
  }

  String _formatTime(DateTime date) {
    final hour = date.hour > 12 ? date.hour - 12 : date.hour;
    final minute = date.minute.toString().padLeft(2, '0');
    final period = date.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }

  void _showSubmissionDetails(SubmissionModel submission) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Container(
          width: 600,
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
                    'Submission Details',
                    style: KStyle.heading3TextStyle.copyWith(
                      color: KStyle.cBlackColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: Icon(
                          Icons.close,
                          color: KStyle.c72GreyColor,
                          size: 24,
                        ),
                      ),
                      Text(
                        _formatDate(submission.createdAt),
                        style: KStyle.labelMdRegularTextStyle.copyWith(
                          color: KStyle.cBlackColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (_form!.requiresApproval)
                        _buildStatusChip(submission.status),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Submission Info
              _buildDetailRow(
                  'Submission Time', _formatDate(submission.createdAt)),
              if (_form!.requiresApproval)
                _buildDetailRow('Status', submission.status),

              const SizedBox(height: 16),

              // Form Data
              if (!_form!.requiresApproval) ...[
                for (final field in _form!.fields)
                  _buildDetailRow(
                    field.label,
                    submission.data[field.id]?.toString() ?? '',
                  ),
              ] else ...[
                Text(
                  'Form Responses:',
                  style: KStyle.labelMdBoldTextStyle.copyWith(
                    color: KStyle.cBlackColor,
                  ),
                ),
                const SizedBox(height: 12),
                // Use structured data with null safety
                ...submission.getStructuredData().map(
                      (item) => _buildDetailRow(
                        item['label'] ?? 'Unknown Question',
                        item['answer'] ?? '',
                      ),
                    ),
              ],

              const SizedBox(height: 16),

              if (_form!.requiresApproval) ...[
                // Comment field for reviewers
                Text(
                  'Comment:',
                  style: KStyle.labelMdRegularTextStyle.copyWith(
                    color: KStyle.cBlackColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Comment',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: KStyle.cE3GreyColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: KStyle.cPrimaryColor),
                    ),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 24),
                // Action Buttons
                if (submission.status == 'pending') ...[
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => _approveSubmission(submission),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: KStyle.cPrimaryColor,
                            foregroundColor: KStyle.cWhiteColor,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            'Approve',
                            style: KStyle.labelMdBoldTextStyle.copyWith(
                              color: KStyle.cWhiteColor,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => _rejectSubmission(submission),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: KStyle.cDBRedColor,
                            foregroundColor: KStyle.cWhiteColor,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            'Reject',
                            style: KStyle.labelMdBoldTextStyle.copyWith(
                              color: KStyle.cWhiteColor,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ] else ...[
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: KStyle.cPrimaryColor,
                        foregroundColor: KStyle.cWhiteColor,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'Close',
                        style: KStyle.labelMdBoldTextStyle.copyWith(
                          color: KStyle.cWhiteColor,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // SizedBox(
          //   width: 120,
          //   child: Text(
          //     '$label:',
          //     style: KStyle.labelMdRegularTextStyle.copyWith(
          //       color: KStyle.c72GreyColor,
          //       fontWeight: FontWeight.w600,
          //     ),
          //   ),
          // ),
          Expanded(
            child: Text(
              value,
              style: KStyle.labelMdRegularTextStyle.copyWith(
                color: KStyle.cBlackColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _approveSubmission(SubmissionModel submission) async {
    try {
      await FirebaseService.updateSubmissionStatus(
        submission.id!,
        'approved',
      );

      // Send approval email to submitter
      if (submission.submitterEmail.isNotEmpty && _form != null) {
        try {
          await FirebaseService.sendEmail(
            to: submission.submitterEmail,
            subject: 'Submission Approved: ${_form!.title}',
            html: '<p>Your submission has been approved!</p>',
            type: 'submission_decision',
            formTitle: _form!.title,
            submitterName: submission.submitterName,
            status: 'approved',
            comments: '', // You can add a comment field if needed
          );
        } catch (emailError) {
          print('Error sending approval email: $emailError');
          // Don't fail the approval if email fails
        }
      }

      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Submission approved successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error approving submission: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _rejectSubmission(SubmissionModel submission) async {
    try {
      await FirebaseService.updateSubmissionStatus(
        submission.id!,
        'rejected',
      );

      // Send rejection email to submitter
      if (submission.submitterEmail.isNotEmpty && _form != null) {
        try {
          await FirebaseService.sendEmail(
            to: submission.submitterEmail,
            subject: 'Submission Rejected: ${_form!.title}',
            html: '<p>Your submission has been rejected.</p>',
            type: 'submission_decision',
            formTitle: _form!.title,
            submitterName: submission.submitterName,
            status: 'rejected',
            comments: '', // You can add a comment field if needed
          );
        } catch (emailError) {
          print('Error sending rejection email: $emailError');
          // Don't fail the rejection if email fails
        }
      }

      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Submission rejected successfully'),
          backgroundColor: Colors.orange,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error rejecting submission: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _deleteSubmission(SubmissionModel submission) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Delete Submission',
          style: KStyle.heading3TextStyle.copyWith(
            color: KStyle.cBlackColor,
          ),
        ),
        content: Text(
          'Are you sure you want to delete this submission? This action cannot be undone.',
          style: KStyle.labelMdRegularTextStyle.copyWith(
            color: KStyle.c72GreyColor,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              'Cancel',
              style: KStyle.labelMdRegularTextStyle.copyWith(
                color: KStyle.c72GreyColor,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: KStyle.cDBRedColor,
              foregroundColor: KStyle.cWhiteColor,
            ),
            child: Text(
              'Delete',
              style: KStyle.labelMdRegularTextStyle.copyWith(
                color: KStyle.cWhiteColor,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await FirebaseService.deleteSubmission(submission.id!);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Submission deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting submission: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _copyShareLink() {
    // Generate a shareable link for the form with dynamic base URL
    String baseUrl;

    // Try to get the current running address
    try {
      // For web, we can try to get the current URL
      if (kIsWeb) {
        // Use window.location for web
        baseUrl =
            '${Uri.base.scheme}://${Uri.base.host}${Uri.base.hasPort ? ':${Uri.base.port}' : ''}';
      } else {
        // For mobile/desktop, use a default URL or get from configuration
        baseUrl =
            'https://formflow-b0484.web.app'; // Default to Firebase hosting URL
      }
    } catch (e) {
      // Fallback to Firebase hosting URL
      baseUrl = 'https://formflow-b0484.web.app';
    }

    // Generate responder link (without view parameter for actual submissions)
    final String link = '$baseUrl/form/${_form!.id}';

    // Show dialog with copy and open options
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Form Submission Link',
            style: KStyle.heading3TextStyle.copyWith(
              color: KStyle.cBlackColor,
            ),
          ),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Share this link to let others fill out your form:',
                style: KStyle.labelMdRegularTextStyle.copyWith(
                  color: KStyle.c72GreyColor,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: KStyle.cF4GreyColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SelectableText(
                  link,
                  style: KStyle.labelMdRegularTextStyle.copyWith(
                    fontFamily: 'monospace',
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Cancel',
                style: KStyle.labelMdRegularTextStyle.copyWith(
                  color: KStyle.c72GreyColor,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _copyToClipboard(link);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: KStyle.cPrimaryColor,
                foregroundColor: KStyle.cWhiteColor,
              ),
              child: Text('Copy Link'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _openLink(link);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: KStyle.cWhiteColor,
                foregroundColor: KStyle.cPrimaryColor,
                side: BorderSide(color: KStyle.cPrimaryColor),
              ),
              child: Text('Open Link'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _copyToClipboard(String link) async {
    try {
      await Clipboard.setData(ClipboardData(text: link));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Form link copied to clipboard!'),
          backgroundColor: KStyle.cPrimaryColor,
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to copy form link: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _openLink(String link) async {
    try {
      final uri = Uri.parse(link);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not open link: $link'),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error opening link: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _toggleApproval(bool value) async {
    try {
      final updatedForm = _form!.copyWith(requiresApproval: value);
      await FirebaseService.updateForm(_form!.id!, updatedForm);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            value ? 'Approval required enabled' : 'Approval required disabled',
          ),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating form: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showUserMenu(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          contentPadding: EdgeInsets.zero,
          content: Container(
            width: 200,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildMenuItem('View Profile', Icons.person_outline, () {
                  Navigator.of(context).pop();
                  // TODO: Navigate to profile screen
                }),
                _buildMenuItem('Settings', Icons.settings_outlined, () {
                  Navigator.of(context).pop();
                  // TODO: Navigate to settings screen
                }),
                Container(
                  height: 1,
                  color: KStyle.cE3GreyColor,
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                ),
                _buildMenuItem('Sign Out', Icons.logout, () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop(); // Go back to home screen
                }, isDestructive: true),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMenuItem(String title, IconData icon, VoidCallback onTap,
      {bool isDestructive = false}) {
    return ListTile(
      leading: Icon(
        icon,
        size: 20,
        color: isDestructive ? KStyle.cDBRedColor : KStyle.c72GreyColor,
      ),
      title: Text(
        title,
        style: KStyle.labelMdRegularTextStyle.copyWith(
          color: isDestructive ? KStyle.cDBRedColor : KStyle.cBlackColor,
        ),
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      minLeadingWidth: 24,
    );
  }

  void _showStatusFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Filter by Status',
          style: KStyle.heading3TextStyle.copyWith(
            color: KStyle.cBlackColor,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            'All',
            'Pending',
            'Approved',
            'Rejected',
          ]
              .map((status) => ListTile(
                    title: Text(status),
                    onTap: () {
                      Navigator.of(context).pop();
                      setState(() {
                        selectedStatusFilter = status;
                      });
                    },
                  ))
              .toList(),
        ),
      ),
    );
  }
}
