import 'package:flutter/material.dart';

/// Small localization seam for the first release; strings can move into ARB
/// files without changing the app's routing or state layers.
class AppLocalizations {
  static const supportedLocales = <Locale>[Locale('en')];

  const AppLocalizations();

  String get appName => 'Rigel Space Saver';
}
