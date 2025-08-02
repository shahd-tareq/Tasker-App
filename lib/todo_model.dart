class Todo {
  final int? id;
  final String title;
  final String time;
  final bool isDone;

  Todo({
    this.id,
    required this.title,
    required this.time,
    required this.isDone,
  });

  // لتحويل الـ object لـ Map علشان SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'time': time,
      'isDone': isDone ? 1 : 0, // SQLite مفيهوش boolean
    };
  }

  // لتحويل Map جاي من SQLite لـ Object
  factory Todo.fromMap(Map<String, dynamic> map) {
    return Todo(
      id: map['id'],
      title: map['title'],
      time: map['time'],
      isDone: map['isDone'] == 1,
    );
  }
}
