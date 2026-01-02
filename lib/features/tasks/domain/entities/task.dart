import 'package:equatable/equatable.dart';

enum TaskPriority { low, medium, high }
enum TaskStatus { todo, inProgress, done }

class Task extends Equatable {
  final String id;
  final String projectId;
  final String title;
  final String description;
  final TaskPriority priority;
  final TaskStatus status;
  final DateTime dueDate;
  final DateTime? completedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Task({
    required this.id,
    required this.projectId,
    required this.title,
    required this.description,
    required this.priority,
    required this.status,
    required this.dueDate,
    this.completedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Task.empty() => Task(
        id: '',
        projectId: '',
        title: '',
        description: '',
        priority: TaskPriority.medium,
        status: TaskStatus.todo,
        dueDate: DateTime.now().add(const Duration(days: 1)),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

  Task copyWith({
    String? id,
    String? projectId,
    String? title,
    String? description,
    TaskPriority? priority,
    TaskStatus? status,
    DateTime? dueDate,
    DateTime? completedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Task(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      title: title ?? this.title,
      description: description ?? this.description,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      dueDate: dueDate ?? this.dueDate,
      completedAt: completedAt ?? this.completedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  bool get isOverdue => dueDate.isBefore(DateTime.now()) && status != TaskStatus.done;

  @override
  List<Object?> get props => [
        id,
        projectId,
        title,
        description,
        priority,
        status,
        dueDate,
        completedAt,
        createdAt,
        updatedAt,
      ];
}
