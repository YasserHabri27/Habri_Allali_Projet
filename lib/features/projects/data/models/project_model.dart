import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';
import '../../domain/entities/project.dart';

part 'project_model.g.dart';

@HiveType(typeId: 2)
class ProjectModel extends Equatable {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String userId;
  @HiveField(2)
  final String name;
  @HiveField(3)
  final String description;
  @HiveField(4)
  final int statusIndex;
  @HiveField(5)
  final double progress;
  @HiveField(6)
  final DateTime startDate;
  @HiveField(7)
  final DateTime endDate;
  @HiveField(8)
  final DateTime createdAt;
  @HiveField(9)
  final DateTime updatedAt;
  @HiveField(10)
  final List<String>? taskIds;
  @HiveField(11)
  final String? colorHex;

  const ProjectModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.description,
    required this.statusIndex,
    required this.progress,
    required this.startDate,
    required this.endDate,
    required this.createdAt,
    required this.updatedAt,
    this.taskIds,
    this.colorHex,
  });

  factory ProjectModel.fromJson(Map<String, dynamic> json) {
    return ProjectModel(
      id: json['id']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      statusIndex: json['status'] ?? 0,
      progress: (json['progress'] ?? 0).toDouble(),
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      taskIds: List<String>.from(json['taskIds'] ?? []),
      colorHex: json['colorHex'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'description': description,
      'status': statusIndex,
      'progress': progress,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'taskIds': taskIds ?? [],
      'colorHex': colorHex,
    };
  }

  Project toEntity() {
    return Project(
      id: id,
      userId: userId,
      name: name,
      description: description,
      status: ProjectStatus.values[statusIndex],
      progress: progress,
      startDate: startDate,
      endDate: endDate,
      createdAt: createdAt,
      updatedAt: updatedAt,
      taskIds: taskIds,
      colorHex: colorHex,
    );
  }

  factory ProjectModel.fromEntity(Project project) {
    return ProjectModel(
      id: project.id,
      userId: project.userId,
      name: project.name,
      description: project.description,
      statusIndex: project.status.index,
      progress: project.progress,
      startDate: project.startDate,
      endDate: project.endDate,
      createdAt: project.createdAt,
      updatedAt: project.updatedAt,
      taskIds: project.taskIds,
      colorHex: project.colorHex,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        name,
        description,
        statusIndex,
        progress,
        startDate,
        endDate,
        createdAt,
        updatedAt,
        taskIds,
        colorHex,
      ];
}
