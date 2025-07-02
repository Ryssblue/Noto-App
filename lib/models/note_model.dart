class NoteModel {
  final String title;
  final String content;

  NoteModel({required this.title, required this.content});

  Map<String, String> toMap() {
    return {'title': title, 'content': content};
  }

  factory NoteModel.fromMap(Map<String, dynamic> map) {
    return NoteModel(
      title: map['title'] ?? '',
      content: map['content'] ?? '',
    );
  }
}
