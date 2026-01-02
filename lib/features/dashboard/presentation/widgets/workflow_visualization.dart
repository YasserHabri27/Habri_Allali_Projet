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
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Workflow Overview',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'This Week',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildWorkflowStep(
                'Projects',
                totalProjects.toString(),
                Icons.grid_view_rounded,
                Colors.blueAccent,
              ),
              const Icon(Icons.arrow_right_alt_rounded, color: Colors.white24, size: 30),
              _buildWorkflowStep(
                'Tasks',
                totalTasks.toString(),
                Icons.check_box_outlined,
                Colors.greenAccent,
              ),
              const Icon(Icons.arrow_right_alt_rounded, color: Colors.white24, size: 30),
              _buildWorkflowStep(
                'Progress',
                '${overallProgress.toStringAsFixed(0)}%',
                Icons.pie_chart_outline_rounded,
                Colors.purpleAccent,
              ),
            ],
          ),
          const SizedBox(height: 24),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: overallProgress / 100,
              backgroundColor: Colors.white10,
              color: Colors.purpleAccent,
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkflowStep(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            shape: BoxShape.circle,
            border: Border.all(color: color.withOpacity(0.5), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.2),
                blurRadius: 10,
                spreadRadius: 2,
              )
            ]
          ),
          child: Icon(icon, color: color, size: 22),
        ),
        const SizedBox(height: 10),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            color: Colors.white,
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(color: color.withOpacity(0.5), blurRadius: 8),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.white54,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
