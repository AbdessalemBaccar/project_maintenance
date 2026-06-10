import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/maintenance_entry.dart';
import '../models/car_profile.dart';

class FirestoreService {
  FirestoreService(this._db);
  final FirebaseFirestore _db;

  // ── Refs ───────────────────────────────────────────────────────────────────
  CollectionReference<Map<String, dynamic>> _vehiclesRef(String userId) =>
      _db.collection('users').doc(userId).collection('vehicles');

  CollectionReference<Map<String, dynamic>> _entriesRef(
          String userId, String vehicleId) =>
      _vehiclesRef(userId).doc(vehicleId).collection('maintenance_entries');

  // ── Vehicles ───────────────────────────────────────────────────────────────
  Stream<List<CarProfile>> vehiclesStream(String userId) {
    return _vehiclesRef(userId)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map((d) => CarProfile.fromFirestore(d)).toList())
        .handleError((e) {
      debugPrint('vehiclesStream: $e');
      return <CarProfile>[];
    });
  }

  Future<CarProfile> addVehicle(CarProfile vehicle) async {
    try {
      final ref = await _vehiclesRef(vehicle.userId).add(vehicle.toFirestore());
      return vehicle.copyWith(id: ref.id);
    } on FirebaseException catch (e) {
      debugPrint('addVehicle: ${e.code}');
      rethrow;
    }
  }

  Future<void> updateVehicle(CarProfile vehicle) async {
    try {
      await _vehiclesRef(vehicle.userId)
          .doc(vehicle.id)
          .update(vehicle.toFirestore());
    } on FirebaseException catch (e) {
      debugPrint('updateVehicle: ${e.code}');
      rethrow;
    }
  }

  Future<void> deleteVehicle(String userId, String vehicleId) async {
    try {
      final entries = await _entriesRef(userId, vehicleId).get();
      final batch = _db.batch();
      for (final doc in entries.docs) {
        batch.delete(doc.reference);
      }
      batch.delete(_vehiclesRef(userId).doc(vehicleId));
      await batch.commit();
    } on FirebaseException catch (e) {
      debugPrint('deleteVehicle: ${e.code}');
      rethrow;
    }
  }

  // ── Maintenance Entries ────────────────────────────────────────────────────
  Stream<List<MaintenanceEntry>> entriesStream(
      String userId, String vehicleId) {
    return _entriesRef(userId, vehicleId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((s) => s.docs.map((d) => MaintenanceEntry.fromFirestore(d)).toList())
        .handleError((e) {
      debugPrint('entriesStream: $e');
      return <MaintenanceEntry>[];
    });
  }

  Future<void> addEntry(
      String userId, String vehicleId, MaintenanceEntry entry) async {
    try {
      await _entriesRef(userId, vehicleId).add(entry.toFirestore());
    } on FirebaseException catch (e) {
      debugPrint('addEntry: ${e.code}');
      rethrow;
    }
  }

  Future<void> deleteEntry(
      String userId, String vehicleId, String entryId) async {
    try {
      await _entriesRef(userId, vehicleId).doc(entryId).delete();
    } on FirebaseException catch (e) {
      debugPrint('deleteEntry: ${e.code}');
      rethrow;
    }
  }
}
