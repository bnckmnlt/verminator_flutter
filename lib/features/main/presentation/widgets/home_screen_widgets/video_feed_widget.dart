import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class VideoFeedWidget extends StatefulWidget {
  final String cameraChannel;

  const VideoFeedWidget({
    super.key,
    required this.cameraChannel,
  });

  @override
  State<VideoFeedWidget> createState() => _VideoFeedWidgetState();
}

class _VideoFeedWidgetState extends State<VideoFeedWidget> {
  late WebViewController _videoController;

  @override
  void initState() {
    super.initState();
    _videoController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.disabled)
      ..loadRequest(Uri.parse(widget.cameraChannel));
  }

  @override
  void didUpdateWidget(VideoFeedWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.cameraChannel != widget.cameraChannel) {
      _videoController.loadRequest(Uri.parse(widget.cameraChannel));
    }
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: WebViewWidget(controller: _videoController));
  }
}
