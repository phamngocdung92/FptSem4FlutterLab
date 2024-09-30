class Todo {
  final int? id;
  final String todoName;
  final int isCompleted;
  final int status;

  Todo({
    this.id,
    required this.todoName,
    this.isCompleted = 0,
    this.status = 1,
  });

  // Convert a Todo into a Map. The keys must match the column names in the database.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'todoName': todoName,
      'isCompleted': isCompleted,
      'status': status,
    };
  }

  // Create a Todo from a Map.
  factory Todo.fromMap(Map<String, dynamic> map) {
    return Todo(
      id: map['id'],
      todoName: map['todoName'],
      isCompleted: map['isCompleted'],
      status: map['status'],
    );
  }
}