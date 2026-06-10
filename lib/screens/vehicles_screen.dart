import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../app_theme.dart';
import '../models/car_profile.dart';
import '../providers/app_providers.dart';
import '../router.dart';
import '../widgets/service_status_badge.dart';

class VehiclesScreen extends ConsumerWidget {
  const VehiclesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vehiclesAsync = ref.watch(vehiclesProvider);

    return Scaffold(
      backgroundColor: AppTheme.primaryDark,
      appBar: AppBar(
        title: Row(children: [
          Container(
            width: 32, height: 32,
            decoration: BoxDecoration(
              gradient: AppTheme.tealGradient,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.directions_car, size: 18, color: Colors.black),
          ),
          const SizedBox(width: 10),
          const Text('CarTrack'),
        ]),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_outlined, color: Colors.white),
            onPressed: () => ref.read(authFormProvider.notifier).signOut(),
            tooltip: 'Sign Out',
          ),
        ],
      ),
      body: vehiclesAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.neonTeal),
          ),
        ),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (vehicles) {
          if (vehicles.isEmpty) {
            return _EmptyVehicles(onAdd: () => context.go(AppRoutes.addVehicle));
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
            physics: const BouncingScrollPhysics(),
            itemCount: vehicles.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final vehicle = vehicles[index];
              return _VehicleCard(
                vehicle: vehicle,
                onTap: () {
                  ref.read(selectedVehicleIdProvider.notifier).state = vehicle.id;
                  context.go(AppRoutes.dashboard);
                },
                onEdit: () {
                  ref.read(selectedVehicleIdProvider.notifier).state = vehicle.id;
                  context.go(AppRoutes.editVehicle);
                },
                onDelete: () => _confirmDelete(context, ref, vehicle),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go(AppRoutes.addVehicle),
        icon: const Icon(Icons.add),
        label: const Text('Add Vehicle'),
      ),
    );
  }

  Future<void> _confirmDelete(
      BuildContext context, WidgetRef ref, CarProfile vehicle) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.cardSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Delete ${vehicle.displayName}?'),
        content: const Text(
          'This will permanently delete the vehicle and ALL its maintenance records.',
          style: TextStyle(color: Color(0xFF7B8FA6)),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: AppTheme.error),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      final user = ref.read(currentUserProvider);
      if (user != null) {
        await ref
            .read(firestoreServiceProvider)
            .deleteVehicle(user.uid, vehicle.id);
      }
    }
  }
}

class _VehicleCard extends StatelessWidget {
  const _VehicleCard({
    required this.vehicle,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  final CarProfile vehicle;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final mileageFmt = NumberFormat('#,###');

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.cardSurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF2A3A4C)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48, height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E2D4A),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(vehicle.vehicleType.emoji,
                        style: const TextStyle(fontSize: 24)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(vehicle.displayName,
                          style: const TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 16)),
                      if (vehicle.licensePlate.isNotEmpty)
                        Text(vehicle.licensePlate,
                            style: const TextStyle(
                                color: Color(0xFF7B8FA6), fontSize: 13)),
                    ],
                  ),
                ),
                ServiceStatusBadge(status: vehicle.serviceStatus),
              ],
            ),
            const SizedBox(height: 14),
            const Divider(height: 1),
            const SizedBox(height: 12),
            Row(
              children: [
                _InfoChip(
                  icon: Icons.speed,
                  label: '${mileageFmt.format(vehicle.currentMileage)} km',
                ),
                const SizedBox(width: 10),
                _InfoChip(
                  icon: Icons.build_outlined,
                  label: vehicle.serviceStatus == ServiceStatus.overdue
                      ? 'Overdue'
                      : '${mileageFmt.format(vehicle.milesUntilService)} km left',
                  color: vehicle.serviceStatus == ServiceStatus.overdue
                      ? AppTheme.error
                      : vehicle.serviceStatus == ServiceStatus.soon
                          ? AppTheme.warning
                          : AppTheme.neonTeal,
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.edit_outlined,
                      size: 20, color: Color(0xFF7B8FA6)),
                  onPressed: onEdit,
                  tooltip: 'Edit',
                  constraints: const BoxConstraints(),
                  padding: const EdgeInsets.all(6),
                ),
                const SizedBox(width: 4),
                IconButton(
                  icon: const Icon(Icons.delete_outline,
                      size: 20, color: Color(0xFF7B8FA6)),
                  onPressed: onDelete,
                  tooltip: 'Delete',
                  constraints: const BoxConstraints(),
                  padding: const EdgeInsets.all(6),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({
    required this.icon,
    required this.label,
    this.color = const Color(0xFF7B8FA6),
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text(label,
            style: TextStyle(
                color: color, fontSize: 12, fontWeight: FontWeight.w600)),
      ],
    );
  }
}

class _EmptyVehicles extends StatelessWidget {
  const _EmptyVehicles({required this.onAdd});
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('🚗', style: TextStyle(fontSize: 64)),
            const SizedBox(height: 16),
            const Text('No vehicles yet',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 20)),
            const SizedBox(height: 8),
            const Text(
              'Add your first vehicle to start\ntracking its maintenance.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xFF7B8FA6), fontSize: 14),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add),
              label: const Text('Add Vehicle'),
            ),
          ],
        ),
      ),
    );
  }
}
