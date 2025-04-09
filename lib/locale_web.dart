import 'dart:js_interop';
import 'package:intl/intl.dart';

@JS('navigator')
extension type NavigatorJS._(JSObject _) implements JSObject {
  external NavigatorJS();
  external static String language;
  external static String languages;
}

String detectedSystemLocale = Intl.canonicalizedLocale(NavigatorJS.language);
