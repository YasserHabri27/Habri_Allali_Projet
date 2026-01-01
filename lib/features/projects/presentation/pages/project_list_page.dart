import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/project_bloc.dart';
import '../bloc/project_event.dart';
import '../bloc/project_state.dart';
import '../../config/injection/injection_container.dart' as di;

class ProjectListPage extends StatelessWidget {
  const ProjectListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => di.getIt<ProjectBloc>()..add(LoadProjects()),
      child: Scaffold(
        appBar: AppBar(title: const Text('Projects')),
        body: BlocBuilder<ProjectBloc, ProjectState>(
          builder: (context, state) {
            if (state is ProjectLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is ProjectError) {
              return Center(child: Text('Error: ${state.message}'));
            }
            if (state is ProjectsLoaded) {
              return ListView.builder(
                itemCount: state.projects.length,
                itemBuilder: (context, index) {
                  final project = state.projects[index];
                  return ListTile(
                    title: Text(project.name),
                    subtitle: Text('Progress: ${project.progress.toStringAsFixed(1)}%'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                  );
                },
              );
            }
            return Center(
              child: ElevatedButton(
                onPressed: () {
                  context.read<ProjectBloc>().add(LoadProjects());
                },
                child: const Text('Load Projects'),
              ),
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            // Navigate to project creation form
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
