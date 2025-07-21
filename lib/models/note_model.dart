class NoteModel {
  String id;
  String title; // Dibuat tidak final agar bisa diubah
  String content; // Dibuat tidak final agar bisa diubah
  DateTime createdAt;
  bool isFavorite;
  bool isArchived;
  String? category;

  NoteModel({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
    this.isFavorite = false,
    this.isArchived = false,
    this.category,
  });

  // Method untuk mengubah status favorit
  void toggleFavorite() {
    isFavorite = !isFavorite;
  }

  // Method untuk mengubah status arsip
  void toggleArchive() {
    isArchived = !isArchived;
  }

  // Konversi dari NoteModel ke Map untuk disimpan
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
      'isFavorite': isFavorite,
      'isArchived': isArchived,
      'category': category,
    };
  }

  // Konversi dari Map ke NoteModel saat dimuat
  factory NoteModel.fromMap(Map<String, dynamic> map) {
    return NoteModel(
      id: map['id'] as String,
      title: map['title'] as String,
      content: map['content'] as String,
      createdAt: DateTime.parse(map['createdAt'] as String),
      isFavorite: map['isFavorite'] ?? false,
      isArchived: map['isArchived'] ?? false,
    );
  }
}
