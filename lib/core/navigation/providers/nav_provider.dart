import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Tracks the currently selected bottom navigation index.
final navProvider = StateProvider<int>((ref) => 0);

/// Global key for the root Scaffold in MainScaffold so nested pages
/// can open the drawer even when they have their own inner Scaffold.
final mainScaffoldKey = GlobalKey<ScaffoldState>();
