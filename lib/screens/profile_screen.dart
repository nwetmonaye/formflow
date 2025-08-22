import 'package:flutter/material.dart';
import 'package:formflow/constants/style.dart';
import 'package:formflow/services/firebase_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int selectedNavItem =
      3; // 0 = My Forms, 1 = Cohorts, 2 = Notifications, 3 = Profile
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  bool _isLoading = false;
  String? _userName;
  String? _userEmail;
  String? _userPhotoURL;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    try {
      final currentUser = FirebaseService.currentUser;
      if (currentUser != null) {
        setState(() {
          _userName = currentUser.displayName ?? 'Thomas Willy';
          _userEmail = currentUser.email ?? 'thomaswilly@gmail.com';
          _userPhotoURL = currentUser.photoURL;
          _nameController.text = _userName!;
          _emailController.text = _userEmail!;
        });
      }
    } catch (e) {
      print('Error loading user data: $e');
    }
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
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
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
                          Navigator.of(context).pushReplacementNamed('/home');
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
                              Navigator.of(context)
                                  .pushReplacementNamed('/notifications');
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
                      _showUserMenu(context);
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
                            child: _userPhotoURL != null
                                ? Image.network(
                                    _userPhotoURL!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
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
                                _userName ?? 'User',
                                style: KStyle.labelMdRegularTextStyle.copyWith(
                                  color: KStyle.cWhiteColor,
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
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
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Text(
                      'Account Settings',
                      style: KStyle.heading2TextStyle.copyWith(
                        color: KStyle.cBlackColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Profile Section
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: KStyle.cWhiteColor,
                        borderRadius: BorderRadius.circular(12),
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
                          Text(
                            'Profile',
                            style: KStyle.heading3TextStyle.copyWith(
                              color: KStyle.cBlackColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Profile Avatar
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Stack(
                              children: [
                                Container(
                                  width: 120,
                                  height: 120,
                                  decoration: BoxDecoration(
                                    color: KStyle.cWhiteColor,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: KStyle.cE3GreyColor,
                                      width: 2,
                                    ),
                                  ),
                                  child: ClipOval(
                                    child: _userPhotoURL != null
                                        ? Image.network(
                                            _userPhotoURL!,
                                            width: 116,
                                            height: 116,
                                            fit: BoxFit.cover,
                                            errorBuilder:
                                                (context, error, stackTrace) {
                                              return Image.asset(
                                                'assets/images/profile.png',
                                                width: 116,
                                                height: 116,
                                                fit: BoxFit.cover,
                                              );
                                            },
                                          )
                                        : Image.asset(
                                            'assets/images/profile.png',
                                            width: 116,
                                            height: 116,
                                            fit: BoxFit.cover,
                                          ),
                                  ),
                                ),
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: Container(
                                    width: 36,
                                    height: 36,
                                    decoration: BoxDecoration(
                                      color: KStyle.cSelectedColor,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: KStyle.cWhiteColor,
                                        width: 3,
                                      ),
                                    ),
                                    child: Icon(
                                      Icons.edit,
                                      color: KStyle.cPrimaryColor,
                                      size: 18,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Name Field
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Name',
                                style: KStyle.labelMdRegularTextStyle.copyWith(
                                  color: KStyle.cBlackColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextField(
                                controller: _nameController,
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: KStyle.cWhiteColor,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(
                                      color: KStyle.cE3GreyColor,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(
                                      color: KStyle.cE3GreyColor,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(
                                      color: KStyle.cPrimaryColor,
                                      width: 2,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),

                          // Email Field
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Email',
                                style: KStyle.labelMdRegularTextStyle.copyWith(
                                  color: KStyle.cBlackColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextField(
                                controller: _emailController,
                                enabled: false,
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: KStyle.cBgColor,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(
                                      color: KStyle.cE3GreyColor,
                                    ),
                                  ),
                                  disabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(
                                      color: KStyle.cE3GreyColor,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          // Update Profile Button
                          // Align(
                          //   alignment: Alignment.centerRight,
                          //   child: ElevatedButton(
                          //     onPressed: _isLoading ? null : _updateProfile,
                          //     style: ElevatedButton.styleFrom(
                          //       backgroundColor: KStyle.cBgColor,
                          //       foregroundColor: KStyle.cBlackColor,
                          //       padding: const EdgeInsets.symmetric(
                          //         horizontal: 24,
                          //         vertical: 12,
                          //       ),
                          //       shape: RoundedRectangleBorder(
                          //         borderRadius: BorderRadius.circular(8),
                          //       ),
                          //     ),
                          //     child: _isLoading
                          //         ? SizedBox(
                          //             width: 20,
                          //             height: 20,
                          //             child: CircularProgressIndicator(
                          //               strokeWidth: 2,
                          //               color: KStyle.cBlackColor,
                          //             ),
                          //           )
                          //         : Text(
                          //             'Update Profile',
                          //             style: KStyle.labelMdRegularTextStyle
                          //                 .copyWith(
                          //               fontWeight: FontWeight.w500,
                          //             ),
                          //           ),
                          //   ),
                          // ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Change Password Section
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: KStyle.cWhiteColor,
                        borderRadius: BorderRadius.circular(12),
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
                          Text(
                            'Change Password',
                            style: KStyle.heading3TextStyle.copyWith(
                              color: KStyle.cBlackColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Update your password to keep your account secure.',
                            style: KStyle.labelMdRegularTextStyle.copyWith(
                              color: KStyle.c72GreyColor,
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Change Password Button
                          Align(
                            alignment: Alignment.centerRight,
                            child: ElevatedButton(
                              // onPressed: _changePassword,
                              onPressed: () {},
                              style: ElevatedButton.styleFrom(
                                backgroundColor: KStyle.cPrimaryColor,
                                foregroundColor: KStyle.cWhiteColor,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 20,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Text(
                                'Change Password',
                                style: KStyle.labelMdRegularTextStyle.copyWith(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
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
      onTap: onTap,
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

  Future<void> _updateProfile() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // TODO: Implement profile update logic
      await Future.delayed(const Duration(seconds: 1)); // Simulate API call

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Profile updated successfully'),
          backgroundColor: KStyle.cE8GreenColor,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating profile: $e'),
          backgroundColor: KStyle.cDBRedColor,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _changePassword() {
    // TODO: Implement change password logic
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:
            const Text('Change password functionality will be implemented'),
        backgroundColor: KStyle.cPrimaryColor,
      ),
    );
  }
}
