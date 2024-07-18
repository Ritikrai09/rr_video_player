import 'package:flutter/material.dart';
import 'package:rr_video_player/src/injection.dart';
import 'package:rr_video_player/src/service/navigation_service.dart';

/// Global BuildContext
final BuildContext context =
    getIt<NavigationService>().navigationKey.currentContext!;
