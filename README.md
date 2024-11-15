# Flutter MP3 Player Wave Visualization

## Overview

This project is a Flutter-based MP3 player that features audio playback controls, a wave visualization of the audio's frequency, and dynamic progress tracking. The application is built using the Flutter framework and employs the `flutter_bloc` package for state management.

# Features

- **Audio Playback**: 
  - Stream audio files from a specified URL.
  - Controls for Play and Pause functionality.

- **Wave Visualization**: 
  - Dynamic wave visualizer that represents audio frequencies.
  - The wave also acts as a progress bar, tracking the audio playback.

- **State Management**: 
  - Utilizes the `flutter_bloc` package for managing application state.


# Implementation Details

### Audio Playback

- The audio is streamed from a specified URL, and the `just_audio` package is used for playback.
- The app includes two main controls:
  - **Play**: Starts audio playback.
  - **Pause**: Pauses the audio.

### Wave Visualization

- The wave visualizer is implemented using the `CustomPainter` class to create a dynamic representation of the audio frequencies.
- The visualizer also functions as a progress bar, updating its display based on the current playback position.

### State Management

- The application uses the BLoC pattern for state management, separating the business logic from the UI.
- The following states are defined:
  - `AudioInitial`
  - `AudioLoading`
  - `AudioPlaying`
  - `AudioPaused`
  - `AudioError`
- State transitions are handled smoothly, ensuring a responsive user experience.
  
## GIF Demonstration

 Here is a short demonstration of the application in action:
 [[MP3 Player Demo](https://github.com/anilvzecdata/flutter_mp3_player/blob/master/lib/assets/gif/VID-20241115-WA0005-ezgif.com-optimize.gif)]
 
 
## Installation

To run this project locally, follow these steps:

1. Clone the repository:Navigate to the project directory:<br/> git clone [https://github.com/anilvishwakarma0529/flutter_mp3_player.git]
2. Navigate to the project directory:<br/> cd flutter_mp3_player
3. Install the dependencies:<br/>flutter pub get
4. Run the application:<br/> flutter run
