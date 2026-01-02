import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/project_bloc.dart';
import '../bloc/project_event.dart';
import '../bloc/project_state.dart';
import '../../../tasks/presentation/bloc/task_bloc.dart';
import '../../../tasks/presentation/bloc/task_event.dart';
import '../../../tasks/presentation/bloc/task_state.dart';
import '../../domain/entities/project.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:pegasus_app/config/injection/injection_container.dart' as di;

class ProjectDetailsPage extends StatelessWidget {
  final String projectId;
  
  const ProjectDetailsPage({super.key, required this.projectId});

  Color _getStatusColor(ProjectStatus status) {
    switch (status) {
      case ProjectStatus.planning:
        return Colors.blue;
      case ProjectStatus.inProgress:
        return Colors.orange;
      case ProjectStatus.completed:
        return Colors.green;
      case ProjectStatus.onHold:
        return Colors.grey;
      case ProjectStatus.cancelled:
        return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => di.getIt<ProjectBloc>()..add(GetProjectById(projectId)),
        ),
        BlocProvider(
          create: (context) => di.getIt<TaskBloc>()..add(LoadTasksByProject(projectId)),
        ),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Détails du Projet'),
          actions: [
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                context.push('/projects/$projectId/edit');
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (dialogContext) => AlertDialog(
                    title: const Text('Supprimer le projet'),
                    content: const Text('Êtes-vous sûr de vouloir supprimer ce projet ?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(dialogContext),
                        child: const Text('Annuler'),
                      ),
                      TextButton(
                        onPressed: () {
                          context.read<ProjectBloc>().add(DeleteProject(projectId));
                          Navigator.pop(dialogContext);
                          context.pop();
                        },
                        child: const Text('Supprimer', style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
        body: BlocBuilder<ProjectBloc, ProjectState>(
          builder: (context, state) {
            if (state is ProjectLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            
            if (state is ProjectError) {
              return Center(child: Text('Erreur : ${state.message}'));
            }
            
            if (state is ProjectLoaded) {
              final project = state.project;
              
              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // En-tête du projet
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Color(int.parse(project.colorHex?.substring(1) ?? 'FF6366F1', radix: 16) + 0xFF000000),
                            Color(int.parse(project.colorHex?.substring(1) ?? 'FF6366F1', radix: 16) + 0xFF000000).withOpacity(0.6),
                          ],
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            project.name,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Chip(
                                label: Text(project.status.name),
                                backgroundColor: _getStatusColor(project.status),
                                labelStyle: const TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    
                    // Progression
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Progression',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                '${project.progress.toStringAsFixed(0)}%',
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          LinearPercentIndicator(
                            lineHeight: 20,
                            percent: project.progress / 100,
                            backgroundColor: Colors.grey.shade300,
                            progressColor: _getStatusColor(project.status),
                            barRadius: const Radius.circular(10),
                          ),
                        ],
                      ),
                    ),
                    
                    // Description
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Description',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text(project.description),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Dates
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: [
                          Expanded(
                            child: Card(
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  children: [
                                    const Icon(Icons.calendar_today, color: Colors.blue),
                                    const SizedBox(height: 4),
                                    const Text('Début', style: TextStyle(fontSize: 12)),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${project.startDate.day}/${project.startDate.month}/${project.startDate.year}',
                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Card(
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  children: [
                                    const Icon(Icons.event, color: Colors.red),
                                    const SizedBox(height: 4),
                                    const Text('Fin', style: TextStyle(fontSize: 12)),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${project.endDate.day}/${project.endDate.month}/${project.endDate.year}',
                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Tâches
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Tâches',
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          ElevatedButton.icon(
                            onPressed: () {
                              context.push('/tasks/new?projectId=$projectId');
                            },
                            icon: const Icon(Icons.add),
                            label: const Text('Nouvelle tâche'),
                          ),
                        ],
                      ),
                    ),
                    
                    BlocBuilder<TaskBloc, TaskState>(
                      builder: (context, taskState) {
                        if (taskState is TaskLoading) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        
                        if (taskState is TasksLoaded) {
                          if (taskState.tasks.isEmpty) {
                            return const Padding(
                              padding: EdgeInsets.all(20),
                              child: Center(
                                child: Text('Aucune tâche pour ce projet'),
                              ),
                            );
                          }
                          
                          return ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: taskState.tasks.length,
                            itemBuilder: (context, index) {
                              final task = taskState.tasks[index];
                              return ListTile(
                                leading: Checkbox(
                                  value: task.status == TaskStatus.done,
                                  onChanged: (value) {
                                    context.read<TaskBloc>().add(
                                      UpdateTaskStatus(
                                        taskId: task.id,
                                        newStatus: value == true ? TaskStatus.done : TaskStatus.todo,
                                      ),
                                    );
                                  },
                                ),
                                title: Text(task.title),
                                subtitle: Text('Priorité: ${task.priority.name}'),
                                trailing: Icon(
                                  Icons.circle,
                                  size: 12,
                                  color: task.priority == TaskPriority.high 
                                    ? Colors.red 
                                    : task.priority == TaskPriority.medium 
                                      ? Colors.orange 
                                      : Colors.blue,
                                ),
                              );
                            },
                          );
                        }
                        
                        return const SizedBox.shrink();
                      },
                    ),
                  ],
                ),
              );
            }
            
            return const Center(child: Text('Projet non trouvé'));
          },
        ),
      ),
    );
  }
}
