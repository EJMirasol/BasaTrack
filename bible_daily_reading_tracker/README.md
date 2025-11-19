# Bible Daily Reading Tracker

A beautiful and motivating Flutter mobile app to help users maintain consistent daily Bible reading habits.

## Features

✨ **Daily Reading Schedule**
- Automatically generated daily Bible reading plan
- 2-3 readings per day (Old Testament, New Testament, Psalms/Proverbs)
- Simple checkbox interface to track completion

🔥 **Streak Tracking**
- Track consecutive days of reading
- Special celebration for 7-day streak achievements
- Visual streak badges with dynamic colors and animations

📊 **Progress Monitoring**
- Daily progress bar showing completion percentage
- Missed days tracking with gentle, motivational reminders
- Total days read statistics

🎨 **Beautiful UI/UX**
- Clean, uplifting design with peaceful color palette
- Smooth animations and micro-interactions
- Material Design 3 with custom theming
- Light and dark mode support
- Google Fonts integration (Inter + Merriweather)

💾 **Local Data Persistence**
- All data stored locally using Hive database
- No internet connection required
- Privacy-focused - your data stays on your device

## Technical Stack

- **Framework**: Flutter 3.0+
- **State Management**: Provider (recommended by Flutter team)
- **Local Storage**: Hive (fast NoSQL database)
- **Architecture**: Clean Architecture with separation of concerns
- **UI**: Material Design 3 with custom theming

## Project Structure

```
lib/
├── core/
│   ├── theme/           # App theme and colors
│   └── constants/       # App-wide constants
├── data/
│   ├── models/          # Data models (ReadingTask, DailySchedule, UserProgress)
│   ├── repositories/    # Business logic and data access
│   └── data_sources/    # Bible reading plan data
├── providers/           # State management (Provider)
├── ui/
│   ├── screens/         # App screens
│   ├── widgets/         # Reusable UI components
│   └── animations/      # Custom animations
└── utils/               # Utility functions
```

## Getting Started

### Prerequisites

- Flutter SDK (3.0 or higher)
- Dart SDK
- Android Studio / VS Code with Flutter extensions

### Installation

1. **Clone the repository**
   ```bash
   cd C:\Users\USER\Documents\GitHub\BasaTrack
   cd bible_daily_reading_tracker
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

### Building for Production

**Android APK:**
```bash
flutter build apk --release
```

**Android App Bundle:**
```bash
flutter build appbundle --release
```

**iOS (requires macOS):**
```bash
flutter build ios --release
```

## How to Use

1. **Daily Reading**: Open the app to see today's reading tasks
2. **Mark Complete**: Tap the checkbox or card to mark a reading as complete
3. **Track Streaks**: Complete all readings daily to build your streak
4. **Celebrate Achievements**: Reach 7 consecutive days for a special celebration!
5. **Stay Motivated**: The app will gently remind you if you've missed days

## Features in Detail

### Reading Plan
The app includes a comprehensive year-long Bible reading plan that covers:
- Old Testament books
- New Testament books
- Psalms and Proverbs

The plan cycles through the entire Bible with balanced daily readings.

### Streak System
- **1-6 days**: Blue flame icon, building your habit
- **7-29 days**: Gold star icon, you've made it a weekly habit!
- **30-99 days**: Orange trophy icon, impressive consistency
- **100+ days**: Legendary crown icon, you're a champion!

### Progress Tracking
- Real-time progress bar for daily completion
- Historical tracking of all completed days
- Intelligent missed days calculation
- Motivational messages based on your progress

## Code Quality

This project follows Flutter best practices:
- ✅ Clean Architecture principles
- ✅ SOLID principles
- ✅ Provider for state management
- ✅ Repository pattern for data access
- ✅ Separation of concerns
- ✅ Proper error handling
- ✅ Type-safe code
- ✅ Comprehensive documentation

## Customization

### Changing the Reading Plan
Edit `lib/data/data_sources/reading_plan_data.dart` to customize the Bible reading plan.

### Modifying Colors
Update `lib/core/theme/app_colors.dart` to change the color scheme.

### Adjusting Messages
Edit `lib/core/constants/app_constants.dart` to customize motivational messages.

## Support

For issues or questions, please create an issue in the repository.

## License

This project is open source and available for personal and educational use.

---

**Built with ❤️ using Flutter**

*"Your word is a lamp to my feet and a light to my path." - Psalm 119:105*
