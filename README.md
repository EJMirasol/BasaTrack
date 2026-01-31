# BasaTrack

This application assists saints in the Lord's Recovery, specifically in the Southern Philippines, in tracking their daily progress through a synchronized two-year Bible reading schedule. It aims to encourage consistency and corporate pursuit.

## Features

✨ **Daily Reading Schedule**
- **2-Year Bible Reading Plan**: Comprehensive 104-week plan covering the entire Bible.
- **Balanced Readings**: 2 readings per day (1 Old Testament, 1 New Testament).
- Simple checkbox interface to track completion.

📊 **Advanced Statistics & Progress Monitoring**
- **Detailed Stats Dashboard**: Track Backlogs, Completed Tasks, and Total Week Streaks.
- **Personal Best**: See your longest reading streak displayed with a "Personal Best" badge.
- **Weekly Overview**: A visual 7-day tracker showing your completion status for the current week.
- **Bible Reading Progress**: Separate progress bars for Old Testament and New Testament completion.
- **Total Days Read**: Milestone tracking for total reading activity.

📅 **Streak Tracking**
- Track consecutive days of reading.
- Special celebration for 7-day streak achievements.
- Visual streak badges with dynamic colors and animations.

🔔 **Smart Notifications**
- **Daily Reminders**: Gentle morning/evening prompts to help you stay on track.
- **Missed Reading Alerts**: Notifications for backlogs to encourage catching up.
- One-time permission request flow on first launch.

💾 **Data Management & Portability**
- **Export Progress**: Save your reading history as a portable JSON file.
- **Import Progress**: Easily restore your data on a new device or after a reset.
- **Guest Mode & Local Storage**: Data is stored securely on your device using Hive (NoSQL).
- **Auto-Login**: Seamless transition to the home screen for returning users.

## Technical Stack

- **Framework**: Flutter 3.0+
- **Language**: Dart
- **State Management**: Provider
- **Local Database**: Hive (NoSQL, fast & offline-ready)
- **Dependencies**: 
  - `path_provider` & `share_plus` (Data Export)
  - `file_picker` (Data Import)
  - `flutter_local_notifications` (Reminders)
- **Architecture**: Clean Architecture with Repository Pattern
- **UI**: Material Design 3 with custom theming and responsive layouts

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
│   └── services/        # Services (NotificationService, StorageService)
├── providers/           # State management (AuthProvider, ReadingProvider, StreakProvider)
├── ui/
│   ├── screens/         # App screens (Home, Stats, Settings, Login)
│   ├── widgets/         # Reusable UI components (NotificationDialog, ProgressCards)
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

**iOS (requires macOS):**
```bash
flutter build ios --release
```

## How to Use

1. **Daily Reading**: Open the **Home** tab to see today's reading tasks.
2. **Mark Complete**: Tap the checkbox or card to mark a reading as complete.
3. **Analyze Stats**: Switch to the **Stats** tab to see your progress, backlogs, and streaks.
4. **Manage Data**: Go to the **Settings** tab to Export or Import your progress.
5. **Notifications**: Accept notification permissions on first launch to receive daily reminders.

## Code Quality

This project follows Flutter best practices:
- ✅ **Clean Architecture principles**
- ✅ **SOLID principles**
- ✅ **Repository Pattern** for data abstraction
- ✅ **Separation of concerns**
- ✅ **Type-safe code**
- ✅ Proper error handling

## Customization

### Changing the Reading Plan
Edit `lib/data/data_sources/reading_plan_data.dart` to customize the Bible reading plan.

### Modifying Colors
Update `lib/core/theme/app_colors.dart` to change the color scheme.

### Adjusting Messages
Edit `lib/core/constants/app_constants.dart` to customize motivational messages.

## Support

For issues or questions, please create an issue in the repository.

---

**Built with ❤️ using Flutter**

*"Your word is a lamp to my feet and a light to my path." - Psalm 119:105*
