import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formflow/blocs/auth_bloc.dart';
import 'package:formflow/constants/style.dart';
import 'package:formflow/models/cohort_model.dart';
import 'package:formflow/services/firebase_service.dart';
import 'package:formflow/screens/home_screen.dart';
import 'package:formflow/screens/notification_screen.dart';
import 'package:formflow/screens/profile_screen.dart';
import 'package:formflow/screens/login_screen.dart';
import 'package:formflow/widgets/create_cohort_modal.dart';
import 'package:formflow/widgets/cohort_card.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CohortsScreen extends StatefulWidget {
  const CohortsScreen({super.key});

  @override
  State<CohortsScreen> createState() => _CohortsScreenState();
}

class _CohortsScreenState extends State<CohortsScreen> {
  int selectedNavItem = 1; // 1 = Cohorts
  List<CohortModel> _cachedCohorts = [];
  bool _hasCachedData = false;
  bool _showMockData = false; // Control when to show mock data

  @override
  void initState() {
    super.initState();
    // Pre-load cohorts to have fallback data
    _preloadCohorts();
    _startLoadingTimeout(); // Start timeout for loading state
  }

  Future<void> _preloadCohorts() async {
    try {
      print('🔍 CohortsScreen: Starting to preload cohorts...');

      // Check if Firebase is initialized first
      final isFirebaseInitialized = await FirebaseService.ensureInitialized();
      print('🔍 CohortsScreen: Firebase initialized: $isFirebaseInitialized');

      if (!isFirebaseInitialized) {
        print(
            '🔍 CohortsScreen: Firebase not initialized, cannot preload cohorts');
        return;
      }

      // Check authentication status
      final isAuthenticated =
          await FirebaseService.isCurrentUserAuthenticated();
      print('🔍 CohortsScreen: User authenticated: $isAuthenticated');

      if (!isAuthenticated) {
        print(
            '🔍 CohortsScreen: User not authenticated, cannot preload cohorts');
        return;
      }

      // Get current user ID directly from Firebase Auth
      final user = FirebaseAuth.instance.currentUser;
      print('🔍 CohortsScreen: Current user ID: ${user?.uid ?? 'null'}');
      print('🔍 CohortsScreen: Current user email: ${user?.email ?? 'null'}');

      // Test direct Firestore query
      try {
        final firestore = FirebaseFirestore.instance;
        print('🔍 CohortsScreen: Testing direct Firestore query...');

        // First, check if cohorts collection exists and has any documents
        final allCohortsQuery =
            await firestore.collection('cohorts').limit(5).get();
        print(
            '🔍 CohortsScreen: Total cohorts in database: ${allCohortsQuery.docs.length}');

        if (allCohortsQuery.docs.isNotEmpty) {
          print('🔍 CohortsScreen: Sample cohort data:');
          for (int i = 0; i < allCohortsQuery.docs.length; i++) {
            final doc = allCohortsQuery.docs[i];
            print(
                '🔍 CohortsScreen: Cohort ${i + 1}: ID=${doc.id}, Data=${doc.data()}');
          }
        }

        // Now test the specific query for current user
        if (user?.uid != null) {
          final userCohortsQuery = await firestore
              .collection('cohorts')
              .where('createdBy', isEqualTo: user!.uid)
              .get();
          print(
              '🔍 CohortsScreen: Cohorts for user ${user.uid}: ${userCohortsQuery.docs.length}');

          if (userCohortsQuery.docs.isNotEmpty) {
            print('🔍 CohortsScreen: User cohort data:');
            for (int i = 0; i < userCohortsQuery.docs.length; i++) {
              final doc = userCohortsQuery.docs[i];
              print(
                  '🔍 CohortsScreen: User Cohort ${i + 1}: ID=${doc.id}, Data=${doc.data()}');
            }
          }
        }
      } catch (firestoreError) {
        print(
            '🔍 CohortsScreen: Direct Firestore query failed: $firestoreError');
      }

      print('🔍 CohortsScreen: Calling FirebaseService.getCohorts()...');
      final cohorts = await FirebaseService.getCohorts();
      print(
          '🔍 CohortsScreen: Received ${cohorts.length} cohorts from Firebase');

      setState(() {
        _cachedCohorts = cohorts;
        _hasCachedData = true;
      });
      print(
          '🔍 CohortsScreen: Successfully preloaded ${cohorts.length} cohorts');
    } catch (e) {
      print('🔍 CohortsScreen: Error preloading cohorts: $e');
      print('🔍 CohortsScreen: Error type: ${e.runtimeType}');
      print('🔍 CohortsScreen: Error stack trace: ${StackTrace.current}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is Unauthenticated) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('You have been signed out successfully.'),
              backgroundColor: Colors.blue,
            ),
          );
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const LoginScreen()),
            (route) => false,
          );
        }
      },
      child: BlocBuilder<AuthBloc, AuthState>(
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
                      'Please sign in to view your cohorts',
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
                                    Navigator.of(context).pushReplacement(
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const NotificationScreen(),
                                      ),
                                    );
                                  },
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
                                    (authState.user.displayName?.isNotEmpty ==
                                            true)
                                        ? authState.user.displayName![0]
                                            .toUpperCase()
                                        : 'U',
                                    style: KStyle.labelMdBoldTextStyle.copyWith(
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
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      authState.user.displayName ?? 'User',
                                      style: KStyle.labelMdRegularTextStyle
                                          .copyWith(
                                        color: KStyle.cWhiteColor,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      'View Profile',
                                      style: KStyle.labelSmRegularTextStyle
                                          .copyWith(
                                        color:
                                            KStyle.cWhiteColor.withOpacity(0.7),
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
                      // crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header Section

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
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Cohorts',
                                          style:
                                              KStyle.headingTextStyle.copyWith(
                                            color: KStyle.cBlackColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Spacer(),
                                    ElevatedButton.icon(
                                      onPressed: _showCreateCohortModal,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: KStyle.cPrimaryColor,
                                        foregroundColor: KStyle.cWhiteColor,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 20,
                                          vertical: 16,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        elevation: 0,
                                      ),
                                      icon: const Icon(Icons.add, size: 20),
                                      label: Text(
                                        'New Cohort',
                                        style: KStyle.labelTextStyle.copyWith(
                                          color: KStyle.cWhiteColor,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    // Manual refresh button
                                    // ElevatedButton.icon(
                                    //   onPressed: _refreshCohorts,
                                    //   style: ElevatedButton.styleFrom(
                                    //     backgroundColor: Colors.blue,
                                    //     foregroundColor: Colors.white,
                                    //     padding: const EdgeInsets.symmetric(
                                    //       horizontal: 16,
                                    //       vertical: 16,
                                    //     ),
                                    //     shape: RoundedRectangleBorder(
                                    //       borderRadius:
                                    //           BorderRadius.circular(8),
                                    //     ),
                                    //     elevation: 0,
                                    //   ),
                                    //   icon: const Icon(Icons.refresh, size: 20),
                                    //   label: const Text('Refresh'),
                                    // ),
                                    // const SizedBox(width: 12),
                                    // // Test Firebase button
                                    // ElevatedButton.icon(
                                    //   onPressed: _testFirebaseConnection,
                                    //   style: ElevatedButton.styleFrom(
                                    //     backgroundColor: Colors.orange,
                                    //     foregroundColor: Colors.white,
                                    //     padding: const EdgeInsets.symmetric(
                                    //       horizontal: 16,
                                    //       vertical: 16,
                                    //     ),
                                    //     shape: RoundedRectangleBorder(
                                    //       borderRadius:
                                    //           BorderRadius.circular(8),
                                    //     ),
                                    //     elevation: 0,
                                    //   ),
                                    //   icon: const Icon(Icons.bug_report,
                                    //       size: 20),
                                    //   label: const Text('Test'),
                                    // ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Content Section - Use StreamBuilder for real-time updates
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

                              return StreamBuilder<List<CohortModel>>(
                                stream: FirebaseService.getCohortsStream(),
                                builder: (context, snapshot) {
                                  print(
                                      '🔍 CohortsScreen: StreamBuilder state: ${snapshot.connectionState}, hasData: ${snapshot.hasData}, hasError: ${snapshot.hasError}, error: ${snapshot.error}');

                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    // Show cached data if available while loading
                                    if (_hasCachedData &&
                                        _cachedCohorts.isNotEmpty) {
                                      print(
                                          '🔍 CohortsScreen: Stream loading, showing cached data');
                                      return _buildCohortsGrid(_cachedCohorts);
                                    }

                                    // If no cached data and still loading, show single skeleton loader
                                    return Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 20),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          // Single skeleton cohort card
                                          Container(
                                            padding: const EdgeInsets.all(16),
                                            decoration: BoxDecoration(
                                              color: KStyle.cWhiteColor,
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black
                                                      .withOpacity(0.08),
                                                  blurRadius: 20,
                                                  offset: const Offset(0, 4),
                                                ),
                                              ],
                                            ),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                // Skeleton title
                                                Container(
                                                  height: 20,
                                                  width: 120,
                                                  decoration: BoxDecoration(
                                                    color: Colors.grey[300],
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            4),
                                                  ),
                                                ),
                                                const SizedBox(height: 80),
                                                // Skeleton team members section
                                                Row(
                                                  children: [
                                                    Container(
                                                      width: 24,
                                                      height: 24,
                                                      decoration: BoxDecoration(
                                                        color: Colors.grey[300],
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(4),
                                                      ),
                                                    ),
                                                    const SizedBox(width: 12),
                                                    Container(
                                                      width: 40,
                                                      height: 20,
                                                      decoration: BoxDecoration(
                                                        color: Colors.grey[300],
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const Spacer(),
                                                // Skeleton button
                                                Container(
                                                  width: double.infinity,
                                                  height: 48,
                                                  decoration: BoxDecoration(
                                                    color: Colors.grey[300],
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(height: 16),
                                          // Loading text
                                          Center(
                                            child: Text(
                                              'Loading cohorts...',
                                              style: KStyle
                                                  .labelMdRegularTextStyle
                                                  .copyWith(
                                                color: KStyle.c72GreyColor,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }

                                  if (snapshot.hasError) {
                                    print(
                                        '🔍 CohortsScreen: Stream error: ${snapshot.error}');

                                    // If user wants to see mock data, show it
                                    if (_showMockData) {
                                      return _buildMockDataFallback();
                                    }

                                    // Show cached data if available, otherwise show error
                                    if (_hasCachedData &&
                                        _cachedCohorts.isNotEmpty) {
                                      print(
                                          '🔍 CohortsScreen: Stream error, showing cached data');
                                      return Column(
                                        children: [
                                          // Show warning about using cached data
                                          Container(
                                            margin: const EdgeInsets.all(16),
                                            padding: const EdgeInsets.all(12),
                                            decoration: BoxDecoration(
                                              color: Colors.orange
                                                  .withOpacity(0.1),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              border: Border.all(
                                                  color: Colors.orange
                                                      .withOpacity(0.3)),
                                            ),
                                            child: Row(
                                              children: [
                                                Icon(
                                                    Icons
                                                        .warning_amber_outlined,
                                                    color: Colors.orange),
                                                const SizedBox(width: 8),
                                                Expanded(
                                                  child: Text(
                                                    'Showing cached data due to connection issues. Pull to refresh.',
                                                    style: TextStyle(
                                                        color:
                                                            Colors.orange[700]),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Expanded(
                                              child: _buildCohortsGrid(
                                                  _cachedCohorts)),
                                        ],
                                      );
                                    }

                                    // If no cached data, show error with retry option
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
                                            'Error loading cohorts',
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
                                            textAlign: TextAlign.center,
                                          ),
                                          const SizedBox(height: 16),
                                          ElevatedButton(
                                            onPressed: () {
                                              // Trigger a refresh by rebuilding the stream
                                              // _refreshCohorts();
                                            },
                                            child: const Text('Retry'),
                                          ),
                                          const SizedBox(height: 16),
                                          ElevatedButton(
                                            onPressed: () {
                                              // Show mock data as fallback
                                              setState(() {
                                                _showMockData = true;
                                              });
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.orange,
                                              foregroundColor: Colors.white,
                                            ),
                                            child:
                                                const Text('Show Sample Data'),
                                          ),
                                          const SizedBox(height: 16),
                                          ElevatedButton(
                                            onPressed: () async {
                                              // Create a test cohort
                                              await _createTestCohort();
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.green,
                                              foregroundColor: Colors.white,
                                            ),
                                            child: const Text(
                                                'Create Test Cohort'),
                                          ),
                                          const SizedBox(height: 16),
                                          ElevatedButton(
                                            onPressed: () async {
                                              // Check all cohorts in database
                                              await _checkAllCohorts();
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.purple,
                                              foregroundColor: Colors.white,
                                            ),
                                            child:
                                                const Text('Check All Cohorts'),
                                          ),
                                          const SizedBox(height: 16),
                                          // Show debug info
                                          Container(
                                            padding: const EdgeInsets.all(16),
                                            decoration: BoxDecoration(
                                              color:
                                                  Colors.grey.withOpacity(0.1),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Column(
                                              children: [
                                                Text(
                                                  'Debug Info:',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.grey[700],
                                                  ),
                                                ),
                                                const SizedBox(height: 8),
                                                Text(
                                                  'Has Cached Data: $_hasCachedData',
                                                  style: TextStyle(
                                                      color: Colors.grey[600]),
                                                ),
                                                Text(
                                                  'Cached Count: ${_cachedCohorts.length}',
                                                  style: TextStyle(
                                                      color: Colors.grey[600]),
                                                ),
                                                Text(
                                                  'Firebase Init: ${FirebaseService.isInitialized}',
                                                  style: TextStyle(
                                                      color: Colors.grey[600]),
                                                ),
                                                Text(
                                                  'Error Type: ${snapshot.error.runtimeType}',
                                                  style: TextStyle(
                                                      color: Colors.grey[600]),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }

                                  final cohorts = snapshot.data ?? [];

                                  // Update cached data when stream provides new data
                                  if (cohorts.isNotEmpty && !_hasCachedData) {
                                    WidgetsBinding.instance
                                        .addPostFrameCallback((_) {
                                      setState(() {
                                        _cachedCohorts = cohorts;
                                        _hasCachedData = true;
                                      });
                                    });
                                  }

                                  if (cohorts.isEmpty) {
                                    // If stream is empty but we have cached data, show cached
                                    if (_hasCachedData &&
                                        _cachedCohorts.isNotEmpty) {
                                      print(
                                          '🔍 CohortsScreen: Stream empty, showing cached data');
                                      return _buildCohortsGrid(_cachedCohorts);
                                    }
                                    return _buildEmptyState();
                                  }

                                  return _buildCohortsGrid(cohorts);
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

  void _showCreateCohortModal() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CreateCohortModal(
          onCohortCreated: (CohortModel cohort) {
            // The stream will automatically update with the new cohort
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Cohort "${cohort.name}" created successfully'),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // Force refresh the cohorts list
  void _refreshCohorts() {
    print('🔍 CohortsScreen: Force refreshing cohorts');

    // Clear cached data first
    setState(() {
      _cachedCohorts.clear();
      _hasCachedData = false;
      _showMockData = false; // Reset mock data flag
    });

    // Then try to refresh
    _preloadCohorts().then((_) {
      print('🔍 CohortsScreen: Refresh completed');
      // Trigger a rebuild of the StreamBuilder
      setState(() {});
    }).catchError((e) {
      print('🔍 CohortsScreen: Error during refresh: $e');
      // Still trigger rebuild even if refresh fails
      setState(() {});
    });
  }

  // Add timeout for loading state
  void _startLoadingTimeout() {
    Future.delayed(const Duration(seconds: 10), () {
      if (mounted && !_hasCachedData) {
        print('🔍 CohortsScreen: Loading timeout reached, showing error state');
        setState(() {
          // Force a rebuild to show error state
        });
      }
    });
  }

  // Show mock data as fallback
  Widget _buildMockDataFallback() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.orange.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.orange.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline, color: Colors.orange),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Showing sample data. Your actual cohorts will appear here once connected to Firebase.',
                  style: TextStyle(color: Colors.orange[700]),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 24,
              mainAxisSpacing: 24,
              childAspectRatio: 1.1,
            ),
            itemCount: 3,
            itemBuilder: (context, index) {
              final mockNames = [
                'Sample Cohort 1',
                'Sample Cohort 2',
                'Sample Cohort 3'
              ];
              final mockCounts = [5, 8, 3];

              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: KStyle.cWhiteColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            mockNames[index],
                            style: KStyle.heading2TextStyle.copyWith(
                              color: KStyle.cBlackColor,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: KStyle.cEDBlueColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.more_horiz,
                            size: 20,
                            color: KStyle.cPrimaryColor,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 80),
                    Row(
                      children: [
                        Icon(
                          Icons.group_outlined,
                          size: 24,
                          color: KStyle.c72GreyColor,
                        ),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: KStyle.cDBRedColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${mockCounts[index]}',
                            style: KStyle.labelXsRegularTextStyle.copyWith(
                              color: KStyle.cWhiteColor,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                  'This is sample data. Connect to Firebase to see your real cohorts.'),
                              backgroundColor: Colors.orange,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: KStyle.cSelectedColor,
                          foregroundColor: KStyle.cPrimaryColor,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          'Share Form',
                          style: KStyle.labelTextStyle.copyWith(
                            color: KStyle.cPrimaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // Test Firebase connectivity
  Future<void> _testFirebaseConnection() async {
    try {
      print('🔍 CohortsScreen: Testing Firebase connection...');

      // Test basic Firebase Auth
      final user = FirebaseAuth.instance.currentUser;
      print('🔍 CohortsScreen: Current Firebase user: ${user?.uid ?? 'null'}');

      // Test Firestore
      final firestore = FirebaseFirestore.instance;
      final testQuery = await firestore.collection('cohorts').limit(1).get();
      print(
          '🔍 CohortsScreen: Firestore test query result: ${testQuery.docs.length} docs');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Firebase test: User=${user?.uid != null}, Firestore=${testQuery.docs.length} docs'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
    } catch (e) {
      print('🔍 CohortsScreen: Firebase connection test failed: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Firebase test failed: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
    }
  }

  // Create a test cohort for debugging
  Future<void> _createTestCohort() async {
    try {
      print('🔍 CohortsScreen: Creating test cohort...');

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('No user authenticated'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
        return;
      }

      // Create a test cohort
      final testCohort = CohortModel(
        name: 'Test Cohort ${DateTime.now().millisecondsSinceEpoch}',
        recipients: [
          CohortRecipient(name: 'Test User 1', email: 'test1@example.com'),
          CohortRecipient(name: 'Test User 2', email: 'test2@example.com'),
        ],
        createdBy: user.uid,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      print('🔍 CohortsScreen: Test cohort data: ${testCohort.toMap()}');

      // Save to Firestore directly
      final firestore = FirebaseFirestore.instance;
      final docRef = await firestore.collection('cohorts').add({
        ...testCohort.toMap(),
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      print('🔍 CohortsScreen: Test cohort created with ID: ${docRef.id}');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text('Test cohort created successfully with ID: ${docRef.id}'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );

      // Refresh the data
      // _refreshCohorts();
    } catch (e) {
      print('🔍 CohortsScreen: Error creating test cohort: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error creating test cohort: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
    }
  }

  // Check all cohorts in the database
  Future<void> _checkAllCohorts() async {
    try {
      print('🔍 CohortsScreen: Checking all cohorts in the database...');
      final firestore = FirebaseFirestore.instance;
      final allCohortsQuery = await firestore.collection('cohorts').get();
      print(
          '🔍 CohortsScreen: Found ${allCohortsQuery.docs.length} cohorts in the database.');
      if (allCohortsQuery.docs.isNotEmpty) {
        print('🔍 CohortsScreen: Sample cohort data:');
        for (int i = 0; i < allCohortsQuery.docs.length; i++) {
          final doc = allCohortsQuery.docs[i];
          print(
              '🔍 CohortsScreen: Cohort ${i + 1}: ID=${doc.id}, Data=${doc.data()}');
        }
      } else {
        print('🔍 CohortsScreen: No cohorts found in the database.');
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Found ${allCohortsQuery.docs.length} cohorts in the database.'),
          backgroundColor: Colors.blue,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
    } catch (e) {
      print('🔍 CohortsScreen: Error checking all cohorts: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error checking all cohorts: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
    }
  }

  void _showDebugInfo() async {
    try {
      final isFirebaseInitialized = await FirebaseService.ensureInitialized();
      final isAuthenticated =
          await FirebaseService.isCurrentUserAuthenticated();

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Debug Information'),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Firebase Initialized: $isFirebaseInitialized'),
                Text('User Authenticated: $isAuthenticated'),
                Text('Has Cached Data: $_hasCachedData'),
                Text('Cached Cohorts: ${_cachedCohorts.length}'),
                const SizedBox(height: 16),
                const Text('Auth State:',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) {
                    return Text('Current State: ${state.runtimeType}');
                  },
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () async {
                    try {
                      final cohorts = await FirebaseService.getCohorts();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Found ${cohorts.length} cohorts'),
                          backgroundColor: Colors.green,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error getting cohorts: $e'),
                          backgroundColor: Colors.red,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      );
                    }
                  },
                  child: const Text('Test Get Cohorts'),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _cachedCohorts.clear();
                      _hasCachedData = false;
                    });
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Cache cleared'),
                        backgroundColor: Colors.blue,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    );
                  },
                  child: const Text('Clear Cache'),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close'),
              ),
            ],
          );
        },
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Debug error: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
    }
  }

  Widget _buildEmptyState() {
    return Container(
      // padding: const EdgeInsets.all(48),
      decoration: BoxDecoration(
        color: KStyle.cWhiteColor,
        // borderRadius: BorderRadius.circular(20),
        // boxShadow: [
        //   BoxShadow(
        //     color: Colors.black.withOpacity(0.04),
        //     blurRadius: 20,
        //     offset: const Offset(0, 4),
        //   ),
        // ],
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/cohort.png',
              fit: BoxFit.contain,
              width: 150,
              height: 150,
            ),
            const SizedBox(height: 32),
            Text(
              'No cohorts yet',
              style: KStyle.heading3TextStyle.copyWith(
                color: KStyle.c72GreyColor,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Create your first cohort to start sharing forms with groups of recipients',
              style: KStyle.labelMdRegularTextStyle.copyWith(
                color: KStyle.c72GreyColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCohortsGrid(List<CohortModel> cohorts) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Stats Section
        // Container(
        //   padding: const EdgeInsets.all(20),
        //   decoration: BoxDecoration(
        //     color: KStyle.cEDBlueColor,
        //     borderRadius: BorderRadius.circular(16),
        //     border: Border.all(
        //       color: KStyle.cPrimaryColor.withOpacity(0.1),
        //       width: 1,
        //     ),
        //   ),
        //   child: Row(
        //     children: [
        //       Icon(
        //         Icons.insights_outlined,
        //         color: KStyle.cPrimaryColor,
        //         size: 24,
        //       ),
        //       const SizedBox(height: 12),
        //       Text(
        //         '${cohorts.length} cohort${cohorts.length == 1 ? '' : 's'} • ${cohorts.fold(0, (sum, cohort) => sum + cohort.recipients.length)} total recipients',
        //         style: KStyle.labelMdRegularTextStyle.copyWith(
        //           color: KStyle.cPrimaryColor,
        //           fontWeight: FontWeight.w600,
        //         ),
        //       ),
        //     ],
        //   ),
        // ),
        // const SizedBox(height: 24),

        // Cohorts Grid
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
            ),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 20,
              mainAxisSpacing: 30,
              childAspectRatio: 1.8,
            ),
            itemCount: cohorts.length,
            itemBuilder: (context, index) {
              return CohortCard(
                cohort: cohorts[index],
                onRefresh: () {
                  // _refreshCohorts();
                },
              );
            },
          ),
        ),
      ],
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
            // Profile dropdown card positioned near the profile tab
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
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const ProfileScreen(),
                          ),
                        );
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
}
