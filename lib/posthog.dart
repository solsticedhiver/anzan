import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

const String posthogApiKey = 'phc_ckgtNDKD1zmDpeRvbmDNjIVfgIF1pyhDg2ATUVEsSaT';

const String posthogApiUrl = 'https://eu.i.posthog.com/i/v0/e/';

const Map<String, String> posthogHeaders = {'Content-Type': 'application/json'};

Future<void> posthog(String distinctId, String event, Map<String, String> properties) async {
  var payload = {
    'api_key': posthogApiKey,
    'event': event,
    'distinct_id': distinctId,
    'properties': properties,
  };
  final req = await http
      .post(Uri.parse(posthogApiUrl), headers: posthogHeaders, body: jsonEncode(payload))
      .timeout(const Duration(seconds: 5));
  if (req.statusCode != 200) {
    debugPrint('Error posting to PostHog: ${req.body}');
  }
}
