// lib/utils/constants.dart
// Purpose: Defines app-wide constants (e.g., colors, strings).
// Location: lib/utils/
// Connection: Imported across the app for consistent theming and configuration.

import 'package:flutter/material.dart'; // Added import for Color class

class Constants {
  // Define colors as static final variables (Color is not a compile-time constant)
  static final primaryColor = Color(0xFFE74C3C); // Red
  static final secondaryColor = Color(0xFF2ECC71); // Green
  static final accentColor = Color(0xFFF1C40F); // Yellow
  static final backgroundColor = Color(0xFFFFFFFF); // White
  static final lightGray = Color(0xFFF5F5F5);
  static final darkGray = Color(0xFF333333);
}