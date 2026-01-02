import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/task_bloc.dart';
import '../bloc/task_event.dart';
import '../bloc/task_state.dart';
import '../../domain/entities/task.dart';
import '../../../projects/presentation/bloc/project_bloc.dart';
import '../../../projects/presentation/bloc/project_event.dart';
import '../../../projects/presentation/bloc/project_state.dart';
import 'package:pegasus_app/config/injection/injection_container.dart' as di;

class TaskFormPage extends StatefulWidget {
  final String? taskId;
  final String? projectId;
  
  const TaskFormPage({super.key, this.taskId, this.projectId});

  @override
  State<TaskFormPage> createState() => _TaskFormPageState();
}

class _TaskFormPageState extends State<TaskFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  String? _selectedProjectId;
  TaskPriority _priority = TaskPriority.medium;
  TaskStatus _status = TaskStatus.todo;
  DateTime _dueDate = DateTime.now().add(const Duration(days: 7));

  @override
  void initState() {
    super.initState();
    _selectedProjectId = widget.projectId;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() => _dueDate = picked);
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      if (_selectedProjectId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Veuillez sélectionner un projet'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      final task = Task(
        id: widget.taskId ?? DateTime.now().millisecondsSinceEpoch.toString(),
        projectId: _selectedProjectId!,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        priority: _priority,
        status: _status,
        dueDate: _dueDate,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      if (widget.taskId == null) {
        context.read<TaskBloc>().add(CreateTask(task));
      } else {
        context.read<TaskBloc>().add(UpdateTask(task));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => di.getIt<TaskBloc>()),
        BlocProvider(create: (context) => di.getIt<ProjectBloc>()..add(LoadProjects())),
      ],
      child: BlocListener<TaskBloc, TaskState>(
        listener: (context, state) {
          if (state is TaskCreated || state is TaskUpdated) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(widget.taskId == null 
                  ? 'Tâche créée avec succès !' 
                  : 'Tâche modifiée avec succès !'),
                backgroundColor: Colors.green,
              ),
            );
            context.pop();
          } else if (state is TaskError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Erreur : ${state.message}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: Scaffold(
          appBar: AppBar(
            title: Text(widget.taskId == null ? 'Nouvelle Tâche' : 'Modifier Tâche'),
          ),
          body: BlocBuilder<TaskBloc, TaskState>(
            builder: (context, taskState) {
              if (taskState is TaskLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      BlocBuilder<ProjectBloc, ProjectState>(
                        builder: (context, projectState) {
                          if (projectState is ProjectsLoaded) {
                            return DropdownButtonFormField<String>(
                              value: _selectedProjectId,
                              decoration: const InputDecoration(
                                labelText: 'Projet',
                                prefixIcon: Icon(Icons.folder),
                              ),
                              items: projectState.projects.map((project) {
                                return DropdownMenuItem(
                                  value: project.id,
                                  child: Text(project.name),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() => _selectedProjectId = value);
                              },
                              validator: (value) {
                                if (value == null) {
                                  return 'Veuillez sélectionner un projet';
                                }
                                return null;
                              },
                            );
                          }
                          return const LinearProgressIndicator();
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _titleController,
                        decoration: const InputDecoration(
                          labelText: 'Titre de la tâche',
                          prefixIcon: Icon(Icons.task),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Le titre est requis';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _descriptionController,
                        decoration: const InputDecoration(
                          labelText: 'Description',
                          prefixIcon: Icon(Icons.description),
                        ),
                        maxLines: 3,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'La description est requise';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<TaskPriority>(
                        value: _priority,
                        decoration: const InputDecoration(
                          labelText: 'Priorité',
                          prefixIcon: Icon(Icons.priority_high),
                        ),
                        items: TaskPriority.values.map((priority) {
                          return DropdownMenuItem(
                            value: priority,
                            child: Row(
                              children: [
                                Icon(
                                  Icons.circle,
                                  size: 12,
                                  color: priority == TaskPriority.high 
                                    ? Colors.red 
                                    : priority == TaskPriority.medium 
                                      ? Colors.orange 
                                      : Colors.blue,
                                ),
                                const SizedBox(width: 8),
                                Text(priority.name),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => _priority = value);
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<TaskStatus>(
                        value: _status,
                        decoration: const InputDecoration(
                          labelText: 'Statut',
                          prefixIcon: Icon(Icons.flag),
                        ),
                        items: TaskStatus.values.map((status) {
                          return DropdownMenuItem(
                            value: status,
                            child: Text(status.name),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => _status = value);
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                      ListTile(
                        leading: const Icon(Icons.event),
                        title: const Text('Date d\'échéance'),
                        subtitle: Text('${_dueDate.day}/${_dueDate.month}/${_dueDate.year}'),
                        trailing: const Icon(Icons.edit),
                        onTap: () => _selectDate(context),
                      ),
                      const SizedBox(height: 32),
                      ElevatedButton(
                        onPressed: _submitForm,
                        child: Text(widget.taskId == null ? 'Créer la tâche' : 'Sauvegarder'),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
