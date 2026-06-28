enum BiometricTimeout {
  immediately('Immediately', Duration.zero),
  oneMinute('After 1 minute', Duration(minutes: 1)),
  fiveMinutes('After 5 minutes', Duration(minutes: 5)),
  fifteenMinutes('After 15 minutes', Duration(minutes: 15)),
  thirtyMinutes('After 30 minutes', Duration(minutes: 30)),
  never('Never while app remains open', Duration(days: 3650)); // effectively never

  final String label;
  final Duration duration;

  const BiometricTimeout(this.label, this.duration);

  static BiometricTimeout fromString(String? val) {
    if (val == null) return BiometricTimeout.immediately;
    return BiometricTimeout.values.firstWhere(
      (e) => e.name == val || e.label == val,
      orElse: () => BiometricTimeout.immediately,
    );
  }
}
