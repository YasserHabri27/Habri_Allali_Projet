import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pegasus_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:pegasus_app/features/auth/presentation/bloc/auth_event.dart';
import 'package:pegasus_app/features/tasks/domain/entities/task.dart';
import 'package:pegasus_app/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:pegasus_app/features/dashboard/presentation/bloc/dashboard_event.dart';
import 'package:pegasus_app/features/dashboard/presentation/bloc/dashboard_state.dart';
import 'package:pegasus_app/features/dashboard/presentation/widgets/stats_card.dart';
import 'package:pegasus_app/features/dashboard/presentation/widgets/project_progress_card.dart';
import 'package:pegasus_app/features/dashboard/presentation/widgets/workflow_visualization.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => context.read<DashboardBloc>()..add(LoadDashboardData()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Dashboard'),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                context.read<DashboardBloc>().add(LoadDashboardData());
              },
            ),
            IconButton(
              onPressed: () {
                context.read<AuthBloc>().add(LogoutRequested());
              },
              icon: const Icon(Icons.logout),
            ),
          ],
        ),
        body: BlocBuilder<DashboardBloc, DashboardState>(
          builder: (context, state) {
            if (state is DashboardLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is DashboardError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error, size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(
                      'Error: ${state.message}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        context.read<DashboardBloc>().add(LoadDashboardData());
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            if (state is DashboardLoaded) {
              final stats = state.projectStatistics;
              final taskStats = state.taskStatistics;
              final projects = state.projects;
              final recentTasks = state.recentTasks;

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Section d'en-tête affichant le message de bienvenue
                    const Text(
                      'Welcome to Pegasus',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Smart Workflow & Productivity Manager',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Composant de visualisation du flux de travail
                    WorkflowVisualization(
                      totalProjects: stats['totalProjects'] ?? 0,
                      totalTasks: taskStats['totalTasks'] ?? 0,
                      overallProgress: stats['averageProgress'] ?? 0.0,
                    ),
                    const SizedBox(height: 24),

                    // Grille affichant les statistiques clés de productivité
                    const Text(
                      'Productivity Stats',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      childAspectRatio: 1.2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      children: [
                        StatsCard(
                          title: 'Total Projects',
                          value: '${stats['totalProjects'] ?? 0}',
                          icon: Icons.folder,
                          color: Colors.blue,
                        ),
                        StatsCard(
                          title: 'Completed',
                          value: '${stats['completedProjects'] ?? 0}',
                          icon: Icons.check_circle,
                          color: Colors.green,
                        ),
                        StatsCard(
                          title: 'Tasks Done',
                          value: '${taskStats['completedTasks'] ?? 0}',
                          icon: Icons.task_alt,
                          color: Colors.purple,
                        ),
                        StatsCard(
                          title: 'Overdue',
                          value: '${taskStats['overdueTasks'] ?? 0}',
                          icon: Icons.warning,
                          color: Colors.orange,
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // Section des projets récemment actifs
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Active Projects',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            context.push('/projects');
                          },
                          child: const Text('View All'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Liste des projets en cours
                    if (projects.isEmpty)
                      const Center(
                        child: Column(
                          children: [
                            Icon(Icons.folder_open, size: 64, color: Colors.grey),
                            SizedBox(height: 16),
                            Text(
                              'No projects yet',
                              style: TextStyle(fontSize: 16, color: Colors.grey),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Create your first project to get started',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      )
                    else
                      ...projects.take(3).map((project) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: ProjectProgressCard(
                            project: project,
                            onTap: () {
                              context.push('/projects/${project.id}');
                            },
                          ),
                        );
                      }),
                    const SizedBox(height: 32),

                    // Section des tâches récemment modifiées
                    const Text(
                      'Recent Tasks',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (recentTasks.isEmpty)
                      const Center(
                        child: Column(
                          children: [
                            Icon(Icons.task, size: 64, color: Colors.grey),
                            SizedBox(height: 16),
                            Text(
                              'No tasks yet',
                              style: TextStyle(fontSize: 16, color: Colors.grey),
                            ),
                          ],
                        ),
                      )
                    else
                      ...recentTasks.map((task) {
                        return _buildTaskItem(context, task);
                      }),
                    const SizedBox(height: 32),

                    // Boutons d'actions rapides
                    const Text(
                      'Quick Actions',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              context.push('/projects/new');
                            },
                            icon: const Icon(Icons.add),
                            label: const Text('New Project'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              context.push('/tasks');
                            },
                            icon: const Icon(Icons.list),
                            label: const Text('View Tasks'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              );
            }

            return const Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }

  Widget _buildTaskItem(BuildContext context, Task task) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _getTaskColor(task.status).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            _getTaskIcon(task.status),
            color: _getTaskColor(task.status),
          ),
        ),
        title: Text(
          task.title,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              'Due: ${_formatDate(task.dueDate)}',
              style: TextStyle(
                fontSize: 12,
                color: task.isOverdue ? Colors.red : Colors.grey,
              ),
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.arrow_forward_ios, size: 16),
          onPressed: () {
            // Navigation vers la vue détaillée de la tâche
          },
        ),
      ),
    );
  }

  Color _getTaskColor(TaskStatus status) {
    switch (status) {
      case TaskStatus.todo:
        return Colors.grey;
      case TaskStatus.inProgress:
        return Colors.blue;
      case TaskStatus.done:
        return Colors.green;
    }
  }

  IconData _getTaskIcon(TaskStatus status) {
    switch (status) {
      case TaskStatus.todo:
        return Icons.radio_button_unchecked;
      case TaskStatus.inProgress:
        return Icons.play_arrow;
      case TaskStatus.done:
        return Icons.check_circle;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
