import 'package:flutter/material.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:pegasus_app/core/presentation/widgets/glass_container.dart';
import '../../../projects/domain/entities/project.dart';

class ProjectProgressCard extends StatelessWidget {
  final Project project;
  final VoidCallback onTap;

  const ProjectProgressCard({
    super.key,
    required this.project,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // GlassContainer needs to be wrapped or used instead of Card
    // Since we are already inside a GlassContainer in the list (DashboardPage), 
    // we can just return a transparent clickable area or a nested glass with different opacity.
    // For better visual hierarchy, let's use a nested glass layer.
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: GlassContainer(
        opacity: 0.05,
        blur: 5,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    project.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: _getStatusColor(project.status).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: _getStatusColor(project.status).withOpacity(0.5)),
                  ),
                  child: Text(
                    project.status.name.toUpperCase(),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: _getStatusColor(project.status),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearPercentIndicator(
                percent: project.progress / 100,
                lineHeight: 6,
                backgroundColor: Colors.white10,
                progressColor: _getStatusColor(project.status),
                barRadius: const Radius.circular(4),
                padding: EdgeInsets.zero,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.list_alt, size: 14, color: Colors.white54),
                    const SizedBox(width: 4),
                    Text(
                      '${project.taskIds?.length ?? 0} Tasks',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white54,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Text(
                      '${project.progress.toStringAsFixed(0)}%',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                 ],
                )
              ],
            ),
             const SizedBox(height: 4),
             Align(
              alignment: Alignment.centerRight,
               child: Text(
                _getDaysRemaining(project.endDate),
                style: TextStyle(
                  fontSize: 11,
                  fontStyle: FontStyle.italic,
                  color: project.isOverdue ? Colors.redAccent : Colors.white38,
                ),
              ),
             ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(ProjectStatus status) {
    switch (status) {
      case ProjectStatus.todo:
        return Colors.white70;
      case ProjectStatus.inProgress:
        return Colors.blueAccent;
      case ProjectStatus.done:
        return Colors.greenAccent;
      case ProjectStatus.archived:
        return Colors.orangeAccent;
    }
  }

  String _getDaysRemaining(DateTime endDate) {
    final now = DateTime.now();
    final difference = endDate.difference(now);
    if (difference.inDays < 0) {
      return 'Overdue';
    } else if (difference.inDays == 0) {
      return 'Due today';
    } else {
      return '${difference.inDays} days remaining';
    }
  }
}
