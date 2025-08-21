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
import 'package:csv/csv.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:file_saver/file_saver.dart';
import 'dart:typed_data';
import 'package:formflow/screens/profile_screen.dart';

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
  bool _isDownloadingCsv = false;

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
              color: KStyle.cPrimaryColor,
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
                          color: KStyle.cWhiteColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        margin: const EdgeInsets.only(top: 10),
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: KStyle.cWhiteColor,
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
                      StreamBuilder<int>(
                        stream:
                            FirebaseService.getUnreadNotificationsCountStream(),
                        builder: (context, snapshot) {
                          final notificationCount = snapshot.data ?? 0;
                          return _buildNavItem(
                            icon: Icons.notifications_outlined,
                            title: 'Notifications',
                            isSelected: selectedNavItem == 2,
                            notificationCount: notificationCount > 0
                                ? notificationCount
                                : null,
                            onTap: () {
                              setState(() {
                                selectedNavItem = 2;
                              });
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const NotificationScreen(),
                                ),
                              );
                            },
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
                        color: KStyle.cWhiteColor,
                        width: 1,
                      ),
                    ),
                  ),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const ProfileScreen(),
                        ),
                      );
                    },
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: KStyle.cWhiteColor,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Image.asset(
                            'assets/images/profile.png',
                            fit: BoxFit.cover,
                            // width: double.infinity,
                            // height: 140,
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
                                  color: KStyle.cWhiteColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                'View Profile',
                                style: KStyle.labelSmRegularTextStyle.copyWith(
                                  color: KStyle.cWhiteColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.keyboard_arrow_down,
                          color: KStyle.cWhiteColor,
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
                color: KStyle.cBackgroundColor,
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
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 16),
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
                                  icon: SvgPicture.asset(
                                    'assets/icons/eye.svg',
                                    width: 20,
                                    height: 20,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                IconButton(
                                  onPressed: _copyShareLink,
                                  icon: SvgPicture.asset(
                                    'assets/icons/copy.svg',
                                    width: 20,
                                    height: 20,
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
                                    backgroundColor: KStyle.cPrimaryColor,
                                    foregroundColor: KStyle.cPrimaryColor,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 8,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    elevation: 0,
                                    side:
                                        BorderSide(color: KStyle.cPrimaryColor),
                                  ),
                                  // icon: const Icon(Icons.edit, size: 20,),
                                  icon: IconButton(
                                    onPressed: () {
                                      // TODO: Implement preview
                                    },
                                    icon: SvgPicture.asset(
                                      'assets/icons/edit.svg',
                                      width: 18,
                                      height: 18,
                                      colorFilter: ColorFilter.mode(
                                          KStyle.cWhiteColor, BlendMode.srcIn),
                                    ),
                                  ),
                                  label: Text(
                                    'Edit Form',
                                    style: KStyle.labelTextStyle.copyWith(
                                      color: KStyle.cWhiteColor,
                                    ),
                                  ),
                                ),
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
          color: isSelected ? KStyle.cWhiteColor : Colors.transparent,
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
                  color: isSelected ? KStyle.cPrimaryColor : KStyle.cWhiteColor,
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
                color: isSelected ? KStyle.cPrimaryColor : KStyle.cWhiteColor,
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
        color: KStyle.cBackgroundColor,
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
                          style: KStyle.labelTextStyle.copyWith(
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
                // ElevatedButton.icon(
                //   onPressed: () {
                //     // TODO: Implement CSV download
                //     ScaffoldMessenger.of(context).showSnackBar(
                //       const SnackBar(
                //         content: Text('CSV download coming soon!'),
                //         backgroundColor: Colors.blue,
                //       ),
                //     );
                //   },
                //   icon: const Icon(Icons.download, size: 20),
                //   label: Text(
                //     'Download CSV',
                //     style: KStyle.labelMdRegularTextStyle.copyWith(
                //       color: KStyle.cWhiteColor,
                //     ),
                //   ),
                //   style: ElevatedButton.styleFrom(
                //     backgroundColor: KStyle.cPrimaryColor,
                //     foregroundColor: KStyle.cWhiteColor,

                //   ),
                // ),

                ElevatedButton.icon(
                  onPressed: _isDownloadingCsv
                      ? null
                      : () async {
                          setState(() => _isDownloadingCsv = true);
                          final allSubmissions =
                              await FirebaseService.getSubmissionsForForm(
                                  _form!.id!);
                          final filtered = _filterSubmissions(allSubmissions);
                          final toExport = selectedSubmissions.isNotEmpty
                              ? selectedSubmissions
                              : filtered;
                          await _downloadCsv(toExport);
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isDownloadingCsv
                        ? KStyle.cE3GreyColor
                        : KStyle.cSelectedColor,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 20,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  icon: SvgPicture.asset(
                    'assets/icons/download.svg',
                    width: 18,
                    height: 18,
                  ),
                  label: Text(
                    _isDownloadingCsv ? 'Downloading...' : 'Download CSV',
                    style: KStyle.labelTextStyle.copyWith(
                      color: KStyle.cPrimaryColor,
                    ),
                  ),
                ),
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
                          Image.asset(
                            'assets/images/no_form.png',
                            fit: BoxFit.contain,
                            width: 150,
                            height: 150,
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
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      // Table Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 5,
                            child: Text(
                              'Status',
                              style: KStyle.labelTextStyle.copyWith(
                                color: KStyle.c89GreyColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          Row(
                            children: [
                              Text(
                                '',
                                style: KStyle.labelTextStyle.copyWith(
                                  color: KStyle.c89GreyColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                      const SizedBox(height: 4),

                      // Divider
                      Container(
                        height: 1,
                        color: KStyle.cE3GreyColor,
                      ),
                      const SizedBox(height: 4),

                      // Submissions List
                      Expanded(
                        child: ListView.separated(
                          itemCount: submissions.length,
                          itemBuilder: (context, index) {
                            final submission = submissions[index];
                            return _buildSubmissionRow(submission);
                          },
                          separatorBuilder: (context, index) => Divider(
                            thickness: 1,
                            color: KStyle.cE3GreyColor,
                          ),
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
    final isSelected = selectedSubmissions.contains(submission);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: isSelected
              ? KStyle.cSelectedColor.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
              width: 24,
              child: Tooltip(
                message:
                    isSelected ? 'Deselect submission' : 'Select submission',
                child: Checkbox(
                  value: isSelected,
                  onChanged: (value) {
                    print(
                        '🔍 Checkbox clicked for submission: ${submission.id}');
                    print('🔍 Current value: $value');
                    print(
                        '🔍 Current selectedSubmissions count: ${selectedSubmissions.length}');
                    print(
                        '🔍 Submission already selected: ${selectedSubmissions.contains(submission)}');

                    setState(() {
                      if (value == true) {
                        selectedSubmissions.add(submission);
                        print('🔍 Added submission to selection');
                      } else {
                        selectedSubmissions.remove(submission);
                        print('🔍 Removed submission from selection');
                      }
                    });

                    print(
                        '🔍 New selectedSubmissions count: ${selectedSubmissions.length}');
                  },
                  activeColor: KStyle.cPrimaryColor,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 2,
              child: InkWell(
                onTap: () => _showSubmissionDetails(submission),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _formatDate(submission.createdAt),
                      style: KStyle.labelTextStyle.copyWith(
                        color: KStyle.c3BGreyColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 5,
              child: InkWell(
                onTap: () => _showSubmissionDetails(submission),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStatusChip(
                        _form!.requiresApproval ? submission.status : '-'),
                  ],
                ),
              ),
            ),
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: KStyle.cFFColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: IconButton(
                    onPressed: () => _deleteSubmission(submission),
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
          ],
        ),
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
        textColor = KStyle.cPendingColor;
        statusText = 'Pending';
        break;
      case 'approved':
        backgroundColor = KStyle.cE8GreenColor;
        textColor = KStyle.cApproveColor;
        statusText = 'Approved';
        break;
      case 'rejected':
        backgroundColor = KStyle.cFF3Color;
        textColor = KStyle.cRejectColor;
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
    final TextEditingController _commentController = TextEditingController();
    bool _isDecisionMade = false;
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: StatefulBuilder(
          builder: (context, setState) {
            return Container(
              decoration: BoxDecoration(
                color: KStyle.cWhiteColor,
                borderRadius: BorderRadius.circular(10),
              ),
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
                  // _buildDetailRow('Submission Time', _formatDate(submission.createdAt)),
                  // if (_form!.requiresApproval)
                  //   _buildDetailRow('Status', submission.status),

                  const SizedBox(height: 16),

                  const SizedBox(height: 8),
                  Text(
                    'Responses:',
                    style: KStyle.labelMdBoldTextStyle.copyWith(
                      color: KStyle.cBlackColor,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...submission.getStructuredData().map(
                        (item) => _buildDetailRow(
                          (item['label']?.isNotEmpty ?? false)
                              ? item['label']!
                              : (item['fieldId'] ?? 'Unknown Question'),
                          item['answer'] ?? '',
                        ),
                      ),

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
                      controller: _commentController,
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
                              onPressed: _isDecisionMade
                                  ? null
                                  : () async {
                                      setState(() => _isDecisionMade = true);
                                      await _approveSubmission(
                                          submission, _commentController.text);
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _isDecisionMade
                                    ? KStyle.cE3GreyColor
                                    : KStyle.cSelectedColor,
                                foregroundColor: _isDecisionMade
                                    ? KStyle.c72GreyColor
                                    : KStyle.cPrimaryColor,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                elevation: 0,
                              ),
                              child: Text(
                                'Approve',
                                style: KStyle.labelMdBoldTextStyle.copyWith(
                                  color: _isDecisionMade
                                      ? KStyle.c72GreyColor
                                      : KStyle.cPrimaryColor,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _isDecisionMade
                                  ? null
                                  : () async {
                                      setState(() => _isDecisionMade = true);
                                      await _rejectSubmission(
                                          submission, _commentController.text);
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _isDecisionMade
                                    ? KStyle.cE3GreyColor
                                    : const Color(0xFFFFE5E5),
                                foregroundColor: _isDecisionMade
                                    ? KStyle.c72GreyColor
                                    : KStyle.cDBRedColor,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                elevation: 0,
                              ),
                              child: Text(
                                'Reject',
                                style: KStyle.labelMdBoldTextStyle.copyWith(
                                  color: _isDecisionMade
                                      ? KStyle.c72GreyColor
                                      : KStyle.cDBRedColor,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ] else ...[
                      SizedBox.shrink(),
                      // SizedBox(
                      //   width: double.infinity,
                      //   child: ElevatedButton(
                      //     onPressed: () => Navigator.of(context).pop(),
                      //     style: ElevatedButton.styleFrom(
                      //       backgroundColor: KStyle.cPrimaryColor,
                      //       foregroundColor: KStyle.cWhiteColor,
                      //       padding: const EdgeInsets.symmetric(vertical: 16),
                      //       shape: RoundedRectangleBorder(
                      //         borderRadius: BorderRadius.circular(8),
                      //       ),
                      //     ),
                      //     child: Text(
                      //       'Close',
                      //       style: KStyle.labelMdBoldTextStyle.copyWith(
                      //         color: KStyle.cWhiteColor,
                      //       ),
                      //     ),
                      //   ),
                      // ),
                    ],
                  ],
                ],
              ),
            );
          },
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
          SizedBox(
            width: 160, // Adjust as needed for your layout
            child: Text(
              '$label:',
              style: KStyle.labelMdBoldTextStyle.copyWith(
                color: KStyle.cBlackColor,
              ),
            ),
          ),
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

  Future<void> _approveSubmission(
      SubmissionModel submission, String comment) async {
    try {
      await FirebaseService.updateSubmissionStatus(
        submission.id!,
        'approved',
        comment: comment,
      );

      // Send approval email to submitter
      if (submission.submitterEmail.isNotEmpty && _form != null) {
        try {
          print(
              '🔍 Sending approval email to submitter: ${submission.submitterEmail}');

          // Create better approval email template
          final approvalHtml = '''
            <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
              <h2 style="color: #10b981;">Submission Approved! 🎉</h2>
              <p>Great news! Your submission for <strong>${_form!.title}</strong> has been approved.</p>
              
              <div style="background: #f0fdf4; padding: 20px; border-radius: 8px; margin: 20px 0; border-left: 4px solid #10b981;">
                <h3 style="color: #166534; margin-top: 0;">Approval Details:</h3>
                <p><strong>Form:</strong> ${_form!.title}</p>
                <p><strong>Status:</strong> <span style="color: #10b981; font-weight: bold;">Approved</span></p>
                <p><strong>Reviewed:</strong> ${DateTime.now().toString()}</p>
              </div>
              
              <p>Your submission has been reviewed and approved. Thank you for your participation!</p>
              
              <div style="text-align: center; margin-top: 30px;">
                <a href="https://formflow-b0484.web.app" style="background: #10b981; color: white; padding: 12px 24px; text-decoration: none; border-radius: 6px; display: inline-block;">View Form</a>
              </div>
            </div>
          ''';

          final emailSent = await FirebaseService.sendEmail(
            to: submission.submitterEmail,
            subject: 'Submission Approved - ${_form!.title}',
            html: approvalHtml,
            type: 'submission_decision',
            formTitle: _form!.title,
            submitterName: submission.submitterName,
            submitterEmail: submission.submitterEmail,
            status: 'approved',
            comments: comment,
          );

          if (emailSent) {
            print('✅ Approval email sent successfully to submitter');
          } else {
            print('❌ Failed to send approval email to submitter');
          }
        } catch (e) {
          print('❌ Failed to send approval email to submitter: $e');
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

  Future<void> _rejectSubmission(
      SubmissionModel submission, String comment) async {
    try {
      await FirebaseService.updateSubmissionStatus(
        submission.id!,
        'rejected',
        comment: comment,
      );

      // Send rejection email to submitter
      if (submission.submitterEmail.isNotEmpty && _form != null) {
        try {
          print(
              '🔍 Sending rejection email to submitter: ${submission.submitterEmail}');

          // Create better rejection email template
          final rejectionHtml = '''
            <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
              <h2 style="color: #ef4444;">Submission Update</h2>
              <p>Your submission for <strong>${_form!.title}</strong> has been reviewed.</p>
              
              <div style="background: #fef2f2; padding: 20px; border-radius: 8px; margin: 20px 0; border-left: 4px solid #ef4444;">
                <h3 style="color: #991b1b; margin-top: 0;">Review Details:</h3>
                <p><strong>Form:</strong> ${_form!.title}</p>
                <p><strong>Status:</strong> <span style="color: #ef4444; font-weight: bold;">Rejected</span></p>
                <p><strong>Reviewed:</strong> ${DateTime.now().toString()}</p>
                ${comment.isNotEmpty ? '<p><strong>Comments:</strong> $comment</p>' : ''}
              </div>
              
              <p>We appreciate your submission. Please review the feedback and consider submitting again if applicable.</p>
              
              <div style="text-align: center; margin-top: 30px;">
                <a href="https://formflow-b0484.web.app" style="background: #ef4444; color: white; padding: 12px 24px; text-decoration: none; border-radius: 6px; display: inline-block;">View Form</a>
              </div>
            </div>
          ''';

          final emailSent = await FirebaseService.sendEmail(
            to: submission.submitterEmail,
            subject: 'Submission Update - ${_form!.title}',
            html: rejectionHtml,
            type: 'submission_decision',
            formTitle: _form!.title,
            submitterName: submission.submitterName,
            submitterEmail: submission.submitterEmail,
            status: 'rejected',
            comments: comment,
          );

          if (emailSent) {
            print('✅ Rejection email sent successfully to submitter');
          } else {
            print('❌ Failed to send rejection email to submitter');
          }
        } catch (e) {
          print('❌ Failed to send rejection email to submitter: $e');
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
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => ProfileScreen(),
                    ),
                  );
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

  Future<void> _downloadCsv(List<SubmissionModel> submissions) async {
    setState(() => _isDownloadingCsv = true);
    print('DEBUG: Starting CSV download');
    if (submissions.isEmpty) {
      print('DEBUG: No submissions to export');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No submissions to export.'),
          backgroundColor: Colors.orange,
        ),
      );
      setState(() => _isDownloadingCsv = false);
      return;
    }

    // Request storage permission only on non-web
    if (!kIsWeb) {
      print('DEBUG: Requesting storage permission');
      final status = await Permission.storage.request();
      print('DEBUG: Permission status:  [33m${status.isGranted} [0m');
      if (!status.isGranted) {
        print('DEBUG: Storage permission denied');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Storage permission denied.'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() => _isDownloadingCsv = false);
        return;
      }
    }

    // Prepare CSV data
    print('DEBUG: Preparing CSV data');
    final headers = <String>[
      'ID',
      'Submitter Name',
      'Submitter Email',
      'Status',
      'Created At',
      ...?_form?.fields.map((f) => f.label),
    ];
    final rows = <List<String>>[headers];
    for (final s in submissions) {
      final row = <String>[
        s.id ?? '',
        s.submitterName,
        s.submitterEmail,
        s.status,
        _formatDate(s.createdAt),
      ];
      if (_form?.fields != null) {
        for (final f in _form!.fields) {
          row.add(s.getQuestionAnswer(f.id));
        }
      }
      rows.add(row);
    }
    final csvData = const ListToCsvConverter().convert(rows);
    print('DEBUG: CSV data prepared, length: ${csvData.length}');

    try {
      final now = DateTime.now();
      final fileName =
          'form_submissions_${_form?.title ?? 'form'}_${now.millisecondsSinceEpoch}.csv';
      final bytes = csvData.codeUnits;
      print('DEBUG: Calling FileSaver.saveFile');
      await FileSaver.instance.saveFile(
        name: fileName,
        bytes: Uint8List.fromList(bytes),
        ext: 'csv',
        mimeType: MimeType.csv,
      );
      print('DEBUG: FileSaver.saveFile completed');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('CSV downloaded: $fileName'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e, stack) {
      print('DEBUG: Error saving CSV: $e\n$stack');
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Download Error'),
          content: Text('Failed to save CSV: $e'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save CSV: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isDownloadingCsv = false);
      print('DEBUG: Download button state reset');
    }
  }
}
