import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formflow/constants/style.dart';
import 'package:formflow/widgets/sidebar_navigation.dart';
import 'package:formflow/widgets/empty_state_widget.dart';
import 'package:formflow/blocs/auth_bloc.dart';
import 'package:formflow/services/auth_service.dart';

class MyFormsScreen extends StatefulWidget {
  const MyFormsScreen({super.key});

  @override
  State<MyFormsScreen> createState() => _MyFormsScreenState();
}

class _MyFormsScreenState extends State<MyFormsScreen> {
  String selectedFilter = 'All';
  final List<String> filters = ['All', 'Active', 'Draft', 'Closed'];
  int selectedNavItem = 0; // 0 = My Forms, 1 = Cohorts, 2 = Notifications

  void _onNavItemTap(int index) {
    setState(() {
      selectedNavItem = index;
    });
    // TODO: Navigate to appropriate screen based on index
  }

  void _onProfileTap() {
    // TODO: Navigate to profile screen
  }

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
              SidebarNavigation(
                user: authState.user,
                selectedIndex: selectedNavItem,
                onNavItemTap: _onNavItemTap,
                onProfileTap: _onProfileTap,
              ),

              // Main Content Area
              Expanded(
                child: Container(
                  color: KStyle.cWhiteColor,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: KStyle.cWhiteColor,
                          border: Border(
                            bottom: BorderSide(
                              color: KStyle.cE3GreyColor,
                              width: 1,
                            ),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'My Forms',
                              style: KStyle.heading2TextStyle.copyWith(
                                color: KStyle.cBlackColor,
                              ),
                            ),
                            ElevatedButton.icon(
                              onPressed: () {
                                // TODO: Navigate to form creation
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

                      // Content Area
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(24),
                          child: const EmptyStateWidget(),
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
    );
  }
}
