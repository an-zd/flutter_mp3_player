import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:math' show sin, pi;
import '../bloc/audio_bloc.dart';

class WaveVisualizer extends StatefulWidget {
  final double progress;
  final bool isPlaying;

  const WaveVisualizer({
    Key? key,
    required this.progress,
    required this.isPlaying,
  }) : super(key: key);

  @override
  State<WaveVisualizer> createState() => _WaveVisualizerState();
}

class _WaveVisualizerState extends State<WaveVisualizer> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1000),
    );
    if (widget.isPlaying) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(WaveVisualizer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPlaying != oldWidget.isPlaying) {
      if (widget.isPlaying) {
        _controller.repeat();
      } else {
        _controller.stop();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AudioBloc, AudioState>(
      builder: (context, state) {
        return AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return CustomPaint(
              painter: WavePainter(
                progress: widget.progress,
                frequencies: state.frequencies,
                animation: _controller.value,
                isPlaying: widget.isPlaying,
              ),
              size: Size(MediaQuery.of(context).size.width, 200),
            );
          },
        );
      },
    );
  }
}

class WavePainter extends CustomPainter {
  final double progress;
  final List<double> frequencies;
  final double animation;
  final bool isPlaying;

  WavePainter({
    required this.progress,
    required this.frequencies,
    required this.animation,
    required this.isPlaying,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint barPaint = Paint()
      ..style = PaintingStyle.fill;

    final Paint progressPaint = Paint()
      ..color = Colors.blue.withOpacity(0.8)
      ..style = PaintingStyle.fill;

    final int barCount = frequencies.isEmpty ? 100 : frequencies.length;
    final double barWidth = size.width / barCount;
    final double maxFrequency = frequencies.isEmpty ? 1.0 : frequencies.reduce((a, b) => a > b ? a : b);

    for (int i = 0; i < barCount; i++) {
      final double normalizedFrequency = frequencies.isEmpty ? 0.5 : frequencies[i] / maxFrequency;
      
      double animatedHeight;
      if (isPlaying) {
        animatedHeight = normalizedFrequency * 
          (0.3 + 0.7 * sin((animation * 2 * pi) + (i * 0.1)));
      } else {
        animatedHeight = normalizedFrequency * 0.3;
      }
      
      final double barHeight = size.height * 0.8 * animatedHeight;
      
      final double x = i * barWidth;
      final double y = (size.height - barHeight) / 2;
      
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(x + 1, y, barWidth - 2, barHeight),
        Radius.circular(barWidth / 2),
      );
      
      if (x / size.width <= progress) {
        barPaint.color = Colors.white.withOpacity(0.8);
      } else {
        barPaint.color = Colors.white.withOpacity(0.3);
      }
      
      canvas.drawRRect(rect, barPaint);
    }

    canvas.drawRect(
      Rect.fromLTWH(0, size.height - 2, size.width * progress, 2),
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant WavePainter oldDelegate) {
    return oldDelegate.progress != progress || 
           oldDelegate.animation != animation ||
           oldDelegate.frequencies != frequencies ||
           oldDelegate.isPlaying != isPlaying;
  }
}
