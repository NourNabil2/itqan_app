import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_player/video_player.dart';
import '../theme/colors.dart';
import '../utils/app_size.dart';

class VideoPlayerWidget extends StatefulWidget {
  final String videoPath;
  final Color? accentColor;
  final double? height;
  final double? width;

  const VideoPlayerWidget({
    super.key,
    required this.videoPath,
    this.accentColor,
    this.height,
    this.width,
  });

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;
  bool _showControls = true;
  bool _isPlaying = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _initializeVideoPlayer();
  }

  Future<void> _initializeVideoPlayer() async {
    try {
      _controller = VideoPlayerController.file(File(widget.videoPath));
      await _controller.initialize();

      _controller.addListener(() {
        if (mounted) {
          setState(() {
            _isPlaying = _controller.value.isPlaying;
          });

          // إخفاء الـ controls بعد 3 ثواني من عدم التفاعل
          if (_controller.value.isPlaying && _showControls) {
            Future.delayed(const Duration(seconds: 3), () {
              if (mounted && _controller.value.isPlaying) {
                setState(() {
                  _showControls = false;
                });
              }
            });
          }
        }
      });

      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'لا يمكن تشغيل الفيديو: ${e.toString()}';
        });
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _togglePlayPause() {
    setState(() {
      if (_controller.value.isPlaying) {
        _controller.pause();
      } else {
        _controller.play();
      }
      _showControls = true;
    });
  }

  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
    });
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.accentColor ?? ColorsManager.primaryColor;

    if (_errorMessage.isNotEmpty) {
      return _buildErrorWidget(color);
    }

    if (!_isInitialized) {
      return _buildLoadingWidget(color);
    }

    return Container(
      height: widget.height ?? 200.h,
      width: widget.width ?? double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(SizeApp.radiusSmall),
        color: Colors.black,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(SizeApp.radiusSmall),
        child: Stack(
          children: [
            // Video Player
            AspectRatio(
              aspectRatio: _controller.value.aspectRatio,
              child: VideoPlayer(_controller),
            ),

            // Tap to toggle controls
            GestureDetector(
              onTap: _toggleControls,
              child: Container(
                width: double.infinity,
                height: double.infinity,
                color: Colors.transparent,
              ),
            ),

            // Controls Overlay
            if (_showControls) _buildControlsOverlay(color),
          ],
        ),
      ),
    );
  }

  Widget _buildControlsOverlay(Color color) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withOpacity(0.3),
            Colors.transparent,
            Colors.black.withOpacity(0.5),
          ],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Top Controls
          Padding(
            padding: EdgeInsets.all(SizeApp.s8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: SizeApp.s8,
                    vertical: SizeApp.s4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(SizeApp.radiusSmall),
                  ),
                  child: Text(
                    'فيديو',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => _showFullScreenDialog(context),
                  icon: Icon(
                    Icons.fullscreen_rounded,
                    color: Colors.white,
                    size: 24.sp,
                  ),
                ),
              ],
            ),
          ),

          // Center Play/Pause Button
          Center(
            child: GestureDetector(
              onTap: _togglePlayPause,
              child: Container(
                padding: EdgeInsets.all(SizeApp.s16),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                  color: Colors.white,
                  size: 32.sp,
                ),
              ),
            ),
          ),

          // Bottom Controls (Progress bar and time)
          Padding(
            padding: EdgeInsets.all(SizeApp.s12),
            child: Column(
              children: [
                // Progress Bar
                VideoProgressIndicator(
                  _controller,
                  allowScrubbing: true,
                  colors: VideoProgressColors(
                    playedColor: color,
                    backgroundColor: Colors.white.withOpacity(0.3),
                    bufferedColor: Colors.white.withOpacity(0.5),
                  ),
                  padding: EdgeInsets.symmetric(vertical: SizeApp.s4),
                ),

                SizedBox(height: SizeApp.s8),

                // Time Display
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _formatDuration(_controller.value.position),
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      _formatDuration(_controller.value.duration),
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingWidget(Color color) {
    return Container(
      height: widget.height ?? 200.h,
      width: widget.width ?? double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(SizeApp.radiusSmall),
        color: color.withOpacity(0.1),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation(color),
            ),
            SizedBox(height: SizeApp.s12),
            Text(
              'جاري تحميل الفيديو...',
              style: TextStyle(
                fontSize: 14.sp,
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorWidget(Color color) {
    return Container(
      height: widget.height ?? 200.h,
      width: widget.width ?? double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(SizeApp.radiusSmall),
        color: ColorsManager.errorFill.withOpacity(0.1),
        border: Border.all(
          color: ColorsManager.errorFill.withOpacity(0.3),
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 48.sp,
              color: ColorsManager.errorFill,
            ),
            SizedBox(height: SizeApp.s12),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: SizeApp.s16),
              child: Text(
                _errorMessage,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: ColorsManager.errorFill,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: SizeApp.s12),
            TextButton.icon(
              onPressed: () {
                setState(() {
                  _errorMessage = '';
                  _isInitialized = false;
                });
                _initializeVideoPlayer();
              },
              icon: Icon(Icons.refresh_rounded, size: 16.sp),
              label: Text('إعادة المحاولة'),
              style: TextButton.styleFrom(
                foregroundColor: ColorsManager.errorFill,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFullScreenDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.black,
      builder: (context) => Dialog.fullscreen(
        backgroundColor: Colors.black,
        child: FullScreenVideoPlayer(
          controller: _controller,
          accentColor: widget.accentColor ?? ColorsManager.primaryColor,
        ),
      ),
    );
  }
}

class FullScreenVideoPlayer extends StatefulWidget {
  final VideoPlayerController controller;
  final Color accentColor;

  const FullScreenVideoPlayer({
    super.key,
    required this.controller,
    required this.accentColor,
  });

  @override
  State<FullScreenVideoPlayer> createState() => _FullScreenVideoPlayerState();
}

class _FullScreenVideoPlayerState extends State<FullScreenVideoPlayer> {
  bool _showControls = true;

  @override
  void initState() {
    super.initState();
    // إخفاء الـ controls تلقائياً بعد 3 ثواني
    _hideControlsAfterDelay();
  }

  void _hideControlsAfterDelay() {
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted && widget.controller.value.isPlaying) {
        setState(() {
          _showControls = false;
        });
      }
    });
  }

  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
    });
    if (_showControls) {
      _hideControlsAfterDelay();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: _toggleControls,
        child: Stack(
          children: [
            Center(
              child: AspectRatio(
                aspectRatio: widget.controller.value.aspectRatio,
                child: VideoPlayer(widget.controller),
              ),
            ),

            if (_showControls) ...[
              // Close Button
              Positioned(
                top: MediaQuery.of(context).padding.top + 16,
                right: 16,
                child: IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.close_rounded,
                      color: Colors.white,
                      size: 24.sp,
                    ),
                  ),
                ),
              ),

              // Play/Pause Button
              Center(
                child: GestureDetector(
                  onTap: () {
                    if (widget.controller.value.isPlaying) {
                      widget.controller.pause();
                    } else {
                      widget.controller.play();
                    }
                  },
                  child: Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      widget.controller.value.isPlaying
                          ? Icons.pause_rounded
                          : Icons.play_arrow_rounded,
                      color: Colors.white,
                      size: 48.sp,
                    ),
                  ),
                ),
              ),

              // Progress Bar
              Positioned(
                bottom: MediaQuery.of(context).padding.bottom + 32,
                left: 16,
                right: 16,
                child: VideoProgressIndicator(
                  widget.controller,
                  allowScrubbing: true,
                  colors: VideoProgressColors(
                    playedColor: widget.accentColor,
                    backgroundColor: Colors.white.withOpacity(0.3),
                    bufferedColor: Colors.white.withOpacity(0.5),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 8),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}