import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:formflow/constants/style.dart';
import 'package:formflow/models/notification_model.dart';
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
            backgroundColor: KStyle.cBgColor,
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
                            notificationCount: null,
                            onTap: () {
                              setState(() {
                                selectedNavItem = 0;
                              });
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                  builder: (context) => const HomeScreen(),
                                ),
                              );
                            },
                          ),
                          _buildNavItem(
                            icon: Icons.group_outlined,
                            title: 'Cohorts',
                            isSelected: selectedNavItem == 1,
                            notificationCount: null,
                            onTap: () {
                              setState(() {
                                selectedNavItem = 1;
                              });
                            },
                          ),
                          StreamBuilder<int>(
                            stream: FirebaseService
                                .getUnreadNotificationsCountStream(),
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
                                  // Already on notifications screen
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
                              child: ClipOval(
                                child: authState.user.photoURL != null
                                    ? Image.network(
                                        authState.user.photoURL!,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                          return Image.asset(
                                            'assets/images/profile.png',
                                            fit: BoxFit.cover,
                                          );
                                        },
                                      )
                                    : Image.asset(
                                        'assets/images/profile.png',
                                        fit: BoxFit.cover,
                                      ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    authState.user.displayName ??
                                        authState.user.email.split('@')[0] ??
                                        'User',
                                    style:
                                        KStyle.labelMdRegularTextStyle.copyWith(
                                      color: KStyle.cWhiteColor,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    'View Profile',
                                    style:
                                        KStyle.labelSmRegularTextStyle.copyWith(
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
                          //     color: KStyle.cE3GreyColor.withOpacity(0.5),
                          //     width: 1,
                          //   ),
                          // ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Notifications',
                                style: KStyle.heading3TextStyle.copyWith(
                                  color: KStyle.cBlackColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
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

                      // Notifications Content
                      Expanded(
                        child: StreamBuilder<List<NotificationModel>>(
                          stream: FirebaseService.getNotificationsStream(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
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
                                      style: KStyle.labelMdRegularTextStyle
                                          .copyWith(
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
                                            color: KStyle.cE3GreyColor
                                                .withOpacity(0.3),
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black
                                                    .withOpacity(0.1),
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
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            4),
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
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Container(
                                                        height: 8,
                                                        width: double.infinity,
                                                        decoration:
                                                            BoxDecoration(
                                                          color: KStyle
                                                              .c72GreyColor
                                                              .withOpacity(0.5),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(4),
                                                        ),
                                                      ),
                                                      const SizedBox(height: 6),
                                                      Container(
                                                        height: 6,
                                                        width: 60,
                                                        decoration:
                                                            BoxDecoration(
                                                          color: KStyle
                                                              .c72GreyColor
                                                              .withOpacity(0.3),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(3),
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
                                              color: KStyle.cE3GreyColor
                                                  .withOpacity(0.4),
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black
                                                      .withOpacity(0.08),
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
                                                      color:
                                                          KStyle.cPrimaryColor,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              3),
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
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        Container(
                                                          height: 6,
                                                          width:
                                                              double.infinity,
                                                          decoration:
                                                              BoxDecoration(
                                                            color: KStyle
                                                                .c72GreyColor
                                                                .withOpacity(
                                                                    0.4),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        3),
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                            height: 4),
                                                        Container(
                                                          height: 5,
                                                          width: 50,
                                                          decoration:
                                                              BoxDecoration(
                                                            color: KStyle
                                                                .c72GreyColor
                                                                .withOpacity(
                                                                    0.3),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        2.5),
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
                                              color: KStyle.cE3GreyColor
                                                  .withOpacity(0.5),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black
                                                      .withOpacity(0.06),
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
                                                      color:
                                                          KStyle.cPrimaryColor,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              2),
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
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        Container(
                                                          height: 4,
                                                          width:
                                                              double.infinity,
                                                          decoration:
                                                              BoxDecoration(
                                                            color: KStyle
                                                                .c72GreyColor
                                                                .withOpacity(
                                                                    0.4),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        2),
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                            height: 3),
                                                        Container(
                                                          height: 4,
                                                          width: 40,
                                                          decoration:
                                                              BoxDecoration(
                                                            color: KStyle
                                                                .c72GreyColor
                                                                .withOpacity(
                                                                    0.3),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        2),
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
                                      style: KStyle.labelMdRegularTextStyle
                                          .copyWith(
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
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20, vertical: 16),
                                    decoration: BoxDecoration(
                                      color: KStyle.cWhiteColor,
                                      border: Border(
                                        bottom: BorderSide(
                                          color: KStyle.cE3GreyColor
                                              .withOpacity(0.5),
                                          width: 1,
                                        ),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            '${notifications.where((n) => !n.isRead).length} unread notifications',
                                            style: KStyle
                                                .labelMdRegularTextStyle
                                                .copyWith(
                                              color: KStyle.cBlackColor,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                        TextButton(
                                          onPressed: _isLoading
                                              ? null
                                              : _markAllAsRead,
                                          style: TextButton.styleFrom(
                                            backgroundColor:
                                                KStyle.cSelectedColor,
                                            foregroundColor:
                                                KStyle.cPrimaryColor,
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 16,
                                              vertical: 16,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                          ),
                                          child: _isLoading
                                              ? SizedBox(
                                                  width: 16,
                                                  height: 16,
                                                  child:
                                                      CircularProgressIndicator(
                                                    strokeWidth: 2,
                                                    color: KStyle.cPrimaryColor,
                                                  ),
                                                )
                                              : Text(
                                                  'Clear Notifications',
                                                  style: KStyle
                                                      .labelMdRegularTextStyle
                                                      .copyWith(
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
                                      return _buildNotificationCard(
                                          notification);
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
              ),
            ],
          ),
          // floatingActionButton: FloatingActionButton(
          //   onPressed: _createTestNotification,
          //   backgroundColor: KStyle.cPrimaryColor,
          //   foregroundColor: KStyle.cWhiteColor,
          //   child: const Icon(Icons.add),
          // ),
        );
      },
    );
  }

  // Navigation item builder
  Widget _buildNavItem({
    required IconData icon,
    required String title,
    required bool isSelected,
    int? notificationCount,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        print('Nav item tapped: $title'); // Debug print
        onTap();
      },
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
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: KStyle.cDBRedColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
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

  // User menu
  void _showUserMenu(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('User Menu'),
          content: const Text('User menu options will be implemented here.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildNotificationCard(NotificationModel notification) {
    final isUnread = !notification.isRead;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: KStyle.cWhiteColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isUnread
              ? KStyle.cPrimaryColor.withOpacity(0.2)
              : KStyle.cE3GreyColor.withOpacity(0.5),
          width: isUnread ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => _onNotificationTap(notification),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Notification icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: _getNotificationIconColor(notification.type)
                      .withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _getNotificationIcon(notification.type),
                  color: _getNotificationIconColor(notification.type),
                  size: 24,
                ),
              ),

              const SizedBox(width: 16),

              // Notification content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title and time
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: KStyle.labelMdBoldTextStyle.copyWith(
                              color: KStyle.cBlackColor,
                              fontWeight:
                                  isUnread ? FontWeight.w600 : FontWeight.w500,
                            ),
                          ),
                        ),
                        Text(
                          _formatTimeAgo(notification.createdAt),
                          style: KStyle.labelSmRegularTextStyle.copyWith(
                            color: KStyle.c72GreyColor,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    // Message
                    Text(
                      notification.message,
                      style: KStyle.labelMdRegularTextStyle.copyWith(
                        color: KStyle.c3BGreyColor,
                        height: 1.4,
                      ),
                    ),

                    // Additional details based on notification type
                    if (notification.submitterName != null ||
                        notification.submitterEmail != null)
                      Container(
                        margin: const EdgeInsets.only(top: 12),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: KStyle.cBgColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (notification.submitterName != null) ...[
                              Row(
                                children: [
                                  Icon(
                                    Icons.person_outline,
                                    size: 16,
                                    color: KStyle.c72GreyColor,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'From: ${notification.submitterName}',
                                    style:
                                        KStyle.labelSmRegularTextStyle.copyWith(
                                      color: KStyle.cBlackColor,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                              if (notification.submitterEmail != null) ...[
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.email_outlined,
                                      size: 16,
                                      color: KStyle.c72GreyColor,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      notification.submitterEmail!,
                                      style: KStyle.labelSmRegularTextStyle
                                          .copyWith(
                                        color: KStyle.c72GreyColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ],
                        ),
                      ),

                    // Action buttons for form submissions
                    // if (notification.type == 'form_submission' &&
                    //     notification.formId != null &&
                    //     notification.submissionId != null)
                    //   Container(
                    //     margin: const EdgeInsets.only(top: 16),
                    //     child: Row(
                    //       children: [
                    //         Expanded(
                    //           child: ElevatedButton(
                    //             onPressed: () => _viewSubmission(notification),
                    //             style: ElevatedButton.styleFrom(
                    //               backgroundColor: KStyle.cPrimaryColor,
                    //               foregroundColor: KStyle.cWhiteColor,
                    //               padding:
                    //                   const EdgeInsets.symmetric(vertical: 12),
                    //               shape: RoundedRectangleBorder(
                    //                 borderRadius: BorderRadius.circular(8),
                    //               ),
                    //             ),
                    //             child: Text(
                    //               'View Submission',
                    //               style:
                    //                   KStyle.labelMdRegularTextStyle.copyWith(
                    //                 color: KStyle.cWhiteColor,
                    //                 fontWeight: FontWeight.w500,
                    //               ),
                    //             ),
                    //           ),
                    //         ),
                    //         const SizedBox(width: 12),
                    //         Expanded(
                    //           child: OutlinedButton(
                    //             onPressed: () =>
                    //                 _approveSubmission(notification),
                    //             style: OutlinedButton.styleFrom(
                    //               foregroundColor: KStyle.cE8GreenColor,
                    //               side: BorderSide(color: KStyle.cE8GreenColor),
                    //               padding:
                    //                   const EdgeInsets.symmetric(vertical: 12),
                    //               shape: RoundedRectangleBorder(
                    //                 borderRadius: BorderRadius.circular(8),
                    //               ),
                    //             ),
                    //             child: Text(
                    //               'Approve',
                    //               style:
                    //                   KStyle.labelMdRegularTextStyle.copyWith(
                    //                 color: KStyle.cE8GreenColor,
                    //                 fontWeight: FontWeight.w500,
                    //               ),
                    //             ),
                    //           ),
                    //         ),
                    //         const SizedBox(width: 12),
                    //         Expanded(
                    //           child: OutlinedButton(
                    //             onPressed: () =>
                    //                 _rejectSubmission(notification),
                    //             style: OutlinedButton.styleFrom(
                    //               foregroundColor: KStyle.cDBRedColor,
                    //               side: BorderSide(color: KStyle.cDBRedColor),
                    //               padding:
                    //                   const EdgeInsets.symmetric(vertical: 12),
                    //               shape: RoundedRectangleBorder(
                    //                 borderRadius: BorderRadius.circular(8),
                    //               ),
                    //             ),
                    //             child: Text(
                    //               'Reject',
                    //               style:
                    //                   KStyle.labelMdRegularTextStyle.copyWith(
                    //                 color: KStyle.cDBRedColor,
                    //                 fontWeight: FontWeight.w500,
                    //               ),
                    //             ),
                    //           ),
                    //         ),
                    //       ],
                    //     ),
                    //   ),
                  ],
                ),
              ),

              // Unread indicator
              if (isUnread)
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: KStyle.cPrimaryColor,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getNotificationIconColor(String type) {
    switch (type) {
      case 'form_submission':
        return KStyle.cPrimaryColor;
      case 'form_approved':
        return KStyle.cE8GreenColor;
      case 'form_rejected':
        return KStyle.cDBRedColor;
      default:
        return KStyle.cPrimaryColor;
    }
  }

  IconData _getNotificationIcon(String type) {
    switch (type) {
      case 'form_submission':
        return Icons.assignment_turned_in;
      case 'form_approved':
        return Icons.check_circle;
      case 'form_rejected':
        return Icons.cancel;
      default:
        return Icons.notifications;
    }
  }

  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

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

  void _onNotificationTap(NotificationModel notification) {
    if (!notification.isRead) {
      FirebaseService.markNotificationAsRead(notification.id!);
    }

    // Handle navigation based on notification type
    switch (notification.type) {
      case 'form_submission':
        if (notification.formId != null) {
          // Navigate to form submissions
          // You can implement navigation to form detail screen here
        }
        break;
      case 'form_approved':
      case 'form_rejected':
        if (notification.formId != null) {
          // Navigate to form detail
          // You can implement navigation to form detail screen here
        }
        break;
    }
  }

  void _viewSubmission(NotificationModel notification) {
    if (!notification.isRead) {
      FirebaseService.markNotificationAsRead(notification.id!);
    }

    // Navigate to submission detail
    // You can implement navigation to submission detail screen here
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Viewing submission: ${notification.submissionId}'),
        backgroundColor: KStyle.cPrimaryColor,
      ),
    );
  }

  void _approveSubmission(NotificationModel notification) {
    if (!notification.isRead) {
      FirebaseService.markNotificationAsRead(notification.id!);
    }

    // Handle submission approval
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Submission approved'),
        backgroundColor: KStyle.cE8GreenColor,
      ),
    );
  }

  void _rejectSubmission(NotificationModel notification) {
    if (!notification.isRead) {
      FirebaseService.markNotificationAsRead(notification.id!);
    }

    // Handle submission rejection
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Submission rejected'),
        backgroundColor: KStyle.cDBRedColor,
      ),
    );
  }

  Future<void> _markAllAsRead() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await FirebaseService.markAllNotificationsAsRead();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('All notifications marked as read'),
          backgroundColor: KStyle.cPrimaryColor,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: KStyle.cDBRedColor,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

//   void _createTestNotification() async {
//     try {
//       final notification = NotificationModel(
//         title: 'Test Notification',
//         message: 'This is a test notification for demonstration purposes.',
//         type: 'form_submission',
//         formId: 'test_form_id',
//         submissionId: 'test_submission_id',
//         createdAt: DateTime.now(),
//         isRead: false,
//       );

//       // Get current user ID from Firebase service
//       final currentUser = FirebaseService.currentUser;
//       if (currentUser != null) {
//         await FirebaseService.createNotification(notification,
//             userId: currentUser.uid);
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: const Text('Test notification created!'),
//             backgroundColor: KStyle.cPrimaryColor,
//           ),
//         );
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text('Please sign in to create test notifications'),
//             backgroundColor: Colors.orange,
//           ),
//         );
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Error creating test notification: $e'),
//           backgroundColor: Colors.red,
//         ),
//       );
//     }
//   }
}
