class Page {
  final int pageNumber;
  final int juzNumber;
  final List<int> surahNumbers;
  bool isRead;
  DateTime? readDate;

  Page({
    required this.pageNumber,
    required this.juzNumber,
    required this.surahNumbers,
    this.isRead = false,
    this.readDate,
  });

  Page copyWith({
    int? pageNumber,
    int? juzNumber,
    List<int>? surahNumbers,
    bool? isRead,
    DateTime? readDate,
  }) {
    return Page(
      pageNumber: pageNumber ?? this.pageNumber,
      juzNumber: juzNumber ?? this.juzNumber,
      surahNumbers: surahNumbers ?? this.surahNumbers,
      isRead: isRead ?? this.isRead,
      readDate: readDate ?? this.readDate,
    );
  }
}
