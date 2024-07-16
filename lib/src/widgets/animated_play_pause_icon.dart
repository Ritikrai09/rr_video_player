part of 'package:rr_video_player/src/rr_player.dart';

class _AnimatedMuteUnmuteIcon extends StatefulWidget {
  final double? size;
  final String tag;

  const _AnimatedMuteUnmuteIcon({
    required this.tag,
    this.size,
  });

  @override
  State<_AnimatedMuteUnmuteIcon> createState() => _AnimatedMuteUnmuteIconState();
}

class _AnimatedMuteUnmuteIconState extends State<_AnimatedMuteUnmuteIcon>{
  @override
  Widget build(BuildContext context) {
   
   return GetBuilder<PodGetXVideoController>(
    tag: widget.tag,
    id: 'overlay',
    builder: (podCtr) {
      return  GetBuilder<PodGetXVideoController>(
        tag: widget.tag,
        id: 'volume',
        builder: (podCtr) => MaterialIconButton(
          toolTipMesg: podCtr.isMute
              ? podCtr.podPlayerLabels.unmute ??
                  'Unmute${kIsWeb ? ' (m)' : ''}'
              : podCtr.podPlayerLabels.mute ??
                  'Mute${kIsWeb ? ' (m)' : ''}',
          color: Colors.white,
          onPressed: podCtr.isOverlayVisible ? podCtr.toggleMute : null,
          child:onMuteUnmuteStateChange(podCtr) 
        ),
      );
    }
  );
    // return GetBuilder<PodGetXVideoController>(
    //   tag: widget.tag,
    //   id: 'overlay',
    //   builder: (podCtr) {
    //     return GetBuilder<PodGetXVideoController>(
    //       tag: widget.tag,
    //       id: 'podVideoState',
    //       builder: (f) => MaterialIconButton(
    //         toolTipMesg: f.isvideoPlaying
    //             ? podCtr.podPlayerLabels.pause ??
    //                 'Pause${kIsWeb ? ' (space)' : ''}'
    //             : podCtr.podPlayerLabels.play ??
    //                 'Play${kIsWeb ? ' (space)' : ''}',
    //         onPressed:
    //             podCtr.isOverlayVisible ? podCtr.togglePlayPauseVideo : null,
    //         child: onStateChange(podCtr),
    //       ),
    //     );
    //   },
    // );
  }

 Widget onMuteUnmuteStateChange(PodGetXVideoController podCtr) {
    if (kIsWeb) return Icon(podCtr.isMute
            ? Icons.volume_off_rounded
            : Icons.volume_up_rounded,
            size: widget.size,
          );
    if (podCtr.podVideoState == PodVideoState.loading) {
      return const SizedBox();
    } else {
      return  Icon(podCtr.isMute
                ? Icons.volume_off_rounded
                : Icons.volume_up_rounded,
                size: widget.size,
          );
    }
  }

}




class _AnimatedPlayPauseIcon extends StatefulWidget {
  final double? size;
  final String tag;

  const _AnimatedPlayPauseIcon({
    required this.tag,
    this.size,
  });

  @override
  State<_AnimatedPlayPauseIcon> createState() => _AnimatedPlayPauseIconState();
}

class _AnimatedPlayPauseIconState extends State<_AnimatedPlayPauseIcon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _payCtr;
  late PodGetXVideoController _podCtr;
  @override
  void initState() {
    _podCtr = Get.find<PodGetXVideoController>(tag: widget.tag);
    _payCtr = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
    _podCtr.addListenerId('podVideoState', playPauseListner);
    if (_podCtr.isvideoPlaying) {
      if (mounted) _payCtr.forward();
    }
    super.initState();
  }

  void playPauseListner() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (_podCtr.podVideoState == PodVideoState.playing) {
        if (mounted) _payCtr.forward();
      }
      if (_podCtr.podVideoState == PodVideoState.paused) {
        if (mounted) _payCtr.reverse();
      }
    });
  }

  @override
  void dispose() {
    // podLog('Play-pause-controller-disposed');
    _payCtr.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<PodGetXVideoController>(
      tag: widget.tag,
      id: 'overlay',
      builder: (podCtr) {
        return GetBuilder<PodGetXVideoController>(
          tag: widget.tag,
          id: 'podVideoState',
          builder: (f) => MaterialIconButton(
            toolTipMesg: f.isvideoPlaying
                ? podCtr.podPlayerLabels.pause ??
                    'Pause${kIsWeb ? ' (space)' : ''}'
                : podCtr.podPlayerLabels.play ??
                    'Play${kIsWeb ? ' (space)' : ''}',
            onPressed:
                podCtr.isOverlayVisible ? podCtr.togglePlayPauseVideo : null,
            child: onStateChange(podCtr),
          ),
        );
      },
    );
  }

  Widget onStateChange(PodGetXVideoController podCtr) {
    if (kIsWeb) return _playPause(podCtr);
    if (podCtr.podVideoState == PodVideoState.loading) {
      return const SizedBox();
    } else {
      return _playPause(podCtr);
    }
  }

  Widget _playPause(PodGetXVideoController podCtr) {
    return AnimatedIcon(
      icon: AnimatedIcons.play_pause,
      progress: _payCtr,
      color: Colors.white,
      size: widget.size,
    );
  }
}
