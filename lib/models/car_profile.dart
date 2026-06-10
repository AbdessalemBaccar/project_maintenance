import 'package:cloud_firestore/cloud_firestore.dart';

enum VehicleType {
  car('Car', '🚗'),
  motorcycle('Motorcycle', '🏍️'),
  truck('Truck / Tractor', '🚛');

  const VehicleType(this.label, this.emoji);
  final String label;
  final String emoji;

  static VehicleType fromLabel(String label) {
    return VehicleType.values.firstWhere(
      (e) => e.label == label,
      orElse: () => VehicleType.car,
    );
  }
}

class CarProfile {
  final String id;
  final String userId;
  final String make;
  final String model;
  final int year;
  final String licensePlate;
  final int currentMileage;
  final int nextServiceMileage;
  final String vin;
  final VehicleType vehicleType;
  final DateTime updatedAt;

  const CarProfile({
    required this.id,
    required this.userId,
    required this.make,
    required this.model,
    required this.year,
    this.licensePlate = '',
    required this.currentMileage,
    required this.nextServiceMileage,
    this.vin = '',
    this.vehicleType = VehicleType.car,
    required this.updatedAt,
  });

  factory CarProfile.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CarProfile(
      id: doc.id,
      userId: data['userId'] as String? ?? '',
      make: data['make'] as String? ?? '',
      model: data['model'] as String? ?? '',
      year: (data['year'] as num?)?.toInt() ?? DateTime.now().year,
      licensePlate: data['licensePlate'] as String? ?? '',
      currentMileage: (data['currentMileage'] as num?)?.toInt() ?? 0,
      nextServiceMileage: (data['nextServiceMileage'] as num?)?.toInt() ?? 5000,
      vin: data['vin'] as String? ?? '',
      vehicleType: VehicleType.fromLabel(data['vehicleType'] as String? ?? ''),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  factory CarProfile.empty(String userId) => CarProfile(
        id: '',
        userId: userId,
        make: '',
        model: '',
        year: DateTime.now().year,
        currentMileage: 0,
        nextServiceMileage: 5000,
        vehicleType: VehicleType.car,
        updatedAt: DateTime.now(),
      );

  Map<String, dynamic> toFirestore() => {
        'userId': userId,
        'make': make,
        'model': model,
        'year': year,
        'licensePlate': licensePlate,
        'currentMileage': currentMileage,
        'nextServiceMileage': nextServiceMileage,
        'vin': vin,
        'vehicleType': vehicleType.label,
        'updatedAt': Timestamp.fromDate(updatedAt),
      };

  String get displayName => '$year $make $model'.trim();
  bool get isEmpty => make.isEmpty && model.isEmpty;
  int get milesUntilService =>
      (nextServiceMileage - currentMileage).clamp(0, 999999);

  ServiceStatus get serviceStatus {
    final remaining = nextServiceMileage - currentMileage;
    if (remaining <= 0) return ServiceStatus.overdue;
    if (remaining <= 1000) return ServiceStatus.soon;
    return ServiceStatus.good;
  }

  CarProfile copyWith({
    String? id,
    String? userId,
    String? make,
    String? model,
    int? year,
    String? licensePlate,
    int? currentMileage,
    int? nextServiceMileage,
    String? vin,
    VehicleType? vehicleType,
    DateTime? updatedAt,
  }) =>
      CarProfile(
        id: id ?? this.id,
        userId: userId ?? this.userId,
        make: make ?? this.make,
        model: model ?? this.model,
        year: year ?? this.year,
        licensePlate: licensePlate ?? this.licensePlate,
        currentMileage: currentMileage ?? this.currentMileage,
        nextServiceMileage: nextServiceMileage ?? this.nextServiceMileage,
        vin: vin ?? this.vin,
        vehicleType: vehicleType ?? this.vehicleType,
        updatedAt: updatedAt ?? this.updatedAt,
      );
}

enum ServiceStatus {
  good,
  soon,
  overdue;

  String get label {
    switch (this) {
      case ServiceStatus.good:    return 'All Good';
      case ServiceStatus.soon:    return 'Service Soon';
      case ServiceStatus.overdue: return 'Overdue';
    }
  }
}
