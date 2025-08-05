import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:formflow/constants/style.dart';
import 'package:formflow/models/form_model.dart';
import 'package:formflow/models/submission_model.dart';
import 'package:formflow/services/firebase_service.dart';
import 'package:formflow/screens/form_builder_screen.dart';

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
      appBar: AppBar(
        backgroundColor: KStyle.cWhiteColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: KStyle.cBlackColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          widget.form.title,
          style: KStyle.heading3TextStyle.copyWith(
            color: KStyle.cBlackColor,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.edit, color: KStyle.cPrimaryColor),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => FormBuilderScreen(form: widget.form),
                ),
              );
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: KStyle.cPrimaryColor,
          unselectedLabelColor: KStyle.c72GreyColor,
          indicatorColor: KStyle.cPrimaryColor,
          tabs: const [
            Tab(text: 'Submissions'),
            Tab(text: 'Share'),
            Tab(text: 'Settings'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildSubmissionsTab(),
          _buildShareTab(),
          _buildSettingsTab(),
        ],
      ),
    );
  }

  Widget _buildSubmissionsTab() {
    return Column(
      children: [
        // Filters and actions
        Container(
          padding: const EdgeInsets.all(24),
          child: Row(
            children: [
              // Status filters
              ...statusFilters.map((filter) {
                bool isSelected = selectedStatusFilter == filter;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedStatusFilter = filter;
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.only(right: 16),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? KStyle.cPrimaryColor
                          : KStyle.cF4GreyColor,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      filter,
                      style: KStyle.labelSmRegularTextStyle.copyWith(
                        color: isSelected
                            ? KStyle.cWhiteColor
                            : KStyle.c72GreyColor,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                  ),
                );
              }).toList(),
              const Spacer(),
              // Download CSV button
              if (selectedSubmissions.isNotEmpty)
                ElevatedButton.icon(
                  onPressed: _downloadCSV,
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
                    'Download CSV (${selectedSubmissions.length})',
                    style: KStyle.labelSmRegularTextStyle.copyWith(
                      color: KStyle.cWhiteColor,
                    ),
                  ),
                ),
            ],
          ),
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
                padding: const EdgeInsets.symmetric(horizontal: 24),
                itemCount: filteredSubmissions.length,
                itemBuilder: (context, index) {
                  final submission = filteredSubmissions[index];
                  return _buildSubmissionCard(submission);
                },
              );
            },
          ),
        ),
      ],
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
        backgroundColor = KStyle.cF4GreyColor;
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
    return '${date.day}/${date.month}/${date.year}';
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
