import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Tracks the currently selected bottom navigation index.
final navProvider = StateProvider<int>((ref) => 0);
