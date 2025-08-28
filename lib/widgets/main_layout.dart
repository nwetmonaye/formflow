import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formflow/blocs/auth_bloc.dart';
import 'package:formflow/constants/style.dart';
import 'package:formflow/screens/home_screen.dart';
import 'package:formflow/screens/cohorts_screen.dart';
import 'package:formflow/screens/notification_screen.dart';
import 'package:formflow/screens/profile_screen.dart';
import 'package:formflow/screens/form_detail_screen.dart';
import 'package:formflow/screens/form_builder_screen.dart';
import 'package:formflow/screens/login_screen.dart';
import 'package:formflow/services/firebase_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:formflow/models/form_model.dart';

class MainLayout extends StatefulWidget {
  final int initialIndex;
  final String? formId;
  final FormModel? form;

  const MainLayout({
    super.key,
    this.initialIndex = 0,
    this.formId,
    this.form,
  });

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int selectedNavItem = 0;
  late PageController _pageController;
  bool _showClosedWarning = false;
  String? _copiedClosedFormTitle;

  @override
  void initState() {
    super.initState();
    selectedNavItem = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _showClosedFormWarning(String formTitle) {
    setState(() {
      _showClosedWarning = true;
      _copiedClosedFormTitle = formTitle;
    });
  }

  void _hideClosedFormWarning() {
    setState(() {
      _showClosedWarning = false;
      _copiedClosedFormTitle = null;
    });
  }

  void _onNavItemTap(int index) {
    if (selectedNavItem == index) return; // Prevent unnecessary navigation

    setState(() {
      selectedNavItem = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _showProfileMenu(BuildContext context, AuthState authState) {
    // Create a custom overlay entry for the profile dropdown
    final OverlayState overlayState = Overlay.of(context);
    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => Material(
        color: Colors.transparent,
        child: Stack(
          children: [
            // Semi-transparent overlay to capture clicks outside
            Positioned.fill(
              child: GestureDetector(
                onTap: () {
                  overlayEntry.remove();
                },
                child: Container(
                  color: Colors.transparent,
                ),
              ),
            ),
            // Profile dropdown card positioned near the profile section
            Positioned(
              bottom: 100, // Position above the profile section
              left: 16, // Align with sidebar padding
              child: Container(
                width: 240,
                decoration: BoxDecoration(
                  color: KStyle.cWhiteColor,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // View Profile option
                    InkWell(
                      onTap: () {
                        overlayEntry.remove();
                        _onNavItemTap(3); // Profile index
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.person_outline,
                              color: KStyle.cPrimaryColor,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'View Profile',
                              style: KStyle.labelTextStyle.copyWith(
                                color: KStyle.cBlackColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Divider
                    Container(
                      height: 1,
                      color: KStyle.cE3GreyColor,
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                    // Log Out option
                    InkWell(
                      onTap: () {
                        overlayEntry.remove();
                        context.read<AuthBloc>().add(SignOutRequested());
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.logout,
                              color: Colors.red,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Log Out',
                              style: KStyle.labelTextStyle.copyWith(
                                color: Colors.red,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );

    overlayState.insert(overlayEntry);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is Unauthenticated) {
          // User has been logged out, show message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('You have been signed out successfully.'),
              backgroundColor: Colors.blue,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          );
          // Navigate to login screen and remove all previous routes
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const LoginScreen()),
            (route) => false,
          );
        }
      },
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, authState) {
          // Check if user is authenticated
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
                      'Please sign in to view your forms',
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
              children: [
                if (_showClosedWarning)
                  Container(
                    width: double.infinity,
                    color: const Color(0xFFFFF3F0),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 16),
                    margin: const EdgeInsets.only(bottom: 0),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.red[400]),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            "Link copied, but this form is closed and can't accept submissions.",
                            style: KStyle.labelMdRegularTextStyle.copyWith(
                              color: Colors.red[400],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, size: 20),
                          color: Colors.red[400],
                          onPressed: _hideClosedFormWarning,
                          splashRadius: 18,
                        ),
                      ],
                    ),
                  ),
                Expanded(
                  child: Row(
                    children: [
                      // Left Sidebar - This stays constant and doesn't rebuild
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
                                    onTap: () => _onNavItemTap(0),
                                  ),
                                  _buildNavItem(
                                    icon: Icons.group_outlined,
                                    title: 'Cohorts',
                                    isSelected: selectedNavItem == 1,
                                    onTap: () => _onNavItemTap(1),
                                  ),
                                  StreamBuilder<int>(
                                    stream: FirebaseService
                                        .getUnreadNotificationsCountStream(),
                                    builder: (context, snapshot) {
                                      final notificationCount =
                                          snapshot.data ?? 0;
                                      return _buildNavItem(
                                        icon: Icons.notifications_outlined,
                                        title: 'Notifications',
                                        isSelected: selectedNavItem == 2,
                                        notificationCount: notificationCount > 0
                                            ? notificationCount
                                            : null,
                                        onTap: () => _onNavItemTap(2),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),

                            // Profile Card
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
                                  _showProfileMenu(context, authState);
                                },
                                child: Row(
                                  children: [
                                    Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: KStyle.cEDBlueColor,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Center(
                                        child: Text(
                                          (authState.user.displayName
                                                      ?.isNotEmpty ==
                                                  true)
                                              ? authState.user.displayName![0]
                                                  .toUpperCase()
                                              : (authState.user.email
                                                          ?.isNotEmpty ==
                                                      true)
                                                  ? authState.user.email![0]
                                                      .toUpperCase()
                                                  : 'U',
                                          style: KStyle.labelMdBoldTextStyle
                                              .copyWith(
                                            color: KStyle.cPrimaryColor,
                                            fontWeight: FontWeight.w700,
                                            fontSize: 18,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            authState.user.displayName ??
                                                authState.user.email
                                                    .split('@')[0],
                                            style: KStyle
                                                .labelMdRegularTextStyle
                                                .copyWith(
                                              color: KStyle.cWhiteColor,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          Text(
                                            'View Profile',
                                            style: KStyle
                                                .labelSmRegularTextStyle
                                                .copyWith(
                                              color: KStyle.cWhiteColor
                                                  .withOpacity(0.7),
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                    Icon(
                                      Icons.keyboard_arrow_up,
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

                      // Main Content Area - This changes based on navigation
                      Expanded(
                        child: RepaintBoundary(
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
                            child: PageView(
                              controller: _pageController,
                              onPageChanged: (index) {
                                setState(() {
                                  selectedNavItem = index;
                                });
                              },
                              // Add smooth page transitions
                              physics: const BouncingScrollPhysics(),
                              children: [
                                // My Forms Page
                                const HomeScreenContent(),
                                // Cohorts Page
                                const CohortsScreenContent(),
                                // Notifications Page
                                const NotificationScreenContent(),
                                // Profile Page
                                const ProfileScreenContent(),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
    int? notificationCount,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
            horizontal: isSelected ? 24 : 16, vertical: 12),
        margin: EdgeInsets.only(
          bottom: 8,
          left: isSelected ? 16 : 0,
          right: isSelected ? 16 : 0,
        ),
        decoration: BoxDecoration(
          color: isSelected ? KStyle.cEDBlueColor : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? KStyle.cPrimaryColor : KStyle.cWhiteColor,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: KStyle.labelMdRegularTextStyle.copyWith(
                  color: isSelected ? KStyle.cPrimaryColor : KStyle.cWhiteColor,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
            if (notificationCount != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: KStyle.cRedColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  notificationCount.toString(),
                  style: KStyle.labelXsRegularTextStyle.copyWith(
                    color: KStyle.cWhiteColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// Content widgets for each page - these will be lightweight and won't rebuild the sidebar
class HomeScreenContent extends StatelessWidget {
  const HomeScreenContent({super.key});

  @override
  Widget build(BuildContext context) {
    return const HomeScreen();
  }
}

class CohortsScreenContent extends StatelessWidget {
  const CohortsScreenContent({super.key});

  @override
  Widget build(BuildContext context) {
    return CohortsScreen();
  }
}

class NotificationScreenContent extends StatelessWidget {
  const NotificationScreenContent({super.key});

  @override
  Widget build(BuildContext context) {
    return NotificationScreen();
  }
}

class ProfileScreenContent extends StatelessWidget {
  const ProfileScreenContent({super.key});

  @override
  Widget build(BuildContext context) {
    return ProfileScreen();
  }
}
