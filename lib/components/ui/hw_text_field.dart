import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/heavyweight_theme.dart';

class HWTextField extends StatefulWidget {
  final String label;
  final TextEditingController controller;
  final String? suffix;
  final String? hintText;
  final bool numeric;
  final double? min;
  final double? max;
  final ValueChanged<String>? onChanged;

  const HWTextField({
    super.key,
    required this.label,
    required this.controller,
    this.suffix,
    this.hintText,
    this.numeric = false,
    this.min,
    this.max,
    this.onChanged,
  });

  @override
  State<HWTextField> createState() => _HWTextFieldState();
}

class _HWTextFieldState extends State<HWTextField> {
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(_handleFocus);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocus);
    _focusNode.dispose();
    super.dispose();
  }

  void _handleFocus() {
    if (!_focusNode.hasFocus &&
        widget.numeric &&
        (widget.min != null || widget.max != null)) {
      final v = double.tryParse(widget.controller.text.trim());
      if (v != null) {
        double clamped = v;
        if (widget.min != null) {
          clamped = clamped < widget.min! ? widget.min! : clamped;
        }
        if (widget.max != null) {
          clamped = clamped > widget.max! ? widget.max! : clamped;
        }
        if (clamped != v) {
          widget.controller.text = _stripTrailingZero(clamped);
        }
      }
    }
  }

  String _stripTrailingZero(double x) {
    final s = x.toStringAsFixed(2);
    return s
        .replaceFirst(RegExp(r'\.00?'), '')
        .replaceFirst(RegExp(r'\.0$'), '');
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      focusNode: _focusNode,
      onChanged: widget.onChanged,
      keyboardType: widget.numeric
          ? const TextInputType.numberWithOptions(decimal: true)
          : TextInputType.text,
      inputFormatters: widget.numeric
          ? [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))]
          : null,
      style: HeavyweightTheme.bodyMedium,
      decoration: InputDecoration(
        labelText: widget.label,
        hintText: widget.hintText,
        suffixText: widget.suffix,
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: HeavyweightTheme.primary),
        ),
        enabledBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: Color(0xFF444444)),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: HeavyweightTheme.primary, width: 2),
        ),
        filled: true,
        fillColor: const Color(0xFF111111),
      ),
    );
  }
}
