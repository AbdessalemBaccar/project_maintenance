import 'package:flutter/material.dart';
import '../app_theme.dart';
import '../models/car_profile.dart';

class ServiceStatusBadge extends StatelessWidget {
  const ServiceStatusBadge({super.key, required this.status});
  final ServiceStatus status;

  Color get _bg {
    switch (status) {
      case ServiceStatus.good:    return AppTheme.success.withOpacity(0.15);
      case ServiceStatus.soon:    return AppTheme.warning.withOpacity(0.15);
      case ServiceStatus.overdue: return AppTheme.error.withOpacity(0.15);
    }
  }

  Color get _fg {
    switch (status) {
      case ServiceStatus.good:    return AppTheme.success;
      case ServiceStatus.soon:    return AppTheme.warning;
      case ServiceStatus.overdue: return AppTheme.error;
    }
  }

  IconData get _icon {
    switch (status) {
      case ServiceStatus.good:    return Icons.check_circle_outline;
      case ServiceStatus.soon:    return Icons.schedule;
      case ServiceStatus.overdue: return Icons.warning_amber_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: _bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _fg.withOpacity(0.4)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(_icon, size: 13, color: _fg),
        const SizedBox(width: 4),
        Text(status.label,
            style: TextStyle(
                color: _fg, fontSize: 12, fontWeight: FontWeight.w600)),
      ]),
    );
  }
}
