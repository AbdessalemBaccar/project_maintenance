import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../app_theme.dart';
import '../models/maintenance_entry.dart';
import '../providers/app_providers.dart';
import '../router.dart';
import '../widgets/entry_list_tile.dart';

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  final _searchCtrl = TextEditingController();
  String _query = '';
  ServiceType? _filterType;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<MaintenanceEntry> _filtered(List<MaintenanceEntry> entries) {
    var list = entries;
    if (_query.isNotEmpty) {
      final q = _query.toLowerCase();
      list = list
          .where((e) =>
              e.serviceType.label.toLowerCase().contains(q) ||
              e.notes.toLowerCase().contains(q))
          .toList();
    }
    if (_filterType != null) {
      list = list.where((e) => e.serviceType == _filterType).toList();
    }
    return list;
  }

  Future<void> _deleteEntry(MaintenanceEntry entry) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.cardSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Entry?'),
        content: Text(
          'Are you sure you want to delete this ${entry.serviceType.label} entry?',
          style: const TextStyle(color: Color(0xFF7B8FA6)),
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

    if (confirmed == true && mounted) {
      try {
        final user    = ref.read(currentUserProvider);
        final vehicle = ref.read(selectedVehicleProvider);
        if (user != null && vehicle != null) {
          await ref
              .read(firestoreServiceProvider)
              .deleteEntry(user.uid, vehicle.id, entry.id);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Entry deleted.')));
          }
        }
      } catch (_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to delete. Please try again.'),
              backgroundColor: AppTheme.error,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final entriesAsync   = ref.watch(maintenanceEntriesProvider);
    final selectedVehicle = ref.watch(selectedVehicleProvider);

    return Scaffold(
      backgroundColor: AppTheme.primaryDark,
      appBar: AppBar(
        title: Text(selectedVehicle != null
            ? '${selectedVehicle.vehicleType.emoji} History'
            : 'Service History'),
        actions: [
          if (_filterType != null)
            TextButton.icon(
              onPressed: () => setState(() => _filterType = null),
              icon: const Icon(Icons.filter_list_off, size: 18),
              label: const Text('Clear'),
            ),
          IconButton(
            icon: const Icon(Icons.filter_list_outlined),
            tooltip: 'Filter',
            onPressed: _showFilterSheet,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (v) => setState(() => _query = v),
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search by service or notes…',
                prefixIcon: const Icon(Icons.search, size: 20),
                suffixIcon: _query.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () {
                          _searchCtrl.clear();
                          setState(() => _query = '');
                        },
                      )
                    : null,
              ),
            ),
          ),

          if (_filterType != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Chip(
                  label: Text(
                      '${_filterType!.emoji} ${_filterType!.label}'),
                  deleteIcon: const Icon(Icons.close, size: 16),
                  onDeleted: () => setState(() => _filterType = null),
                ),
              ),
            ),

          Expanded(
            child: entriesAsync.when(
              loading: () => const Center(
                child: CircularProgressIndicator(
                  valueColor:
                      AlwaysStoppedAnimation<Color>(AppTheme.neonTeal),
                ),
              ),
              error: (e, _) => Center(
                  child: Text('Error: $e',
                      style: const TextStyle(color: Color(0xFF7B8FA6)))),
              data: (entries) {
                final filtered = _filtered(entries);
                if (filtered.isEmpty) {
                  return _EmptyState(
                    hasFilter: _query.isNotEmpty || _filterType != null,
                    onAdd: () => context.go(AppRoutes.addEntry),
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 120),
                  physics: const BouncingScrollPhysics(),
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final entry = filtered[index];
                    return Dismissible(
                      key: Key(entry.id),
                      direction: DismissDirection.endToStart,
                      confirmDismiss: (_) async {
                        await _deleteEntry(entry);
                        return false;
                      },
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        decoration: BoxDecoration(
                          color: AppTheme.error.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(Icons.delete_outline,
                            color: AppTheme.error),
                      ),
                      child: EntryListTile(
                        entry: entry,
                        onDelete: () => _deleteEntry(entry),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterSheet() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppTheme.cardSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFF3A4A5C),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Filter by Service Type',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: ServiceType.values.map((type) {
                final isSelected = _filterType == type;
                return FilterChip(
                  label: Text('${type.emoji} ${type.label}'),
                  selected: isSelected,
                  onSelected: (_) {
                    setState(() => _filterType = isSelected ? null : type);
                    Navigator.pop(ctx);
                  },
                  selectedColor: AppTheme.neonTeal.withOpacity(0.2),
                  checkmarkColor: AppTheme.neonTeal,
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.hasFilter, required this.onAdd});
  final bool hasFilter;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(hasFilter ? Icons.search_off : Icons.history,
                size: 56, color: const Color(0xFF3A4A5C)),
            const SizedBox(height: 16),
            Text(hasFilter ? 'No results found' : 'No service records',
                style: const TextStyle(
                    fontWeight: FontWeight.w600, fontSize: 16)),
            const SizedBox(height: 8),
            Text(
              hasFilter
                  ? 'Try adjusting your search or filter.'
                  : 'Log your first maintenance entry.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: Color(0xFF7B8FA6), fontSize: 13),
            ),
            if (!hasFilter) ...[
              const SizedBox(height: 20),
              OutlinedButton.icon(
                onPressed: onAdd,
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Log Service'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
