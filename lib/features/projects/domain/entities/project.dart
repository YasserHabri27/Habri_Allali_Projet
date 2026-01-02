import 'package:equatable/equatable.dart';

enum ProjectStatus { todo, inProgress, done, archived }

class Project extends Equatable {
  final String id;
  final String userId;
  final String name;
  final String description;
  final ProjectStatus status;
  final double progress;
  final DateTime startDate;
  final DateTime endDate;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<String>? taskIds;
  final String? colorHex;

  const Project({
    required this.id,
    required this.userId,
    required this.name,
    required this.description,
    required this.status,
    required this.progress,
    required this.startDate,
    required this.endDate,
    required this.createdAt,
    required this.updatedAt,
    this.taskIds,
    this.colorHex,
  });

  factory Project.empty() => Project(
        id: '',
        userId: '',
        name: '',
        description: '',
        status: ProjectStatus.todo,
        progress: 0.0,
        startDate: DateTime.now(),
        endDate: DateTime.now().add(const Duration(days: 7)),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        taskIds: const [],
        colorHex: '#2196F3',
      );

  Project copyWith({
    String? id,
    String? userId,
    String? name,
    String? description,
    ProjectStatus? status,
    double? progress,
    DateTime? startDate,
    DateTime? endDate,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<String>? taskIds,
    String? colorHex,
  }) {
    return Project(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      description: description ?? this.description,
      status: status ?? this.status,
      progress: progress ?? this.progress,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      taskIds: taskIds ?? this.taskIds,
      colorHex: colorHex ?? this.colorHex,
    );
  }

  bool get isOverdue => endDate.isBefore(DateTime.now()) && status != ProjectStatus.done;
  bool get isActive => status == ProjectStatus.inProgress;

  @override
  List<Object?> get props => [
        id,
        userId,
        name,
        description,
        status,
        progress,
        startDate,
        endDate,
        createdAt,
        updatedAt,
        taskIds,
        colorHex,
      ];
}
