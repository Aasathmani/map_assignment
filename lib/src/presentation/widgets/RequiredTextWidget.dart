import 'package:flutter/material.dart';
import 'package:map_assignment/src/presentation/core/theme/colors.dart';
import 'package:map_assignment/src/utils/string_utils.dart';

class RequiredTextWidget extends StatelessWidget {
  final bool isRequired;
  final String? text;
  final TextStyle? textStyle;

  const RequiredTextWidget({
    super.key,
    required this.isRequired,
    this.text,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    return isRequired
        ? RichText(
            text: TextSpan(
              style: textStyle,
              children: <TextSpan>[
                if (StringUtils.isNotNullAndEmpty(text)) TextSpan(text: text),
                TextSpan(
                  text: ' *',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.red,
                      ),
                ),
              ],
            ),
          )
        : Text(
            text ?? '',
            style: textStyle,
          );
  }
}
