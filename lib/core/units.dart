enum HWUnit { kg, lb }

double kgToLb(double kg) => kg * 2.2046226218;
double lbToKg(double lb) => lb * 0.45359237;

String formatWeightForUnit(double kgValue, HWUnit unit, {int decimals = 1}) {
  final v = unit == HWUnit.kg ? kgValue : kgToLb(kgValue);
  return v.toStringAsFixed(decimals);
}

/// Parses a numeric input string assumed in the provided unit and returns KG.
double parseWeightInput(String input, HWUnit unit) {
  final v = double.tryParse(input.trim()) ?? 0.0;
  return unit == HWUnit.kg ? v : lbToKg(v);
}

