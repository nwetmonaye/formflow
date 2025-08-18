import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formflow/blocs/auth_bloc.dart';
import 'package:formflow/constants/style.dart';
import 'package:formflow/models/form_model.dart';
import 'package:formflow/services/firebase_service.dart';
import 'package:formflow/screens/form_builder_screen.dart';
import 'package:formflow/screens/form_detail_screen.dart';
import 'package:formflow/screens/notification_screen.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:formflow/screens/form_preview_screen.dart';
import 'package:formflow/models/submission_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String selectedFilter = 'All';
  final List<String> filters = ['All', 'Live', 'Draft', 'Closed'];
  int selectedNavItem = 0; // 0 = My Forms, 1 = Cohorts, 2 = Notifications

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is Unauthenticated) {
          // User has been logged out, show message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('You have been signed out successfully.'),
              backgroundColor: Colors.blue,
            ),
          );
        }
      },
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, authState) {
          // Check if user is authenticated
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
                                    builder: (context) =>
                                        const NotificationScreen(),
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
                                      authState.user.displayName ??
                                          authState.user.email.split('@')[0],
                                      style: KStyle.labelMdRegularTextStyle
                                          .copyWith(
                                        color: KStyle.cBlackColor,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Text(
                                      'View Profile',
                                      style: KStyle.labelSmRegularTextStyle
                                          .copyWith(
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
                      color: KStyle.cBackgroundColor,
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
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'My Forms',
                                    style: KStyle.headingTextStyle.copyWith(
                                      color: KStyle.cBlackColor,
                                    ),
                                  ),
                                ],
                              ),
                              ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const FormBuilderScreen(),
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
                                icon: const Icon(Icons.add, size: 20),
                                label: Text(
                                  'New Form',
                                  style: KStyle.labelMdBoldTextStyle.copyWith(
                                    color: KStyle.cWhiteColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Filters
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
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 16),
                          child: Row(
                            children: filters.map((filter) {
                              bool isSelected = selectedFilter == filter;
                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    selectedFilter = filter;
                                  });
                                },
                                child: Container(
                                  margin: const EdgeInsets.only(right: 32),
                                  child: Column(
                                    children: [
                                      Text(
                                        filter,
                                        style: KStyle.labelMdRegularTextStyle
                                            .copyWith(
                                          color: isSelected
                                              ? KStyle.cPrimaryColor
                                              : KStyle.c72GreyColor,
                                          fontWeight: isSelected
                                              ? FontWeight.w600
                                              : FontWeight.w400,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      if (isSelected)
                                        Container(
                                          width: 20,
                                          height: 2,
                                          decoration: BoxDecoration(
                                            color: KStyle.cPrimaryColor,
                                            borderRadius:
                                                BorderRadius.circular(1),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),

                        // Forms Grid
                        Expanded(
                          child: FutureBuilder<bool>(
                            future: FirebaseService.ensureInitialized(),
                            builder: (context, initSnapshot) {
                              if (initSnapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Center(
                                    child: CircularProgressIndicator());
                              }

                              if (initSnapshot.hasError ||
                                  initSnapshot.data != true) {
                                return Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.error_outline,
                                        size: 64,
                                        color: Colors.red,
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        'Failed to initialize Firebase',
                                        style:
                                            KStyle.heading3TextStyle.copyWith(
                                          color: Colors.red,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Please check your internet connection and try again',
                                        style: KStyle.labelMdRegularTextStyle
                                            .copyWith(
                                          color: KStyle.c72GreyColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }

                              return StreamBuilder<List<FormModel>>(
                                stream: FirebaseService.getFormsStream(),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return const Center(
                                        child: CircularProgressIndicator());
                                  }

                                  if (snapshot.hasError) {
                                    print('Stream error: ${snapshot.error}');
                                    return Center(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.error_outline,
                                            size: 64,
                                            color: Colors.red,
                                          ),
                                          const SizedBox(height: 16),
                                          Text(
                                            'Error loading forms',
                                            style: KStyle.heading3TextStyle
                                                .copyWith(
                                              color: Colors.red,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            'Error: ${snapshot.error}',
                                            style: KStyle
                                                .labelMdRegularTextStyle
                                                .copyWith(
                                              color: KStyle.c72GreyColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }

                                  final forms = snapshot.data ?? [];
                                  final filteredForms =
                                      _filterForms(forms, selectedFilter);

                                  if (filteredForms.isEmpty) {
                                    return Center(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Image.asset(
                                            'assets/images/no_form.png',
                                            fit: BoxFit.contain,
                                            width: 150,
                                            height: 150,
                                          ),
                                          const SizedBox(height: 16),
                                          Text(
                                            'No forms found',
                                            style: KStyle.heading3TextStyle
                                                .copyWith(
                                              color: KStyle.c72GreyColor,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            'Create your first form to get started',
                                            style: KStyle
                                                .labelMdRegularTextStyle
                                                .copyWith(
                                              color: KStyle.c72GreyColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }

                                  return GridView.builder(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 80, vertical: 20),
                                    gridDelegate:
                                        const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 3,
                                      crossAxisSpacing: 30,
                                      mainAxisSpacing: 30,
                                      childAspectRatio: 1.8,
                                    ),
                                    itemCount: filteredForms.length,
                                    itemBuilder: (context, index) {
                                      final form = filteredForms[index];
                                      return _buildFormCard(form);
                                    },
                                  );
                                },
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
          );
        },
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

  List<FormModel> _filterForms(List<FormModel> forms, String filter) {
    switch (filter) {
      case 'Live':
        return forms.where((form) => form.status == 'active').toList();
      case 'Draft':
        return forms.where((form) => form.status == 'draft').toList();
      case 'Closed':
        return forms.where((form) => form.status == 'closed').toList();
      default:
        return forms;
    }
  }

  Widget _buildFormCard(FormModel form) {
    Color borderColor;
    switch (form.status) {
      case 'active':
        borderColor = Colors.green;
        break;
      case 'draft':
        borderColor = Colors.blue;
        break;
      case 'closed':
        borderColor = Colors.red;
        break;
      default:
        borderColor = KStyle.cPrimaryColor;
    }
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => FormDetailScreen(form: form),
          ),
        );
      },
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
          border: Border(
            top: BorderSide(color: borderColor, width: 2),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title and Menu Row
              Row(
                children: [
                  Expanded(
                    child: Text(
                      form.title,
                      style: KStyle.heading2TextStyle.copyWith(
                        color: KStyle.cBlackColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      _showFormOptionsDialog(context, form);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: KStyle.cF4GreyColor,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Icon(
                        Icons.more_horiz,
                        size: 16,
                        color: KStyle.c72GreyColor,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              // Status Badge
              _buildStatusChip(form.status),
              const Spacer(),
              // Bottom Row - Inbox and Action Icons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Inbox with count
                  Row(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        child: SvgPicture.asset(
                          'assets/icons/inbox.svg',
                          width: 24,
                          height: 24,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: KStyle.cNotiColor,
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: Center(
                          child: StreamBuilder<List<SubmissionModel>>(
                            stream:
                                FirebaseService.getSubmissionsStream(form.id!),
                            builder: (context, snapshot) {
                              int count = 0;
                              if (snapshot.hasData) {
                                count = snapshot.data!.length;
                              }
                              return Text(
                                count.toString(),
                                style: KStyle.labelXsRegularTextStyle.copyWith(
                                  color: KStyle.cWhiteColor,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 10,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                  // Action Icons
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          // Navigate to form preview screen when view icon is clicked
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) =>
                                  FormPreviewScreen(form: form),
                            ),
                          );
                        },
                        child: Container(
                          width: 24,
                          height: 24,
                          child: SvgPicture.asset(
                            'assets/icons/eye.svg',
                            width: 24,
                            height: 24,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      GestureDetector(
                        onTap: () {
                          _copyFormLink(form);
                        },
                        child: Container(
                          width: 22,
                          height: 22,
                          child: SvgPicture.asset(
                            'assets/icons/copy.svg',
                            width: 22,
                            height: 22,
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
      ),
    );
  }

  void _showFormOptionsDialog(BuildContext context, FormModel form) {
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
                _buildMenuItem('Edit', Icons.edit_outlined, () {
                  Navigator.of(context).pop();
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => FormBuilderScreen(form: form),
                    ),
                  );
                }),
                _buildMenuItem('Share with cohorts', Icons.share_outlined, () {
                  Navigator.of(context).pop();
                  // TODO: Implement share with cohorts
                }),
                _buildMenuItem('Close form', Icons.close, () async {
                  Navigator.of(context).pop();
                  if (form.status == 'closed') {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Form is already closed.'),
                        backgroundColor: Colors.orange,
                      ),
                    );
                    return;
                  }
                  try {
                    await FirebaseService.updateForm(
                      form.id!,
                      form.copyWith(status: 'closed'),
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Form "${form.title}" closed.'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Failed to close form: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }),
                _buildMenuItem('Duplicate', Icons.copy_outlined, () {
                  Navigator.of(context).pop();
                  // TODO: Implement duplicate form
                }),
                Container(
                  height: 1,
                  color: KStyle.cE3GreyColor,
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                ),
                _buildMenuItem('Delete', Icons.delete_outline, () {
                  Navigator.of(context).pop();
                  _showDeleteConfirmation(context, form);
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

  void _showDeleteConfirmation(BuildContext context, FormModel form) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Delete Form',
            style: KStyle.heading3TextStyle.copyWith(
              color: KStyle.cBlackColor,
            ),
          ),
          content: Text(
            'Are you sure you want to delete "${form.title}"? This action cannot be undone.',
            style: KStyle.labelMdRegularTextStyle.copyWith(
              color: KStyle.c72GreyColor,
            ),
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
                try {
                  await FirebaseService.deleteForm(form.id!);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content:
                          Text('Form "${form.title}" deleted successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error deleting form: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
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
        );
      },
    );
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
                  context.read<AuthBloc>().add(SignOutRequested());
                }, isDestructive: true),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusChip(String status) {
    Color backgroundColor;
    Color textColor;
    String statusText;

    switch (status) {
      case 'active':
        backgroundColor = KStyle.cE8GreenColor;
        textColor = KStyle.c25GreenColor;
        statusText = 'Live';
        break;
      case 'draft':
        backgroundColor = KStyle.cF4GreyColor;
        textColor = KStyle.c72GreyColor;
        statusText = 'Draft';
        break;
      case 'closed':
        backgroundColor = KStyle.cFF3Color;
        textColor = KStyle.cDBRedColor;
        statusText = 'Closed';
        break;
      default:
        backgroundColor = KStyle.cF4GreyColor;
        textColor = KStyle.c72GreyColor;
        statusText = 'Draft';
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

  Future<void> _copyFormLink(FormModel form) async {
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

    // Add responder link (without view parameter for actual submissions)
    final String link = '$baseUrl/form/${form.id}';

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

  void _showDebugStreamDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Debug: Forms Stream',
            style: KStyle.heading3TextStyle.copyWith(
              color: KStyle.cBlackColor,
            ),
          ),
          content: Container(
            width: 400,
            height: 300,
            child: StreamBuilder<List<FormModel>>(
              stream: FirebaseService.getFormsStreamDebug(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Error: ${snapshot.error}',
                      style: KStyle.labelMdRegularTextStyle.copyWith(
                        color: Colors.red,
                      ),
                    ),
                  );
                }

                final forms = snapshot.data ?? [];

                if (forms.isEmpty) {
                  return Center(
                    child: Text(
                      'No forms found in database',
                      style: KStyle.labelMdRegularTextStyle.copyWith(
                        color: KStyle.c72GreyColor,
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: forms.length,
                  itemBuilder: (context, index) {
                    final form = forms[index];
                    return ListTile(
                      title: Text(
                        form.title,
                        style: KStyle.labelMdRegularTextStyle.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: Text(
                        'ID: ${form.id} | Created by: ${form.createdBy} | Status: ${form.status}',
                        style: KStyle.labelSmRegularTextStyle.copyWith(
                          color: KStyle.c72GreyColor,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Close',
                style: KStyle.labelMdRegularTextStyle.copyWith(
                  color: KStyle.c72GreyColor,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showOrderedStreamDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Debug: Ordered Forms Stream',
            style: KStyle.heading3TextStyle.copyWith(
              color: KStyle.cBlackColor,
            ),
          ),
          content: Container(
            width: 400,
            height: 300,
            child: StreamBuilder<List<FormModel>>(
              stream: FirebaseService.getFormsStreamWithOrderBy(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Error: ${snapshot.error}',
                      style: KStyle.labelMdRegularTextStyle.copyWith(
                        color: Colors.red,
                      ),
                    ),
                  );
                }

                final forms = snapshot.data ?? [];

                if (forms.isEmpty) {
                  return Center(
                    child: Text(
                      'No forms found in database',
                      style: KStyle.labelMdRegularTextStyle.copyWith(
                        color: KStyle.c72GreyColor,
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: forms.length,
                  itemBuilder: (context, index) {
                    final form = forms[index];
                    return ListTile(
                      title: Text(
                        form.title,
                        style: KStyle.labelMdRegularTextStyle.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: Text(
                        'ID: ${form.id} | Created by: ${form.createdBy} | Status: ${form.status}',
                        style: KStyle.labelSmRegularTextStyle.copyWith(
                          color: KStyle.c72GreyColor,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Close',
                style: KStyle.labelMdRegularTextStyle.copyWith(
                  color: KStyle.c72GreyColor,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
