// static_equalizer.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class StaticEqualizer extends StatelessWidget {
 final List<double> frequencies;

 const StaticEqualizer({Key? key, required this.frequencies}) : super(key: key);

 @override
 Widget build(BuildContext context) {
   return Container(
     height: 100, // Height of the equalizer
     child: CustomPaint(
       painter: EqualizerPainter(frequencies),
     ),
   );
 }
}

class EqualizerPainter extends CustomPainter {
 final List<double> frequencies;

 EqualizerPainter(this.frequencies);

 @override
 void paint(Canvas canvas, Size size) {
   final Paint paint = Paint()
     ..color = Colors.green
     ..style = PaintingStyle.fill;

   final int barCount = frequencies.length;
   final double barWidth = size.width / barCount;

   for (int i = 0; i < barCount; i++) {
     final double normalizedFrequency = frequencies.isEmpty ? 0.5 : frequencies[i];
     final double barHeight = normalizedFrequency * size.height;

     final double x = i * barWidth;
     final double y = size.height - barHeight;

     canvas.drawRect(Rect.fromLTWH(x, y, barWidth - 1, barHeight), paint);
   }
 }

 @override
 bool shouldRepaint(covariant CustomPainter oldDelegate) {
   return true; // Repaint every time frequencies change
 }
}

// audio_player.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/audio_bloc.dart';
import 'wave_visualizer.dart';
import 'static_equalizer.dart'; // Import the StaticEqualizer

class AudioPlayer extends StatelessWidget {
 final String songTitle = "Awesome Song - Great Artist";

 String _formatDuration(Duration? duration) {
   if (duration == null) return "--:--";
   String twoDigits(int n) => n.toString().padLeft(2, "0");
   String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
   String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
   return "$twoDigitMinutes:$twoDigitSeconds";
 }

 @override
 Widget build(BuildContext context) {
   return BlocBuilder<AudioBloc, AudioState>(
     builder: (context, state) {
       final bool isPlaying = state is AudioPlaying;
       final Duration currentPosition = Duration(milliseconds: (state.progress * (state.duration?.inMilliseconds ?? 0)).round());
       
       return Column(
         mainAxisAlignment: MainAxisAlignment.center,
         children: [
           Expanded(
             child: Center(
               child: Text(
                 songTitle,
                 style: TextStyle(
                   fontSize: 24,
                   fontWeight: FontWeight.bold,
                   color: Colors.white,
                   shadows: [
                     Shadow(
                       blurRadius: 10.0,
                       color: Colors.black,
                       offset: Offset(5.0, 5.0),
                     ),
                   ],
                 ),
                 textAlign: TextAlign.center,
               ),
             ),
           ),
           // Add the StaticEqualizer here
           Container(
             height: 100,
             padding: EdgeInsets.symmetric(horizontal: 20),
             child: StaticEqualizer(
               frequencies: state.frequencies,
             ),
           ),
           Container(
             height: 200,
             padding: EdgeInsets.symmetric(horizontal: 20),
             child: WaveVisualizer(
               progress: state.progress,
               isPlaying: isPlaying,
             ),
           ),
           SizedBox(height: 20),
           Text(
             "${_formatDuration(currentPosition)} / ${_formatDuration(state.duration)}",
             style: TextStyle(
               fontSize: 18,
               color: Colors.white,
               shadows: [
                 Shadow(
                   blurRadius: 5.0,
                   color: Colors.black,
                   offset: Offset(2.0, 2.0),
                 ),
               ],
             ),
           ),
           SizedBox(height: 20),
           GestureDetector(
             onTap: () {
               if (isPlaying) {
                 context.read<AudioBloc>().add(PauseAudio());
               } else {
                 context.read<AudioBloc>().add(PlayAudio());
               }
             },
             child: Container(
               width: 80,
               height: 80,
               decoration: BoxDecoration(
                 shape: BoxShape.circle,
                 gradient: LinearGradient(
                   begin: Alignment.topLeft,
                   end: Alignment.bottomRight,
                   colors: [Colors.blue, Colors.purple],
                 ),
                 boxShadow: [
                   BoxShadow(
                     color: Colors.black.withOpacity(0.3),
                     spreadRadius: 2,
                     blurRadius: 5,
                     offset: Offset( 0, 3),
                   ),
                 ],
               ),
               child: Icon(
                 isPlaying ? Icons.pause : Icons.play_arrow,
                 color: Colors.white,
                 size: 48,
               ),
             ),
           ),
           SizedBox(height: 40),
         ],
       );
     },
   );
 }
}