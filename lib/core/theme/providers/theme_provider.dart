import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Controls the app-wide dark mode toggle.
final themeProvider = StateProvider<bool>((ref) => false);
