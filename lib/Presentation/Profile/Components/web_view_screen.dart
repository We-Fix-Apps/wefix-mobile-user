import 'package:flutter/material.dart';

import 'package:webview_flutter/webview_flutter.dart';
import 'package:wefix/Data/Constant/theme/color_constant.dart';

class WebviewScreen extends StatelessWidget {
  final String? url;
  final String? title;

  const WebviewScreen({super.key, this.url, this.title});

  WebViewController _createController(BuildContext context) {
    final controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..clearCache()
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) => const CircularProgressIndicator(),
          onPageFinished: (_) => const CircularProgressIndicator(),
          onWebResourceError: (_) => const CircularProgressIndicator(),
        ),
      )
      ..loadRequest(Uri.parse(url ?? 'https://example.com'));
    return controller;
  }

  @override
  Widget build(BuildContext context) {
    final controller = _createController(context);
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: AppColors(context).primaryColor.withOpacity(0.45),
        title: Text(
          title ?? '',
          style: const TextStyle(color: AppColors.blackColor1),
        ),
      ),
      body: WebViewWidget(controller: controller),
    );
  }
}
