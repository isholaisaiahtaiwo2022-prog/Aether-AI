
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class AnimatedOrb extends StatefulWidget {
  const AnimatedOrb({
    super.key,
    this.size = 1000,
  });

  final double size;

  @override
  State<AnimatedOrb> createState() => _AnimatedOrbState();
}

class _AnimatedOrbState extends State<AnimatedOrb> {
  late final VideoPlayerController _controller;
  late final Future<void> _initializeVideo;

  @override
  void initState() {
    super.initState();

    _controller = VideoPlayerController.asset(
      'lib/assets/animations/aether_orb.mp4',
    );

    _initializeVideo = _initialize();
  }

  Future<void> _initialize() async {
    await _controller.initialize();
    await _controller.setLooping(true);
    await _controller.setVolume(0);
    await _controller.play();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: FutureBuilder<void>(
        future: _initializeVideo,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Icon(
                Icons.error_outline,
                color: Colors.white54,
              ),
            );
          }

          if (snapshot.connectionState != ConnectionState.done) {
            return const SizedBox.shrink();
          }

          return FittedBox(
            fit: BoxFit.cover,
            child: SizedBox(
              width: _controller.value.size.width,
              height: _controller.value.size.height,
              child: VideoPlayer(_controller),
            ),
          );
        },
      ),
    );
  }
}
