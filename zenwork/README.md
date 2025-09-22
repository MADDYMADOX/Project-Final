# Zen Work - Premium Focus Enhancement App

A premium Flutter app with stunning glassmorphism UI that helps users improve focus by pairing ambient sounds with task sessions. Features real-time sound recommendations, animated timers, and beautiful data visualizations.

## Features

### Core Functionality
- **Task Selection**: Choose from 6 work types (Writing, Coding, Studying, Reading, Creative, Other)
- **Smart Sound Recommendations**: AI-powered ambient sound suggestions based on task type
- **Audio Player**: Background ambient sound playback with loop functionality
- **Session Timer**: Customizable focus sessions from 5 minutes to 2 hours
- **Focus Score**: Performance metrics based on session completion and interruptions
- **Session History**: Track and analyze your focus patterns over time

### Premium UI/UX Features
- **Glassmorphism Design**: Stunning frosted glass effects with blur and transparency
- **Animated Gradients**: Dynamic background gradients that subtly shift over time
- **Premium Typography**: Plus Jakarta Sans font family for modern, readable text
- **Glowing Animations**: Pulsing timer with gradient rings and glow effects
- **Smooth Transitions**: 60fps animations with spring physics and easing curves
- **Dark/Light Mode**: Seamless theme switching with premium color palettes
- **Responsive Design**: Optimized for mobile and tablet with touch-friendly interactions

### Technical Features
- **Clean Architecture**: Modular code structure with services, models, and providers
- **State Management**: Riverpod for reactive state management
- **Local Storage**: Hive for session data and SharedPreferences for settings
- **Audio Playback**: just_audio package for seamless sound management
- **Charts**: fl_chart for beautiful focus score visualizations

## Getting Started

### Prerequisites
- Flutter 3.8.1 or higher
- Dart SDK
- Android Studio / VS Code
- iOS Simulator / Android Emulator

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd zenwork
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Replace placeholder assets**
   - Add actual audio files to `assets/audio/` (MP3 format recommended)
   - Add Poppins font files to `assets/fonts/` (download from Google Fonts)
   - Add task type icons to `assets/icons/` (PNG format, 48x48px recommended)

4. **Generate Hive adapters** (if needed)
   ```bash
   flutter packages pub run build_runner build
   ```

5. **Run the app**
   ```bash
   flutter run
   ```

## Project Structure

```
lib/
├── main.dart                 # App entry point and navigation
├── models/                   # Data models
│   ├── ambient_sound.dart    # Sound track model
│   ├── focus_session.dart    # Session data model
│   └── task_type.dart        # Task type enum
├── services/                 # Business logic services
│   ├── audio_service.dart    # Audio playback management
│   ├── storage_service.dart  # Local data persistence
│   └── recommendation_service.dart # Sound recommendation logic
├── providers/                # State management
│   └── app_providers.dart    # Riverpod providers
├── screens/                  # Main app screens
│   ├── home_screen.dart      # Task selection and session management
│   ├── history_screen.dart   # Session history and statistics
│   └── settings_screen.dart  # App configuration
├── widgets/                  # Reusable UI components
│   ├── gradient_background.dart
│   ├── task_type_card.dart
│   ├── sound_card.dart
│   └── focus_timer.dart
└── utils/                    # Utilities and constants
    ├── app_colors.dart       # Color scheme
    ├── app_theme.dart        # Theme configuration
    └── constants.dart        # App constants
```

## Asset Requirements

### Audio Files (assets/audio/)
Replace placeholder files with actual audio tracks:
- `rain.mp3` - Gentle rainfall sounds
- `lofi_beats.mp3` - Chill lo-fi music
- `soft_piano.mp3` - Peaceful piano melodies
- `nature_sounds.mp3` - Birds and forest ambience
- `white_noise.mp3` - Pure white noise
- `ocean_waves.mp3` - Calming ocean sounds
- `forest_ambience.mp3` - Deep forest atmosphere
- `cafe_ambience.mp3` - Coffee shop background
- `thunderstorm.mp3` - Distant thunder and rain
- `meditation_bells.mp3` - Gentle meditation bells

### Fonts (assets/fonts/)
Download Plus Jakarta Sans font family from Google Fonts:
- `PlusJakartaSans-Regular.ttf`
- `PlusJakartaSans-Medium.ttf`
- `PlusJakartaSans-SemiBold.ttf`
- `PlusJakartaSans-Bold.ttf`
- `PlusJakartaSans-ExtraBold.ttf`

### Icons (assets/icons/)
Create or download 48x48px PNG icons:
- `writing.png` - Writing/editing icon
- `coding.png` - Programming icon
- `studying.png` - Study/education icon
- `reading.png` - Book/reading icon
- `creative.png` - Art/creativity icon
- `other.png` - General work icon

## Configuration

### Audio Sources
For production use, replace placeholder audio files with royalty-free tracks from:
- [Freesound.org](https://freesound.org/)
- [Zapsplat](https://www.zapsplat.com/)
- [Adobe Stock Audio](https://stock.adobe.com/audio)

### Customization
- Modify `AppColors` class to change the color scheme
- Update `AppConstants` for different timer durations or thresholds
- Extend `TaskType` enum to add new work categories
- Add more ambient sounds to `AmbientSound.allSounds` list

## Building for Production

### Android
```bash
flutter build apk --release
# or for app bundle
flutter build appbundle --release
```

### iOS
```bash
flutter build ios --release
```

## Dependencies

### Core Dependencies
- `flutter_riverpod: ^2.4.9` - State management
- `just_audio: ^0.9.36` - Audio playback
- `hive: ^2.2.3` - Local database
- `hive_flutter: ^1.1.0` - Hive Flutter integration
- `shared_preferences: ^2.2.2` - Simple key-value storage
- `fl_chart: ^0.66.0` - Premium charts and graphs
- `glassmorphism: ^3.0.0` - Glassmorphism effects
- `shimmer: ^3.0.0` - Shimmer loading animations

### Development Dependencies
- `hive_generator: ^2.0.1` - Code generation for Hive
- `build_runner: ^2.4.7` - Build system

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

For support and questions:
- Create an issue on GitHub
- Check the Flutter documentation
- Visit the Flutter community forums
