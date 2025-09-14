class HWStrings {
  static String recorded(int reps, int pct) => "RECORDED: $reps · ADJUSTING ${pct >= 0 ? "+" : ""}$pct%";
  static String locked(double kg) => "WORKING WEIGHT LOCKED: ${kg.toStringAsFixed(1)} KG";
  static String setOf(int i, int n, double kg) => "SET $i OF $n · ${kg.toStringAsFixed(1)} KG";
  static String rest(Duration d) => "REST ${d.inMinutes}:${(d.inSeconds % 60).toString().padLeft(2, '0')}";
  static const sessionComplete = "SESSION COMPLETE";
  static String load(double kg) => "LOAD: ${kg.toStringAsFixed(1)} KG";
  static String header(String exercise, int set) => "$exercise · SET $set";
}

