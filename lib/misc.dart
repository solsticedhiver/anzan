import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';

import 'config.dart';

final htmlStyle = {
  "p": Style(
      fontSize: FontSize.large,
      padding: HtmlPaddings.only(top: 5.0, bottom: 5.0, left: 10.0, right: 10.0),
      margin: Margins.only(top: 0.0, bottom: 0.0)),
  "p.green": Style(
      fontSize: FontSize.large,
      fontWeight: FontWeight.bold,
      padding: HtmlPaddings.only(top: 5.0, bottom: 5.0, left: 10.0, right: 10.0),
      margin: Margins.only(top: 0.0, bottom: 0.0),
      color: green),
  "h1":
      Style(padding: HtmlPaddings.only(bottom: 0.0, top: 0.0, left: 5.0), margin: Margins.only(bottom: 0.0, top: 0.0)),
  "h3":
      Style(padding: HtmlPaddings.only(bottom: 0.0, top: 0.0, left: 10.0), margin: Margins.only(bottom: 0.0, top: 0.0)),
  "a": Style(color: green, textDecorationColor: green),
};

class PrivacyPolicy extends StatelessWidget {
  const PrivacyPolicy({super.key});

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(title: const Center(child: Text('Privacy policy')), children: [
      Container(width: 550, margin: const EdgeInsets.all(5.0), child: Html(data: '''
<h3>No personal data</h3>
<p class="green">We don't collect personal data because we do not ask for it, and you do not provide it.</p>

<p>So this privacy notice is very short because it doesn't have much ground to cover.</p>

<h3>Usage data collection</h3>
<p>If you have <em>opted in</em> and allowed us to collect <strong>usage data</strong>, we record the interactions you have with our app:</p>
<ul>
<li>When the app is launched</li>
<li>When you press a button, like <em>play</em> or <em>replay</em>; This may not be limited to those buttons</li>
<li>When you change a setting</li>
</ul>

<p>Each time such an event occurs, a request is sent to the <em>PostHog API</em>. Such requests can happen in bulk, meaning that the events are collected in small subsets, and sent all at once in a single request.</p>
<p>During that interaction with the PostHog API server, your IP address is known, and is recorded as part of that process. It is stored alongside the collected data.</p>
<p>The GDPR states that the IP addresses is a personnal data, but there is an exception for the IP address given how the protocols on internet work.</p>

<p><em>We use these collected usage data to make statistics, and learn how the app is used by our users, and how it could be improved.</em></p>


''', style: htmlStyle)),
      Row(children: [
        const Expanded(child: SizedBox.shrink()),
        SizedBox(
            width: 200,
            child: Center(
                child: SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: Text('Dismiss',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, fontSize: Theme.of(context).textTheme.labelLarge!.fontSize! + 2.0)),
            ))),
      ]),
    ]);
  }
}

class UsageDataDialog extends StatelessWidget {
  const UsageDataDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(title: const Center(child: Text('Usage data collection')), children: [
      Container(
          width: 500,
          margin: const EdgeInsets.all(5.0),
          child: Html(
            data: '''
<!--<h1>Telemetry</h1>-->
<p>To help improve the <strong>Flash Anzan</strong> <em>app</em>, you can allow the <em>development team</em> to collect <strong>usage data</strong> (i.e. how you interact with the app).</p>

<p>Read our <a href="/privacy">privacy policy</a> to learn more on how we use usage data.</p>

<p>If you change your mind later on, you can go to the <strong>Settings</strong>, and change the state of the <em>Telemetry</em> checkbox.</p>
<p class="green">Do you accept usage data collection?</p>
''',
            style: htmlStyle,
            onLinkTap: (url, attributes, element) {
              if (url == "/privacy") {
                showDialog(
                    context: context,
                    builder: (context) {
                      return const PrivacyPolicy();
                    });
              }
            },
          )),
      Row(mainAxisAlignment: MainAxisAlignment.end, children: [
        SimpleDialogOption(
          onPressed: () {
            Navigator.pop(context, true);
          },
          child: Text('I accept',
              style: TextStyle(
                  fontWeight: FontWeight.bold, fontSize: Theme.of(context).textTheme.labelLarge!.fontSize! + 2.0)),
        ),
        SimpleDialogOption(
          onPressed: () {
            Navigator.pop(context, false);
          },
          child: const Text('No thanks'),
        )
      ]),
    ]);
  }
}
