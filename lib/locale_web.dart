import 'dart:js_interop';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'dart:convert';
import 'posthog.dart' show posthogApiKey;
import 'package:http/browser_client.dart';
import 'package:http/http.dart' as http show Client;

@JS('navigator')
extension type NavigatorJS._(JSObject _) implements JSObject {
  external NavigatorJS();
  external static String language;
  external static String languages;
}

@JS('localStorage')
extension type LocalStorageJS._(JSObject _) implements JSObject {
  external LocalStorageJS();
  external static String? getItem(String keyName);
}

@JS('window.location')
extension type LocationJS(JSObject _) implements JSObject {
  external static String hostname;
}

String detectedSystemLocale = Intl.canonicalizedLocale(NavigatorJS.language);

String getDistinctId() {
  final String? posthog = LocalStorageJS.getItem('ph_${posthogApiKey}_posthog');
  String distinctId;
  if (posthog != null) {
    distinctId = jsonDecode(posthog)['distinct_id'];
  } else {
    const uuid = Uuid();
    distinctId = uuid.v7();
  }
  return distinctId;
}

String getHostname() {
  return LocationJS.hostname;
}

// for the web, we need this quirk to get cookies
http.Client httpClient = BrowserClient()..withCredentials = true;
