import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:pegasus_app/core/presentation/widgets/glass_container.dart';
import 'package:pegasus_app/core/presentation/widgets/premium_background.dart';
import 'package:pegasus_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:pegasus_app/features/auth/presentation/bloc/auth_event.dart';
import 'package:pegasus_app/features/tasks/domain/entities/task.dart';
import 'package:pegasus_app/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:pegasus_app/features/dashboard/presentation/bloc/dashboard_event.dart';
import 'package:pegasus_app/features/dashboard/presentation/bloc/dashboard_state.dart';
import 'package:pegasus_app/features/dashboard/presentation/widgets/stats_card.dart';
import 'package:pegasus_app/features/dashboard/presentation/widgets/project_progress_card.dart';
import 'package:pegasus_app/features/dashboard/presentation/widgets/workflow_visualization.dart';
import 'package:pegasus_app/config/injection/injection_container.dart' as di;


class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => di.getIt<DashboardBloc>()..add(LoadDashboardData()),
      child: Scaffold(
        extendBodyBehindAppBar: true,
        // Nous configurons l'AppBar pour être transparente afin de laisser apparaître le fond premium
        appBar: AppBar(
          title: const Text('Dashboard'),
          elevation: 0,
          backgroundColor: Colors.transparent,
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
        body: PremiumBackground(
          child: BlocBuilder<DashboardBloc, DashboardState>(
            builder: (context, state) {
              if (state is DashboardLoading) {
                return const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                );
              }

              if (state is DashboardError) {
                return Center(
                  child: GlassContainer(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.error_outline, size: 64, color: Colors.redAccent),
                        const SizedBox(height: 16),
                        Text(
                          'Error: ${state.message}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.white),
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
                  ),
                );
              }

              if (state is DashboardLoaded) {
                final stats = state.projectStatistics;
                final taskStats = state.taskStatistics;
                final projects = state.projects;
                final recentTasks = state.recentTasks;

                return SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 80, 20, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      const Text(
                        'Welcome Back',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ).animate().fadeIn().slideX(),
                      
                      const Text(
                        'Here is your daily overview',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white70,
                        ),
                      ).animate().fadeIn(delay: 200.ms),
                      
                      const SizedBox(height: 30),
                      
                      // Nous affichons une visualisation du flux de travail dans un conteneur en verre
                      GlassContainer(
                        child: WorkflowVisualization(
                          totalProjects: stats['totalProjects'] ?? 0,
                          totalTasks: taskStats['totalTasks'] ?? 0,
                          overallProgress: stats['averageProgress'] ?? 0.0,
                        ),
                      ).animate().scale(delay: 300.ms),
                      
                      const SizedBox(height: 30),

                      // Sats Grid
                      const Text(
                        'Statistics',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 16),
                      GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 2,
                        childAspectRatio: 1.3,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        children: [
                          StatsCard(
                            title: 'Projects',
                            value: '${stats['totalProjects'] ?? 0}',
                            icon: Icons.folder_special,
                            color: Colors.blueAccent,
                          ),
                          StatsCard(
                            title: 'Completed',
                            value: '${stats['completedProjects'] ?? 0}',
                            icon: Icons.check_circle_outline,
                            color: Colors.greenAccent,
                          ),
                          StatsCard(
                            title: 'Tasks',
                            value: '${taskStats['completedTasks'] ?? 0}',
                            icon: Icons.task_alt,
                            color: Colors.purpleAccent,
                          ),
                          StatsCard(
                            title: 'Overdue',
                            value: '${taskStats['overdueTasks'] ?? 0}',
                            icon: Icons.warning_amber_rounded,
                            color: Colors.orangeAccent,
                          ),
                        ],
                      ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1),

                      const SizedBox(height: 32),

                      // Active Projects
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Active Projects',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          TextButton(
                            onPressed: () => context.push('/projects'),
                            child: const Text('View All'),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 10),
                      
                      if (projects.isEmpty)
                        const Center(child: Text("No projects yet", style: TextStyle(color: Colors.white54)))
                      else
                        ...projects.take(3).map((project) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: GlassContainer(
                              padding: EdgeInsets.zero,
                              child: ProjectProgressCard(
                                project: project,
                                onTap: () => context.push('/projects/${project.id}'),
                              ),
                            ),
                          );
                        }),
                        
                      const SizedBox(height: 32),
                      
                      // Recent Tasks
                       const Text(
                        'Recent Tasks',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                       const SizedBox(height: 16),
                       if (recentTasks.isEmpty)
                          const Center(child: Text("No tasks yet", style: TextStyle(color: Colors.white54)))
                       else
                          ...recentTasks.map((task) => _buildTaskItem(context, task)),

                      const SizedBox(height: 80), // Bottom padding
                    ],
                  ),
                );
              }

              return const Center(child: CircularProgressIndicator());
            },
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => context.push('/tasks'),
          label: const Text('New Task'),
          icon: const Icon(Icons.add),
          backgroundColor: Theme.of(context).primaryColor,
        ),
      ),
    );
  }

  Widget _buildTaskItem(BuildContext context, Task task) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: GlassContainer(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: _getTaskColor(task.status).withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _getTaskIcon(task.status),
                color: _getTaskColor(task.status),
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Due: ${_formatDate(task.dueDate)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: task.isOverdue ? Colors.redAccent : Colors.white60,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.white),
              onPressed: () {
                 // Navigate
              },
            ),
          ],
        ),
      ),
    );
  }

  Color _getTaskColor(TaskStatus status) {
    switch (status) {
      case TaskStatus.todo:
        return Colors.grey;
      case TaskStatus.inProgress:
        return Colors.blueAccent;
      case TaskStatus.done:
        return Colors.greenAccent;
    }
  }

  IconData _getTaskIcon(TaskStatus status) {
    switch (status) {
      case TaskStatus.todo:
        return Icons.circle_outlined;
      case TaskStatus.inProgress:
        return Icons.timelapse;
      case TaskStatus.done:
        return Icons.check_circle;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}';
  }
}
