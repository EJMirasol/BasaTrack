import '../models/reading_task.dart';

/// Provides a year-long Bible reading plan
/// This is a simplified plan with 2-3 readings per day (OT, NT, and Psalms/Proverbs)
class ReadingPlanData {
  ReadingPlanData._();

  /// Get reading tasks for a specific day of the year (1-365)
  static List<ReadingTask> getReadingsForDay(int dayOfYear) {
    // Normalize to 1-365 range
    final day = ((dayOfYear - 1) % 365) + 1;
    
    // This is a simplified Bible reading plan
    // In a real app, you would have all 365 days mapped out
    final readings = _readingPlan[day] ?? _getDefaultReadings(day);
    
    return readings.asMap().entries.map((entry) {
      return ReadingTask(
        id: 'day_${day}_reading_${entry.key}',
        reference: entry.value,
      );
    }).toList();
  }

  /// Fallback reading generator for days not explicitly defined
  static List<String> _getDefaultReadings(int day) {
    // Simple algorithm to generate readings across the Bible
    final otChapter = ((day - 1) * 3) % 929 + 1; // OT has ~929 chapters
    final ntChapter = ((day - 1) * 2) % 260 + 1; // NT has ~260 chapters
    final psalmNumber = ((day - 1) % 150) + 1; // Psalms has 150 chapters
    
    return [
      _getOTReference(otChapter),
      _getNTReference(ntChapter),
      'Psalm $psalmNumber',
    ];
  }

  /// Map chapter number to OT book reference (simplified)
  static String _getOTReference(int chapter) {
    if (chapter <= 50) return 'Genesis ${chapter}';
    if (chapter <= 90) return 'Exodus ${chapter - 50}';
    if (chapter <= 117) return 'Leviticus ${chapter - 90}';
    if (chapter <= 153) return 'Numbers ${chapter - 117}';
    if (chapter <= 187) return 'Deuteronomy ${chapter - 153}';
    if (chapter <= 211) return 'Joshua ${chapter - 187}';
    if (chapter <= 232) return 'Judges ${chapter - 211}';
    if (chapter <= 236) return 'Ruth ${chapter - 232}';
    if (chapter <= 267) return '1 Samuel ${chapter - 236}';
    if (chapter <= 291) return '2 Samuel ${chapter - 267}';
    if (chapter <= 313) return '1 Kings ${chapter - 291}';
    if (chapter <= 338) return '2 Kings ${chapter - 313}';
    if (chapter <= 367) return '1 Chronicles ${chapter - 338}';
    if (chapter <= 403) return '2 Chronicles ${chapter - 367}';
    if (chapter <= 413) return 'Ezra ${chapter - 403}';
    if (chapter <= 426) return 'Nehemiah ${chapter - 413}';
    if (chapter <= 436) return 'Esther ${chapter - 426}';
    if (chapter <= 478) return 'Job ${chapter - 436}';
    if (chapter <= 628) return 'Psalms ${chapter - 478}';
    if (chapter <= 659) return 'Proverbs ${chapter - 628}';
    if (chapter <= 671) return 'Ecclesiastes ${chapter - 659}';
    if (chapter <= 679) return 'Song of Solomon ${chapter - 671}';
    if (chapter <= 745) return 'Isaiah ${chapter - 679}';
    if (chapter <= 797) return 'Jeremiah ${chapter - 745}';
    if (chapter <= 802) return 'Lamentations ${chapter - 797}';
    if (chapter <= 850) return 'Ezekiel ${chapter - 802}';
    if (chapter <= 862) return 'Daniel ${chapter - 850}';
    if (chapter <= 876) return 'Hosea ${chapter - 862}';
    if (chapter <= 879) return 'Joel ${chapter - 876}';
    if (chapter <= 888) return 'Amos ${chapter - 879}';
    if (chapter <= 889) return 'Obadiah ${chapter - 888}';
    if (chapter <= 893) return 'Jonah ${chapter - 889}';
    if (chapter <= 900) return 'Micah ${chapter - 893}';
    if (chapter <= 903) return 'Nahum ${chapter - 900}';
    if (chapter <= 906) return 'Habakkuk ${chapter - 903}';
    if (chapter <= 909) return 'Zephaniah ${chapter - 906}';
    if (chapter <= 911) return 'Haggai ${chapter - 909}';
    if (chapter <= 925) return 'Zechariah ${chapter - 911}';
    return 'Malachi ${chapter - 925}';
  }

