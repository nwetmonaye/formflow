import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:formflow/constants/style.dart';
import 'package:formflow/models/notification_model.dart';
import 'package:formflow/screens/cohorts_screen.dart';
import 'package:formflow/services/firebase_service.dart';
import 'package:formflow/screens/home_screen.dart';
import 'package:formflow/screens/profile_screen.dart';
import 'package:formflow/blocs/auth_bloc.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  bool _isLoading = false;
  int selectedNavItem = 2; // 0 = My Forms, 1 = Cohorts, 2 = Notifications

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        if (authState is! Authenticated) {
          return Scaffold(
            backgroundColor: KStyle.cBackgroundColor,
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.person_outline,
                    size: 64,
                    color: KStyle.c72GreyColor,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Please sign in to view notifications',
                    style: KStyle.heading3TextStyle.copyWith(
                      color: KStyle.c72GreyColor,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return Scaffold(
          backgroundColor: KStyle.cBackgroundColor,
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
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
                height: 150,
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Notifications',
                                style: KStyle.headingTextStyle.copyWith(
                                  color: KStyle.cBlackColor,
                                ),
                              ),
                            ],
                          ),
                          StreamBuilder<int>(
                            stream: FirebaseService
                                .getUnreadNotificationsCountStream(),
                            builder: (context, snapshot) {
                              final unreadCount = snapshot.data ?? 0;
                              if (unreadCount == 0)
                                return const SizedBox.shrink();

                              return Container(
                                margin: const EdgeInsets.only(right: 16),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: KStyle.cPrimaryColor,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  unreadCount.toString(),
                                  style:
                                      KStyle.labelXsRegularTextStyle.copyWith(
                                    color: KStyle.cWhiteColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Content
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(24),
                  child: _buildNotificationsContent(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNotificationsContent() {
    return StreamBuilder<List<NotificationModel>>(
      stream: FirebaseService.getNotificationsStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(
              color: KStyle.cPrimaryColor,
            ),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: KStyle.cDBRedColor,
                ),
                const SizedBox(height: 16),
                Text(
                  'Error loading notifications',
                  style: KStyle.heading3TextStyle.copyWith(
                    color: KStyle.cBlackColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Please try again later',
                  style: KStyle.labelMdRegularTextStyle.copyWith(
                    color: KStyle.c72GreyColor,
                  ),
                ),
              ],
            ),
          );
        }

        final notifications = snapshot.data ?? [];

        if (notifications.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Custom notification cards illustration
                Stack(
                  alignment: Alignment.center,
                  children: [
                    // Bottom card (largest)
                    Container(
                      width: 120,
                      height: 80,
                      decoration: BoxDecoration(
                        color: KStyle.cE3GreyColor.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                color: KStyle.cPrimaryColor,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Icon(
                                Icons.question_mark,
                                color: KStyle.cWhiteColor,
                                size: 16,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    height: 8,
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      color:
                                          KStyle.c72GreyColor.withOpacity(0.5),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Container(
                                    height: 6,
                                    width: 60,
                                    decoration: BoxDecoration(
                                      color:
                                          KStyle.c72GreyColor.withOpacity(0.3),
                                      borderRadius: BorderRadius.circular(3),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Middle card
                    Positioned(
                      top: -15,
                      child: Container(
                        width: 100,
                        height: 65,
                        decoration: BoxDecoration(
                          color: KStyle.cE3GreyColor.withOpacity(0.4),
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 6,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Row(
                            children: [
                              Container(
                                width: 20,
                                height: 20,
                                decoration: BoxDecoration(
                                  color: KStyle.cPrimaryColor,
                                  borderRadius: BorderRadius.circular(3),
                                ),
                                child: Icon(
                                  Icons.question_mark,
                                  color: KStyle.cWhiteColor,
                                  size: 14,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      height: 6,
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        color: KStyle.c72GreyColor
                                            .withOpacity(0.4),
                                        borderRadius: BorderRadius.circular(3),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Container(
                                      height: 5,
                                      width: 50,
                                      decoration: BoxDecoration(
                                        color: KStyle.c72GreyColor
                                            .withOpacity(0.3),
                                        borderRadius:
                                            BorderRadius.circular(2.5),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Top card (smallest)
                    Positioned(
                      top: -30,
                      child: Container(
                        width: 80,
                        height: 50,
                        decoration: BoxDecoration(
                          color: KStyle.cE3GreyColor.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.06),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: Row(
                            children: [
                              Container(
                                width: 16,
                                height: 16,
                                decoration: BoxDecoration(
                                  color: KStyle.cPrimaryColor,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                                child: Icon(
                                  Icons.question_mark,
                                  color: KStyle.cWhiteColor,
                                  size: 12,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      height: 4,
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        color: KStyle.c72GreyColor
                                            .withOpacity(0.4),
                                        borderRadius: BorderRadius.circular(2),
                                      ),
                                    ),
                                    const SizedBox(height: 3),
                                    Container(
                                      height: 4,
                                      width: 40,
                                      decoration: BoxDecoration(
                                        color: KStyle.c72GreyColor
                                            .withOpacity(0.3),
                                        borderRadius: BorderRadius.circular(2),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                Text(
                  'No notifications',
                  style: KStyle.heading2TextStyle.copyWith(
                    color: KStyle.cBlackColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'You\'re all caught up. No notifications right now.',
                  style: KStyle.labelMdRegularTextStyle.copyWith(
                    color: KStyle.c72GreyColor,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return Column(
          children: [
            // Header with mark all as read button
            if (notifications.any((n) => !n.isRead))
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                decoration: BoxDecoration(
                  color: KStyle.cWhiteColor,
                  border: Border(
                    bottom: BorderSide(
                      color: KStyle.cE3GreyColor.withOpacity(0.5),
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${notifications.where((n) => !n.isRead).length} unread notifications',
                        style: KStyle.labelMdRegularTextStyle.copyWith(
                          color: KStyle.cBlackColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: _isLoading ? null : _markAllAsRead,
                      style: TextButton.styleFrom(
                        backgroundColor: KStyle.cSelectedColor,
                        foregroundColor: KStyle.cPrimaryColor,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: _isLoading
                          ? SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: KStyle.cPrimaryColor,
                              ),
                            )
                          : Text(
                              'Clear Notifications',
                              style: KStyle.labelMdRegularTextStyle.copyWith(
                                color: KStyle.cPrimaryColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                    ),
                  ],
                ),
              ),

            // Notifications list
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(24),
                itemCount: notifications.length,
                itemBuilder: (context, index) {
                  final notification = notifications[index];
                  return _buildNotificationCard(notification);
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildNotificationCard(NotificationModel notification) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: KStyle.cWhiteColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: notification.isRead
              ? KStyle.cE3GreyColor.withOpacity(0.3)
              : KStyle.cPrimaryColor.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Notification icon
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: notification.isRead
                      ? KStyle.cE3GreyColor.withOpacity(0.2)
                      : KStyle.cPrimaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getNotificationIcon(notification.type),
                  color: notification.isRead
                      ? KStyle.c72GreyColor
                      : KStyle.cPrimaryColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notification.title,
                      style: KStyle.labelMdBoldTextStyle.copyWith(
                        color: notification.isRead
                            ? KStyle.c72GreyColor
                            : KStyle.cBlackColor,
                        fontWeight: notification.isRead
                            ? FontWeight.w500
                            : FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notification.message,
                      style: KStyle.labelMdRegularTextStyle.copyWith(
                        color: KStyle.c72GreyColor,
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              // Timestamp
              Text(
                _formatTimestamp(notification.createdAt),
                style: KStyle.labelSmRegularTextStyle.copyWith(
                  color: KStyle.c72GreyColor,
                ),
              ),
            ],
          ),
          if (notification.actionUrl != null) ...[
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    // Handle action
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: KStyle.cPrimaryColor.withOpacity(0.1),
                    foregroundColor: KStyle.cPrimaryColor,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  child: Text(
                    'View Details',
                    style: KStyle.labelSmRegularTextStyle.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  IconData _getNotificationIcon(String type) {
    switch (type.toLowerCase()) {
      case 'form_submission':
        return Icons.description;
      case 'cohort_invite':
        return Icons.people;
      case 'approval':
        return Icons.check_circle;
      case 'reminder':
        return Icons.schedule;
      default:
        return Icons.notifications;
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  Future<void> _markAllAsRead() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await FirebaseService.markAllNotificationsAsRead();
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error marking notifications as read: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    }
  }
}
