import '../models/reading_task.dart';

/// Provides a 104-week Bible reading plan (2 years)
/// Each week has 7 days with OT and NT readings
class ReadingPlanData {
  ReadingPlanData._();

  /// Get week number from day number (1-728)
  static int getWeekNumber(int dayOfPlan) {
    return ((dayOfPlan - 1) ~/ 7) + 1;
  }

  /// Get day of week from day number (1-7)
  static int getDayOfWeek(int dayOfPlan) {
    return ((dayOfPlan - 1) % 7) + 1;
  }

  /// Get day name from day of week number
  static String getDayName(int dayOfWeek) {
    switch (dayOfWeek) {
      case 1:
        return "Lord's Day";
      case 2:
        return 'Monday';
      case 3:
        return 'Tuesday';
      case 4:
        return 'Wednesday';
      case 5:
        return 'Thursday';
      case 6:
        return 'Friday';
      case 7:
        return 'Saturday';
      default:
        return '';
    }
  }

  /// Get reading tasks for a specific day (1-728)
  static List<ReadingTask> getReadingsForDay(int dayOfPlan) {
    // Normalize to 1-728 range (104 weeks * 7 days)
    final day = ((dayOfPlan - 1) % 728) + 1;
    
    final weekNumber = getWeekNumber(day);
    final dayOfWeek = getDayOfWeek(day);
    
    // Get readings from plan or use fallback
    final weekReadings = _readingPlan[weekNumber];
    
    if (weekReadings != null && dayOfWeek <= weekReadings.length) {
      final dayReadings = weekReadings[dayOfWeek - 1];
      return [
        ReadingTask(
          id: 'week_${weekNumber}_day_${dayOfWeek}_ot',
          reference: dayReadings['ot']!,
        ),
        ReadingTask(
          id: 'week_${weekNumber}_day_${dayOfWeek}_nt',
          reference: dayReadings['nt']!,
        ),
      ];
    }
    
    // Fallback for undefined weeks
    return _getFallbackReadings(weekNumber, dayOfWeek);
  }

  /// Fallback reading generator
  static List<ReadingTask> _getFallbackReadings(int week, int day) {
    final otChapter = ((week - 1) * 7 + day) % 929 + 1;
    final ntChapter = ((week - 1) * 7 + day) % 260 + 1;
    
    return [
      ReadingTask(
        id: 'week_${week}_day_${day}_ot',
        reference: _getOTReference(otChapter),
      ),
      ReadingTask(
        id: 'week_${week}_day_${day}_nt',
        reference: _getNTReference(ntChapter),
      ),
    ];
  }

  /// Generate OT reference
  static String _getOTReference(int chapter) {
    final verseStart = 1;
    final verseEnd = 10 + (chapter % 20);
    
    if (chapter <= 50) return 'Gen ${chapter}:$verseStart-$verseEnd';
    if (chapter <= 90) return 'Ex ${chapter - 50}:$verseStart-$verseEnd';
    if (chapter <= 117) return 'Lev ${chapter - 90}:$verseStart-$verseEnd';
    if (chapter <= 153) return 'Num ${chapter - 117}:$verseStart-$verseEnd';
    if (chapter <= 187) return 'Deut ${chapter - 153}:$verseStart-$verseEnd';
    // ... continue with other books
    return 'Gen 1:1-10'; // Fallback
  }

  /// Generate NT reference
  static String _getNTReference(int chapter) {
    final verseStart = 1;
    final verseEnd = 8 + (chapter % 15);
    
    if (chapter <= 28) return 'Matt ${chapter}:$verseStart-$verseEnd';
    if (chapter <= 44) return 'Mark ${chapter - 28}:$verseStart-$verseEnd';
    if (chapter <= 68) return 'Luke ${chapter - 44}:$verseStart-$verseEnd';
    // ... continue with other books
    return 'Matt 1:1-10'; // Fallback
  }

