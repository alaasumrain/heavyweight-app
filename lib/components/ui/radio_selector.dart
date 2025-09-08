import 'package:flutter/material.dart';
import '../../core/theme/heavyweight_theme.dart';

class RadioSelector<T> extends StatelessWidget {
  final List<RadioOption<T>> options;
  final T? selectedValue;
  final Function(T) onChanged;
  
  const RadioSelector({
    Key? key,
    required this.options,
    required this.selectedValue,
    required this.onChanged,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: options.map((option) {
        final isSelected = option.value == selectedValue;
        return GestureDetector(
          onTap: () => onChanged(option.value),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.only(bottom: 20),
            padding: const EdgeInsets.all(24),
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border.all(
                color: isSelected ? Colors.white : Colors.grey.shade700,
                width: isSelected ? 3 : 1,
              ),
              color: isSelected ? Colors.white.withOpacity(0.1) : Colors.transparent,
              boxShadow: isSelected ? [
                BoxShadow(
                  color: Colors.white.withOpacity(0.2),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ] : null,
            ),
            child: Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: isSelected ? Colors.white : Colors.grey.shade600,
                      width: 2,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: isSelected ? Center(
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ) : null,
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Text(
                    option.label,
                    style: HeavyweightTheme.bodyLarge.copyWith(
                      color: isSelected ? HeavyweightTheme.primary : HeavyweightTheme.textSecondary,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class RadioOption<T> {
  final T value;
  final String label;
  
  const RadioOption({required this.value, required this.label});
}