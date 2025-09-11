import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/heavyweight_theme.dart';

class RadioSelector<T> extends StatelessWidget {
  final List<RadioOption<T>> options;
  final T? selectedValue;
  final Function(T) onChanged;
  final String? semanticLabel;
  
  const RadioSelector({
    Key? key,
    required this.options,
    required this.selectedValue,
    required this.onChanged,
    this.semanticLabel,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel ?? 'Radio button group',
      child: Column(
        children: options.map((option) {
          final isSelected = option.value == selectedValue;
          return Semantics(
            button: true,
            selected: isSelected,
            label: option.label,
            child: InkWell(
              onTap: () {
                try {
                  HapticFeedback.selectionClick();
                  onChanged(option.value);
                } catch (error) {
                  debugPrint('RadioSelector error: $error');
                }
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(bottom: HeavyweightTheme.spacingMd),
                padding: const EdgeInsets.all(HeavyweightTheme.spacingLg),
                width: double.infinity,
                constraints: const BoxConstraints(minHeight: 60), // Accessibility minimum
                decoration: BoxDecoration(
                  border: Border.all(
                    color: isSelected ? HeavyweightTheme.primary : HeavyweightTheme.secondary,
                    width: isSelected ? 2 : 1,
                  ),
                  color: isSelected ? HeavyweightTheme.surface : Colors.transparent,
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: HeavyweightTheme.primary.withValues(alpha: 0.08),
                            blurRadius: 8,
                            spreadRadius: 1,
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: isSelected ? HeavyweightTheme.primary : HeavyweightTheme.secondary,
                          width: 2,
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: isSelected
                          ? Center(
                              child: Container(
                                width: 12,
                                height: 12,
                                decoration: const BoxDecoration(
                                  color: HeavyweightTheme.primary,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(width: HeavyweightTheme.spacingMd),
                    Expanded(
                      child: Text(
                        option.label,
                        style: HeavyweightTheme.bodyLarge.copyWith(
                          color: isSelected ? HeavyweightTheme.primary : HeavyweightTheme.textSecondary,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class RadioOption<T> {
  final T value;
  final String label;
  
  const RadioOption({required this.value, required this.label});
}
