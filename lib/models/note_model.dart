class NoteModel {
  String title;   // Dibuat tidak final agar bisa diubah
  String content; // Dibuat tidak final agar bisa diubah
  bool isFavorite;
  bool isArchived;
  String? category;
  List<String>? tags;

  NoteModel({
    required this.title,
    required this.content,
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
      'title': title,
      'content': content,
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
      title: map['title'] ?? '',
      content: map['content'] ?? '',
      isFavorite: map['isFavorite'] ?? false,
      isArchived: map['isArchived'] ?? false,
      category: map['category'],
      // Penanganan yang aman untuk konversi list dari JSON
      tags: map['tags'] != null ? List<String>.from(map['tags']) : null,
    );
  }
}