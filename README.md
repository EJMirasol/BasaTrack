# BasaTrack

A beautiful and motivating Flutter mobile app to help users maintain consistent daily Bible reading habits.

## Features

✨ **Daily Reading Schedule**l
- **2-Year Bible Reading Plan**: Comprehensive 104-week plan covering the entire Bible.
- **Balanced Readings**: 2 readings per day (1 Old Testament, 1 New Testament).
- Simple checkbox interface to track completion.

☁️ **Cloud Sync & Backup** (Optional)
- **Cross-Device Sync**: Sign in to sync your progress across multiple devices.
- **Secure Backup**: Your reading history and streaks are safely backed up to the cloud.
- **Guest Mode**: Use the app completely offline without signing in.

🔥 **Streak Tracking**
- Track consecutive days of reading.
- Special celebration for 7-day streak achievements.
- Visual streak badges with dynamic colors and animations.

📊 **Progress Monitoring**
- Daily progress bar showing completion percentage.
- Missed days tracking with gentle, motivational reminders.
- Total days read statistics.

🎨 **Beautiful UI/UX**
- Clean, uplifting design with peaceful color palette.
- Smooth animations and micro-interactions.
- Material Design 3 with custom theming.
- Light and dark mode support.
- Google Fonts integration (Inter + Merriweather).

💾 **Offline-First Architecture**
- Works seamlessly without internet connection (Local-first with Hive).
- Data automatically syncs when online if signed in.

## Technical Stack

- **Framework**: Flutter 3.0+
- **Language**: Dart
- **State Management**: Provider
- **Local Database**: Hive (NoSQL, fast & offline-ready)
- **Cloud Backend**: Firebase
    - **Authentication**: Firebase Auth (Google Sign-In, etc.)
    - **Database**: Cloud Firestore
- **Architecture**: Clean Architecture with Repository Pattern
- **UI**: Material Design 3 with custom theming
- **Other Key Packages**:
    - `connectivity_plus`: Network connectivity monitoring
    - `google_fonts`: Custom typography
    - `lottie`: High-quality animations

## Project Structure

```
lib/
├── core/
│   ├── theme/           # App theme and colors
│   └── constants/       # App-wide constants
├── data/
│   ├── models/          # Data models (ReadingTask, DailySchedule, UserProgress, AppUser)
│   ├── repositories/    # Data access (Sync, Storage, Auth)
│   ├── data_sources/    # Bible reading plan data
│   └── services/        # External services (Firestore, Auth)
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
   git clone https://github.com/yourusername/BasaTrack.git
   cd BasaTrack
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

1. **Daily Reading**: Open the app to see today's reading tasks.
2. **Mark Complete**: Tap the checkbox or card to mark a reading as complete.
3. **Track Streaks**: Complete all readings daily to build your streak.
4. **Celebrate Achievements**: Reach 7 consecutive days for a special celebration!
5. **Sync (Optional)**: Sign in via the settings/profile page to back up your data.

## Features in Detail

### Reading Plan
The app includes a comprehensive **2-year (104-week) Bible reading plan** that covers:
- **Old Testament**: 1 reading per day.
- **New Testament**: 1 reading per day.

This balanced approach ensures you read through the entire Bible at a steady, manageable pace.

### Streak System
- **1-6 days**: Blue flame icon, building your habit.
- **7-29 days**: Gold star icon, you've made it a weekly habit!
- **30-99 days**: Orange trophy icon, impressive consistency.
- **100+ days**: Legendary crown icon, you're a champion!

### Progress Tracking
- Real-time progress bar for daily completion.
- Historical tracking of all completed days.
- Intelligent missed days calculation.
- Motivational messages based on your progress.

## Code Quality

This project follows Flutter best practices:
- ✅ **Clean Architecture principles**
- ✅ **SOLID principles**
- ✅ **Repository Pattern** for data abstraction
- ✅ **Offline-First** capability
- ✅ **Separation of concerns**
- ✅ **Type-safe code**
- ✅ Proper error handling
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