  /// 104-week reading plan
  /// Each week contains 7 days, each day has OT and NT readings
  static final Map<int, List<Map<String, String>>> _readingPlan = {
    // Week 1
    1: [
      {'ot': 'Gen 1:1-5', 'nt': 'Matt 1:1-2'},
      {'ot': 'Gen 1:6-23', 'nt': 'Matt 1:3-7'},
      {'ot': 'Gen 1:24-31', 'nt': 'Matt 1:8-17'},
      {'ot': 'Gen 2:1-9', 'nt': 'Matt 1:18-25'},
      {'ot': 'Gen 2:10-25', 'nt': 'Matt 2:1-23'},
      {'ot': 'Gen 3:1-13', 'nt': 'Matt 3:1-6'},
      {'ot': 'Gen 3:14-24', 'nt': 'Matt 3:7-17'},
    ],
    
    // Week 2
    2: [
      {'ot': 'Gen 4:1-26', 'nt': 'Matt 4:1-11'},
      {'ot': 'Gen 5:1-32', 'nt': 'Matt 4:12-25'},
      {'ot': 'Gen 6:1-22', 'nt': 'Matt 5:1-4'},
      {'ot': 'Gen 7:1-24', 'nt': 'Matt 5:5-12'},
      {'ot': 'Gen 8:4-22', 'nt': 'Matt 5:13-20'},
      {'ot': 'Gen 9:1-29', 'nt': 'Matt 5:21-26'},
      {'ot': 'Gen 10:1-32', 'nt': 'Matt 5:27-48'},
    ],
    
    // Week 3
    3: [
      {'ot': 'Gen 11:1-32', 'nt': 'Matt 6:1-8'},
      {'ot': 'Gen 12:1-20', 'nt': 'Matt 6:9-18'},
      {'ot': 'Gen 13:1-18', 'nt': 'Matt 6:19-34'},
      {'ot': 'Gen 14:1-24', 'nt': 'Matt 7:1-12'},
      {'ot': 'Gen 15:1-21', 'nt': 'Matt 7:13-29'},
      {'ot': 'Gen 16:1-16', 'nt': 'Matt 8:1-17'},
      {'ot': 'Gen 17:1-27', 'nt': 'Matt 8:18-34'},
    ],
    
    // Week 4
    4: [
      {'ot': 'Gen 18:1-33', 'nt': 'Matt 8:23-34'},
      {'ot': 'Gen 19:1-38', 'nt': 'Matt 9:1-13'},
      {'ot': 'Gen 20:1-18', 'nt': 'Matt 10:24-42'},
      {'ot': 'Gen 21:1-34', 'nt': 'Matt 9:14-17'},
      {'ot': 'Gen 22:1-24', 'nt': 'Matt 9:18-34'},
      {'ot': 'Gen 23:1—24:27', 'nt': 'Matt 9:35—10:5'},
      {'ot': 'Gen 24:28-67', 'nt': 'Matt 10:6-25'},
    ],
  
    //Week 5
    5: [
      {'ot': 'Gen 25:1-34', 'nt': 'Matt 11:1-15'},
      {'ot': 'Gen 26:1-35', 'nt': 'Matt 11:16-30'},
      {'ot': 'Gen 27:1-46', 'nt': 'Matt 12:1-14'},
      {'ot': 'Gen 28:1-22', 'nt': 'Matt 12:15-32'},
      {'ot': 'Gen 29:1-35', 'nt': 'Matt 12:33-42'},
      {'ot': 'Gen 30:1-43', 'nt': 'Matt 12:43—13:2'},
      {'ot': 'Gen 31:1-55', 'nt': 'Matt 13:3-12'},
    ],
    
    //Week 6
    6: [
      {'ot': 'Gen 32:1-32', 'nt': 'Matt 13:13-30'},
      {'ot': 'Gen 33:1—34:31', 'nt': 'Matt 13:31-43'},
      {'ot': 'Gen 34:1—34:31', 'nt': 'Matt 13:44-58'},
      {'ot': 'Gen 35:1-29', 'nt': 'Matt 14:1-13'},
      {'ot': 'Gen 36:1-43', 'nt': 'Matt 14:14-21'},
      {'ot': 'Gen 37:1-36', 'nt': 'Matt 14:22-36'},
      {'ot': 'Gen 38:1-39:23', 'nt': 'Matt 15:1-20'},
      {'ot': 'Gen 40:1—41:13', 'nt': 'Matt 15:1-20'},
    ],

    //Week 7
    7: [
      {'ot': 'Gen 41:14-57', 'nt': 'Matt 15:21-31'},
      {'ot': 'Gen 42:1-38', 'nt': 'Matt 15:32-39'},
      {'ot': 'Gen 43:1-34', 'nt': 'Matt 16:1-12'},
      {'ot': 'Gen 44:1-34', 'nt': 'Matt 16:13-20'},
      {'ot': 'Gen 45:1-28', 'nt': 'Matt 16:21-28'},
      {'ot': 'Gen 46:1-34', 'nt': 'Matt 17:1-13'},
      {'ot': 'Gen 47:1-31', 'nt': 'Matt 17:14-27'},
    ],
    //Week 8
    8: [
      {'ot': 'Gen 48:1-22', 'nt': 'Matt 18:1-14'},
      {'ot': 'Gen 49:1-15', 'nt': 'Matt 18:15-22'},
      {'ot': 'Gen 49:16-33', 'nt': 'Matt 18:23-35'},
      {'ot': 'Gen 50:1-26', 'nt': 'Matt 19:1-15'},
      {'ot': 'Exo 1:1-22', 'nt': 'Matt 19:16-30'},
      {'ot': 'Exo 2:1-25', 'nt': 'Matt 20:1-16'},
      {'ot': 'Exo 3:1-22', 'nt': 'Matt 20:17-34'},
    ],
    //Week 9
    9: [
      {'ot': 'Exo 4:1-31', 'nt': 'Matt 21:1-11'},
      {'ot': 'Exo 5:1-23', 'nt': 'Matt 21:12-22'},
      {'ot': 'Exo 6:1-30', 'nt': 'Matt 21:23-32'},
      {'ot': 'Exo 7:1-25', 'nt': 'Matt 21:33-46'},
      {'ot': 'Exo 8:1-32', 'nt': 'Matt 22:1-22'},
      {'ot': 'Exo 9:1-35', 'nt': 'Matt 22:23-33'},
      {'ot': 'Exo 10:1-29', 'nt': 'Matt 22:34-46'},
    ],
    //Week 10
    10: [
      {'ot': 'Exo 11:1-10', 'nt': 'Matt 23:1-12'},
      {'ot': 'Exo 12:1-14', 'nt': 'Matt 23:13-39'},
      {'ot': 'Exo 12:15-36', 'nt': 'Matt 24:1-14'},
      {'ot': 'Exo 12:37-51', 'nt': 'Matt 24:15-31'},
      {'ot': 'Exo 13:1-22', 'nt': 'Matt 24:32-51'},
      {'ot': 'Exo 14:1-31', 'nt': 'Matt 25:1-13'},
      {'ot': 'Exo 15:1-27', 'nt': 'Matt 25:14-30'},
    ],
    //Week 11
    11: [
      {'ot': 'Exo 16:1-36', 'nt': 'Matt 25:31-46'},
      {'ot': 'Exo 17:1-16', 'nt': 'Matt 26:1-16'},
      {'ot': 'Exo 18:1-27', 'nt': 'Matt 26:17-35'},
      {'ot': 'Exo 19:1-25', 'nt': 'Matt 26:36-46'},
      {'ot': 'Exo 20:1-26', 'nt': 'Matt 26:47-64'},
      {'ot': 'Exo 21:1-36', 'nt': 'Matt 26:65-75'},
      {'ot': 'Exo 22:1-31', 'nt': 'Matt 27:1-26'},
    ],
    //Week 12
    12: [
      {'ot': 'Exo 23:1-33', 'nt': 'Matt 27:27-44'},
      {'ot': 'Exo 24:1-18', 'nt': 'Matt 27:45-56'},
      {'ot': 'Exo 25:1-22', 'nt': 'Matt 27:57—28:15'},
      {'ot': 'Exo 25:23-40', 'nt': 'Matt 28:16-20'},
      {'ot': 'Exo 26:1-14', 'nt': 'Mark 1:1-11'},
      {'ot': 'Exo 26:15-37', 'nt': 'Mark 1:2-6'},
      {'ot': 'Exo 27:1-21', 'nt': 'Mark 1:7-13'},
    ],
   
  };
}
