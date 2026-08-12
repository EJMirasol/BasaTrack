import '../models/reading_task.dart';
import '../../utils/date_utils.dart';

/// Provides a 104-week Bible reading plan (2 years)
/// Each week has 7 days with OT and NT readings
class ReadingPlanData {
  ReadingPlanData._();

  /// The official start date of the reading plan
  static final DateTime planStartDate = DateUtils.planStartDate;

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

  /// Get the number of days in a given week (6 or 7)
  static int getDaysInWeek(int weekNumber) {
    final weekReadings = _readingPlan[weekNumber];
    if (weekReadings != null) return weekReadings.length;
    return weekNumber <= 31 ? 7 : 6;
  }

  /// Get raw readings for a specific week
  static List<Map<String, String>>? getWeekReadings(int weekNumber) {
    return _readingPlan[weekNumber];
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
    const verseStart = 1;
    final verseEnd = 10 + (chapter % 20);

    if (chapter <= 50) return 'Gen $chapter:$verseStart-$verseEnd';
    if (chapter <= 90) return 'Ex ${chapter - 50}:$verseStart-$verseEnd';
    if (chapter <= 117) return 'Lev ${chapter - 90}:$verseStart-$verseEnd';
    if (chapter <= 153) return 'Num ${chapter - 117}:$verseStart-$verseEnd';
    if (chapter <= 187) return 'Deut ${chapter - 153}:$verseStart-$verseEnd';
    // ... continue with other books
    return 'Gen 1:1-10'; // Fallback
  }

  /// Generate NT reference
  static String _getNTReference(int chapter) {
    const verseStart = 1;
    final verseEnd = 8 + (chapter % 15);

    if (chapter <= 28) return 'Matt $chapter:$verseStart-$verseEnd';
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
      {'ot': 'Gen 7:1-8:3', 'nt': 'Matt 5:5-12'},
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
      {'ot': 'Gen 16:1-16', 'nt': 'Matt 8:1-13'},
      {'ot': 'Gen 17:1-27', 'nt': 'Matt 8:14-22'},
    ],

