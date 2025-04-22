import 'dart:io';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

String detectedSystemLocale = Intl.canonicalizedLocale(Platform.localeName);

String getDistinctId() {
  const uuid = Uuid();
  return uuid.v7();
}
