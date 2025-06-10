import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class VideoFeedWidget extends StatefulWidget {
  final String cameraChannel;
  final void Function(WebViewController controller) onWebViewCreated;

  const VideoFeedWidget({
    super.key,
    required this.cameraChannel,
    required this.onWebViewCreated,
  });

  @override
  State<VideoFeedWidget> createState() => _VideoFeedWidgetState();
}

class _VideoFeedWidgetState extends State<VideoFeedWidget> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse(widget.cameraChannel));

    widget.onWebViewCreated(_controller);
  }

  @override
  void didUpdateWidget(VideoFeedWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.cameraChannel != widget.cameraChannel) {
      _controller.loadRequest(Uri.parse(widget.cameraChannel));
    }
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: WebViewWidget(controller: _controller));
  }
}
