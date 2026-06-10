import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../app_theme.dart';
import '../models/car_profile.dart';
import '../providers/app_providers.dart';
import '../router.dart';
import '../widgets/stat_card.dart';
import '../widgets/service_status_badge.dart';
import '../widgets/entry_list_tile.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedVehicle = ref.watch(selectedVehicleProvider);
    final entriesAsync   = ref.watch(maintenanceEntriesProvider);
    final user           = ref.watch(currentUserProvider);
    final currencyFmt    = NumberFormat.currency(symbol: 'DT ', decimalDigits: 3);
    final mileageFmt     = NumberFormat('#,###');

    return Scaffold(
      backgroundColor: AppTheme.primaryDark,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: 0,
            floating: true,
            pinned: false,
            backgroundColor: AppTheme.primaryDark,
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
                icon: const Icon(Icons.garage_outlined, color: Colors.white),
                onPressed: () => context.go(AppRoutes.vehicles),
                tooltip: 'My Vehicles',
              ),
              IconButton(
                icon: const Icon(Icons.logout_outlined, color: Colors.white),
                onPressed: () => ref.read(authFormProvider.notifier).signOut(),
                tooltip: 'Sign Out',
              ),
            ],
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Greeting ─────────────────────────────────────────────
                  Text(_greeting(),
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: const Color(0xFF7B8FA6))),
                  Text(
                    user?.email?.split('@').first ?? 'Driver',
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 24),

                  // ── Vehicle Hero Card ─────────────────────────────────────
                  selectedVehicle == null
                      ? _SetupVehicleCard(
                          onTap: () => context.go(AppRoutes.addVehicle))
                      : _VehicleHeroCard(
                          profile: selectedVehicle, mileageFmt: mileageFmt),
                  const SizedBox(height: 24),

                  // ── Stats Row ─────────────────────────────────────────────
                  entriesAsync.when(
                    loading: () => const _StatsRowSkeleton(),
                    error: (_, __) => const SizedBox.shrink(),
                    data: (entries) {
                      final totalSpend =
                          entries.fold<double>(0, (s, e) => s + e.cost);
                      return Row(children: [
                        Expanded(
                          child: StatCard(
                            label: 'Total Spent',
                            value: currencyFmt.format(totalSpend),
                            icon: Icons.payments_outlined,
                            iconColor: AppTheme.neonTeal,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: StatCard(
                            label: 'Service Logs',
                            value: entries.length.toString(),
                            icon: Icons.receipt_long_outlined,
                            iconColor: const Color(0xFF7B8CDE),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: StatCard(
                            label: 'This Year',
                            value: currencyFmt.format(entries
                                .where((e) =>
                                    e.date.year == DateTime.now().year)
                                .fold<double>(0, (s, e) => s + e.cost)),
                            icon: Icons.calendar_today_outlined,
                            iconColor: AppTheme.warning,
                          ),
                        ),
                      ]);
                    },
                  ),
                  const SizedBox(height: 28),

                  // ── Recent Activity ───────────────────────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Recent Activity',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.w700)),
                      TextButton(
                        onPressed: () => context.go(AppRoutes.history),
                        child: const Text('See All'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  entriesAsync.when(
                    loading: () => Column(
                      children: List.generate(
                          3, (_) => const _EntryTileSkeleton()),
                    ),
                    error: (e, _) =>
                        const _ErrorCard('Could not load maintenance history'),
                    data: (entries) {
                      if (entries.isEmpty) {
                        return _EmptyHistory(
                            onAdd: () => context.go(AppRoutes.addEntry));
                      }
                      return Column(
                        children: entries
                            .take(3)
                            .map((e) => Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: EntryListTile(entry: e),
                                ))
                            .toList(),
                      );
                    },
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning,';
    if (h < 17) return 'Good afternoon,';
    return 'Good evening,';
  }
}

// ── Vehicle Hero Card ──────────────────────────────────────────────────────────
class _VehicleHeroCard extends StatelessWidget {
  const _VehicleHeroCard({required this.profile, required this.mileageFmt});
  final CarProfile profile;
  final NumberFormat mileageFmt;

  @override
  Widget build(BuildContext context) {
    final status = profile.serviceStatus;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppTheme.heroGradient,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF2A3A4C)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(profile.vehicleType.emoji,
                  style: const TextStyle(fontSize: 28)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(profile.displayName,
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge
                            ?.copyWith(fontWeight: FontWeight.w700)),
                    if (profile.licensePlate.isNotEmpty)
                      Text(profile.licensePlate,
                          style: const TextStyle(
                              color: Color(0xFF7B8FA6), fontSize: 13)),
                  ],
                ),
              ),
              ServiceStatusBadge(status: status),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(height: 1),
          const SizedBox(height: 16),
          Row(children: [
            _MileageStat(
              label: 'Current Mileage',
              value: '${mileageFmt.format(profile.currentMileage)} km',
              icon: Icons.speed,
            ),
            const SizedBox(width: 24),
            _MileageStat(
              label: 'Next Service',
              value: status == ServiceStatus.overdue
                  ? 'OVERDUE'
                  : '${mileageFmt.format(profile.milesUntilService)} km',
              icon: Icons.build_outlined,
              valueColor: status == ServiceStatus.overdue
                  ? AppTheme.error
                  : status == ServiceStatus.soon
                      ? AppTheme.warning
                      : AppTheme.neonTeal,
            ),
          ]),
        ],
      ),
    );
  }
}

