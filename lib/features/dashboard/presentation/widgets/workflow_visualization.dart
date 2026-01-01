import 'package:flutter/material.dart';

class WorkflowVisualization extends StatelessWidget {
  final int totalProjects;
  final int totalTasks;
  final double overallProgress;

  const WorkflowVisualization({
    super.key,
    required this.totalProjects,
    required this.totalTasks,
    required this.overallProgress,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Workflow Overview',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            // Diagramme simplifié Projects → Tasks
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildWorkflowStep(
                  'Projects',
                  totalProjects.toString(),
                  Icons.folder,
                  Colors.blue,
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Icon(Icons.arrow_forward, color: Colors.grey),
                ),
                _buildWorkflowStep(
                  'Tasks',
                  totalTasks.toString(),
                  Icons.task,
                  Colors.green,
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Icon(Icons.arrow_forward, color: Colors.grey),
                ),
                _buildWorkflowStep(
                  'Progress',
                  '${overallProgress.toStringAsFixed(1)}%',
                  Icons.trending_up,
                  Colors.purple,
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Barre de progression globale
            LinearProgressIndicator(
              value: overallProgress / 100,
              backgroundColor: Colors.grey[200],
              color: Colors.purple,
              minHeight: 8,
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Overall Progress',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                Text(
                  '${overallProgress.toStringAsFixed(1)}%',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWorkflowStep(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
