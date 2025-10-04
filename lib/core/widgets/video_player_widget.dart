// lib/core/widgets/video_player_widget.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:itqan_gym/core/language/app_localizations.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:video_player/video_player.dart';

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
  late final Player _player;
  late final VideoController _controller;

  bool _isInitialized = false;
  bool _showControls = true;
  bool _isPlaying = false;
  double _playbackSpeed = 1.0;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initPlayer();
  }

  Future<void> _initPlayer() async {
    try {
      final file = File(widget.videoPath);
      if (!await file.exists()) {
        throw Exception('Video file not found');
      }

      _player = Player(configuration: const PlayerConfiguration());
      _controller = VideoController(_player);

      // Listen to player state
      _player.stream.playing.listen((playing) {
        if (mounted) setState(() => _isPlaying = playing);
      });

      _player.stream.position.listen((position) {
        if (mounted) setState(() => _position = position);
      });

      _player.stream.duration.listen((duration) {
        if (mounted) setState(() => _duration = duration);
      });

      _player.stream.error.listen((error) {
        if (mounted) setState(() => _errorMessage = error);
      });

      await _player.open(Media(widget.videoPath));

      if (mounted) setState(() => _isInitialized = true);
    } catch (e) {
      if (mounted) setState(() => _errorMessage = e.toString());
    }
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  void _togglePlayPause() {
    _player.playOrPause();
    setState(() => _showControls = true);
  }

  void _skipForward() {
    final newPos = _position + const Duration(seconds: 10);
    _player.seek(newPos > _duration ? _duration : newPos);
  }

  void _skipBackward() {
    final newPos = _position - const Duration(seconds: 10);
    _player.seek(newPos < Duration.zero ? Duration.zero : newPos);
  }

  void _showSpeedDialog() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);
    final color = widget.accentColor ?? colorScheme.primary;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Text(
          l10n.playbackSpeed,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [0.25, 0.5, 0.75, 1.0, 1.25, 1.5, 1.75, 2.0].map((speed) {
            final isSelected = _playbackSpeed == speed;
            return ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              title: Text(
                speed == 1.0 ? l10n.normal : '${speed}x',
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? color : colorScheme.onSurface,
                ),
              ),
              trailing: isSelected
                  ? Icon(Icons.check_rounded, color: color, size: 20.sp)
                  : null,
              onTap: () {
                setState(() => _playbackSpeed = speed);
                _player.setRate(speed);
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.close),
          ),
        ],
      ),
    );
  }

  void _toggleControls() {
    setState(() => _showControls = !_showControls);
  }

  void _showFullscreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _FullscreenPlayer(
          player: _player,
          controller: _controller,
          accentColor: widget.accentColor,
          initialSpeed: _playbackSpeed,
          onSpeedChanged: (speed) {
            setState(() => _playbackSpeed = speed);
          },
        ),
      ),
    );
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.toString().padLeft(2, '0');
    final seconds = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);
    final color = widget.accentColor ?? colorScheme.primary;

    if (_errorMessage != null) {
      return _buildError(colorScheme, l10n);
    }

    if (!_isInitialized) {
      return _buildLoading(colorScheme, l10n, color);
    }

    return Container(
      height: widget.height ?? 200.h,
      width: widget.width ?? double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.r),
        color: Colors.black,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12.r),
        child: Stack(
          children: [
            // Video
            Center(
              child: Video(
                controller: _controller,
                fit: BoxFit.contain,
                controls: NoVideoControls,
              ),
            ),

            // Tap area
            GestureDetector(
              onTap: _toggleControls,
              child: Container(
                color: Colors.transparent,
                width: double.infinity,
                height: double.infinity,
              ),
            ),

            // Custom controls
            if (_showControls) _buildControls(color, l10n),
          ],
        ),
      ),
    );
  }

  Widget _buildControls(Color color, AppLocalizations l10n) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withOpacity(0.4),
            Colors.transparent,
            Colors.black.withOpacity(0.6),
          ],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Top bar
          Padding(
            padding: EdgeInsets.all(12.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.play_circle_outline_rounded,
                        color: Colors.white,
                        size: 14.sp,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        l10n.video,
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Speed
                    IconButton(
                      onPressed: _showSpeedDialog,
                      icon: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 4.h,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        child: Text(
                          _playbackSpeed == 1.0 ? '1x' : '${_playbackSpeed}x',
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    // Fullscreen
                    IconButton(
                      onPressed: _showFullscreen,
                      icon: Icon(
                        Icons.fullscreen_rounded,
                        color: Colors.white,
                        size: 24.sp,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Center controls
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildControlButton(
                  Icons.replay_10_rounded,
                  _skipBackward,
                ),
                SizedBox(width: 16.w),
                _buildControlButton(
                  _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                  _togglePlayPause,
                  large: true,
                ),
                SizedBox(width: 16.w),
                _buildControlButton(
                  Icons.forward_10_rounded,
                  _skipForward,
                ),
              ],
            ),
          ),

          // Bottom bar
          Padding(
            padding: EdgeInsets.all(12.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Progress bar
                SliderTheme(
                  data: SliderThemeData(
                    trackHeight: 3.h,
                    thumbShape: RoundSliderThumbShape(enabledThumbRadius: 6.w),
                    overlayShape: RoundSliderOverlayShape(overlayRadius: 12.w),
                    activeTrackColor: color,
                    inactiveTrackColor: Colors.white.withOpacity(0.3),
                    thumbColor: color,
                    overlayColor: color.withOpacity(0.3),
                  ),
                  child: Slider(
                    value: _duration.inMilliseconds > 0
                        ? _position.inMilliseconds.toDouble()
                        : 0,
                    max: _duration.inMilliseconds.toDouble(),
                    onChanged: (value) {
                      _player.seek(Duration(milliseconds: value.toInt()));
                    },
                  ),
                ),
                SizedBox(height: 4.h),
                // Time
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _formatDuration(_position),
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      _formatDuration(_duration),
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
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

  Widget _buildControlButton(IconData icon, VoidCallback onTap,
      {bool large = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(large ? 16.w : 12.w),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.6),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: large ? 32.sp : 24.sp,
        ),
      ),
    );
  }

  Widget _buildLoading(ColorScheme scheme, AppLocalizations l10n, Color color) {
    return Container(
      height: widget.height ?? 200.h,
      width: widget.width ?? double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.r),
        color: color.withOpacity(0.1),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation(color),
              strokeWidth: 3,
            ),
            SizedBox(height: 12.h),
            Text(
              l10n.loadingVideo,
              style: TextStyle(
                fontSize: 13.sp,
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError(ColorScheme scheme, AppLocalizations l10n) {
    return Container(
      height: widget.height ?? 200.h,
      width: widget.width ?? double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.r),
        color: scheme.errorContainer,
        border: Border.all(color: scheme.error.withOpacity(0.3)),
      ),
      child: Center(
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline_rounded,
                size: 48.sp,
                color: scheme.error,
              ),
              SizedBox(height: 12.h),
              Text(
                l10n.cannotPlayVideo,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: scheme.onErrorContainer,
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),
              if (_errorMessage?.isNotEmpty == true) ...[
                SizedBox(height: 8.h),
                Text(
                  _errorMessage!,
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: scheme.onErrorContainer.withOpacity(0.8),
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              SizedBox(height: 16.h),
              FilledButton.icon(
                onPressed: () {
                  setState(() {
                    _errorMessage = null;
                    _isInitialized = false;
                  });
                  _initPlayer();
                },
                icon: Icon(Icons.refresh_rounded, size: 16.sp),
                label: Text(l10n.retry),
                style: FilledButton.styleFrom(
                  backgroundColor: scheme.error,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Fullscreen player
class _FullscreenPlayer extends StatefulWidget {
  final Player player;
  final VideoController controller;
  final Color? accentColor;
  final double initialSpeed;
  final Function(double) onSpeedChanged;

  const _FullscreenPlayer({
    required this.player,
    required this.controller,
    this.accentColor,
    required this.initialSpeed,
    required this.onSpeedChanged,
  });

  @override
  State<_FullscreenPlayer> createState() => _FullscreenPlayerState();
}

class _FullscreenPlayerState extends State<_FullscreenPlayer> {
  bool _showControls = true;
  bool _isPlaying = false;
  double _playbackSpeed = 1.0;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;

  @override
  void initState() {
    super.initState();
    _playbackSpeed = widget.initialSpeed;
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    widget.player.stream.playing.listen((playing) {
      if (mounted) setState(() => _isPlaying = playing);
    });

    widget.player.stream.position.listen((position) {
      if (mounted) setState(() => _position = position);
    });

    widget.player.stream.duration.listen((duration) {
      if (mounted) setState(() => _duration = duration);
    });

    _hideControlsAfterDelay();
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  void _hideControlsAfterDelay() {
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted && _isPlaying) {
        setState(() => _showControls = false);
      }
    });
  }

  void _toggleControls() {
    setState(() => _showControls = !_showControls);
    if (_showControls) _hideControlsAfterDelay();
  }

  void _showSpeedDialog() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);
    final color = widget.accentColor ?? colorScheme.primary;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Text(
          l10n.playbackSpeed,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [0.25, 0.5, 0.75, 1.0, 1.25, 1.5, 1.75, 2.0].map((speed) {
            final isSelected = _playbackSpeed == speed;
            return ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              title: Text(
                speed == 1.0 ? l10n.normal : '${speed}x',
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? color : colorScheme.onSurface,
                ),
              ),
              trailing: isSelected
                  ? Icon(Icons.check_rounded, color: color, size: 20.sp)
                  : null,
              onTap: () {
                setState(() => _playbackSpeed = speed);
                widget.player.setRate(speed);
                widget.onSpeedChanged(speed);
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.close),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.toString().padLeft(2, '0');
    final seconds = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final color = widget.accentColor ?? colorScheme.primary;

    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: _toggleControls,
        child: Stack(
          children: [
            Center(
              child: Video(
                controller: widget.controller,
                fit: BoxFit.contain,
                controls: NoVideoControls,
              ),
            ),

            if (_showControls) ...[
              // Top bar
              Positioned(
                top: MediaQuery.of(context).padding.top + 8,
                left: 16.w,
                right: 16.w,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Container(
                        padding: EdgeInsets.all(8.w),
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
                    IconButton(
                      onPressed: _showSpeedDialog,
                      icon: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 6.h,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Text(
                          _playbackSpeed == 1.0
                              ? '1x'
                              : '${_playbackSpeed}x',
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Center controls
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: () {
                        final newPos = _position - const Duration(seconds: 10);
                        widget.player.seek(
                          newPos < Duration.zero ? Duration.zero : newPos,
                        );
                      },
                      icon: Container(
                        padding: EdgeInsets.all(16.w),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.replay_10_rounded,
                          color: Colors.white,
                          size: 32.sp,
                        ),
                      ),
                    ),
                    SizedBox(width: 24.w),
                    GestureDetector(
                      onTap: () => widget.player.playOrPause(),
                      child: Container(
                        padding: EdgeInsets.all(20.w),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _isPlaying
                              ? Icons.pause_rounded
                              : Icons.play_arrow_rounded,
                          color: Colors.white,
                          size: 48.sp,
                        ),
                      ),
                    ),
                    SizedBox(width: 24.w),
                    IconButton(
                      onPressed: () {
                        final newPos = _position + const Duration(seconds: 10);
                        widget.player.seek(
                          newPos > _duration ? _duration : newPos,
                        );
                      },
                      icon: Container(
                        padding: EdgeInsets.all(16.w),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.forward_10_rounded,
                          color: Colors.white,
                          size: 32.sp,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Progress bar
              Positioned(
                bottom: MediaQuery.of(context).padding.bottom + 20,
                left: 16.w,
                right: 16.w,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SliderTheme(
                      data: SliderThemeData(
                        trackHeight: 4.h,
                        thumbShape:
                        RoundSliderThumbShape(enabledThumbRadius: 8.w),
                        overlayShape:
                        RoundSliderOverlayShape(overlayRadius: 16.w),
                        activeTrackColor: color,
                        inactiveTrackColor: Colors.white.withOpacity(0.3),
                        thumbColor: color,
                        overlayColor: color.withOpacity(0.3),
                      ),
                      child: Slider(
                        value: _duration.inMilliseconds > 0
                            ? _position.inMilliseconds.toDouble()
                            : 0,
                        max: _duration.inMilliseconds.toDouble(),
                        onChanged: (value) {
                          widget.player
                              .seek(Duration(milliseconds: value.toInt()));
                        },
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _formatDuration(_position),
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          _formatDuration(_duration),
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// preview video
class VideoThumbnailWidget extends StatefulWidget {
  final String videoPath;
  final Color accentColor;
  final double height;
  final double width;

  const VideoThumbnailWidget({super.key,
    required this.videoPath,
    required this.accentColor,
    required this.height,
    required this.width,
  });

  @override
  _VideoThumbnailWidgetState createState() => _VideoThumbnailWidgetState();
}

class _VideoThumbnailWidgetState extends State<VideoThumbnailWidget> {
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeVideoThumbnail();
  }

  Future<void> _initializeVideoThumbnail() async {
    try {
      final file = File(widget.videoPath);
      if (!await file.exists()) {
        throw Exception('Video file not found');
      }

      _controller = VideoPlayerController.file(file)
        ..initialize().then((_) {
          if (mounted) {
            setState(() {
              _isInitialized = true;
              _controller!.seekTo(Duration.zero); // Show first frame
              _controller!.setVolume(0.0); // Mute to prevent audio
            });
          }
        }).catchError((error) {
          if (mounted) {
            setState(() {
              _errorMessage = error.toString();
            });
          }
        });
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
        });
      }
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (_errorMessage != null) {
      return Container(
        color: colorScheme.surfaceContainerHighest,
        child: Center(
          child: Icon(
            Icons.broken_image_rounded,
            size: 32.sp,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      );
    }

    if (!_isInitialized || _controller == null) {
      return Container(
        color: colorScheme.surfaceContainerHighest,
        child: Center(
          child: CircularProgressIndicator(
            color: widget.accentColor,
            strokeWidth: 2.5,
          ),
        ),
      );
    }

    return VideoPlayer(_controller!);
  }
}