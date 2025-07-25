class NoteModel {
  String id;
  String title;
  String content;
  DateTime createdAt;
  bool isFavorite;
  bool isArchived;
  String? imagePath; // <--- TAMBAHKAN PROPERTI INI

  NoteModel({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
    this.isFavorite = false,
    this.isArchived = false,
    this.imagePath, // <--- TAMBAHKAN KE KONSTRUKTOR
  });

  // Konversi dari Map (saat memuat dari SharedPreferences)
  factory NoteModel.fromMap(Map<String, dynamic> map) {
    return NoteModel(
      id: map['id'],
      title: map['title'],
      content: map['content'],
      createdAt: DateTime.parse(map['createdAt']),
      isFavorite: map['isFavorite'] ?? false,
      isArchived: map['isArchived'] ?? false,
      imagePath: map['imagePath'], // <--- PASTIKAN INI ADA SAAT MEMUAT
    );
  }

  // Konversi ke Map (saat menyimpan ke SharedPreferences)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
      'isFavorite': isFavorite,
      'isArchived': isArchived,
      'imagePath': imagePath, // <--- PASTIKAN INI ADA SAAT MENYIMPAN
    };
  }

  void toggleFavorite() {
    isFavorite = !isFavorite;
  }

  void toggleArchive() {
    isArchived = !isArchived;
  }
}
