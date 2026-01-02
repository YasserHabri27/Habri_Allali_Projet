import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';
import '../../domain/entities/task.dart';

part 'task_model.g.dart';

@HiveType(typeId: 3)
class TaskModel extends Equatable {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String projectId;
  @HiveField(2)
  final String title;
  @HiveField(3)
  final String description;
  @HiveField(4)
  final int priorityIndex;
  @HiveField(5)
  final int statusIndex;
  @HiveField(6)
  final DateTime dueDate;
  @HiveField(7)
  final DateTime? completedAt;
  @HiveField(8)
  final DateTime createdAt;
  @HiveField(9)
  final DateTime updatedAt;

  const TaskModel({
    required this.id,
    required this.projectId,
    required this.title,
    required this.description,
    required this.priorityIndex,
    required this.statusIndex,
    required this.dueDate,
    this.completedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id']?.toString() ?? '',
      projectId: json['projectId']?.toString() ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      priorityIndex: json['priority'] ?? 1,
      statusIndex: json['status'] ?? 0,
      dueDate: DateTime.parse(json['dueDate']),
      completedAt: json['completedAt'] != null ? DateTime.parse(json['completedAt']) : null,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'projectId': projectId,
      'title': title,
      'description': description,
      'priority': priorityIndex,
      'status': statusIndex,
      'dueDate': dueDate.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  Task toEntity() {
    return Task(
      id: id,
      projectId: projectId,
      title: title,
      description: description,
      priority: TaskPriority.values[priorityIndex],
      status: TaskStatus.values[statusIndex],
      dueDate: dueDate,
      completedAt: completedAt,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  factory TaskModel.fromEntity(Task task) {
    return TaskModel(
      id: task.id,
      projectId: task.projectId,
      title: task.title,
      description: task.description,
      priorityIndex: task.priority.index,
      statusIndex: task.status.index,
      dueDate: task.dueDate,
      completedAt: task.completedAt,
      createdAt: task.createdAt,
      updatedAt: task.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        projectId,
        title,
        description,
        priorityIndex,
        statusIndex,
        dueDate,
        completedAt,
        createdAt,
        updatedAt,
      ];
}
