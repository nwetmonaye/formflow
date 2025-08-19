import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:formflow/constants/style.dart';

class FormHeader extends StatelessWidget {
  final String title;
  final String description;
  final VoidCallback? onEditTitle;
  final VoidCallback? onEditDescription;
  final bool showEditIcon;
  final Widget? child;

  const FormHeader({
    Key? key,
    required this.title,
    required this.description,
    this.onEditTitle,
    this.onEditDescription,
    this.showEditIcon = true,
    this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            spreadRadius: 0,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border(
          left: BorderSide(
            color: KStyle.cPrimaryColor,
            width: 6,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  title.isNotEmpty ? title : 'Untitled',
                  style: KStyle.headingTextStyle.copyWith(
                    color: KStyle.cBlackColor,
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (showEditIcon && onEditTitle != null)
                IconButton(
                  onPressed: onEditTitle,
                  icon: SvgPicture.asset(
                    'assets/icons/edit.svg',
                    width: 17,
                    height: 17,
                  ),
                  tooltip: 'Edit title',
                ),
            ],
          ),
          const SizedBox(height: 8),
          // Description Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  description.isNotEmpty ? description : 'Form Description',
                  style: KStyle.labelSmTextStyle.copyWith(
                    color: KStyle.c89GreyColor,
                  ),
                ),
              ),
              if (showEditIcon && onEditDescription != null)
                IconButton(
                  onPressed: onEditDescription,
                  icon: SvgPicture.asset(
                    'assets/icons/edit.svg',
                    width: 15,
                    height: 15,
                  ),
                  tooltip: 'Edit description',
                ),
            ],
          ),
          if (child != null) ...[
            const SizedBox(height: 20),
            child!,
          ],
        ],
      ),
    );
  }
}
