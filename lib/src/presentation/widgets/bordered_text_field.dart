
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:map_assignment/src/core/app_constants.dart';
import 'package:map_assignment/src/presentation/core/theme/colors.dart';
import 'package:map_assignment/src/presentation/core/theme/text_styles.dart';
import 'package:map_assignment/src/utils/string_utils.dart';

class BorderedTextField extends StatefulWidget {
  final Stream<String?>? textStream;
  final FocusNode? focusNode;
  final double textBoxHeight;
  final String? labelText;
  final void Function(String)? onTextChanged;
  final Color? backgroundColor;
  final VoidCallback? onTap;
  final double leftPadding;
  final double rightPadding;
  final Widget? suffix;
  final Widget? suffixIcon;
  final TextInputType? textInputType;
  final int? maxLines;
  final int minLines;
  final TextAlign textAlign;
  final Color? textColor;
  final TextStyle? style;
  final TextAlignVertical textAlignVertical;
  final TextInputAction? textInputAction;
  final List<TextInputFormatter>? inputFormatters;
  final Stream<String?>? errorStream;
  final bool enabled;
  final bool obscureText;
  final bool enableSelection;
  final bool alignLabelWithHint;
  final TextCapitalization textCapitalization;
  final bool isMandatory;
  final bool readOnly;
  final Widget? prefixIcon;
  final Color errorMessageColor;
  final bool isRequired;

  const BorderedTextField({
    super.key,
    this.focusNode,
    this.textStream,
    this.textBoxHeight = Units.kTextBoxHeight,
    this.labelText,
    this.onTextChanged,
    this.onTap,
    this.leftPadding = Units.kLPadding,
    this.rightPadding = Units.kLPadding,
    this.textInputType = TextInputType.text,
    this.suffix,
    this.suffixIcon,
    this.maxLines,
    this.minLines = 1,
    this.textInputAction,
    this.inputFormatters,
    this.textColor,
    this.style,
    this.textAlign = TextAlign.start,
    this.textAlignVertical = TextAlignVertical.center,
    this.alignLabelWithHint = false,
    this.errorStream,
    this.enabled = true,
    this.obscureText = false,
    this.enableSelection = true,
    this.textCapitalization = TextCapitalization.none,
    this.isMandatory = false,
    this.readOnly = false,
    this.backgroundColor,
    this.prefixIcon,
    this.errorMessageColor = AppColors.red,
    this.isRequired = false,
  });

  @override
  _BorderedTextFieldState createState() => _BorderedTextFieldState();
}

class _BorderedTextFieldState extends State<BorderedTextField> {
  final _controller = TextEditingController();
  FocusNode? _focusNode;

  @override
  void dispose() {
    super.dispose();
    if (widget.focusNode == null) _focusNode?.dispose();
    _focusNode!.removeListener(_onFocusChange);
    _controller.dispose();
  }

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode?.addListener(_onFocusChange);
    if (widget.textStream == null) {
      _controller.clear();
    } else {
      widget.textStream!.listen((value) {
        if (StringUtils.isNullOrEmpty(value)) {
          _controller.clear();
        } else if (_controller.text != value) {
          _controller.text = value!;
        }
      });
    }
  }

  void _onFocusChange() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (widget.errorStream != null) {
      return StreamBuilder<String?>(
        stream: widget.errorStream,
        builder: (context, snapshot) {
          return _getBodyLayout(context, snapshot.data);
        },
      );
    }
    return _getBodyLayout(context, null);
  }

  Widget _getBodyLayout(
    BuildContext context,
    String? error,
  ) {
    return Focus(
      focusNode: _focusNode,
      child: _getContentLayout(context, error),
    );
  }

  Widget _getContentLayout(
    BuildContext context,
    String? error,
  ) {
    final theme = Theme.of(context).colorScheme;
    // final bool hasFocus = _focusNode!.hasFocus;

    return AbsorbPointer(
      absorbing: !widget.enabled,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            readOnly: widget.readOnly,
            textCapitalization: widget.textCapitalization,
            textAlign: widget.textAlign,
            textAlignVertical: widget.textAlignVertical,
            minLines: widget.minLines,
            enableInteractiveSelection: widget.enableSelection,
            enabled: widget.enabled,
            controller: _controller,
            onTap: widget.onTap,
            cursorColor: Theme.of(context).textSelectionTheme.cursorColor,
            keyboardType: widget.textInputType,
            textInputAction: widget.textInputAction,
            maxLines: widget.maxLines,
            obscureText: widget.obscureText,
            inputFormatters: [
              ...?widget.inputFormatters,
            ],
            style: widget.style ??
                TextStyles.title2Bold(context)?.copyWith(
                  color: widget.textColor ?? theme.tertiary,
                ),
            decoration: InputDecoration(
              filled: true,
              fillColor: widget.backgroundColor,
              enabledBorder: OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(Units.kTextFieldBorderRadius),
                borderSide: BorderSide(
                  width: 1.5,
                  color: theme.onSecondaryContainer,
                ),
              ),
              disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(Units.kTextFieldBorderRadius),
                borderSide: BorderSide(
                  width: 1.5,
                  color: theme.onSecondaryContainer,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(Units.kTextFieldBorderRadius),
                borderSide: BorderSide(
                  width: 1.5,
                  color: theme.primary,
                ),
              ),
              // isDense: false,
              //isCollapsed: true,

              // errorText: error,
              // errorMaxLines: 3,
              contentPadding: const EdgeInsets.only(
                top: Units.kXSPadding,
                bottom: Units.kXSPadding,
                left: Units.kStandardPadding,
                right: Units.kStandardPadding,
              ),

              prefixIconConstraints:
                  const BoxConstraints(minHeight: 30, minWidth: 30),
              prefixIcon: widget.prefixIcon,
              suffixIconConstraints:
                  const BoxConstraints(minHeight: 20, minWidth: 20),
              suffix: widget.suffix,
              suffixIcon: widget.suffixIcon,
              labelStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.tundoraLight,
                  ),
              // errorStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
              //       color: AppColors.red,
              //     ),
              //  fillColor: AppColors.transparent,
              // fillColor: AppColors.gallery,
              // filled: !widget.enabled || widget.readOnly,
            ),
            onChanged: widget.onTextChanged != null
                ? (text) => widget.onTextChanged!(text)
                : null,
          ),
          if (StringUtils.isNotNullAndEmpty(error))
            Padding(
              padding: const EdgeInsets.only(
                top: Units.kXSPadding,
                right: Units.kLPadding,
              ),
              child: Text(
                error!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: widget.errorMessageColor,
                    ),
                textAlign: TextAlign.left,
              ),
            ),
        ],
      ),
    );
  }
}
