import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_platform_interface/webview_flutter_platform_interface.dart';

class VideoStreamScreen extends StatelessWidget {
  final String streamUrl;

  const VideoStreamScreen({required this.streamUrl, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CAMERA'),
      ),
      body: ViewWidget(streamUrl: streamUrl),
    );
  }
}

class ViewWidget extends StatefulWidget {
  final String streamUrl;

  const ViewWidget({required this.streamUrl, super.key});

  @override
  State<ViewWidget> createState() => _ViewWidgetState();
}

class _ViewWidgetState extends State<ViewWidget> {
  late final PlatformWebViewController _controller;
  @override
  void initState() {
    super.initState();

    _controller = PlatformWebViewController(
      const PlatformWebViewControllerCreationParams(),
    )..loadRequest(
        LoadRequestParams(
          uri: Uri.parse(widget.streamUrl),
          // headers: {
          //   'Access-Control-Allow-Origin': '*',
          //   'Content-Security-Policy':
          //       'frame-ancestors ' 'self' ' ${widget.streamUrl}',
          //   'X-Frame-Options': 'ALLOW-FROM ${widget.streamUrl}'
          // },
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.5,
      child: PlatformWebViewWidget(
        PlatformWebViewWidgetCreationParams(controller: _controller),
      ).build(context),
    );
  }
}
