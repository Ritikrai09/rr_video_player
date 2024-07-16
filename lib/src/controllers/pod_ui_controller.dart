part of 'pod_getx_video_controller.dart';

class _RRUiController extends _PodBaseController {
  bool alwaysShowProgressBar = true;
  RRProgressBarConfig podProgressBarConfig = const RRProgressBarConfig();
  Widget Function(OverLayOptions options)? overlayBuilder;
  Widget? videoTitle;
  DecorationImage? videoThumbnail;

  /// Callback when fullscreen mode changes
  Future<void> Function(bool isFullScreen)? onToggleFullScreen;

  /// Builder for custom loading widget
  WidgetBuilder? onLoading;

  ///video player labels
  RRPlayerLabels podPlayerLabels = const RRPlayerLabels();
}
