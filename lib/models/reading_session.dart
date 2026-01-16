class ReadingSession {
  final DateTime date;
  final int pagesRead;
  final String hatimId;

  ReadingSession({
    required this.date,
    required this.pagesRead,
    required this.hatimId,
  });

  // Helper method to get date without time
  DateTime get dateOnly => DateTime(date.year, date.month, date.day);
}
