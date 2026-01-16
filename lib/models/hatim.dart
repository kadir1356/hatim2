import 'page.dart';

class Hatim {
  final String id;
  final String name;
  final DateTime createdAt;
  final List<Page> pages;
  bool isActive;

  Hatim({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.pages,
    this.isActive = true,
  });

  int get totalPages => pages.length;

  int get readPages => pages.where((p) => p.isRead).length;

  double get progressPercentage => totalPages > 0 ? (readPages / totalPages) * 100 : 0.0;

  Page? get lastReadPage {
    final readPages = pages.where((p) => p.isRead && p.readDate != null).toList();
    if (readPages.isEmpty) return null;
    readPages.sort((a, b) => b.readDate!.compareTo(a.readDate!));
    return readPages.first;
  }

  Hatim copyWith({
    String? id,
    String? name,
    DateTime? createdAt,
    List<Page>? pages,
    bool? isActive,
  }) {
    return Hatim(
      id: id ?? this.id,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      pages: pages ?? this.pages,
      isActive: isActive ?? this.isActive,
    );
  }
}