  /// Map chapter number to NT book reference (simplified)
  static String _getNTReference(int chapter) {
    if (chapter <= 28) return 'Matthew ${chapter}';
    if (chapter <= 44) return 'Mark ${chapter - 28}';
    if (chapter <= 68) return 'Luke ${chapter - 44}';
    if (chapter <= 89) return 'John ${chapter - 68}';
    if (chapter <= 117) return 'Acts ${chapter - 89}';
    if (chapter <= 133) return 'Romans ${chapter - 117}';
    if (chapter <= 149) return '1 Corinthians ${chapter - 133}';
    if (chapter <= 162) return '2 Corinthians ${chapter - 149}';
    if (chapter <= 168) return 'Galatians ${chapter - 162}';
    if (chapter <= 174) return 'Ephesians ${chapter - 168}';
    if (chapter <= 178) return 'Philippians ${chapter - 174}';
    if (chapter <= 182) return 'Colossians ${chapter - 178}';
    if (chapter <= 187) return '1 Thessalonians ${chapter - 182}';
    if (chapter <= 190) return '2 Thessalonians ${chapter - 187}';
    if (chapter <= 196) return '1 Timothy ${chapter - 190}';
    if (chapter <= 200) return '2 Timothy ${chapter - 196}';
    if (chapter <= 203) return 'Titus ${chapter - 200}';
    if (chapter <= 204) return 'Philemon ${chapter - 203}';
    if (chapter <= 217) return 'Hebrews ${chapter - 204}';
    if (chapter <= 222) return 'James ${chapter - 217}';
    if (chapter <= 227) return '1 Peter ${chapter - 222}';
    if (chapter <= 230) return '2 Peter ${chapter - 227}';
    if (chapter <= 235) return '1 John ${chapter - 230}';
    if (chapter <= 236) return '2 John ${chapter - 235}';
    if (chapter <= 237) return '3 John ${chapter - 236}';
    if (chapter <= 238) return 'Jude ${chapter - 237}';
    return 'Revelation ${chapter - 238}';
  }

  /// Sample reading plan for the first few days
  /// In production, this would have all 365 days defined
  static final Map<int, List<String>> _readingPlan = {
    1: ['Genesis 1-2', 'Matthew 1', 'Psalm 1'],
    2: ['Genesis 3-4', 'Matthew 2', 'Psalm 2'],
    3: ['Genesis 5-6', 'Matthew 3', 'Psalm 3'],
    4: ['Genesis 7-8', 'Matthew 4', 'Psalm 4'],
    5: ['Genesis 9-11', 'Matthew 5', 'Psalm 5'],
    6: ['Genesis 12-14', 'Matthew 6', 'Psalm 6'],
    7: ['Genesis 15-17', 'Matthew 7', 'Psalm 7'],
    8: ['Genesis 18-19', 'Matthew 8', 'Psalm 8'],
    9: ['Genesis 20-22', 'Matthew 9', 'Psalm 9'],
    10: ['Genesis 23-24', 'Matthew 10', 'Psalm 10'],
    11: ['Genesis 25-26', 'Matthew 11', 'Psalm 11'],
    12: ['Genesis 27-28', 'Matthew 12', 'Psalm 12'],
    13: ['Genesis 29-30', 'Matthew 13', 'Psalm 13'],
    14: ['Genesis 31-32', 'Matthew 14', 'Psalm 14'],
    15: ['Genesis 33-35', 'Matthew 15', 'Psalm 15'],
    16: ['Genesis 36-38', 'Matthew 16', 'Psalm 16'],
    17: ['Genesis 39-40', 'Matthew 17', 'Psalm 17'],
    18: ['Genesis 41-42', 'Matthew 18', 'Psalm 18'],
    19: ['Genesis 43-45', 'Matthew 19', 'Psalm 19'],
    20: ['Genesis 46-47', 'Matthew 20', 'Psalm 20'],
    // Additional days would be defined here...
    // For brevity, we'll use the fallback for other days
  };
}
