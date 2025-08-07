import 'package:flutter/material.dart';
import 'package:formflow/constants/style.dart';
import 'package:formflow/models/form_model.dart';
import 'package:formflow/services/firebase_service.dart';
import 'package:formflow/screens/form_builder_screen.dart';
import 'package:formflow/screens/form_detail_screen.dart';
import 'package:formflow/screens/notification_screen.dart';
import 'package:flutter_svg/flutter_svg.dart';

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
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'My Forms',
                          style: KStyle.headingTextStyle.copyWith(
                            color: KStyle.cBlackColor,
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const FormBuilderScreen(),
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
                                  style:
                                      KStyle.labelMdRegularTextStyle.copyWith(
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
                                      borderRadius: BorderRadius.circular(1),
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
                    child: StreamBuilder<List<FormModel>>(
                      stream: FirebaseService.getFormsStream(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }

                        if (snapshot.hasError) {
                          return Center(
                            child: Text(
                              'Error loading forms: ${snapshot.error}',
                              style: KStyle.labelMdRegularTextStyle.copyWith(
                                color: Colors.red,
                              ),
                            ),
                          );
                        }

                        final forms = snapshot.data ?? [];
                        final filteredForms =
                            _filterForms(forms, selectedFilter);

                        if (filteredForms.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.description_outlined,
                                  size: 64,
                                  color: KStyle.c72GreyColor,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No forms found',
                                  style: KStyle.heading3TextStyle.copyWith(
                                    color: KStyle.c72GreyColor,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Create your first form to get started',
                                  style:
                                      KStyle.labelMdRegularTextStyle.copyWith(
                                    color: KStyle.c72GreyColor,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }

                        return GridView.builder(
                          padding: const EdgeInsets.all(20),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 16,
                            childAspectRatio: 1.8,
                          ),
                          itemCount: filteredForms.length,
                          itemBuilder: (context, index) {
                            final form = filteredForms[index];
                            return _buildFormCard(form);
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
                          child: Text(
                            '4', // TODO: Get actual submission count
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

                  // Action Icons
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          // TODO: Implement view form
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
                          // TODO: Implement copy link
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
                _buildMenuItem('Close form', Icons.close, () {
                  Navigator.of(context).pop();
                  // TODO: Implement close form
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
}
