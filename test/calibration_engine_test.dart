import 'dart:math' as math;
import 'package:flutter_test/flutter_test.dart';

double _median(List<double> xs) {
  xs.sort();
  final n = xs.length;
  if (n == 0) return 0;
  if (n % 2 == 1) return xs[n >> 1];
  return (xs[n ~/ 2 - 1] + xs[n ~/ 2]) / 2.0;
}

double computeNextCalibration({
  required double current,
  required int reps,
  required int attempt,
  double inc = 2.5,
  double minClamp = 20.0,
}) {
  final r = reps.clamp(0, 15);
  if (r == 5) return current;
  final est1RM_e = current * (1 + r / 30.0);
  final est1RM_b = current * 36.0 / (37 - (r == 0 ? 1 : r));
  final est1RM = _median([est1RM_e, est1RM_b]);
  final tgt_e = est1RM / (1 + 5 / 30.0);
  final tgt_b = est1RM * (37 - 5) / 36.0;
  double target = _median([tgt_e, tgt_b]);
  double jump = target / (current == 0 ? 1 : current);
  if (attempt <= 1 && reps >= 12) {
    jump = jump.clamp(1.0, 1.55);
  } else if (attempt <= 1 && reps <= 2) {
    jump = jump.clamp(0.45, 1.0);
  } else {
    jump = jump.clamp(0.75, 1.25);
  }
  double next = current * jump;
  if (attempt == 1 && (target / (current == 0 ? 1 : current)) > 1.35) {
    next = math.sqrt(current * target);
  }
  final rounded = (next / inc).round() * inc;
  return rounded < minClamp ? minClamp : rounded;
}

void main() {
  test('Bench 60x12 suggests around 75-85 kg', () {
    final next = computeNextCalibration(current: 60, reps: 12, attempt: 1, inc: 2.5, minClamp: 20);
    expect(next >= 75 && next <= 85, true);
  });

  test('OHP 30x3 drops near 27.5 with 1.25 inc', () {
    final next = computeNextCalibration(current: 30, reps: 3, attempt: 1, inc: 1.25, minClamp: 20);
    expect(next <= 30, true);
    expect((next / 1.25).round() * 1.25, next);
  });

  test('Clamp enforces min 20kg for non-BW', () {
    final next = computeNextCalibration(current: 10, reps: 0, attempt: 1, inc: 2.5, minClamp: 20);
    expect(next, 20);
  });
}

