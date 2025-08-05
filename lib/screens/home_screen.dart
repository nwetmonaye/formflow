import 'package:flutter/material.dart';
import 'package:formflow/constants/style.dart';
import 'package:formflow/models/form_model.dart';
import 'package:formflow/services/firebase_service.dart';
import 'package:formflow/screens/form_builder_screen.dart';
import 'package:formflow/screens/form_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String selectedFilter = 'All';
  final List<String> filters = ['All', 'Active', 'Draft', 'Closed'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KStyle.cBgColor,
      body: Column(
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
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
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
                          style: KStyle.labelMdRegularTextStyle.copyWith(
                            color: isSelected
                                ? KStyle.cPrimaryColor
                                : KStyle.c72GreyColor,
                            fontWeight:
                                isSelected ? FontWeight.w600 : FontWeight.w400,
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
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
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
                final filteredForms = _filterForms(forms, selectedFilter);

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
                          style: KStyle.labelMdRegularTextStyle.copyWith(
                            color: KStyle.c72GreyColor,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return GridView.builder(
                  padding: const EdgeInsets.all(24),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 24,
                    mainAxisSpacing: 24,
                    childAspectRatio: 1.2,
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
    );
  }

  List<FormModel> _filterForms(List<FormModel> forms, String filter) {
    switch (filter) {
      case 'Active':
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
          border: Border.all(color: KStyle.cE3GreyColor),
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
            // Header with color theme
            Container(
              height: 8,
              decoration: BoxDecoration(
                color: _getThemeColor(form.colorTheme),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
            ),

            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      form.title,
                      style: KStyle.heading4TextStyle.copyWith(
                        color: KStyle.cBlackColor,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      form.description,
                      style: KStyle.labelSmRegularTextStyle.copyWith(
                        color: KStyle.c72GreyColor,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),

                    // Status and stats
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildStatusChip(form.status),
                        Text(
                          '${form.fields.length} questions',
                          style: KStyle.labelXsRegularTextStyle.copyWith(
                            color: KStyle.c72GreyColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
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
        statusText = 'Active';
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
        statusText = 'Unknown';
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

  Color _getThemeColor(String colorTheme) {
    switch (colorTheme) {
      case 'green':
        return const Color(0xFF10B981);
      case 'orange':
        return const Color(0xFFF59E0B);
      case 'red':
        return const Color(0xFFEF4444);
      default:
        return KStyle.cPrimaryColor;
    }
  }
}
