class NoteModel {
  String id;
  String title; // Dibuat tidak final agar bisa diubah
  String content; // Dibuat tidak final agar bisa diubah
  DateTime createdAt;
  bool isFavorite;
  bool isArchived;
  String? category;
  List<String>? tags;

  NoteModel({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
    this.isFavorite = false,
    this.isArchived = false,
    this.category,
    this.tags,
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
      // Pastikan untuk menangani list kosong dengan benar
      'tags': tags,
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
      category: map['category'],
      // Penanganan yang aman untuk konversi list dari JSON
      tags: map['tags'] != null ? List<String>.from(map['tags']) : null,
    );
  }
}
