import 'dart:io';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;

String detectedSystemLocale = Intl.canonicalizedLocale(Platform.localeName);

String getDistinctId() {
  const uuid = Uuid();
  return uuid.v7();
}

String getHostname() {
  return 'unknown';
}

http.Client httpClient = http.Client();
