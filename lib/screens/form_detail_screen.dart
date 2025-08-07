import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:formflow/constants/style.dart';
import 'package:formflow/models/form_model.dart';
import 'package:formflow/models/submission_model.dart';
import 'package:formflow/services/firebase_service.dart';
import 'package:formflow/screens/form_builder_screen.dart';
import 'package:formflow/screens/notification_screen.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:formflow/screens/home_screen.dart';

class FormDetailScreen extends StatefulWidget {
  final FormModel form;

  const FormDetailScreen({super.key, required this.form});

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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: KStyle.cPrimaryColor,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'form.',
                        style: KStyle.heading2TextStyle.copyWith(
                          color: KStyle.cPrimaryColor,
                          fontWeight: FontWeight.w600,
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
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(
                              builder: (context) => const HomeScreen(),
                            ),
                            (route) => false,
                          );
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
                              'Thomas Willy',
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
                crossAxisAlignment: CrossAxisAlignment.start,
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
                        Text(
                          'My Forms / ${widget.form.title}',
                          style: KStyle.labelSmRegularTextStyle.copyWith(
                            color: KStyle.c72GreyColor,
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Title and Actions Row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                widget.form.title,
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
                                    // TODO: Implement view form
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
                                  onPressed: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) => FormBuilderScreen(
                                            form: widget.form),
                                      ),
                                    );
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
                                    elevation: 0,
                                  ),
                                  icon: const Icon(Icons.edit, size: 20),
                                  label: Text(
                                    'Edit Form',
                                    style: KStyle.labelMdBoldTextStyle.copyWith(
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
    return GestureDetector(
      onTap: onTap,
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
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Container(
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
          children: [
            // Filters and actions
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  // Status filter dropdown
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                          size: 16,
                          color: KStyle.c72GreyColor,
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  // Download CSV button
                  ElevatedButton.icon(
                    onPressed:
                        selectedSubmissions.isNotEmpty ? _downloadCSV : null,
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
                    icon: const Icon(Icons.download, size: 16),
                    label: Text(
                      'Download CSV',
                      style: KStyle.labelSmRegularTextStyle.copyWith(
                        color: KStyle.cWhiteColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Table header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                color: KStyle.cWhiteColor,
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 40,
                    child: Checkbox(
                      value: selectedSubmissions.isNotEmpty,
                      onChanged: (value) {
                        setState(() {
                          if (value == true) {
                            // TODO: Select all submissions
                          } else {
                            selectedSubmissions.clear();
                          }
                        });
                      },
                      activeColor: KStyle.cPrimaryColor,
                      side: BorderSide(color: KStyle.c89GreyColor),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      'Submission Time',
                      style: KStyle.labelTextStyle.copyWith(
                        color: KStyle.c89GreyColor,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Text(
                      'Status',
                      style: KStyle.labelTextStyle.copyWith(
                        color: KStyle.c89GreyColor,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 40,
                    child: Text(
                      '',
                      style: KStyle.labelTextStyle.copyWith(
                        color: KStyle.c89GreyColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Divider
            Container(
              height: 1,
              color: KStyle.cE3GreyColor,
            ),

            // Submissions list
            Expanded(
              child: StreamBuilder<List<SubmissionModel>>(
                stream: FirebaseService.getSubmissionsStream(widget.form.id!),
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

                  final submissions = snapshot.data ?? [];
                  final filteredSubmissions = _filterSubmissions(submissions);

                  if (filteredSubmissions.isEmpty) {
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
                            'No submissions yet',
                            style: KStyle.heading3TextStyle.copyWith(
                              color: KStyle.c72GreyColor,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Share your form to start receiving responses',
                            style: KStyle.labelMdRegularTextStyle.copyWith(
                              color: KStyle.c72GreyColor,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: filteredSubmissions.length,
                    itemBuilder: (context, index) {
                      final submission = filteredSubmissions[index];
                      return _buildSubmissionRow(submission);
                    },
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
                        widget.form.shareLink ?? 'No share link available',
                        style: KStyle.labelMdRegularTextStyle.copyWith(
                          color: KStyle.cPrimaryColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton.icon(
                      onPressed:
                          widget.form.shareLink != null ? _copyShareLink : null,
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
                      'Form status: ${widget.form.status}',
                      style: KStyle.labelSmRegularTextStyle.copyWith(
                        color: KStyle.c72GreyColor,
                      ),
                    ),
                  ],
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
                  value: widget.form.requiresApproval,
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

    return Container(
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
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Row(
          children: [
            SizedBox(
              width: 40,
              child: Checkbox(
                value: isSelected,
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
            Expanded(
              flex: 2,
              child: Text(
                _formatDate(submission.createdAt),
                style: KStyle.labelMdRegularTextStyle.copyWith(
                  color: KStyle.cBlackColor,
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: _buildStatusChip(submission.status),
            ),
            SizedBox(
              width: 40,
              child: IconButton(
                onPressed: () {
                  _showDeleteConfirmation(submission);
                },
                icon: Icon(
                  Icons.delete_outline,
                  color: KStyle.cDBRedColor,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmissionCard(SubmissionModel submission) {
    final isSelected = selectedSubmissions.contains(submission);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: KStyle.cWhiteColor,
        border: Border.all(color: KStyle.cE3GreyColor),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: Checkbox(
          value: isSelected,
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
        title: Text(
          submission.submitterName,
          style: KStyle.labelMdBoldTextStyle.copyWith(
            color: KStyle.cBlackColor,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              submission.submitterEmail,
              style: KStyle.labelSmRegularTextStyle.copyWith(
                color: KStyle.c72GreyColor,
              ),
            ),
            Text(
              'Submitted: ${_formatDate(submission.createdAt)}',
              style: KStyle.labelXsRegularTextStyle.copyWith(
                color: KStyle.c72GreyColor,
              ),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildStatusChip(submission.status),
            const SizedBox(width: 8),
            PopupMenuButton<String>(
              onSelected: (value) => _handleSubmissionAction(submission, value),
              itemBuilder: (context) => [
                if (submission.status == 'pending')
                  const PopupMenuItem(
                    value: 'approve',
                    child: Text('Approve'),
                  ),
                if (submission.status == 'pending')
                  const PopupMenuItem(
                    value: 'reject',
                    child: Text('Reject'),
                  ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Text('Delete'),
                ),
              ],
              child: Icon(Icons.more_vert, color: KStyle.c72GreyColor),
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
    final months = [
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

    final month = months[date.month - 1];
    final day = date.day;
    final year = date.year;
    final hour = date.hour > 12 ? date.hour - 12 : date.hour;
    final minute = date.minute.toString().padLeft(2, '0');
    final period = date.hour >= 12 ? 'PM' : 'AM';

    return '$month $day, $year, $hour:$minute $period';
  }

  void _copyShareLink() {
    if (widget.form.shareLink != null) {
      Clipboard.setData(ClipboardData(text: widget.form.shareLink!));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Link copied to clipboard'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _toggleApproval(bool value) async {
    try {
      final updatedForm = widget.form.copyWith(requiresApproval: value);
      await FirebaseService.updateForm(widget.form.id!, updatedForm);

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
          content: Text('Error updating settings: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _handleSubmissionAction(
      SubmissionModel submission, String action) async {
    try {
      switch (action) {
        case 'approve':
          await FirebaseService.updateSubmissionStatus(
            submission.id!,
            'approved',
          );
          break;
        case 'reject':
          await FirebaseService.updateSubmissionStatus(
            submission.id!,
            'rejected',
          );
          break;
        case 'delete':
          _showDeleteConfirmation(submission);
          break;
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showDeleteConfirmation(SubmissionModel submission) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Submission'),
        content: const Text(
          'Are you sure you want to delete this submission? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await FirebaseService.deleteSubmission(submission.id!);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Submission deleted'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _downloadCSV() {
    // TODO: Implement CSV download functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('CSV download functionality coming soon'),
        backgroundColor: Colors.blue,
      ),
    );
  }
}
