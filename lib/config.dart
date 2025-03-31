import 'dart:ui';

class AppConfig {
  static int numRowInt = 5;
  static int numDigit = 1;
  static int timeFlash = 500;
  static int timeout = 1000;
  static bool useNegNumber = false;
  static bool useContinuousMode = false;
  static int maxHistoryLength = 20;
  static List<List<int>> history = [];
  static List<bool?> success = [];
  static String ttsLocale = 'No sound';
  static List<String> languages = [];
  static String host = 'https://www.sorobanexam.org';
}

const green = Color(0xFF168362);
const lightBrown = Color(0xFFB39E8F);

const AppVersion = '0.0.1';