    // Week 4
    4: [
      {'ot': 'Gen 18:1-33', 'nt': 'Matt 8:23-34'},
      {'ot': 'Gen 19:1-38', 'nt': 'Matt 9:1-13'},
      {'ot': 'Gen 20:1-18', 'nt': 'Matt 9:14-17'},
      {'ot': 'Gen 21:1-34', 'nt': 'Matt 9:18-34'},
      {'ot': 'Gen 22:1-24', 'nt': 'Matt 9:35-10:5'},
      {'ot': 'Gen 23:1—24:27', 'nt': 'Matt 10:6-25'},
      {'ot': 'Gen 24:28-67', 'nt': 'Matt 10:26-42'},
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
      {'ot': 'Gen 35:1-29', 'nt': 'Matt 13:44-58'},
      {'ot': 'Gen 36:1-43', 'nt': 'Matt 14:1-13'},
      {'ot': 'Gen 37:1-36', 'nt': 'Matt 14:14-21'},
      {'ot': 'Gen 38:1-39:23', 'nt': 'Matt 14:22-36'},
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
      {'ot': 'Exo 26:1-14', 'nt': 'Mark 1:1'},
      {'ot': 'Exo 26:15-37', 'nt': 'Mark 1:2-6'},
      {'ot': 'Exo 27:1-21', 'nt': 'Mark 1:7-13'},
    ],
    // Week 13
    13: [
      {'ot': 'Exo 28:1-21', 'nt': 'Mark 1:14-28'},
      {'ot': 'Exo 28:22-43', 'nt': 'Mark 1:29-45'},
      {'ot': 'Exo 29:1-21', 'nt': 'Mark 2:1-12'},
      {'ot': 'Exo 29:22-46', 'nt': 'Mark 2:13-28'},
      {'ot': 'Exo 30:1-10', 'nt': 'Mark 3:1-19'},
      {'ot': 'Exo 30:11-38', 'nt': 'Mark 3:20-35'},
      {'ot': 'Exo 31:1-17', 'nt': 'Mark 4:1-25'},
    ],
// Week 14
    14: [
      {'ot': 'Exo 31:18—32:35', 'nt': 'Mark 4:26-41'},
      {'ot': 'Exo 33:1-23', 'nt': 'Mark 5:1-20'},
      {'ot': 'Exo 34:1-35', 'nt': 'Mark 5:21-43'},
      {'ot': 'Exo 35:1-35', 'nt': 'Mark 6:1-29'},
      {'ot': 'Exo 36:1-38', 'nt': 'Mark 6:30-56'},
      {'ot': 'Exo 37:1-29', 'nt': 'Mark 7:1-23'},
      {'ot': 'Exo 38:1-31', 'nt': 'Mark 7:24-37'},
    ],
// Week 15
    15: [
      {'ot': 'Exo 39:1-43', 'nt': 'Mark 8:1-26'},
      {'ot': 'Exo 40:1-38', 'nt': 'Mark 8:27—9:1'},
      {'ot': 'Lev 1:1-17', 'nt': 'Mark 9:2-29'},
      {'ot': 'Lev 2:1-16', 'nt': 'Mark 9:30-50'},
      {'ot': 'Lev 3:1-17', 'nt': 'Mark 10:1-16'},
      {'ot': 'Lev 4:1-35', 'nt': 'Mark 10:17-34'},
      {'ot': 'Lev 5:1-19', 'nt': 'Mark 10:35-52'},
    ],
// Week 16
    16: [
      {'ot': 'Lev 6:1-30', 'nt': 'Mark 11:1-16'},
      {'ot': 'Lev 7:1-38', 'nt': 'Mark 11:17-33'},
      {'ot': 'Lev 8:1-36', 'nt': 'Mark 12:1-27'},
      {'ot': 'Lev 9:1-24', 'nt': 'Mark 12:28-44'},
      {'ot': 'Lev 10:1-20', 'nt': 'Mark 13:1-13'},
      {'ot': 'Lev 11:1-47', 'nt': 'Mark 13:14-37'},
      {'ot': 'Lev 12:1-8', 'nt': 'Mark 14:1-26'},
    ],
// Week 17
    17: [
      {'ot': 'Lev 13:1-28', 'nt': 'Mark 14:27-52'},
      {'ot': 'Lev 13:29-59', 'nt': 'Mark 14:53-72'},
      {'ot': 'Lev 14:1-18', 'nt': 'Mark 15:1-15'},
      {'ot': 'Lev 14:19-32', 'nt': 'Mark 15:16-47'},
      {'ot': 'Lev 14:33-57', 'nt': 'Mark 16:1-8'},
      {'ot': 'Lev 15:1-33', 'nt': 'Mark 16:9-20'},
      {'ot': 'Lev 16:1-17', 'nt': 'Luke 1:1-4'},
    ],
// Week 18
    18: [
      {'ot': 'Lev 16:18-34', 'nt': 'Luke 1:5-25'},
      {'ot': 'Lev 17:1-16', 'nt': 'Luke 1:26-46'},
      {'ot': 'Lev 18:1-30', 'nt': 'Luke 1:47-56'},
      {'ot': 'Lev 19:1-37', 'nt': 'Luke 1:57-80'},
      {'ot': 'Lev 20:1-27', 'nt': 'Luke 2:1-8'},
      {'ot': 'Lev 21:1-24', 'nt': 'Luke 2:9-20'},
      {'ot': 'Lev 22:1-33', 'nt': 'Luke 2:21-39'},
    ],
// Week 19
    19: [
      {'ot': 'Lev 23:1-22', 'nt': 'Luke 2:40-52'},
      {'ot': 'Lev 23:23-44', 'nt': 'Luke 3:1-20'},
      {'ot': 'Lev 24:1-23', 'nt': 'Luke 3:21-38'},
      {'ot': 'Lev 25:1-23', 'nt': 'Luke 4:1-13'},
      {'ot': 'Lev 25:24-55', 'nt': 'Luke 4:14-30'},
      {'ot': 'Lev 26:1-24', 'nt': 'Luke 4:31-44'},
      {'ot': 'Lev 26:25-46', 'nt': 'Luke 5:1-26'},
    ],
// Week 20
    20: [
      {'ot': 'Lev 27:1-34', 'nt': 'Luke 5:27—6:16'},
      {'ot': 'Num 1:1-54', 'nt': 'Luke 6:17-38'},
      {'ot': 'Num 2:1-34', 'nt': 'Luke 6:39-49'},
      {'ot': 'Num 3:1-51', 'nt': 'Luke 7:1-17'},
      {'ot': 'Num 4:1-49', 'nt': 'Luke 7:18-23'},
      {'ot': 'Num 5:1-31', 'nt': 'Luke 7:24-35'},
      {'ot': 'Num 6:1-27', 'nt': 'Luke 7:36-50'},
    ],
// Week 21
    21: [
      {'ot': 'Num 7:1-41', 'nt': 'Luke 8:1-15'},
      {'ot': 'Num 7:42-88', 'nt': 'Luke 8:16-25'},
      {'ot': 'Num 7:89—8:26', 'nt': 'Luke 8:26-39'},
      {'ot': 'Num 9:1-23', 'nt': 'Luke 8:40-56'},
      {'ot': 'Num 10:1-36', 'nt': 'Luke 9:1-17'},
      {'ot': 'Num 11:1-35', 'nt': 'Luke 9:18-26'},
      {'ot': 'Num 12:1—13:33', 'nt': 'Luke 9:27-36'},
    ],
// Week 22
    22: [
      {'ot': 'Num 14:1-45', 'nt': 'Luke 9:37-50'},
      {'ot': 'Num 15:1-41', 'nt': 'Luke 9:51-62'},
      {'ot': 'Num 16:1-50', 'nt': 'Luke 10:1-11'},
      {'ot': 'Num 17:1—18:7', 'nt': 'Luke 10:12-24'},
      {'ot': 'Num 18:8-32', 'nt': 'Luke 10:25-37'},
      {'ot': 'Num 19:1-22', 'nt': 'Luke 10:38-42'},
      {'ot': 'Num 20:1-29', 'nt': 'Luke 11:1-13'},
    ],
// Week 23
    23: [
      {'ot': 'Num 21:1-35', 'nt': 'Luke 11:14-26'},
      {'ot': 'Num 22:1-41', 'nt': 'Luke 11:27-36'},
      {'ot': 'Num 23:1-30', 'nt': 'Luke 11:37-54'},
      {'ot': 'Num 24:1-25', 'nt': 'Luke 12:1-12'},
      {'ot': 'Num 25:1-18', 'nt': 'Luke 12:13-21'},
      {'ot': 'Num 26:1-65', 'nt': 'Luke 12:22-34'},
      {'ot': 'Num 27:1-23', 'nt': 'Luke 12:35-48'},
    ],
// Week 24
    24: [
      {'ot': 'Num 28:1-31', 'nt': 'Luke 12:49-59'},
      {'ot': 'Num 29:1-40', 'nt': 'Luke 13:1-9'},
      {'ot': 'Num 30:1—31:24', 'nt': 'Luke 13:10-17'},
      {'ot': 'Num 31:25-54', 'nt': 'Luke 13:18-30'},
      {'ot': 'Num 32:1-42', 'nt': 'Luke 13:31—14:6'},
      {'ot': 'Num 33:1-56', 'nt': 'Luke 14:7-14'},
      {'ot': 'Num 34:1-29', 'nt': 'Luke 14:15-24'},
    ],
// Week 25
    25: [
      {'ot': 'Num 35:1-34', 'nt': 'Luke 14:25-35'},
      {'ot': 'Num 36:1-13', 'nt': 'Luke 15:1-10'},
      {'ot': 'Deut 1:1-46', 'nt': 'Luke 15:11-21'},
      {'ot': 'Deut 2:1-37', 'nt': 'Luke 15:22-32'},
      {'ot': 'Deut 3:1-29', 'nt': 'Luke 16:1-13'},
      {'ot': 'Deut 4:1-49', 'nt': 'Luke 16:14-22'},
      {'ot': 'Deut 5:1-33', 'nt': 'Luke 16:23-31'},
    ],
// Week 26
    26: [
      {'ot': 'Deut 6:1—7:26', 'nt': 'Luke 17:1-19'},
      {'ot': 'Deut 8:1-20', 'nt': 'Luke 17:20-37'},
      {'ot': 'Deut 9:1-29', 'nt': 'Luke 18:1-14'},
      {'ot': 'Deut 10:1-22', 'nt': 'Luke 18:15-30'},
      {'ot': 'Deut 11:1-32', 'nt': 'Luke 18:31-43'},
      {'ot': 'Deut 12:1-32', 'nt': 'Luke 19:1-10'},
      {'ot': 'Deut 13:1—14:21', 'nt': 'Luke 19:11-27'},
    ],
// Week 27
    27: [
      {'ot': 'Deut 14:22—15:23', 'nt': 'Luke 19:28-48'},
      {'ot': 'Deut 16:1-22', 'nt': 'Luke 20:1-19'},
      {'ot': 'Deut 17:1—18:8', 'nt': 'Luke 20:20-38'},
      {'ot': 'Deut 18:9—19:21', 'nt': 'Luke 20:39—21:4'},
      {'ot': 'Deut 20:1—21:17', 'nt': 'Luke 21:5-27'},
      {'ot': 'Deut 21:18—22:30', 'nt': 'Luke 21:28-38'},
      {'ot': 'Deut 23:1-25', 'nt': 'Luke 22:1-20'},
    ],
// Week 28
    28: [
      {'ot': 'Deut 24:1-22', 'nt': 'Luke 22:21-38'},
      {'ot': 'Deut 25:1-19', 'nt': 'Luke 22:39-54'},
      {'ot': 'Deut 26:1-19', 'nt': 'Luke 22:55-71'},
      {'ot': 'Deut 27:1-26', 'nt': 'Luke 23:1-43'},
      {'ot': 'Deut 28:1-68', 'nt': 'Luke 23:44-56'},
      {'ot': 'Deut 29:1-29', 'nt': 'Luke 24:1-12'},
      {'ot': 'Deut 30:1—31:29', 'nt': 'Luke 24:13-35'},
    ],
// Week 29
    29: [
      {'ot': 'Deut 31:30—32:52', 'nt': 'Luke 24:36-53'},
      {'ot': 'Deut 33:1-29', 'nt': 'John 1:1-13'},
      {'ot': 'Deut 34:1-12', 'nt': 'John 1:14-18'},
      {'ot': 'Josh 1:1-18', 'nt': 'John 1:19-34'},
      {'ot': 'Josh 2:1-24', 'nt': 'John 1:35-51'},
      {'ot': 'Josh 3:1-17', 'nt': 'John 2:1-11'},
      {'ot': 'Josh 4:1-24', 'nt': 'John 2:12-22'},
    ],
// Week 30
    30: [
      {'ot': 'Josh 5:1-15', 'nt': 'John 2:23—3:13'},
      {'ot': 'Josh 6:1-27', 'nt': 'John 3:14-21'},
      {'ot': 'Josh 7:1-26', 'nt': 'John 3:22-36'},
      {'ot': 'Josh 8:1-35', 'nt': 'John 4:1-14'},
      {'ot': 'Josh 9:1-27', 'nt': 'John 4:15-26'},
      {'ot': 'Josh 10:1-43', 'nt': 'John 4:27-42'},
      {'ot': 'Josh 11:1-12:24', 'nt': 'John 4:43-54'},
    ],
// Week 31
    31: [
      {'ot': 'Josh 13:1-33', 'nt': 'John 5:1-16'},
      {'ot': 'Josh 14:1—15:63', 'nt': 'John 5:17-30'},
      {'ot': 'Josh 16:1—18:28', 'nt': 'John 5:31-47'},
      {'ot': 'Josh 19:1-51', 'nt': 'John 6:1-15'},
      {'ot': 'Josh 20:1—21:45', 'nt': 'John 6:16-31'},
      {'ot': 'Josh 22:1-34', 'nt': 'John 6:32-51'},
      {'ot': 'Josh 23:1—24:33', 'nt': 'John 6:52-71'},
    ],
// Week 32
    32: [
      {'ot': 'Judg (Huk) 1:1-36', 'nt': 'John 7:1-9'},
      {'ot': 'Judg (Huk) 2:1-23', 'nt': 'John 7:10-24'},
      {'ot': 'Judg (Huk) 3:1-31', 'nt': 'John 7:25-36'},
      {'ot': 'Judg (Huk) 4:1-24', 'nt': 'John 7:37-52'},
      {'ot': 'Judg (Huk) 5:1-31', 'nt': 'John 7:53—8:11'},
      {'ot': 'Judg (Huk) 6:1-40', 'nt': 'John 8:12-27'},
      {'ot': 'Judg (Huk) 7:1-25', 'nt': 'John 8:28-44'},
    ],
// Week 33
    33: [
      {'ot': 'Judg (Huk) 8:1-35', 'nt': 'John 8:45-59'},
      {'ot': 'Judg (Huk) 9:1-57', 'nt': 'John 9:1-13'},
      {'ot': 'Judg (Huk) 10:1—11:40', 'nt': 'John 9:14-34'},
      {'ot': 'Judg (Huk) 12:1—13:25', 'nt': 'John 9:35—10:9'},
      {'ot': 'Judg (Huk) 14:1—15:20', 'nt': 'John 10:10-30'},
      {'ot': 'Judg (Huk) 16:1-31', 'nt': 'John 10:31—11:4'},
      {'ot': 'Judg (Huk) 17:1—18:31', 'nt': 'John 11:5-22'},
    ],
// Week 34
    34: [
      {'ot': 'Judg (Huk) 19:1-30', 'nt': 'John 11:23-40'},
      {'ot': 'Judg (Huk) 20:1-48', 'nt': 'John 11:41-57'},
      {'ot': 'Judg (Huk) 21:1-25', 'nt': 'John 12:1-11'},
      {'ot': 'Ruth 1:1-22', 'nt': 'John 12:12-24'},
      {'ot': 'Ruth 2:1-23', 'nt': 'John 12:25-36'},
      {'ot': 'Ruth 3:1-18', 'nt': 'John 12:37-50'},
      {'ot': 'Ruth 4:1-22', 'nt': 'John 13:1-11'},
    ],
// Week 35
    35: [
      {'ot': '1 Sam 1:1-28', 'nt': 'John 13:12-30'},
      {'ot': '1 Sam 2:1-36', 'nt': 'John 13:31-38'},
      {'ot': '1 Sam 3:1—4:22', 'nt': 'John 14:1-6'},
      {'ot': '1 Sam 5:1—6:21', 'nt': 'John 14:7-20'},
      {'ot': '1 Sam 7:1—8:22', 'nt': 'John 14:21-31'},
      {'ot': '1 Sam 9:1-27', 'nt': 'John 15:1-11'},
      {'ot': '1 Sam 10:1—11:15', 'nt': 'John 15:22-27'},
    ],
// Week 36
    36: [
      {'ot': '1 Sam 12:1—13:23', 'nt': 'John 16:1-15'},
      {'ot': '1 Sam 14:1-52', 'nt': 'John 16:16-33'},
      {'ot': '1 Sam 15:1-35', 'nt': 'John 17:1-5'},
      {'ot': '1 Sam 16:1-23', 'nt': 'John 17:6-13'},
      {'ot': '1 Sam 17:1-58', 'nt': 'John 17:14-24'},
      {'ot': '1 Sam 18:1-30', 'nt': 'John 17:25—18:11'},
      {'ot': '1 Sam 19:1-24', 'nt': 'John 18:12-27'},
    ],
// Week 37
    37: [
      {'ot': '1 Sam 20:1-42', 'nt': 'John 18:28-40'},
      {'ot': '1 Sam 21:1—22:23', 'nt': 'John 19:1-16'},
      {'ot': '1 Sam 23:1—24:22', 'nt': 'John 19:17-30'},
      {'ot': '1 Sam 25:1-44', 'nt': 'John 19:31-42'},
      {'ot': '1 Sam 26:1-25', 'nt': 'John 20:1-13'},
      {'ot': '1 Sam 27:1—28:25', 'nt': 'John 20:14-18'},
      {'ot': '1 Sam 29:1—30:31', 'nt': 'John 20:19-22'},
    ],
// Week 38
    38: [
      {'ot': '1 Sam 31:1-13', 'nt': 'John 20:23-31'},
      {'ot': '2 Sam 1:1-27', 'nt': 'John 21:1-14'},
      {'ot': '2 Sam 2:1-32', 'nt': 'John 21:15-22'},
      {'ot': '2 Sam 3:1-39', 'nt': 'John 21:23-25'},
      {'ot': '2 Sam 4:1—5:25', 'nt': 'Acts (Buh) 1:1-8'},
      {'ot': '2 Sam 6:1-23', 'nt': 'Acts (Buh) 1:9-14'},
      {'ot': '2 Sam 7:1-29', 'nt': 'Acts (Buh) 1:15-26'},
    ],
// Week 39
    39: [
      {'ot': '2 Sam 8:1—9:13', 'nt': 'Acts (Buh) 2:1-13'},
      {'ot': '2 Sam 10:1—11:27', 'nt': 'Acts (Buh) 2:14-21'},
      {'ot': '2 Sam 12:1-31', 'nt': 'Acts (Buh) 2:22-36'},
      {'ot': '2 Sam 13:1-39', 'nt': 'Acts (Buh) 2:37-41'},
      {'ot': '2 Sam 14:1-33', 'nt': 'Acts (Buh) 2:42-47'},
      {'ot': '2 Sam 15:1—16:23', 'nt': 'Acts (Buh) 3:1-18'},
      {'ot': '2 Sam 17:1—18:33', 'nt': 'Acts (Buh) 3:19—4:22'},
    ],
// Week 40
    40: [
      {'ot': '2 Sam 19:1-43', 'nt': 'Acts (Buh) 4:23-37'},
      {'ot': '2 Sam 20:1—21:22', 'nt': 'Acts (Buh) 5:1-16'},
      {'ot': '2 Sam 22:1-51', 'nt': 'Acts (Buh) 5:17-32'},
      {'ot': '2 Sam 23:1-39', 'nt': 'Acts (Buh) 5:33-42'},
      {'ot': '2 Sam 24:1-25', 'nt': 'Acts (Buh) 6:1—7:1'},
      {'ot': '1 Kings 1:1-19', 'nt': 'Acts (Buh) 7:2-29'},
      {'ot': '1 Kings 1:20-53', 'nt': 'Acts (Buh) 7:30-60'},
    ],
// Week 41
    41: [
      {'ot': '1 Kings 2:1-46', 'nt': 'Acts (Buh) 8:1-13'},
      {'ot': '1 Kings 3:1-28', 'nt': 'Acts (Buh) 8:14-25'},
      {'ot': '1 Kings 4:1-34', 'nt': 'Acts (Buh) 8:26-40'},
      {'ot': '1 Kings 5:1—6:38', 'nt': 'Acts (Buh) 9:1-19'},
      {'ot': '1 Kings 7:1-22', 'nt': 'Acts (Buh) 9:20-43'},
      {'ot': '1 Kings 7:23-51', 'nt': 'Acts (Buh) 10:1-16'},
      {'ot': '1 Kings 8:1-36', 'nt': 'Acts (Buh) 10:17-33'},
    ],
// Week 42
    42: [
      {'ot': '1 Kings 8:37-66', 'nt': 'Acts (Buh) 10:34-48'},
      {'ot': '1 Kings 9:1-28', 'nt': 'Acts (Buh) 11:1-18'},
      {'ot': '1 Kings 10:1-29', 'nt': 'Acts (Buh) 11:19-30'},
      {'ot': '1 Kings 11:1-43', 'nt': 'Acts (Buh) 12:1-25'},
      {'ot': '1 Kings 12:1-33', 'nt': 'Acts (Buh) 13:1-12'},
      {'ot': '1 Kings 13:1-34', 'nt': 'Acts (Buh) 13:13-43'},
      {'ot': '1 Kings 14:1-31', 'nt': 'Acts (Buh) 13:44—14:5'},
    ],
// Week 43
    43: [
      {'ot': '1 Kings 15:1-34', 'nt': 'Acts (Buh) 14:6-28'},
      {'ot': '1 Kings 16:1—17:24', 'nt': 'Acts (Buh) 15:1-12'},
      {'ot': '1 Kings 18:1-46', 'nt': 'Acts (Buh) 15:13-34'},
      {'ot': '1 Kings 19:1-21', 'nt': 'Acts (Buh) 15:35—16:5'},
      {'ot': '1 Kings 20:1-43', 'nt': 'Acts (Buh) 16:6-18'},
      {'ot': '1 Kings 21:1—22:53', 'nt': 'Acts (Buh) 16:19-40'},
      {'ot': '2 Kings 1:1-18', 'nt': 'Acts (Buh) 17:1-18'},
    ],
// Week 44
    44: [
      {'ot': '2 Kings 2:1—3:27', 'nt': 'Acts (Buh) 17:19-34'},
      {'ot': '2 Kings 4:1-44', 'nt': 'Acts (Buh) 18:1-17'},
      {'ot': '2 Kings 5:1—6:33', 'nt': 'Acts (Buh) 18:18-28'},
      {'ot': '2 Kings 7:1-20', 'nt': 'Acts (Buh) 19:1-20'},
      {'ot': '2 Kings 8:1-29', 'nt': 'Acts (Buh) 19:21-41'},
      {'ot': '2 Kings 9:1-37', 'nt': 'Acts (Buh) 20:1-12'},
      {'ot': '2 Kings 10:1-36', 'nt': 'Acts (Buh) 20:13-38'},
    ],
// Week 45
    45: [
      {'ot': '2 Kings 11:1—12:21', 'nt': 'Acts (Buh) 21:1-14'},
      {'ot': '2 Kings 13:1—14:29', 'nt': 'Acts (Buh) 21:15-26'},
      {'ot': '2 Kings 15:1-38', 'nt': 'Acts (Buh) 21:27-40'},
      {'ot': '2 Kings 16:1-20', 'nt': 'Acts (Buh) 22:1-21'},
      {'ot': '2 Kings 17:1-31', 'nt': 'Acts (Buh) 22:22-29'},
      {'ot': '2 Kings 18:1-37', 'nt': 'Acts (Buh) 22:30—23:11'},
      {'ot': '2 Kings 19:1-37', 'nt': 'Acts (Buh) 23:12-15'},
    ],
// Week 46
    46: [
      {'ot': '2 Kings 20:1—21:26', 'nt': 'Acts (Buh) 23:16-30'},
      {'ot': '2 Kings 22:1-20', 'nt': 'Acts (Buh) 23:31—24:21'},
      {'ot': '2 Kings 23:1-37', 'nt': 'Acts (Buh) 24:22—25:5'},
      {'ot': '2 Kings 24:1—25:30', 'nt': 'Acts (Buh) 25:6-27'},
      {'ot': '1 Chron 1:1-54', 'nt': 'Acts (Buh) 26:1-13'},
      {'ot': '1 Chron 2:1—3:24', 'nt': 'Acts (Buh) 26:14-32'},
      {'ot': '1 Chron 4:1—5:26', 'nt': 'Acts (Buh) 27:1-26'},
    ],
// Week 47
    47: [
      {'ot': '1 Chron 6:1-81', 'nt': 'Acts (Buh) 27:27—28:10'},
      {'ot': '1 Chron 7:1-40', 'nt': 'Acts (Buh) 28:11-22'},
      {'ot': '1 Chron 8:1-40', 'nt': 'Acts (Buh) 28:23-31'},
      {'ot': '1 Chron 9:1-44', 'nt': 'Rom 1:1-2'},
      {'ot': '1 Chron 10:1—11:47', 'nt': 'Rom 1:3-7'},
      {'ot': '1 Chron 12:1-40', 'nt': 'Rom 1:8-17'},
      {'ot': '1 Chron 13:1—14:17', 'nt': 'Rom 1:18-25'},
    ],
// Week 48
    48: [
      {'ot': '1 Chron 15:1—16:43', 'nt': 'Rom 1:26—2:10'},
      {'ot': '1 Chron 17:1-27', 'nt': 'Rom 2:11-29'},
      {'ot': '1 Chron 18:1—19:19', 'nt': 'Rom 3:1-20'},
      {'ot': '1 Chron 20:1—21:30', 'nt': 'Rom 3:21-31'},
      {'ot': '1 Chron 22:1—23:32', 'nt': 'Rom 4:1-12'},
      {'ot': '1 Chron 24:1—25:31', 'nt': 'Rom 4:13-25'},
      {'ot': '1 Chron 26:1-32', 'nt': 'Rom 5:1-11'},
    ],
// Week 49
    49: [
      {'ot': '1 Chron 27:1-34', 'nt': 'Rom 5:12-17'},
      {'ot': '1 Chron 28:—29:30', 'nt': 'Rom 5:18—6:5'},
      {'ot': '2 Chron 1:1-17', 'nt': 'Rom 6:6-11'},
      {'ot': '2 Chron 2:1—3:17', 'nt': 'Rom 6:12-23'},
      {'ot': '2 Chron 4:1—5:14', 'nt': 'Rom 7:1-12'},
      {'ot': '2 Chron 6:1-42', 'nt': 'Rom 7:13-25'},
      {'ot': '2 Chron 7:1—8:18', 'nt': 'Rom 8:1-2'},
    ],
// Week 50
    50: [
      {'ot': '2 Chron 9:1—10:19', 'nt': 'Rom 8:3-6'},
      {'ot': '2 Chron 11:1—12:16', 'nt': 'Rom 8:7-13'},
      {'ot': '2 Chron 13:1—15:19', 'nt': 'Rom 8:14-25'},
      {'ot': '2 Chron 16:1—17:19', 'nt': 'Rom 8:26-39'},
      {'ot': '2 Chron 18:1—19:11', 'nt': 'Rom 9:1-18'},
      {'ot': '2 Chron 20:1-37', 'nt': 'Rom 9:19—10:3'},
      {'ot': '2 Chron 21:1—22:12', 'nt': 'Rom 10:4-15'},
    ],
// Week 51
    51: [
      {'ot': '2 Chron 23:1—24:27', 'nt': 'Rom 10:16—11:10'},
      {'ot': '2 Chron 25:1—26:23', 'nt': 'Rom 11:11-22'},
      {'ot': '2 Chron 27:1—28:27', 'nt': 'Rom 11:23-36'},
      {'ot': '2 Chron 29:1-36', 'nt': 'Rom 12:1-3'},
      {'ot': '2 Chron 30:1—31:21', 'nt': 'Rom 12:4-21'},
      {'ot': '2 Chron 32:1-33', 'nt': 'Rom 13:1-14'},
      {'ot': '2 Chron 33:1—34:33', 'nt': 'Rom 14:1-12'},
    ],
// Week 52
    52: [
      {'ot': '2 Chron 35:1—36:23', 'nt': 'Rom 14:13-23'},
      {'ot': 'Ezra 1:1-11', 'nt': 'Rom 15:1-13'},
      {'ot': 'Ezra 2:1-70', 'nt': 'Rom 15:14-33'},
      {'ot': 'Ezra 3:1—4:24', 'nt': 'Rom 16:1-5'},
      {'ot': 'Ezra 5:1—6:22', 'nt': 'Rom 16:6-24'},
      {'ot': 'Ezra 7:1-28', 'nt': 'Rom 16:25-27'},
      {'ot': 'Ezra 8:1-36', 'nt': '1 Cor 1:1-4'},
    ],
// Week 53
    53: [
      {'ot': 'Ezra 9:1—10:44', 'nt': '1 Cor 1:5-9'},
      {'ot': 'Neh 1:1-11', 'nt': '1 Cor 1:10-17'},
      {'ot': 'Neh 2:1—3:32', 'nt': '1 Cor 1:18-31'},
      {'ot': 'Neh 4:1—5:19', 'nt': '1 Cor 2:1-5'},
      {'ot': 'Neh 6:1-19', 'nt': '1 Cor 2:6-10'},
      {'ot': 'Neh 7:1-73', 'nt': '1 Cor 2:11-16'},
      {'ot': 'Neh 8:1-18', 'nt': '1 Cor 3:1-9'},
    ],
// Week 54
    54: [
      {'ot': 'Neh 9:1-20', 'nt': '1 Cor 3:10-13'},
      {'ot': 'Neh 9:21-38', 'nt': '1 Cor 3:14-23'},
      {'ot': 'Neh 10:1—11:36', 'nt': '1 Cor 4:1-9'},
      {'ot': 'Neh 12:1-47', 'nt': '1 Cor 4:10-21'},
      {'ot': 'Neh 13:1-31', 'nt': '1 Cor 5:1-13'},
      {'ot': 'Esth 1:1-22', 'nt': '1 Cor 6:1-11'},
      {'ot': 'Esth 2:1—3:15', 'nt': '1 Cor 6:12-20'},
    ],
// Week 55
    55: [
      {'ot': 'Esth 4:1—5:14', 'nt': '1 Cor 7:1-16'},
      {'ot': 'Esth 6:1—7:10', 'nt': '1 Cor 7:17-24'},
      {'ot': 'Esth 8:1-17', 'nt': '1 Cor 7:25-40'},
      {'ot': 'Esth 9:1—10:3', 'nt': '1 Cor 8:1-13'},
      {'ot': 'Job 1:1-22', 'nt': '1 Cor 9:1-15'},
      {'ot': 'Job 2:1—3:26', 'nt': '1 Cor 9:16-27'},
      {'ot': 'Job 4:1—5:27', 'nt': '1 Cor 10:1-4'},
    ],
// Week 56
    56: [
      {'ot': 'Job 6:1—7:21', 'nt': '1 Cor 10:5-13'},
      {'ot': 'Job 8:1—9:35', 'nt': '1 Cor 10:14-33'},
      {'ot': 'Job 10:1—11:20', 'nt': '1 Cor 11:1-6'},
      {'ot': 'Job 12:1—13:28', 'nt': '1 Cor 11:7-16'},
      {'ot': 'Job 14:1—15:35', 'nt': '1 Cor 11:17-26'},
      {'ot': 'Job 16:1—17:16', 'nt': '1 Cor 11:27-34'},
      {'ot': 'Job 18:1—19:29', 'nt': '1 Cor 12:1-11'},
    ],
// Week 57
    57: [
      {'ot': 'Job 20:1—21:34', 'nt': '1 Cor 12:12-22'},
      {'ot': 'Job 22:1—23:17', 'nt': '1 Cor 12:23-31'},
      {'ot': 'Job 24:1—25:6', 'nt': '1 Cor 13:1-13'},
      {'ot': 'Job 26:1—27:23', 'nt': '1 Cor 14:1-12'},
      {'ot': 'Job 28:1—29:25', 'nt': '1 Cor 14:13-25'},
      {'ot': 'Job 30:1—31:40', 'nt': '1 Cor 14:26-33'},
      {'ot': 'Job 32:1—33:33', 'nt': '1 Cor 14:34-40'},
    ],
// Week 58
    58: [
      {'ot': 'Job 34:1—35:16', 'nt': '1 Cor 15:1-19'},
      {'ot': 'Job 36:1-33', 'nt': '1 Cor 15:20-28'},
      {'ot': 'Job 37:1-24', 'nt': '1 Cor 15:29-34'},
      {'ot': 'Job 38:1-41', 'nt': '1 Cor 15:35-49'},
      {'ot': 'Job 39:1-30', 'nt': '1 Cor 15:50-58'},
      {'ot': 'Job 40:1-24', 'nt': '1 Cor 16:1-9'},
      {'ot': 'Job 41:1-34', 'nt': '1 Cor 16:10-24'},
    ],
// Week 59
    59: [
      {'ot': 'Job 42:1-17', 'nt': '2 Cor 1:1-4'},
      {'ot': 'Psa 1:1-6', 'nt': '2 Cor 1:5-14'},
      {'ot': 'Psa 2:1—3:8', 'nt': '2 Cor 1:15-22'},
      {'ot': 'Psa 4:1—6:10', 'nt': '2 Cor 1:23—2:11'},
      {'ot': 'Psa 7:1—8:9', 'nt': '2 Cor 2:12-17'},
      {'ot': 'Psa 9:1—10:18', 'nt': '2 Cor 3:1-6'},
      {'ot': 'Psa 11:1—15:5', 'nt': '2 Cor 3:7-11'},
    ],
// Week 60
    60: [
      {'ot': 'Psa 16:1—17:15', 'nt': '2 Cor 3:12-18'},
      {'ot': 'Psa 18:1-50', 'nt': '2 Cor 4:1-6'},
      {'ot': 'Psa 19:1—21:13', 'nt': '2 Cor 4:7-12'},
      {'ot': 'Psa 22:1-31', 'nt': '2 Cor 4:13-18'},
      {'ot': 'Psa 23:1—24:10', 'nt': '2 Cor 5:1-8'},
      {'ot': 'Psa 25:1—27:14', 'nt': '2 Cor  5:9-15'},
      {'ot': 'Psa 28:1—30:12', 'nt': '2 Cor 5:16-21'},
    ],
// Week 61
    61: [
      {'ot': 'Psa 31:1—32:11', 'nt': '2 Cor 6:1-13'},
      {'ot': 'Psa 33:1—34:22', 'nt': '2 Cor 6:14—7:4'},
      {'ot': 'Psa 35:1—36:12', 'nt': '2 Cor 7:5-16'},
      {'ot': 'Psa 37:1-40', 'nt': '2 Cor 8:1-15'},
      {'ot': 'Psa 38:1—39:13', 'nt': '2 Cor 8:16-24'},
      {'ot': 'Psa 40:1—41:13', 'nt': '2 Cor 9:1-15'},
      {'ot': 'Psa 42:1—43:5', 'nt': '2 Cor 10:1-6'},
    ],
// Week 62
    62: [
      {'ot': 'Psa 44:1-26', 'nt': '2 Cor 10:7-18'},
      {'ot': 'Psa 45:1-17', 'nt': '2 Cor 11:1-15'},
      {'ot': 'Psa 46:1—48:14', 'nt': '2 Cor 11:16-33'},
      {'ot': 'Psa 49:1—50:23', 'nt': '2 Cor 12:1-10'},
      {'ot': 'Psa 51:1—52:9', 'nt': '2 Cor 12:11-21'},
      {'ot': 'Psa 53:1—55:23', 'nt': '2 Cor 13:1-10'},
      {'ot': 'Psa 56:1—58:11', 'nt': '2 Cor 13:11-14'},
    ],
// Week 63
    63: [
      {'ot': 'Psa 59:1—61:8', 'nt': 'Gal 1:1-5'},
      {'ot': 'Psa 62:1—64:10', 'nt': 'Gal 1:6-14'},
      {'ot': 'Psa 65:1—67:7', 'nt': 'Gal 1:15-24'},
      {'ot': 'Psa 68:1-35', 'nt': 'Gal 2:1-13'},
      {'ot': 'Psa 69:1—70:5', 'nt': 'Gal 2:14-21'},
      {'ot': 'Psa 71:1—72:20', 'nt': 'Gal 3:1-4'},
      {'ot': 'Psa 73:1—74:23', 'nt': 'Gal 3:5-14'},
    ],
// Week 64
    64: [
      {'ot': 'Psa 75:1—77:20', 'nt': 'Gal 3:15-22'},
      {'ot': 'Psa 78:1-72', 'nt': 'Gal 3:23-29'},
      {'ot': 'Psa 79:1—81:16', 'nt': 'Gal 4:1-7'},
      {'ot': 'Psa 82:1—84:12', 'nt': 'Gal 4:8-20'},
      {'ot': 'Psa 85:1—87:7', 'nt': 'Gal 4:21-31'},
      {'ot': 'Psa 88:1—89:52', 'nt': 'Gal 5:1-12'},
      {'ot': 'Psa 90:1—91:16', 'nt': 'Gal 5:13-21'},
    ],
// Week 65
    65: [
      {'ot': 'Psa 92:1—94:23', 'nt': 'Gal 5:22-26'},
      {'ot': 'Psa 95:1—97:12', 'nt': 'Gal 6:1-10'},
      {'ot': 'Psa 98:1—101:8', 'nt': 'Gal 6:11-15'},
      {'ot': 'Psa 102:1—103:22', 'nt': 'Gal 6:16-18'},
      {'ot': 'Psa 104:1—105:45', 'nt': 'Eph 1:1-3'},
      {'ot': 'Psa 106:1-48', 'nt': 'Eph 1:4-6'},
      {'ot': 'Psa 107:1-43', 'nt': 'Eph 1:7-10'},
    ],
// Week 66
    66: [
      {'ot': 'Psa 108:1—109:31', 'nt': 'Eph 1:11-14'},
      {'ot': 'Psa 110:1—112:10', 'nt': 'Eph 1:15-18'},
      {'ot': 'Psa 113:1—115:18', 'nt': 'Eph 1:19-23'},
      {'ot': 'Psa 116:1—118:29', 'nt': 'Eph 2:1-5'},
      {'ot': 'Psa 119:1-32', 'nt': 'Eph 2:6-10'},
      {'ot': 'Psa 119:33-72', 'nt': 'Eph 2:11-14'},
      {'ot': 'Psa 119:73-120', 'nt': 'Eph 2:15-18'},
    ],
// Week 67
    67: [
      {'ot': 'Psa 119:121-176', 'nt': 'Eph 2:19-22'},
      {'ot': 'Psa 120:1—124:8', 'nt': 'Eph 3:1-7'},
      {'ot': 'Psa 125:1—128:6', 'nt': 'Eph 3:8-13'},
      {'ot': 'Psa 129:1—132:18', 'nt': 'Eph 3:14-18'},
      {'ot': 'Psa 133:1—135:21', 'nt': 'Eph 3:19-21'},
      {'ot': 'Psa 136:1—138:8', 'nt': 'Eph 4:1-4'},
      {'ot': 'Psa 139:1—140:13', 'nt': 'Eph 4:5-10'},
    ],
// Week 68
    68: [
      {'ot': 'Psa 141:1—144:15', 'nt': 'Eph 4:11-16'},
      {'ot': 'Psa 145:1—147:20', 'nt': 'Eph 4:17:24'},
      {'ot': 'Psa 148:1—150:6', 'nt': 'Eph 4:25-32'},
      {'ot': 'Prov 1:1-33', 'nt': 'Eph 5:1-10'},
      {'ot': 'Prov 2:1—3:35', 'nt': 'Eph 5:11-21'},
      {'ot': 'Prov 4:1—5:23', 'nt': 'Eph 5:22-26'},
      {'ot': 'Prov 6:1-35', 'nt': 'Eph 5:27-33'},
    ],
// Week 69
    69: [
      {'ot': 'Prov 7:1—8:36', 'nt': 'Eph 6:1-9'},
      {'ot': 'Prov 9:1—10:32', 'nt': 'Eph 6:10-14'},
      {'ot': 'Prov 11:1—12:28', 'nt': 'Eph 6:15-18'},
      {'ot': 'Prov 13:1—14:35', 'nt': 'Eph 6:19-24'},
      {'ot': 'Prov 15:1-33', 'nt': 'Phil 1:1-7'},
      {'ot': 'Prov 16:1-33', 'nt': 'Phil 1:8-18'},
      {'ot': 'Prov 17:1-28', 'nt': 'Phil 1:19-26'},
    ],
// Week 70
    70: [
      {'ot': 'Prov 18:1-24', 'nt': 'Phil 1:27—2:4'},
      {'ot': 'Prov 19:1—20:30', 'nt': 'Phil 2:5-11'},
      {'ot': 'Prov 21:1—22:29', 'nt': 'Phil 2:12-16'},
      {'ot': 'Prov 23:1-35', 'nt': 'Phil 2:17-30'},
      {'ot': 'Prov 24:1—25:28', 'nt': 'Phil 3:1-6'},
      {'ot': 'Prov 26:1—27:27', 'nt': 'Phil 3:7-11'},
      {'ot': 'Prov 28:1—29:27', 'nt': 'Phil 3:12-16'},
    ],
// Week 71
    71: [
      {'ot': 'Prov 30:1-33', 'nt': 'Phil 3:17-21'},
      {'ot': 'Prov 31:1-31', 'nt': 'Phil 4:1-9'},
      {'ot': 'Eccl 1:1-18', 'nt': 'Phil 4:10-23'},
      {'ot': 'Eccl 2:1—3:22', 'nt': 'Col 1:1-8'},
      {'ot': 'Eccl 4:1—5:20', 'nt': 'Col 1:9-13'},
      {'ot': 'Eccl 6:1—7:29', 'nt': 'Col 1:14-23'},
      {'ot': 'Eccl 8:1—9:18', 'nt': 'Col 1:24-29'},
    ],
// Week 72
    72: [
      {'ot': 'Eccl 10:1—11:10', 'nt': 'Col 2:1-7'},
      {'ot': 'Eccl 12:1-14', 'nt': 'Col 2:8-15'},
      {'ot': 'S.S (A.A) 1:1-8', 'nt': 'Col 2:16-23'},
      {'ot': 'S.S (A.A) 1:9-17', 'nt': 'Col 3:1-4'},
      {'ot': 'S.S (A.A) 2:1-17', 'nt': 'Col 3:5-15'},
      {'ot': 'S.S (A.A) 3:1-11', 'nt': 'Col 3:16-25'},
      {'ot': 'S.S (A.A)  4:1-8', 'nt': 'Col 4:1-18'},
    ],
// Week 73
    73: [
      {'ot': 'S.S (A.A) 4:9-16', 'nt': '1 Thes 1:1-3'},
      {'ot': 'S.S (A.A) 5:1-16', 'nt': '1 Thes 1:4-10'},
      {'ot': 'S.S (A.A) 6:1-13', 'nt': '1 Thes 2:1-12'},
      {'ot': 'S.S (A.A) 7:1-13', 'nt': '1 Thes 2:13—3:5'},
      {'ot': 'S.S (A.A) 8:1-14', 'nt': '1 Thes 3:6-13'},
      {'ot': 'Isa 1:1-11', 'nt': '1 Thes 4:1-10'},
      {'ot': 'Isa 1:12-31', 'nt': '1 Thes 4:11—5:11'},
    ],
// Week 74
    74: [
      {'ot': 'Isa 2:1-22', 'nt': '1 Thes 5:12-28'},
      {'ot': 'Isa 3:1-26', 'nt': '2 Thes 1:1-12'},
      {'ot': 'Isa 4:1-6', 'nt': '2 Thes 2:1-17'},
      {'ot': 'Isa 5:1-30', 'nt': '2 Thes 3:1-18'},
      {'ot': 'Isa 6:1-13', 'nt': '1 Tim 1:1-2'},
      {'ot': 'Isa 7:1-25', 'nt': '1 Tim 1:3-4'},
      {'ot': 'Isa 8:1-22', 'nt': '1 Tim 1:5-14'},
    ],
// Week 75
    75: [
      {'ot': 'Isa 9:1-21', 'nt': '1 Tim 1:15-20'},
      {'ot': 'Isa 10:1-34', 'nt': '1 Tim 2:1-7'},
      {'ot': 'Isa 11:1—12:6', 'nt': '1 Tim 2:8-15'},
      {'ot': 'Isa 13:1-22', 'nt': '1 Tim 3:1-13'},
      {'ot': 'Isa 14:1-14', 'nt': '1 Tim 3:14—4:5'},
      {'ot': 'Isa 14:15-32', 'nt': '1 Tim 4:6-16'},
      {'ot': 'Isa 15:1—16:14', 'nt': '1 Tim 5:1-25'},
    ],
// Week 76
    76: [
      {'ot': 'Isa 17:1—18:7', 'nt': '1 Tim 6:1-10'},
      {'ot': 'Isa 19:1-25', 'nt': '1 Tim 6:11-21'},
      {'ot': 'Isa 20:1—21:17', 'nt': '2 Tim 1:1-10'},
      {'ot': 'Isa 22:1-25', 'nt': '2 Tim 1:11-18'},
      {'ot': 'Isa 23:1-18', 'nt': '2 Tim 2:1-15'},
      {'ot': 'Isa 24:1-23', 'nt': '2 Tim 2:16-26'},
      {'ot': 'Isa 25:1-12', 'nt': '2 Tim 3:1-13'},
    ],
// Week 77
    77: [
      {'ot': 'Isa 26:1-21', 'nt': '2 Tim 3:14—4:8'},
      {'ot': 'Isa 27:1-13', 'nt': '2 Tim 4:9-22'},
      {'ot': 'Isa 28:1-29', 'nt': 'Titus 1:1-4'},
      {'ot': 'Isa 29:1-24', 'nt': 'Titus 1:5-16'},
      {'ot': 'Isa 30:1-33', 'nt': 'Titus 2:1-15'},
      {'ot': 'Isa 31:1—32:20', 'nt': 'Titus 3:1-8'},
      {'ot': 'Isa 33:1-24', 'nt': 'Titus 3:9-15'},
    ],
// Week 78
    78: [
      {'ot': 'Isa 34:1-17', 'nt': 'Phil 1:1-11'},
      {'ot': 'Isa 35:1-10', 'nt': 'Phil 1:12-25'},
      {'ot': 'Isa 36:1-22', 'nt': 'Heb 1:1-2'},
      {'ot': 'Isa 37:1-38', 'nt': 'Heb 1:3-5'},
      {'ot': 'Isa 38:1—39:8', 'nt': 'Heb 1:6-14'},
      {'ot': 'Isa 40:1-31', 'nt': 'Heb 2:1-9'},
      {'ot': 'Isa 41:1-29', 'nt': 'Heb 2:10-18'},
    ],
// Week 79
    79: [
      {'ot': 'Isa 42:1-25', 'nt': 'Heb 3:1-6'},
      {'ot': 'Isa 43:1-28', 'nt': 'Heb 3:7-19'},
      {'ot': 'Isa 44:1-28', 'nt': 'Heb 4:1-9'},
      {'ot': 'Isa 45:1-25', 'nt': 'Heb 4:10-13'},
      {'ot': 'Isa 46:1-13', 'nt': 'Heb 4:14-16'},
      {'ot': 'Isa 47:1-15', 'nt': 'Heb 5:1-10'},
      {'ot': 'Isa 48:1-22', 'nt': 'Heb 5:11—6:3'},
    ],
// Week 80
    80: [
      {'ot': 'Isa 49:1-13', 'nt': 'Heb 6:4-8'},
      {'ot': 'Isa 49:14-26', 'nt': 'Heb 6:9-20'},
      {'ot': 'Isa 50:1—51:23', 'nt': 'Heb 7:1-10'},
      {'ot': 'Isa 52:1-15', 'nt': 'Heb 7:11-28'},
      {'ot': 'Isa 53:1-12', 'nt': 'Heb 8:1-6'},
      {'ot': 'Isa 54:1-17', 'nt': 'Heb 8:7-13'},
      {'ot': 'Isa 55:1-13', 'nt': 'Heb 9:1-4'},
    ],
// Week 81
    81: [
      {'ot': 'Isa 56:1-12', 'nt': 'Heb 9:5-14'},
      {'ot': 'Isa 57:1-21', 'nt': 'Heb 9:15-28'},
      {'ot': 'Isa 58:1-14', 'nt': 'Heb 10:1-18'},
      {'ot': 'Isa 59:1-21', 'nt': 'Heb 10:19-28'},
      {'ot': 'Isa 60:1-22', 'nt': 'Heb 10:29-39'},
      {'ot': 'Isa 61:1-11', 'nt': 'Heb 11:1-6'},
      {'ot': 'Isa 62:1-12', 'nt': 'Heb 11:7-19'},
    ],
// Week 82
    82: [
      {'ot': 'Isa 63:1-19', 'nt': 'Heb 11:20-31'},
      {'ot': 'Isa 64:1-12', 'nt': 'Heb 11:32-40'},
      {'ot': 'Isa 65:1-25', 'nt': 'Heb 12:1-2'},
      {'ot': 'Isa 66:1-24', 'nt': 'Heb 12:3-13'},
      {'ot': 'Jer 1:1-19', 'nt': 'Heb 12:14-17'},
      {'ot': 'Jer 2:1-19', 'nt': 'Heb 12:18-26'},
      {'ot': 'Jer 2:20-37', 'nt': 'Heb 12:27-29'},
    ],
// Week 83
    83: [
      {'ot': 'Jer 3:1-25', 'nt': 'Heb 13:1-7'},
      {'ot': 'Jer 4:1-31', 'nt': 'Heb 13:8-12'},
      {'ot': 'Jer 5:1-31', 'nt': 'Heb 13:13-15'},
      {'ot': 'Jer 6:1-30', 'nt': 'Heb 13:16-25'},
      {'ot': 'Jer 7:1-34', 'nt': 'James (Sant) 1:1-8'},
      {'ot': 'Jer 8:1-22', 'nt': 'James (Sant) 1:9-18'},
      {'ot': 'Jer 9:1-26', 'nt': 'James (Sant) 1:19-27'},
    ],
// Week 84
    84: [
      {'ot': 'Jer 10:1-25', 'nt': 'James (Sant) 2:1-13'},
      {'ot': 'Jer 11:1—12:17', 'nt': 'James (Sant) 2:15-26'},
      {'ot': 'Jer 13:1-27', 'nt': 'James (Sant) 3:1-18'},
      {'ot': 'Jer 14:1-22', 'nt': 'James (Sant) 4:1-10'},
      {'ot': 'Jer 15:1-21', 'nt': 'James (Sant) 4:11-17'},
      {'ot': 'Jer 16:1—17:27', 'nt': 'James (Sant) 5:1-12'},
      {'ot': 'Jer 18:1-23', 'nt': 'James (Sant) 5:13-20'},
    ],
// Week 85
    85: [
      {'ot': 'Jer 19:1—20:18', 'nt': '1 Peter 1:1-2'},
      {'ot': 'Jer 21:1—22:30', 'nt': '1 Peter 1:3-4'},
      {'ot': 'Jer 23:1-40', 'nt': '1 Peter 1:5'},
      {'ot': 'Jer 24:1—25:38', 'nt': '1 Peter 1:6-9'},
      {'ot': 'Jer 26:1—27:22', 'nt': '1 Peter 1:10-12'},
      {'ot': 'Jer 28:1—29:32', 'nt': '1 Peter 1:13-17'},
      {'ot': 'Jer 30:1-24', 'nt': '1 Peter 1:18-25'},
    ],
// Week 86
    86: [
      {'ot': 'Jer 31:1-23', 'nt': '1 Peter 2:1-3'},
      {'ot': 'Jer 31:24-40', 'nt': '1 Peter 2:4-8'},
      {'ot': 'Jer 32:1-44', 'nt': '1 Peter 2:9-17'},
      {'ot': 'Jer 33:1-26', 'nt': '1 Peter 2:18-25'},
      {'ot': 'Jer 34:1-22', 'nt': '1 Peter 3:1-13'},
      {'ot': 'Jer 35:1-19', 'nt': '1 Peter 3:14-22'},
      {'ot': 'Jer 36:1-32', 'nt': '1 Peter 4:1-6'},
    ],
// Week 87
    87: [
      {'ot': 'Jer 37:1-21', 'nt': '1 Peter 4:7-16'},
      {'ot': 'Jer 38:1-28', 'nt': '1 Peter 4:17-19'},
      {'ot': 'Jer 39:1—40:16', 'nt': '1 Peter 5:1-4'},
      {'ot': 'Jer 41:1—42:22', 'nt': '1 Peter 5:5-9'},
      {'ot': 'Jer 43:1—44:30', 'nt': '1 Peter 5:10-14'},
      {'ot': 'Jer 45:1—46:28', 'nt': '2 Peter 1:1-2'},
      {'ot': 'Jer 47:1—48:16', 'nt': '2 Peter 1:3-4'},
    ],
// Week 88
    88: [
      {'ot': 'Jer 48:17-47', 'nt': '2 Peter 1:5-8'},
      {'ot': 'Jer 49:1-22', 'nt': '2 Peter 1:9-11'},
      {'ot': 'Jer 49:23-39', 'nt': '2 Peter 1:12-18'},
      {'ot': 'Jer 50:1-27', 'nt': '2 Peter 1:19-21'},
      {'ot': 'Jer 50:28-46', 'nt': '2 Peter 2:1-3'},
      {'ot': 'Jer 51:1-27', 'nt': '2 Peter 2:4-11'},
      {'ot': 'Jer 51:28-64', 'nt': '2 Peter 2:12-22'},
    ],
// Week 89
    89: [
      {'ot': 'Jer 52:1-34', 'nt': '2 Peter 3:1-6'},
      {'ot': 'Lam 1:1-22', 'nt': '2 Peter 3:7-9'},
      {'ot': 'Lam 2:1-22', 'nt': '2 Peter 3:10-12'},
      {'ot': 'Lam 3:1-39', 'nt': '2 Peter 3:13-15'},
      {'ot': 'Lam 3:40-66', 'nt': '2 Peter 3:16'},
      {'ot': 'Lam 4:1-22', 'nt': '2 Peter 3:17-18'},
      {'ot': 'Lam 5:1-22', 'nt': '1 John 1:1-2'},
    ],
// Week 90
    90: [
      {'ot': 'Ezek 1:1-14', 'nt': '1 John 1:3-4'},
      {'ot': 'Ezek 1:15-28', 'nt': '1 John 1:5'},
      {'ot': 'Ezek 2:1—3:27', 'nt': '1 John 1:6'},
      {'ot': 'Ezek 4:1—5:17', 'nt': '1 John 1:7'},
      {'ot': 'Ezek 6:1—7:27', 'nt': '1 John 1:8-10'},
      {'ot': 'Ezek 8:1—9:11', 'nt': '1 John 2:1-2'},
      {'ot': 'Ezek 10:1—11:25', 'nt': '1 John 2:3-11'},
    ],
// Week 91
    91: [
      {'ot': 'Ezek 12:1—13:23', 'nt': '1 John 2:12-14'},
      {'ot': 'Ezek 14:1—15:8', 'nt': '1 John 2:15-19'},
      {'ot': 'Ezek 16:1-63', 'nt': '1 John 2:20-23'},
      {'ot': 'Ezek 17:1—18:32', 'nt': '1 John 2:24-27'},
      {'ot': 'Ezek 19:1-14', 'nt': '1 John 2:28-29'},
      {'ot': 'Ezek 20:1-49', 'nt': '1 John 3:1-5'},
      {'ot': 'Ezek 21:1-32', 'nt': '1 John 3:6-10'},
    ],
// Week 92
    92: [
      {'ot': 'Ezek 22:1-31', 'nt': '1 John 3:11-18'},
      {'ot': 'Ezek 23:1-49', 'nt': '1 John 3:19-24'},
      {'ot': 'Ezek 24:1-27', 'nt': '1 John 4:1-6'},
      {'ot': 'Ezek 25:1—26:21', 'nt': '1 John 4:7-11'},
      {'ot': 'Ezek 27:1-36', 'nt': '1 John 4:12-15'},
      {'ot': 'Ezek 28:1-26', 'nt': '1 John 4:16—5:3'},
      {'ot': 'Ezek 29:1—30:26', 'nt': '1 John 5:4-13'},
    ],
// Week 93
    93: [
      {'ot': 'Ezek 31:1—32:32', 'nt': '1 John 5:14-17'},
      {'ot': 'Ezek 33:1-33', 'nt': '1 John 5:18-21'},
      {'ot': 'Ezek 34:1-31', 'nt': '2 John 1:1-3'},
      {'ot': 'Ezek 35:1—36:21', 'nt': '2 John 1:4-9'},
      {'ot': 'Ezek 36:22-38', 'nt': '2 John 1:10-13'},
      {'ot': 'Ezek 37:1-28', 'nt': '3 John 1:1-6'},
      {'ot': 'Ezek 38:1—39:29', 'nt': '3 John 1:7-14'},
    ],
// Week 94
    94: [
      {'ot': 'Ezek 40:1-27', 'nt': 'Jude 1:1-4'},
      {'ot': 'Ezek 40:28-49', 'nt': 'Jude 1:5-10'},
      {'ot': 'Ezek 41:1-26', 'nt': 'Jude 1:11-19'},
      {'ot': 'Ezek 42:1—43:27', 'nt': 'Jude 1:20-25'},
      {'ot': 'Ezek 44:1-31', 'nt': 'Rev (Bug) 1:1-3'},
      {'ot': 'Ezek 45:1-25', 'nt': 'Rev (Bug) 1:4-6'},
      {'ot': 'Ezek 46:1-24', 'nt': 'Rev (Bug) 1:7-11'},
    ],
// Week 95
    95: [
      {'ot': 'Ezek 47:1-23', 'nt': 'Rev (Bug) 1:12-13'},
      {'ot': 'Ezek 48:1-35', 'nt': 'Rev (Bug) 1:14-16'},
      {'ot': 'Dan 1:1-21', 'nt': 'Rev (Bug) 1:17-20'},
      {'ot': 'Dan 2:1-30', 'nt': 'Rev (Bug) 2:1-6'},
      {'ot': 'Dan 2:31-49', 'nt': 'Rev (Bug) 2:7'},
      {'ot': 'Dan 3:1-30', 'nt': 'Rev (Bug) 2:8-9'},
      {'ot': 'Dan 4:1-37', 'nt': 'Rev (Bug) 2:10-11'},
    ],
// Week 96
    96: [
      {'ot': 'Dan 5:1-31', 'nt': 'Rev (Bug) 2:12-14'},
      {'ot': 'Dan 6:1-28', 'nt': 'Rev (Bug) 2:15-17'},
      {'ot': 'Dan 7:1-12', 'nt': 'Rev (Bug) 2:18-23'},
      {'ot': 'Dan 7:13-28', 'nt': 'Rev (Bug) 2:24-29'},
      {'ot': 'Dan 8:1-27', 'nt': 'Rev (Bug) 3:1-3'},
      {'ot': 'Dan 9:1-27', 'nt': 'Rev (Bug) 3:4-6'},
      {'ot': 'Dan 10:1-21', 'nt': 'Rev (Bug) 3:7-9'},
    ],
// Week 97
    97: [
      {'ot': 'Dan 11:1-22', 'nt': 'Rev (Bug) 3:10-13'},
      {'ot': 'Dan 11:23-45', 'nt': 'Rev (Bug) 3:14-18'},
      {'ot': 'Dan 12:1-13', 'nt': 'Rev (Bug) 3:19-22'},
      {'ot': 'Hosea (Os) 1:1-11', 'nt': 'Rev (Bug) 4:1-5'},
      {'ot': 'Hosea (Os) 2:1-23', 'nt': 'Rev (Bug) 4:6-7'},
      {'ot': 'Hosea (Os) 3:1—4:19', 'nt': 'Rev (Bug) 4:8-11'},
      {'ot': 'Hosea (Os) 5:1-15', 'nt': 'Rev (Bug) 5:1-6'},
    ],
// Week 98
    98: [
      {'ot': 'Hosea (Os) 6:1-11', 'nt': 'Rev (Bug) 5:7-14'},
      {'ot': 'Hosea (Os) 7:1-16', 'nt': 'Rev (Bug) 6:1-8'},
      {'ot': 'Hosea (Os) 8:1-14', 'nt': 'Rev (Bug) 6:9-17'},
      {'ot': 'Hosea (Os) 9:1-17', 'nt': 'Rev (Bug) 7:1-8'},
      {'ot': 'Hosea (Os) 10:1-15', 'nt': 'Rev (Bug) 7:9-17'},
      {'ot': 'Hosea (Os) 11:1-12', 'nt': 'Rev (Bug) 8:1-6'},
      {'ot': 'Hosea (Os) 12:1-14', 'nt': 'Rev (Bug) 8:7-12'},
    ],
// Week 99
    99: [
      {'ot': 'Hosea (Os) 13:1—14:9', 'nt': 'Rev (Bug) 8:13—9:11'},
      {'ot': 'Joel 1:1-20', 'nt': 'Rev (Bug) 9:12-21'},
      {'ot': 'Joel 2:1-16', 'nt': 'Rev (Bug) 10:1-4'},
      {'ot': 'Joel 2:17-32', 'nt': 'Rev (Bug) 10:5-11'},
      {'ot': 'Joel 3:1-21', 'nt': 'Rev (Bug) 11:1-4'},
      {'ot': 'Amos 1:1-15', 'nt': 'Rev (Bug) 11:5-14'},
      {'ot': 'Amos 2:1-16', 'nt': 'Rev (Bug) 11:15-19'},
    ],
// Week 100
    100: [
      {'ot': 'Amos 3:1-15', 'nt': 'Rev (Bug) 12:1-4'},
      {'ot': 'Amos 4:1—5:27', 'nt': 'Rev (Bug) 12:5-9'},
      {'ot': 'Amos 6:1—7:17', 'nt': 'Rev (Bug) 12:10-18'},
      {'ot': 'Amos 8:1—9:15', 'nt': 'Rev (Bug) 13:1-10'},
      {'ot': 'Obad 1-21', 'nt': 'Rev (Bug) 13:11-18'},
      {'ot': 'Jonah 1:1-17', 'nt': 'Rev (Bug) 14:1-5'},
      {'ot': 'Jonah 2:1—4:11', 'nt': 'Rev (Bug) 14:6-12'},
    ],
// Week 101
    101: [
      {'ot': 'Micah 1:1-16', 'nt': 'Rev (Bug) 14:13-20'},
      {'ot': 'Micah 2:1—3:12', 'nt': 'Rev (Bug) 15:1-8'},
      {'ot': 'Micah 4:1—5:15', 'nt': 'Rev (Bug) 16:1-12'},
      {'ot': 'Micah 6:1—7:20', 'nt': 'Rev (Bug) 16:13-21'},
      {'ot': 'Nahum 1:1-15', 'nt': 'Rev (Bug) 17:1-6'},
      {'ot': 'Nahum 2:1—3:19', 'nt': 'Rev (Bug) 17:7-18'},
      {'ot': 'Hab 1:1-17', 'nt': 'Rev (Bug) 18:1-8'},
    ],
// Week 102
    102: [
      {'ot': 'Hab 2:1-20', 'nt': 'Rev (Bug) 18:9—19:4'},
      {'ot': 'Hab 3:1-19', 'nt': 'Rev (Bug) 19:5-10'},
      {'ot': 'Zeph (Sof) 1:1-18', 'nt': 'Rev (Bug) 19:11-16'},
      {'ot': 'Zeph (Sof) 2:1-15', 'nt': 'Rev (Bug) 19:17-21'},
      {'ot': 'Zeph (Sof) 3:1-20', 'nt': 'Rev (Bug) 20:1-6'},
      {'ot': 'Hag 1:1-15', 'nt': 'Rev (Bug) 20:7-10'},
      {'ot': 'Hag 2:1-23', 'nt': 'Rev (Bug) 20:11-15'},
    ],
// Week 103
    103: [
      {'ot': 'Zech 1:1-21', 'nt': 'Rev (Bug) 21:1'},
      {'ot': 'Zech 2:1-13', 'nt': 'Rev (Bug) 21:2'},
      {'ot': 'Zech 3:1-10', 'nt': 'Rev (Bug) 21:3-8'},
      {'ot': 'Zech 4:1-14', 'nt': 'Rev (Bug) 21:9-13'},
      {'ot': 'Zech 5:1—6:15', 'nt': 'Rev (Bug) 21:14-18'},
      {'ot': 'Zech 7:1—8:23', 'nt': 'Rev (Bug) 21:19-21'},
      {'ot': 'Zech 9:1-17', 'nt': 'Rev (Bug) 21:22-27'},
    ],
// Week 104
    104: [
      {'ot': 'Zech 10:1—11:17', 'nt': 'Rev (Bug) 22:1'},
      {'ot': 'Zech 12:1—13:9', 'nt': 'Rev (Bug) 22:2'},
      {'ot': 'Zech 14:1-21', 'nt': 'Rev (Bug) 22:3-11'},
      {'ot': 'Mal 1:1-14', 'nt': 'Rev (Bug) 22:12-15'},
      {'ot': 'Mal 2:1-17', 'nt': 'Rev (Bug) 22:16-17'},
      {'ot': 'Mal 3:1-18', 'nt': 'Rev (Bug) 22:18-21'},
      {'ot': 'Mal 4:1-6', 'nt': ''},
    ],
  };
}
