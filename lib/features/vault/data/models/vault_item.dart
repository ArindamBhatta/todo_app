class VaultItem {
  final String id;
  final String title;
  final String category; // 'photo', 'video', 'audio', 'doc', 'note'
  final String? filePath;
  final String? secretNote;
  final int fileSize;
  final DateTime createdAt;
  final String? fileExtension;

  VaultItem({
    required this.id,
    required this.title,
    required this.category,
    this.filePath,
    this.secretNote,
    required this.fileSize,
    required this.createdAt,
    this.fileExtension,
  });

  VaultItem copyWith({
    String? id,
    String? title,
    String? category,
    String? filePath,
    String? secretNote,
    int? fileSize,
    DateTime? createdAt,
    String? fileExtension,
  }) {
    return VaultItem(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      filePath: filePath ?? this.filePath,
      secretNote: secretNote ?? this.secretNote,
      fileSize: fileSize ?? this.fileSize,
      createdAt: createdAt ?? this.createdAt,
      fileExtension: fileExtension ?? this.fileExtension,
    );
  }

  Map<String, Object?> toJson() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'file_path': filePath,
      'secret_note': secretNote,
      'file_size': fileSize,
      'created_at': createdAt.toIso8601String(),
      'file_extension': fileExtension,
    };
  }

  factory VaultItem.fromJson(Map<String, Object?> json) {
    return VaultItem(
      id: json['id'] as String,
      title: json['title'] as String,
      category: json['category'] as String,
      filePath: json['file_path'] as String?,
      secretNote: json['secret_note'] as String?,
      fileSize: (json['file_size'] as num?)?.toInt() ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
      fileExtension: json['file_extension'] as String?,
    );
  }
}
