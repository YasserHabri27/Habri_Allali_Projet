import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/project_bloc.dart';
import '../bloc/project_event.dart';
import '../bloc/project_state.dart';
import '../../domain/entities/project.dart';
import 'package:pegasus_app/config/injection/injection_container.dart' as di;

class ProjectFormPage extends StatefulWidget {
  final String? projectId;
  
  const ProjectFormPage({super.key, this.projectId});

  @override
  State<ProjectFormPage> createState() => _ProjectFormPageState();
}

class _ProjectFormPageState extends State<ProjectFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 30));
  ProjectStatus _status = ProjectStatus.planning;
  String? _selectedColor;

  final List<Map<String, dynamic>> _colors = [
    {'name': 'Indigo', 'hex': '#6366F1'},
    {'name': 'Rose', 'hex': '#EC4899'},
    {'name': 'Emerald', 'hex': '#10B981'},
    {'name': 'Amber', 'hex': '#F59E0B'},
    {'name': 'Purple', 'hex': '#8B5CF6'},
  ];

  @override
  void initState() {
    super.initState();
    _selectedColor = _colors[0]['hex'];
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStartDate ? _startDate : _endDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
          if (_endDate.isBefore(_startDate)) {
            _endDate = _startDate.add(const Duration(days: 7));
          }
        } else {
          _endDate = picked;
        }
      });
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final project = Project(
        id: widget.projectId ?? DateTime.now().millisecondsSinceEpoch.toString(),
        userId: 'current-user',
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        status: _status,
        progress: 0.0,
        startDate: _startDate,
        endDate: _endDate,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        taskIds: const [],
        colorHex: _selectedColor,
      );

      if (widget.projectId == null) {
        context.read<ProjectBloc>().add(CreateProject(project));
      } else {
        context.read<ProjectBloc>().add(UpdateProject(project));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => di.getIt<ProjectBloc>(),
      child: BlocListener<ProjectBloc, ProjectState>(
        listener: (context, state) {
          if (state is ProjectCreated || state is ProjectUpdated) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(widget.projectId == null 
                  ? 'Projet créé avec succès !' 
                  : 'Projet modifié avec succès !'),
                backgroundColor: Colors.green,
              ),
            );
            context.pop();
          } else if (state is ProjectError) {
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
            title: Text(widget.projectId == null ? 'Nouveau Projet' : 'Modifier Projet'),
          ),
          body: BlocBuilder<ProjectBloc, ProjectState>(
            builder: (context, state) {
              if (state is ProjectLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Nom du projet',
                          prefixIcon: Icon(Icons.folder),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Le nom est requis';
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
                      DropdownButtonFormField<ProjectStatus>(
                        value: _status,
                        decoration: const InputDecoration(
                          labelText: 'Statut',
                          prefixIcon: Icon(Icons.flag),
                        ),
                        items: ProjectStatus.values.map((status) {
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
                        leading: const Icon(Icons.calendar_today),
                        title: const Text('Date de début'),
                        subtitle: Text('${_startDate.day}/${_startDate.month}/${_startDate.year}'),
                        trailing: const Icon(Icons.edit),
                        onTap: () => _selectDate(context, true),
                      ),
                      ListTile(
                        leading: const Icon(Icons.event),
                        title: const Text('Date de fin'),
                        subtitle: Text('${_endDate.day}/${_endDate.month}/${_endDate.year}'),
                        trailing: const Icon(Icons.edit),
                        onTap: () => _selectDate(context, false),
                      ),
                      const SizedBox(height: 16),
                      const Text('Couleur du projet', style: TextStyle(fontSize: 16)),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: _colors.map((color) {
                          final isSelected = _selectedColor == color['hex'];
                          return ChoiceChip(
                            label: Text(color['name']),
                            selected: isSelected,
                            onSelected: (selected) {
                              setState(() => _selectedColor = color['hex']);
                            },
                            selectedColor: Color(int.parse(color['hex'].substring(1), radix: 16) + 0xFF000000),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 32),
                      ElevatedButton(
                        onPressed: _submitForm,
                        child: Text(widget.projectId == null ? 'Créer le projet' : 'Sauvegarder'),
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
