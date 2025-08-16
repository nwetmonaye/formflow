import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:formflow/constants/style.dart';
import 'package:formflow/models/form_model.dart' as form_model;
import 'package:formflow/services/firebase_service.dart';
import 'package:formflow/screens/form_builder_screen.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class FormPreviewScreen extends StatefulWidget {
  final form_model.FormModel? form;
  final String? formId;

  const FormPreviewScreen({super.key, this.form, this.formId})
      : assert(form != null || formId != null,
            'Either form or formId must be provided');

  @override
  State<FormPreviewScreen> createState() => _FormPreviewScreenState();
}

class _FormPreviewScreenState extends State<FormPreviewScreen> {
  form_model.FormModel? _form;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeForm();
  }

  Future<void> _initializeForm() async {
    if (widget.form != null) {
      _form = widget.form;
    } else if (widget.formId != null) {
      setState(() {
        _isLoading = true;
      });

      try {
        final loadedForm = await FirebaseService.getForm(widget.formId!);
        if (loadedForm != null) {
          setState(() {
            _form = loadedForm;
            _isLoading = false;
          });
        } else {
          setState(() {
            _isLoading = false;
          });
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Form not found'),
                backgroundColor: Colors.red,
              ),
            );
            Navigator.of(context).pop();
          }
        }
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error loading form: $e'),
              backgroundColor: Colors.red,
            ),
          );
          Navigator.of(context).pop();
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading || _form == null) {
      return Scaffold(
        backgroundColor: KStyle.cBgColor,
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: KStyle.cWhiteColor,
      body: Column(
        children: [
          // Full-width white header bar with preview button
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(top: 0, left: 0, right: 0),
            child: SafeArea(
              bottom: false,
              child: Container(
                height: 64,
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 8),
                      decoration: BoxDecoration(
                        color: KStyle.cSelectedColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: SvgPicture.asset(
                              'assets/icons/eye.svg',
                              color: KStyle.c3BGreyColor,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Preview',
                            style: KStyle.labelTextStyle.copyWith(
                              color: KStyle.c3BGreyColor,
                            ),
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () => Navigator.of(context).pop(),
                            child: Icon(Icons.close,
                                size: 18, color: KStyle.c3BGreyColor),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Full-width divider
          Container(
            width: double.infinity,
            height: 1,
            color: KStyle.cE3GreyColor,
          ),
          // Main content
          Expanded(
            child: SingleChildScrollView(
              child: Center(
                child: Container(
                  color: Colors.white,
                  width: 700,
                  margin: const EdgeInsets.only(top: 32, bottom: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Form Header Card
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black
                                    .withOpacity(0.15), // darker main shadow
                                blurRadius: 12,
                                offset: const Offset(0, 6),
                              ),
                              BoxShadow(
                                color: Colors.black
                                    .withOpacity(0.08), // soft spread shadow
                                blurRadius: 30,
                                offset: const Offset(0, 20),
                              ),
                            ],
                            border: Border(
                              left: BorderSide(
                                color: KStyle.cPrimaryColor,
                                width: 6,
                              ),
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(32),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _form!.title.isNotEmpty
                                      ? _form!.title
                                      : 'Untitled',
                                  style: KStyle.heading2TextStyle.copyWith(
                                    color: KStyle.cBlackColor,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 32,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _form!.description.isNotEmpty
                                      ? _form!.description
                                      : 'Form Description',
                                  style:
                                      KStyle.labelMdRegularTextStyle.copyWith(
                                    color: KStyle.c72GreyColor,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  '* Indicates required question',
                                  style:
                                      KStyle.labelMdRegularTextStyle.copyWith(
                                    color: Colors.red[200],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      // Form Questions
                      ...(_form!.fields
                              .map((field) => _buildQuestionCard(field)) ??
                          []),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionCard(form_model.FormField field) {
    final questionType = field.type;
    final questionText = field.label;
    final isRequired = field.required;
    final options = field.options;

    return Container(
      width: 700,
      margin: const EdgeInsets.only(top: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Question text
            Row(
              children: [
                Expanded(
                  child: Text(
                    questionText,
                    style: KStyle.heading3TextStyle.copyWith(
                      color: KStyle.cBlackColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                if (isRequired)
                  Text(
                    ' *',
                    style: KStyle.heading3TextStyle.copyWith(
                      color: Colors.red,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            // Question input based on type
            _buildQuestionInput(questionType, options, field),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionInput(
      String questionType, List<String>? options, form_model.FormField field) {
    switch (questionType) {
      case 'text':
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: KStyle.cE3GreyColor,
                width: 1,
              ),
            ),
          ),
          child: Text(
            field.placeholder ?? 'Your answer',
            style: KStyle.labelMdRegularTextStyle.copyWith(
              color: KStyle.c72GreyColor,
            ),
          ),
        );

      case 'multiple_choice':
        return Column(
          children: (options ?? []).map<Widget>((option) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: KStyle.cE3GreyColor,
                        width: 2,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    option,
                    style: KStyle.labelMdRegularTextStyle.copyWith(
                      color: KStyle.cBlackColor,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        );

      case 'date':
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: KStyle.cE3GreyColor,
                width: 1,
              ),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'mm/dd/yyyy',
                  style: KStyle.labelMdRegularTextStyle.copyWith(
                    color: KStyle.c72GreyColor,
                  ),
                ),
              ),
              Icon(
                Icons.calendar_today,
                color: KStyle.c72GreyColor,
                size: 20,
              ),
            ],
          ),
        );

      case 'checkbox':
        return Column(
          children: (options ?? []).map<Widget>((option) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: KStyle.cE3GreyColor,
                        width: 2,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    option,
                    style: KStyle.labelMdRegularTextStyle.copyWith(
                      color: KStyle.cBlackColor,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        );

      case 'dropdown':
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: KStyle.cE3GreyColor,
                width: 1,
              ),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Select an option',
                  style: KStyle.labelMdRegularTextStyle.copyWith(
                    color: KStyle.c72GreyColor,
                  ),
                ),
              ),
              Icon(
                Icons.arrow_drop_down,
                color: KStyle.c72GreyColor,
                size: 20,
              ),
            ],
          ),
        );

      case 'number':
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: KStyle.cE3GreyColor,
                width: 1,
              ),
            ),
          ),
          child: Text(
            field.placeholder ?? 'Enter a number',
            style: KStyle.labelMdRegularTextStyle.copyWith(
              color: KStyle.c72GreyColor,
            ),
          ),
        );

      case 'file_upload':
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(
              color: KStyle.cE3GreyColor,
              width: 1,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(
                Icons.upload_file,
                color: KStyle.c72GreyColor,
                size: 20,
              ),
              const SizedBox(width: 12),
              Text(
                'Click to upload file',
                style: KStyle.labelMdRegularTextStyle.copyWith(
                  color: KStyle.c72GreyColor,
                ),
              ),
            ],
          ),
        );

      default:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: KStyle.cE3GreyColor,
                width: 1,
              ),
            ),
          ),
          child: Text(
            field.placeholder ?? 'Your answer',
            style: KStyle.labelMdRegularTextStyle.copyWith(
              color: KStyle.c72GreyColor,
            ),
          ),
        );
    }
  }

  Future<void> _copyResponderLink() async {
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

    // Generate responder link (without view parameter for actual submissions)
    final String link = '$baseUrl/form/${_form!.id}';

    await Clipboard.setData(ClipboardData(text: link));

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Responder link copied to clipboard!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }
}
