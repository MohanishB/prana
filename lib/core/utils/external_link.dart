import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../localization/app_localizations_x.dart';

/// Opens a web address, email (mailto:) or phone (tel:) link outside the app and
/// tells the person when it cannot be opened. Any other kind of link is refused.
Future<void> openExternalLink(BuildContext context, String url) async {
  final messenger = ScaffoldMessenger.of(context);
  final message = context.l10n.couldNotOpenLink;
  final uri = Uri.tryParse(url.trim());
  var opened = false;
  if (uri != null && const {'http', 'https', 'mailto', 'tel'}.contains(uri.scheme)) {
    try {
      opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    } on Object {
      opened = false;
    }
  }
  if (!opened) {
    messenger.showSnackBar(SnackBar(content: Text(message)));
  }
}
