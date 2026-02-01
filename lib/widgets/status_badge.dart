import 'package:flutter/material.dart';
import '../models/job.dart';

class StatusBadge extends StatelessWidget {
  final JobStatus status;
  const StatusBadge({Key? key, required this.status}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color color;
    String text = status.name;
    switch (status) {
      case JobStatus.NEW: color = Colors.grey; break;
      case JobStatus.QUEUED: color = Colors.blue; break;
      case JobStatus.PROCESSING: color = Colors.amber; break;
      case JobStatus.APPLIED: color = Colors.greenAccent; break;
      case JobStatus.FAILED: color = Colors.redAccent; break;
      case JobStatus.SKIPPED: color = Colors.grey; break;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        border: Border.all(color: color.withOpacity(0.2)),
        borderRadius: BorderRadius.circular(8),
        boxShadow: status == JobStatus.APPLIED
            ? [BoxShadow(color: color.withOpacity(0.1), blurRadius: 10)]
            : null,
      ),
      child: Text(
        text,
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }
}
