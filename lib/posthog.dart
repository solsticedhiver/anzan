import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

const String POSTHOG_API_KEY = 'phc_ckgtNDKD1zmDpeRvbmDNjIVfgIF1pyhDg2ATUVEsSaT';

const String POSTHOG_API = 'https://eu.i.posthog.com/i/v0/e/';

const Map<String, String>? POSTHOG_HEADERS = {'Content-Type': 'application/json'};

Future<void> posthog(String distinctId, String event, Map<String, String> properties) async {
  var payload = {
    'api_key': POSTHOG_API_KEY,
    'event': event,
    'distinct_id': distinctId,
    'properties': properties,
  };
  final req = await http
      .post(Uri.parse(POSTHOG_API), headers: POSTHOG_HEADERS, body: jsonEncode(payload))
      .timeout(const Duration(seconds: 10));
  if (req.statusCode != 200) {
    debugPrint('Error posting to PostHog: ${req.body}');
  }
}
