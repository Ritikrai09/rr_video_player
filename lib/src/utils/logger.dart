import 'dart:developer';

import '../../rr_video_player.dart';

void podLog(String message) =>
    RRVideoPlayer.enableLogs ? log(message, name: 'RR') : null;
