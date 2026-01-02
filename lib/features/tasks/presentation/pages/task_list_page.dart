import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/task_bloc.dart';
import '../bloc/task_event.dart';
import '../bloc/task_state.dart';
import '../../domain/entities/task.dart';
import '../../../../config/injection/injection_container.dart' as di;

class TaskListPage extends StatelessWidget {
  final String? projectId;
  
  const TaskListPage({super.key, this.projectId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => di.getIt<TaskBloc>()..add(
        projectId != null ? LoadTasksByProject(projectId!) : LoadTasks(),
      ),
      child: Scaffold(
        appBar: AppBar(
          title: Text(projectId != null ? 'Project Tasks' : 'All Tasks'),
        ),
        body: BlocBuilder<TaskBloc, TaskState>(
          builder: (context, state) {
            if (state is TaskLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            
            if (state is TaskError) {
              return Center(child: Text('Error: ${state.message}'));
            }
            
            if (state is TasksLoaded) {
              if (state.tasks.isEmpty) {
                return const Center(child: Text('No tasks found'));
              }
              return ListView.builder(
                itemCount: state.tasks.length,
                itemBuilder: (context, index) {
                  final task = state.tasks[index];
                  return ListTile(
                    title: Text(task.title),
                    subtitle: Text('Status: ${task.status.name}'),
                    trailing: IconButton(
                      icon: Icon(
                        task.status == TaskStatus.done ? Icons.check_circle : Icons.check_circle_outline,
                        color: task.status == TaskStatus.done ? Colors.green : Colors.grey,
                      ),
                      onPressed: () {
                        context.read<TaskBloc>().add(
                          UpdateTaskStatus(
                            taskId: task.id,
                            newStatus: task.status == TaskStatus.done 
                              ? TaskStatus.todo 
                              : TaskStatus.done,
                          ),
                        );
                      },
                    ),
                  );
                },
              );
            }
            
            // Permet de réessayer le chargement ou de charger la liste initiale
            return Center(
              child: ElevatedButton(
                onPressed: () {
                  if (projectId != null) {
                    context.read<TaskBloc>().add(LoadTasksByProject(projectId!));
                  } else {
                    context.read<TaskBloc>().add(LoadTasks());
                  }
                },
                child: const Text('Load Tasks'),
              ),
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            context.push('/tasks/new');
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
