import 'package:flutter/material.dart';
import 'package:formflow/constants/style.dart';
import 'package:formflow/models/submission_model.dart';
import 'package:formflow/services/firebase_service.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KStyle.cBgColor,
      appBar: AppBar(
        backgroundColor: KStyle.cWhiteColor,
        elevation: 0,
        title: Text(
          'Notifications',
          style: KStyle.heading3TextStyle.copyWith(
            color: KStyle.cBlackColor,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: KStyle.cBlackColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: StreamBuilder<List<SubmissionModel>>(
        stream: _getAllSubmissionsStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error loading notifications: ${snapshot.error}',
                style: KStyle.labelMdRegularTextStyle.copyWith(
                  color: Colors.red,
                ),
              ),
            );
          }

          final submissions = snapshot.data ?? [];
          final pendingSubmissions =
              submissions.where((s) => s.status == 'pending').toList();

          if (pendingSubmissions.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_none,
                    size: 64,
                    color: KStyle.c72GreyColor,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No new notifications',
                    style: KStyle.heading3TextStyle.copyWith(
                      color: KStyle.c72GreyColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'You\'re all caught up!',
                    style: KStyle.labelMdRegularTextStyle.copyWith(
                      color: KStyle.c72GreyColor,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: pendingSubmissions.length,
            itemBuilder: (context, index) {
              final submission = pendingSubmissions[index];
              return _buildNotificationCard(submission);
            },
          );
        },
      ),
    );
  }

  Widget _buildNotificationCard(SubmissionModel submission) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: KStyle.cWhiteColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: KStyle.cE3GreyColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: KStyle.cPrimaryColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.person,
            color: KStyle.cPrimaryColor,
            size: 20,
          ),
        ),
        title: Text(
          'New form submission',
          style: KStyle.labelMdBoldTextStyle.copyWith(
            color: KStyle.cBlackColor,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'From: ${submission.submitterName}',
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
            ElevatedButton(
              onPressed: () => _approveSubmission(submission),
              style: ElevatedButton.styleFrom(
                backgroundColor: KStyle.cE8GreenColor,
                foregroundColor: KStyle.c25GreenColor,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              child: Text(
                'Approve',
                style: KStyle.labelXsRegularTextStyle.copyWith(
                  color: KStyle.c25GreenColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () => _rejectSubmission(submission),
              style: ElevatedButton.styleFrom(
                backgroundColor: KStyle.cFF3Color,
                foregroundColor: KStyle.cDBRedColor,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              child: Text(
                'Reject',
                style: KStyle.labelXsRegularTextStyle.copyWith(
                  color: KStyle.cDBRedColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _approveSubmission(SubmissionModel submission) async {
    try {
      await FirebaseService.updateSubmissionStatus(
        submission.id!,
        'approved',
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Submission approved'),
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

  void _rejectSubmission(SubmissionModel submission) async {
    try {
      await FirebaseService.updateSubmissionStatus(
        submission.id!,
        'rejected',
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Submission rejected'),
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

  Stream<List<SubmissionModel>> _getAllSubmissionsStream() {
    // This would need to be implemented to get all submissions across all forms
    // For now, we'll return an empty stream
    return Stream.fromFuture(Future.value(<SubmissionModel>[]));
  }
}