class _MileageStat extends StatelessWidget {
  const _MileageStat({
    required this.label,
    required this.value,
    required this.icon,
    this.valueColor,
  });
  final String label;
  final String value;
  final IconData icon;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Row(children: [
        Icon(icon, size: 18, color: valueColor ?? AppTheme.neonTeal),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(
                      color: Color(0xFF7B8FA6), fontSize: 11)),
              Text(value,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: valueColor ?? Colors.white,
                  )),
            ],
          ),
        ),
      ]),
    );
  }
}

class _SetupVehicleCard extends StatelessWidget {
  const _SetupVehicleCard({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppTheme.neonTeal.withOpacity(0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.neonTeal.withOpacity(0.3)),
        ),
        child: Row(children: [
          const Icon(Icons.add_circle_outline,
              color: AppTheme.neonTeal, size: 36),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Add Your Vehicle',
                    style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        color: AppTheme.neonTeal)),
                const SizedBox(height: 2),
                Text('Set up a vehicle to start tracking',
                    style: TextStyle(
                        color: AppTheme.neonTeal.withOpacity(0.7),
                        fontSize: 13)),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: AppTheme.neonTeal),
        ]),
      ),
    );
  }
}

class _EmptyHistory extends StatelessWidget {
  const _EmptyHistory({required this.onAdd});
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: AppTheme.cardSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2A3A4C)),
      ),
      child: Column(children: [
        const Icon(Icons.history, size: 40, color: Color(0xFF3A4A5C)),
        const SizedBox(height: 12),
        const Text('No service records yet',
            style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 4),
        const Text('Log your first maintenance entry.',
            style: TextStyle(color: Color(0xFF7B8FA6), fontSize: 13)),
        const SizedBox(height: 16),
        OutlinedButton.icon(
          onPressed: onAdd,
          icon: const Icon(Icons.add, size: 18),
          label: const Text('Log Service'),
        ),
      ]),
    );
  }
}

// ── Skeletons ──────────────────────────────────────────────────────────────────
class _StatsRowSkeleton extends StatelessWidget {
  const _StatsRowSkeleton();
  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(
        3,
        (i) => Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: i < 2 ? 12 : 0),
            child: Container(
              height: 80,
              decoration: BoxDecoration(
                color: AppTheme.cardSurface,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _EntryTileSkeleton extends StatelessWidget {
  const _EntryTileSkeleton();
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Container(
          height: 72,
          decoration: BoxDecoration(
            color: AppTheme.cardSurface,
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
}

class _ErrorCard extends StatelessWidget {
  const _ErrorCard(this.message);
  final String message;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.error.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.error.withOpacity(0.3)),
      ),
      child: Row(children: [
        const Icon(Icons.error_outline, color: AppTheme.error, size: 20),
        const SizedBox(width: 8),
        Expanded(
            child: Text(message,
                style:
                    const TextStyle(color: AppTheme.error, fontSize: 13))),
      ]),
    );
  }
}
