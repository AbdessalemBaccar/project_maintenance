import 'package:cloud_firestore/cloud_firestore.dart';

enum ServiceType {
  oilChange('Oil Change', '🛢️'),
  tireRotation('Tire Rotation', '🔄'),
  brakeService('Brake Service', '🛑'),
  airFilter('Air Filter', '💨'),
  transmission('Transmission Service', '⚙️'),
  coolant('Coolant Flush', '🌡️'),
  battery('Battery Replacement', '🔋'),
  sparkPlugs('Spark Plugs', '⚡'),
  alignment('Wheel Alignment', '📐'),
  inspection('Annual Inspection', '📋'),
  detailing('Detailing / Wash', '✨'),
  other('Other', '🔧');

  const ServiceType(this.label, this.emoji);
  final String label;
  final String emoji;

  static ServiceType fromLabel(String label) {
    return ServiceType.values.firstWhere(
      (e) => e.label == label,
      orElse: () => ServiceType.other,
    );
  }
}

class MaintenanceEntry {
  final String id;
  final String userId;
  final ServiceType serviceType;
  final DateTime date;
  final int mileage;
  final double cost;
  final String notes;
  final DateTime createdAt;

  const MaintenanceEntry({
    required this.id,
    required this.userId,
    required this.serviceType,
    required this.date,
    required this.mileage,
    required this.cost,
    this.notes = '',
    required this.createdAt,
  });

  factory MaintenanceEntry.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return MaintenanceEntry(
      id: doc.id,
      userId: data['userId'] as String? ?? '',
      serviceType: ServiceType.fromLabel(data['serviceType'] as String? ?? ''),
      date: (data['date'] as Timestamp).toDate(),
      mileage: (data['mileage'] as num?)?.toInt() ?? 0,
      cost: (data['cost'] as num?)?.toDouble() ?? 0.0,
      notes: data['notes'] as String? ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'userId': userId,
        'serviceType': serviceType.label,
        'date': Timestamp.fromDate(date),
        'mileage': mileage,
        'cost': cost,
        'notes': notes,
        'createdAt': Timestamp.fromDate(createdAt),
      };

  MaintenanceEntry copyWith({
    String? id,
    String? userId,
    ServiceType? serviceType,
    DateTime? date,
    int? mileage,
    double? cost,
    String? notes,
    DateTime? createdAt,
  }) =>
      MaintenanceEntry(
        id: id ?? this.id,
        userId: userId ?? this.userId,
        serviceType: serviceType ?? this.serviceType,
        date: date ?? this.date,
        mileage: mileage ?? this.mileage,
        cost: cost ?? this.cost,
        notes: notes ?? this.notes,
        createdAt: createdAt ?? this.createdAt,
      );
}
