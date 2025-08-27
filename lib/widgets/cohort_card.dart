import 'package:flutter/material.dart';
import 'package:formflow/constants/style.dart';
import 'package:formflow/models/cohort_model.dart';
import 'package:formflow/services/firebase_service.dart';

class CohortCard extends StatelessWidget {
  final CohortModel cohort;
  final VoidCallback onRefresh;

  const CohortCard({
    super.key,
    required this.cohort,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
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
          // Top Section - Title and Options
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Title
              Expanded(
                child: Text(
                  cohort.name,
                  style: KStyle.heading2TextStyle.copyWith(
                    color: KStyle.cBlackColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              // Options Button
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: KStyle.cEDBlueColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: IconButton(
                  onPressed: () => _showOptionsMenu(context),
                  icon: Icon(
                    Icons.more_horiz,
                    size: 20,
                    color: KStyle.cPrimaryColor,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ),
            ],
          ),

          // Middle Section - Team Members and Count
          // const Spacer(),
          SizedBox(
            height: 80,
          ),
          Row(
            children: [
              // Team Members Icon
              Icon(
                Icons.group_outlined,
                size: 24,
                color: KStyle.c72GreyColor,
              ),
              const SizedBox(width: 12),
              // Member Count Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: KStyle.cDBRedColor,
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Text(
                  '${cohort.recipients.length}',
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

          // Bottom Section - Share Form Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _showShareFormDialog(context),
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
  }

  void _showOptionsMenu(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Cohort Options',
            style: KStyle.heading3TextStyle.copyWith(
              color: KStyle.cBlackColor,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Edit Option
              ListTile(
                leading: Icon(Icons.edit_outlined, color: KStyle.cPrimaryColor),
                title: Text(
                  'Edit Cohort',
                  style: KStyle.labelTextStyle.copyWith(
                    color: KStyle.cBlackColor,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _editCohort(context);
                },
              ),
              // Delete Option
              ListTile(
                leading: Icon(Icons.delete_outline, color: KStyle.cDBRedColor),
                title: Text(
                  'Delete Cohort',
                  style: KStyle.labelTextStyle.copyWith(
                    color: KStyle.cDBRedColor,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _deleteCohort(context);
                },
              ),
              // View Members Option
              ListTile(
                leading:
                    Icon(Icons.people_outline, color: KStyle.cPrimaryColor),
                title: Text(
                  'View Members',
                  style: KStyle.labelTextStyle.copyWith(
                    color: KStyle.cBlackColor,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _viewMembers(context);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: KStyle.labelTextStyle.copyWith(
                  color: KStyle.c72GreyColor,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showShareFormDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Share Form with ${cohort.name}',
            style: KStyle.heading3TextStyle.copyWith(
              color: KStyle.cBlackColor,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'This will share a form with all ${cohort.recipients.length} members of the ${cohort.name} cohort.',
                style: KStyle.labelMdRegularTextStyle.copyWith(
                  color: KStyle.c72GreyColor,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Note: You need to select a form to share first.',
                style: KStyle.labelSmRegularTextStyle.copyWith(
                  color: KStyle.c72GreyColor,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: KStyle.labelTextStyle.copyWith(
                  color: KStyle.c72GreyColor,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _navigateToFormSelection(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: KStyle.cPrimaryColor,
                foregroundColor: KStyle.cWhiteColor,
              ),
              child: Text(
                'Select Form',
                style: KStyle.labelTextStyle.copyWith(
                  color: KStyle.cWhiteColor,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _editCohort(BuildContext context) {
    // TODO: Implement edit cohort functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Edit ${cohort.name} - Coming soon'),
        backgroundColor: KStyle.cPrimaryColor,
      ),
    );
  }

  void _deleteCohort(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Delete Cohort',
            style: KStyle.heading3TextStyle.copyWith(
              color: KStyle.cDBRedColor,
            ),
          ),
          content: Text(
            'Are you sure you want to delete "${cohort.name}"? This action cannot be undone.',
            style: KStyle.labelMdRegularTextStyle.copyWith(
              color: KStyle.cBlackColor,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: KStyle.labelTextStyle.copyWith(
                  color: KStyle.c72GreyColor,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                await _confirmDeleteCohort(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: KStyle.cDBRedColor,
                foregroundColor: KStyle.cWhiteColor,
              ),
              child: Text(
                'Delete',
                style: KStyle.labelTextStyle.copyWith(
                  color: KStyle.cWhiteColor,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _confirmDeleteCohort(BuildContext context) async {
    try {
      if (cohort.id != null && cohort.id!.isNotEmpty) {
        await FirebaseService.deleteCohort(cohort.id!);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${cohort.name} deleted successfully'),
            backgroundColor: KStyle.cE8GreenColor,
          ),
        );
        onRefresh();
      } else {
        throw Exception('Cohort ID is empty or null');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error deleting cohort: $e'),
          backgroundColor: KStyle.cDBRedColor,
        ),
      );
    }
  }

  void _viewMembers(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            '${cohort.name} Members',
            style: KStyle.heading3TextStyle.copyWith(
              color: KStyle.cBlackColor,
            ),
          ),
          content: SizedBox(
            width: 300, // Reduced width for better appearance
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: cohort.recipients.length,
              itemBuilder: (context, index) {
                final recipient = cohort.recipients[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: KStyle.cPrimaryColor.withOpacity(0.1),
                    child: Text(
                      recipient.name.isNotEmpty
                          ? recipient.name[0].toUpperCase()
                          : '?',
                      style: KStyle.labelTextStyle.copyWith(
                        color: KStyle.cPrimaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  title: Text(
                    recipient.name.isNotEmpty ? recipient.name : 'Unnamed',
                    style: KStyle.labelTextStyle.copyWith(
                      color: KStyle.cBlackColor,
                    ),
                  ),
                  subtitle: Text(
                    recipient.email,
                    style: KStyle.labelSmRegularTextStyle.copyWith(
                      color: KStyle.c72GreyColor,
                    ),
                  ),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Close',
                style: KStyle.labelTextStyle.copyWith(
                  color: KStyle.cPrimaryColor,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _navigateToFormSelection(BuildContext context) {
    // TODO: Navigate to form selection screen
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Form selection - Coming soon'),
        backgroundColor: KStyle.cPrimaryColor,
      ),
    );
  }
}
