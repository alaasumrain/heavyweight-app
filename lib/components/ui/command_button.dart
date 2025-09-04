import 'package:flutter/material.dart';
import '../../core/theme/heavyweight_theme.dart';

enum ButtonVariant { primary, secondary, accent, danger }
enum ButtonSize { large, medium, small }

class CommandButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final ButtonVariant variant;
  final ButtonSize size;
  final bool isDisabled;
  final bool isLoading;
  
  const CommandButton({
    Key? key,
    required this.text,
    this.onPressed,
    this.variant = ButtonVariant.primary,
    this.size = ButtonSize.large,
    this.isDisabled = false,
    this.isLoading = false,
  }) : super(key: key);
  
  // Legacy constructor for backward compatibility
  const CommandButton.inverse({
    Key? key,
    required this.text,
    this.onPressed,
    this.isDisabled = false,
    this.isLoading = false,
  }) : variant = ButtonVariant.primary,
       size = ButtonSize.large,
       super(key: key);
  
  @override
  Widget build(BuildContext context) {
    final isEffectivelyDisabled = isDisabled || isLoading || onPressed == null;
    
    return GestureDetector(
      onTap: isEffectivelyDisabled ? null : onPressed,
      child: Container(
        width: double.infinity,
        height: _getHeight(),
        decoration: _getDecoration(isEffectivelyDisabled),
        child: Center(
          child: isLoading 
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: _getTextColor(isEffectivelyDisabled),
                  strokeWidth: 2,
                ),
              )
            : Text(
                text,
                style: _getTextStyle(isEffectivelyDisabled),
              ),
        ),
      ),
    );
  }
  
  double _getHeight() {
    switch (size) {
      case ButtonSize.large:
        return HeavyweightTheme.buttonHeight;
      case ButtonSize.medium:
        return HeavyweightTheme.buttonHeightSmall;
      case ButtonSize.small:
        return 40.0;
    }
  }
  
  BoxDecoration _getDecoration(bool isEffectivelyDisabled) {
    if (isEffectivelyDisabled) {
      return BoxDecoration(
        color: Colors.transparent,
        border: Border.all(color: HeavyweightTheme.textDisabled),
      );
    }
    
    switch (variant) {
      case ButtonVariant.primary:
        return BoxDecoration(
          color: HeavyweightTheme.primary,
          border: Border.all(color: HeavyweightTheme.primary),
        );
      case ButtonVariant.secondary:
        return BoxDecoration(
          color: Colors.transparent,
          border: Border.all(color: HeavyweightTheme.primary),
        );
      case ButtonVariant.accent:
        return BoxDecoration(
          color: HeavyweightTheme.accent,
          border: Border.all(color: HeavyweightTheme.accent),
        );
      case ButtonVariant.danger:
        return BoxDecoration(
          color: HeavyweightTheme.error,
          border: Border.all(color: HeavyweightTheme.error),
        );
    }
  }
  
  Color _getTextColor(bool isEffectivelyDisabled) {
    if (isEffectivelyDisabled) {
      return HeavyweightTheme.textDisabled;
    }
    
    switch (variant) {
      case ButtonVariant.primary:
        return HeavyweightTheme.onPrimary;
      case ButtonVariant.secondary:
        return HeavyweightTheme.primary;
      case ButtonVariant.accent:
        return HeavyweightTheme.background;
      case ButtonVariant.danger:
        return HeavyweightTheme.primary;
    }
  }
  
  TextStyle _getTextStyle(bool isEffectivelyDisabled) {
    final baseStyle = size == ButtonSize.large 
        ? HeavyweightTheme.labelLarge 
        : HeavyweightTheme.labelMedium;
    
    return baseStyle.copyWith(
      color: _getTextColor(isEffectivelyDisabled),
    );
  }
}