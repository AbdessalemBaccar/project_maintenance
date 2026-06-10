import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../app_theme.dart';
import '../models/maintenance_entry.dart';

class EntryListTile extends StatelessWidget {
  const EntryListTile({super.key, required this.entry, this.onDelete});

  final MaintenanceEntry entry;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final dateFmt     = DateFormat('MMM d, yyyy');
    final currencyFmt = NumberFormat.currency(symbol: 'DT ', decimalDigits: 3);
    final mileageFmt  = NumberFormat('#,###');

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.cardSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF2A3A4C)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Emoji avatar
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFF1E2D4A),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(entry.serviceType.emoji,
                  style: const TextStyle(fontSize: 20)),
            ),
          ),
          const SizedBox(width: 12),

          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(entry.serviceType.label,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 14)),
                const SizedBox(height: 4),
                Row(children: [
                  const Icon(Icons.calendar_today_outlined,
                      size: 11, color: Color(0xFF7B8FA6)),
                  const SizedBox(width: 4),
                  Text(dateFmt.format(entry.date),
                      style: const TextStyle(
                          color: Color(0xFF7B8FA6), fontSize: 12)),
                  const SizedBox(width: 12),
                  const Icon(Icons.speed, size: 11, color: Color(0xFF7B8FA6)),
                  const SizedBox(width: 4),
                  Text('${mileageFmt.format(entry.mileage)} km',
                      style: const TextStyle(
                          color: Color(0xFF7B8FA6), fontSize: 12)),
                ]),
                if (entry.notes.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(entry.notes,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          color: Color(0xFF5A6A7C), fontSize: 12)),
                ],
              ],
            ),
          ),

          // Cost + delete
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(currencyFmt.format(entry.cost),
                  style: const TextStyle(
                    color: AppTheme.neonTeal,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  )),
              if (onDelete != null) ...[
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: onDelete,
                  child: const Icon(Icons.delete_outline,
                      size: 18, color: Color(0xFF4A5A6C)),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
