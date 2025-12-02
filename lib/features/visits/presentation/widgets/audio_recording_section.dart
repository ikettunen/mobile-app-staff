import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:flutter/material.dart';
import 'package:nurse_app/core/theme/app_theme.dart';

class AudioRecordingSection extends StatefulWidget {
  final bool isRecording;
  final String? audioPath;
  final Function() onStartRecording;
  final Function() onStopRecording;

  const AudioRecordingSection({
    super.key,
    required this.isRecording,
    this.audioPath,
    required this.onStartRecording,
    required this.onStopRecording,
  });

  @override
  State<AudioRecordingSection> createState() => _AudioRecordingSectionState();
}

class _AudioRecordingSectionState extends State<AudioRecordingSection> {
  PlayerController? _playerController;
  bool _isPlaying = false;
  bool _isPlayerInitialized = false;

  @override
  void initState() {
    super.initState();
    if (widget.audioPath != null) {
      _initializePlayer();
    }
  }

  @override
  void didUpdateWidget(AudioRecordingSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.audioPath != widget.audioPath && widget.audioPath != null) {
      _initializePlayer();
    }
  }

  Future<void> _initializePlayer() async {
    if (widget.audioPath == null) return;

    _playerController = PlayerController();
    try {
      await _playerController!.preparePlayer(path: widget.audioPath!);
      setState(() {
        _isPlayerInitialized = true;
      });
    } catch (e) {
      debugPrint('Error initializing player: $e');
    }
  }

  Future<void> _playPause() async {
    if (_playerController == null || !_isPlayerInitialized) return;

    if (_isPlaying) {
      await _playerController!.pausePlayer();
    } else {
      await _playerController!.startPlayer();
    }

    setState(() {
      _isPlaying = !_isPlaying;
    });
  }

  @override
  void dispose() {
    _playerController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isRecording) {
      return _buildRecordingInProgress();
    } else if (widget.audioPath != null) {
      return _buildPlaybackControls();
    } else {
      return _buildStartRecording();
    }
  }

  Widget _buildStartRecording() {
    return Center(
      child: Column(
        children: [
          const Text(
            'Tap to record audio notes',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: widget.onStartRecording,
            icon: const Icon(Icons.mic),
            label: const Text('Start Recording'),
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecordingInProgress() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: const BoxDecoration(
                color: AppColors.danger,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              'Recording in progress...',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Animated waveform placeholder
        Container(
          height: 50,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Center(
            child: Text('Recording audio...'),
          ),
        ),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: widget.onStopRecording,
          icon: const Icon(Icons.stop),
          label: const Text('Stop Recording'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.danger,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPlaybackControls() {
    return Column(
      children: [
        if (_isPlayerInitialized && _playerController != null)
          AudioFileWaveforms(
            size: Size(MediaQuery.of(context).size.width * 0.8, 70),
            playerController: _playerController!,
            waveformType: WaveformType.fitWidth,
            playerWaveStyle: const PlayerWaveStyle(
              fixedWaveColor: AppColors.primary,
              liveWaveColor: AppColors.primaryLight,
              spacing: 6,
              showBottom: true,
              waveThickness: 3,
            ),
          )
        else
          Container(
            height: 70,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
              child: Text('Audio recorded'),
            ),
          ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_isPlayerInitialized)
              IconButton(
                onPressed: _playPause,
                icon: Icon(
                  _isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled,
                  size: 48,
                  color: AppColors.primary,
                ),
              ),
            const SizedBox(width: 16),
            OutlinedButton.icon(
              onPressed: widget.onStartRecording,
              icon: const Icon(Icons.mic),
              label: const Text('Record Again'),
            ),
          ],
        ),
      ],
    );
  }
}
