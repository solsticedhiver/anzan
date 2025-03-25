class AppConfig {
  static int numRowInt = 5;
  static int numDigit = 1;
  static int timeFlash = 500;
  static int timeout = 1000;
  static bool useNegNumber = false;
  static bool useContinuousMode = false;
  static int maxHistoryLength = 20;
  static List<List<int>> history = [];
  static String ttsLocale = 'en-US';
  static List<String> languages = [];
  //static String host = 'https://www.sorobanexam.org';
  static String host = 'http://127.0.0.1:5000';
}
