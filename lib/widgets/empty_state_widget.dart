import 'package:flutter/material.dart';
import 'package:formflow/constants/style.dart';

class EmptyStateWidget extends StatelessWidget {
  const EmptyStateWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Illustration Container
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: KStyle.cEDBlueColor,
              shape: BoxShape.circle,
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Main form icon
                Icon(
                  Icons.description_outlined,
                  size: 48,
                  color: KStyle.cPrimaryColor,
                ),
                // Small dots above
                Positioned(
                  top: 20,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(
                        3,
                        (index) => Container(
                              margin: EdgeInsets.only(right: index < 2 ? 4 : 0),
                              width: 4,
                              height: 4,
                              decoration: BoxDecoration(
                                color: KStyle.cPrimaryColor,
                                shape: BoxShape.circle,
                              ),
                            )),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Title
          Text(
            'No forms yet',
            style: KStyle.heading3TextStyle.copyWith(
              color: KStyle.cBlackColor,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 8),

          // Description
          Container(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Text(
              'Start by creating a new form to collect responses or manage approvals.',
              style: KStyle.labelMdRegularTextStyle.copyWith(
                color: KStyle.c72GreyColor,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
