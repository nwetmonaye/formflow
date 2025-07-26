import 'package:flutter/material.dart';
import 'package:formflow/constants/style.dart';

class SidebarNavigation extends StatelessWidget {
  const SidebarNavigation({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      color: KStyle.cWhiteColor,
      child: Column(
        children: [
          // Logo Section
          Container(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: KStyle.cPrimaryColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'form.',
                  style: KStyle.heading3TextStyle.copyWith(
                    color: KStyle.cBlackColor,
                  ),
                ),
              ],
            ),
          ),

          // Navigation Menu
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  // My Forms (Selected)
                  _buildNavItem(
                    icon: Icons.folder,
                    label: 'My Forms',
                    isSelected: true,
                    onTap: () {},
                  ),

                  const SizedBox(height: 8),

                  // Cohorts
                  _buildNavItem(
                    icon: Icons.people,
                    label: 'Cohorts',
                    isSelected: false,
                    onTap: () {},
                  ),

                  const SizedBox(height: 8),

                  // Notifications
                  _buildNavItem(
                    icon: Icons.notifications,
                    label: 'Notifications',
                    isSelected: false,
                    onTap: () {},
                    badge: '5',
                  ),
                ],
              ),
            ),
          ),

          // User Profile Section
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
                // Profile Picture
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: KStyle.cPrimaryColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.person,
                    color: KStyle.cWhiteColor,
                    size: 20,
                  ),
                ),

                const SizedBox(width: 12),

                // User Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Thomas Willy',
                        style: KStyle.labelMdBoldTextStyle.copyWith(
                          color: KStyle.cBlackColor,
                        ),
                      ),
                      Text(
                        'View Profile',
                        style: KStyle.labelXsRegularTextStyle.copyWith(
                          color: KStyle.c72GreyColor,
                        ),
                      ),
                    ],
                  ),
                ),

                // Dropdown Icon
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
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    String? badge,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? KStyle.cEDBlueColor : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? KStyle.cPrimaryColor : KStyle.c72GreyColor,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: KStyle.labelMdRegularTextStyle.copyWith(
                  color:
                      isSelected ? KStyle.cPrimaryColor : KStyle.c72GreyColor,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
            if (badge != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: KStyle.cRedColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  badge,
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
