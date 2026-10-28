import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../core/localization/app_localizations_x.dart';
import '../../../core/widgets/prana_app_bar.dart';

/// The booking calendar (choose date and time, fill the medical forms) inside
/// the app.
class ConsultationScheduleScreen extends StatefulWidget {
  const ConsultationScheduleScreen({
    required this.url,
    super.key,
    this.title,
  });

  final String url;
  final String? title;

  @override
  State<ConsultationScheduleScreen> createState() =>
      _ConsultationScheduleScreenState();
}

class _ConsultationScheduleScreenState
    extends State<ConsultationScheduleScreen> {
  late final WebViewController _controller;
  final ValueNotifier<int> _progress = ValueNotifier<int>(0);

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(onProgress: (value) => _progress.value = value),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  void dispose() {
    _progress.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PranaAppBar(
        title: widget.title ?? context.l10n.scheduleTitle,
        showBack: true,
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          ValueListenableBuilder<int>(
            valueListenable: _progress,
            builder: (context, value, _) => value >= 100
                ? const SizedBox.shrink()
                : LinearProgressIndicator(value: value / 100),
          ),
        ],
      ),
    );
  }
}
