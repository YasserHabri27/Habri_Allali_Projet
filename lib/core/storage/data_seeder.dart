import 'package:hive/hive.dart';
import '../../features/auth/data/models/user_model.dart';
import '../../features/projects/data/models/project_model.dart';
import '../../features/tasks/data/models/task_model.dart';
import '../../features/projects/domain/entities/project.dart';
import '../../features/tasks/domain/entities/task.dart';

class DataSeeder {
  static Future<void> seedIfNeeded() async {
    final projectBox = Hive.box<ProjectModel>('projects');
    final taskBox = Hive.box<TaskModel>('tasks');
    
    // Nous vérifions si des données existent déjà pour éviter de dupliquer
    if (projectBox.isNotEmpty || taskBox.isNotEmpty) {
      print('📦 Data already seeded, skipping...');
      return;
    }
    
    print('🌱 Seeding demo data...');
    
    // Nous créons 3 projets de démonstration
    final projects = [
      ProjectModel(
        id: '1',
        userId: 'demo-user',
        name: 'Application Mobile Pegasus',
        description: 'Développement de l\'application de gestion de projets',
        statusIndex: ProjectStatus.inProgress.index,
        progress: 65.0,
        startDate: DateTime.now().subtract(const Duration(days: 30)),
        endDate: DateTime.now().add(const Duration(days: 30)),
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        updatedAt: DateTime.now(),
        colorHex: '#6366F1',
      ),
      ProjectModel(
        id: '2',
        userId: 'demo-user',
        name: 'Site Web E-commerce',
        description: 'Plateforme de vente en ligne moderne',
        statusIndex: ProjectStatus.todo.index,
        progress: 15.0,
        startDate: DateTime.now(),
        endDate: DateTime.now().add(const Duration(days: 90)),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        taskIds: ['4'],
        colorHex: '#EC4899',
      ),
      ProjectModel(
        id: '3',
        userId: 'demo-user',
        name: 'Migration Cloud AWS',
        description: 'Migration de l\'infrastructure vers AWS',
        statusIndex: ProjectStatus.done.index,
        progress: 100.0,
        startDate: DateTime.now().subtract(const Duration(days: 60)),
        endDate: DateTime.now().subtract(const Duration(days: 5)),
        createdAt: DateTime.now().subtract(const Duration(days: 60)),
        updatedAt: DateTime.now().subtract(const Duration(days: 5)),
        taskIds: ['5', '6'],
        colorHex: '#10B981',
      ),
    ];
    
    // Nous créons 6 tâches de démonstration
    final tasks = [
      TaskModel(
        id: '1',
        projectId: '1',
        title: 'Concevoir l\'architecture de l\'application',
        description: 'Définir la structure Clean Architecture',
        priorityIndex: TaskPriority.high.index,
        statusIndex: TaskStatus.done.index,
        dueDate: DateTime.now().subtract(const Duration(days: 20)),
        completedAt: DateTime.now().subtract(const Duration(days: 18)),
        createdAt: DateTime.now().subtract(const Duration(days: 25)),
        updatedAt: DateTime.now().subtract(const Duration(days: 18)),
      ),
      TaskModel(
        id: '2',
        projectId: '1',
        title: 'Implémenter le module Auth',
        description: 'Login, Register, Logout avec BLoC',
        priorityIndex: TaskPriority.high.index,
        statusIndex: TaskStatus.done.index,
        dueDate: DateTime.now().subtract(const Duration(days: 10)),
        completedAt: DateTime.now().subtract(const Duration(days: 12)),
        createdAt: DateTime.now().subtract(const Duration(days: 20)),
        updatedAt: DateTime.now().subtract(const Duration(days: 12)),
      ),
      TaskModel(
        id: '3',
        projectId: '1',
        title: 'Créer l\'interface Dashboard',
        description: 'Design moderne avec glassmorphism',
        priorityIndex: TaskPriority.medium.index,
        statusIndex: TaskStatus.inProgress.index,
        dueDate: DateTime.now().add(const Duration(days: 5)),
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
        updatedAt: DateTime.now(),
      ),
      TaskModel(
        id: '4',
        projectId: '2',
        title: 'Setup du projet e-commerce',
        description: 'Initialiser le repository et dépendances',
        priorityIndex: TaskPriority.high.index,
        statusIndex: TaskStatus.todo.index,
        dueDate: DateTime.now().add(const Duration(days: 3)),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      TaskModel(
        id: '5',
        projectId: '3',
        title: 'Configuration AWS',
        description: 'Setup EC2, RDS, S3',
        priorityIndex: TaskPriority.high.index,
        statusIndex: TaskStatus.done.index,
        dueDate: DateTime.now().subtract(const Duration(days: 30)),
        completedAt: DateTime.now().subtract(const Duration(days: 28)),
        createdAt: DateTime.now().subtract(const Duration(days: 35)),
        updatedAt: DateTime.now().subtract(const Duration(days: 28)),
      ),
      TaskModel(
        id: '6',
        projectId: '3',
        title: 'Migration de la base de données',
        description: 'Migrer PostgreSQL vers RDS',
        priorityIndex: TaskPriority.high.index,
        statusIndex: TaskStatus.done.index,
        dueDate: DateTime.now().subtract(const Duration(days: 15)),
        completedAt: DateTime.now().subtract(const Duration(days: 17)),
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        updatedAt: DateTime.now().subtract(const Duration(days: 17)),
      ),
    ];
    
    // Nous peuplons la base de données locale
    for (final project in projects) {
      await projectBox.put(project.id, project);
    }
    
    for (final task in tasks) {
      await taskBox.put(task.id, task);
    }
    
    print('✅ Demo data seeded successfully: ${projects.length} projects, ${tasks.length} tasks');
  }
}
