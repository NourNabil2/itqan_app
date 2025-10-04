import 'package:flutter/material.dart';
import 'package:itqan_gym/core/theme/colors.dart';

class ErrorContainer extends StatelessWidget {
  final String? generalError;
  final Map<String, String>? fieldErrors;
  final List<String>? errors;
  final Color? errorColor;
  final Color? backgroundColor;
  final Color? borderColor;
  final IconData? errorIcon;
  final double? iconSize;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BorderRadius? borderRadius;
  final double? borderWidth;
  final TextStyle? textStyle;
  final double? fontSize;
  final bool showIcon;
  final Widget? customIcon;
  final CrossAxisAlignment? crossAxisAlignment;

  const ErrorContainer({
    Key? key,
    this.generalError,
    this.fieldErrors,
    this.errors,
    this.errorColor,
    this.backgroundColor,
    this.borderColor,
    this.errorIcon = Icons.error_outline,
    this.iconSize = 20,
    this.padding = const EdgeInsets.all(12),
    this.margin = const EdgeInsets.only(bottom: 16),
    this.borderRadius,
    this.borderWidth = 1,
    this.textStyle,
    this.fontSize = 14,
    this.showIcon = true,
    this.customIcon,
    this.crossAxisAlignment = CrossAxisAlignment.start,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const defaultErrorColor = ColorsManager.errorFill;

    // Collect all errors
    List<String> allErrors = _collectAllErrors();

    // Return empty widget if no errors
    if (allErrors.isEmpty) {
      return const SizedBox.shrink();
    }

    final effectiveErrorColor = errorColor ?? defaultErrorColor;
    final effectiveBackgroundColor = backgroundColor ??
        effectiveErrorColor.withOpacity(0.1);
    final effectiveBorderColor = borderColor ?? effectiveErrorColor;
    final effectiveBorderRadius = borderRadius ??
        BorderRadius.circular(8);

    return Container(
      width: double.infinity,
      padding: padding,
      margin: margin,
      decoration: BoxDecoration(
        color: effectiveBackgroundColor,
        border: Border.all(
          color: effectiveBorderColor,
          width: borderWidth!,
        ),
        borderRadius: effectiveBorderRadius,
      ),
      child: Row(
        crossAxisAlignment: crossAxisAlignment!,
        children: [
          if (showIcon) ...[
            customIcon ?? Icon(
              errorIcon,
              color: effectiveErrorColor,
              size: iconSize,
            ),
            const SizedBox(width: 8),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: allErrors.asMap().entries.map((entry) {
                final index = entry.key;
                final error = entry.value;
                return Padding(
                  padding: EdgeInsets.only(
                    bottom: index < allErrors.length - 1 ? 4 : 0,
                  ),
                  child: Text(
                    error,
                    style: textStyle ?? TextStyle(
                      color: effectiveErrorColor,
                      fontSize: fontSize,
                    ),
                    softWrap: true, // يلف الأسطر
                    overflow: TextOverflow.visible, // مايقطعش النص
                    maxLines: null, // يخلي النص يكبر لعدد أسطر غير محدود
                  )

                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  List<String> _collectAllErrors() {
    List<String> allErrors = [];

    // Add general error
    if (generalError != null && generalError!.isNotEmpty) {
      allErrors.add(generalError!);
    }

    // Add field-specific errors
    if (fieldErrors != null) {
      fieldErrors!.forEach((field, error) {
        if (error.isNotEmpty) {
          allErrors.add(error);
        }
      });
    }

    // Add direct errors list
    if (errors != null) {
      allErrors.addAll(errors!.where((error) => error.isNotEmpty));
    }

    return allErrors;
  }
}

// Extension for easy usage with validation results
extension ErrorContainerExtension on Map<String, String> {
  Widget toErrorContainer({
    String? generalError,
    Color? errorColor,
    EdgeInsetsGeometry? margin,
    EdgeInsetsGeometry? padding,
  }) {
    return ErrorContainer(
      generalError: generalError,
      fieldErrors: this,
      errorColor: errorColor,
      margin: margin,
      padding: padding,
    );
  }
}

// Predefined error container styles
class ErrorContainerStyles {
  static ErrorContainer minimal({
    required List<String> errors,
    Color? errorColor,
  }) {
    return ErrorContainer(
      errors: errors,
      errorColor: errorColor,
      showIcon: false,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      margin: const EdgeInsets.only(bottom: 8),
      borderWidth: 0,
      backgroundColor: errorColor?.withOpacity(0.05),
    );
  }

  static ErrorContainer outlined({
    required List<String> errors,
    Color? errorColor,
  }) {
    return ErrorContainer(
      errors: errors,
      errorColor: errorColor,
      backgroundColor: Colors.transparent,
      borderWidth: 1.5,
      padding: const EdgeInsets.all(16),
    );
  }

  static ErrorContainer filled({
    required List<String> errors,
    Color? errorColor,
  }) {
    return ErrorContainer(
      errors: errors,
      errorColor: errorColor,
      borderWidth: 0,
      padding: const EdgeInsets.all(16),
      borderRadius: BorderRadius.circular(12),
    );
  }

  static ErrorContainer compact({
    required String error,
    Color? errorColor,
  }) {
    return ErrorContainer(
      errors: [error],
      errorColor: errorColor,
      showIcon: false,
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
      margin: const EdgeInsets.only(bottom: 8),
      fontSize: 13,
      borderRadius: BorderRadius.circular(6),
    );
  }
}

// Specialized error containers for common use cases
class FormErrorContainer extends ErrorContainer {
  const FormErrorContainer({
    Key? key,
    String? generalError,
    Map<String, String>? fieldErrors,
  }) : super(
    key: key,
    generalError: generalError,
    fieldErrors: fieldErrors,
    margin: const EdgeInsets.only(bottom: 12),
    borderRadius: const BorderRadius.all(Radius.circular(8)),
  );
}

class ValidationErrorContainer extends ErrorContainer {
  const ValidationErrorContainer({
    Key? key,
    required List<String> validationErrors,
    Color? errorColor,
  }) : super(
    key: key,
    errors: validationErrors,
    errorColor: errorColor,
    errorIcon: Icons.warning_outlined,
    padding: const EdgeInsets.all(14),
    margin: const EdgeInsets.symmetric(vertical: 8),
  );
}

class NetworkErrorContainer extends ErrorContainer {
  NetworkErrorContainer({
    Key? key,
    required String networkError,
    Color? errorColor,
  }) : super(
    key: key,
    errors: [networkError],
    errorColor: errorColor,
    errorIcon: Icons.wifi_off_outlined,
    padding: const EdgeInsets.all(16),
    backgroundColor: Colors.red.shade50,
    borderColor: Colors.red.shade200,
  );
}