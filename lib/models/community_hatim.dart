class CommunityHatim {
  final String id;
  final String title;
  final Map<String, String> juzStatus; // Key: "1" to "30", Value: UserID or "empty"
  final DateTime createdAt;
  final DateTime? updatedAt;

  CommunityHatim({
    required this.id,
    required this.title,
    required this.juzStatus,
    required this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'juzStatus': juzStatus,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory CommunityHatim.fromJson(Map<String, dynamic> json) {
    return CommunityHatim(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      juzStatus: Map<String, String>.from(json['juzStatus'] ?? {}),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
    );
  }

  CommunityHatim copyWith({
    String? id,
    String? title,
    Map<String, String>? juzStatus,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CommunityHatim(
      id: id ?? this.id,
      title: title ?? this.title,
      juzStatus: juzStatus ?? this.juzStatus,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  String getJuzStatus(int juzNumber) {
    return juzStatus[juzNumber.toString()] ?? 'empty';
  }

  bool isJuzEmpty(int juzNumber) {
    return getJuzStatus(juzNumber) == 'empty';
  }

  bool isJuzReading(int juzNumber, String userId) {
    return getJuzStatus(juzNumber) == userId;
  }

  bool isJuzCompleted(int juzNumber) {
    final status = getJuzStatus(juzNumber);
    return status != 'empty' && status.isNotEmpty;
  }
}
