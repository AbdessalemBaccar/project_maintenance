import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../models/maintenance_entry.dart';
import '../models/car_profile.dart';

// ── Services ───────────────────────────────────────────────────────────────────
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(FirebaseAuth.instance);
});

final firestoreServiceProvider = Provider<FirestoreService>((ref) {
  return FirestoreService(FirebaseFirestore.instance);
});

// ── Auth ───────────────────────────────────────────────────────────────────────
final authStateProvider = StreamProvider<User?>((ref) {
  return ref.read(authServiceProvider).authStateChanges;
});

final currentUserProvider = Provider<User?>((ref) {
  return ref.watch(authStateProvider).asData?.value;
});

// ── Vehicles ───────────────────────────────────────────────────────────────────
final vehiclesProvider = StreamProvider<List<CarProfile>>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return const Stream.empty();
  return ref.read(firestoreServiceProvider).vehiclesStream(user.uid);
});

// ── Selected Vehicle ───────────────────────────────────────────────────────────
final selectedVehicleIdProvider = StateProvider<String?>((ref) => null);

final selectedVehicleProvider = Provider<CarProfile?>((ref) {
  final vehicles = ref.watch(vehiclesProvider).asData?.value ?? [];
  final selectedId = ref.watch(selectedVehicleIdProvider);
  if (vehicles.isEmpty) return null;
  if (selectedId == null) return vehicles.first;
  return vehicles.where((v) => v.id == selectedId).firstOrNull ?? vehicles.first;
});

// ── Maintenance Entries ────────────────────────────────────────────────────────
final maintenanceEntriesProvider = StreamProvider<List<MaintenanceEntry>>((ref) {
  final user = ref.watch(currentUserProvider);
  final vehicle = ref.watch(selectedVehicleProvider);
  if (user == null || vehicle == null) return const Stream.empty();
  return ref.read(firestoreServiceProvider).entriesStream(user.uid, vehicle.id);
});

// ── Auth Form ──────────────────────────────────────────────────────────────────
class AuthFormNotifier extends StateNotifier<AuthFormState> {
  AuthFormNotifier(this._authService) : super(const AuthFormState());
  final AuthService _authService;

  void toggleMode() =>
      state = state.copyWith(isLogin: !state.isLogin, errorMessage: null);
  void clearError() => state = state.copyWith(errorMessage: null);

  Future<bool> submit({required String email, required String password}) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    final result = state.isLogin
        ? await _authService.signInWithEmail(email: email, password: password)
        : await _authService.signUpWithEmail(email: email, password: password);
    if (result.isFailure) {
      state = state.copyWith(isLoading: false, errorMessage: result.errorMessage);
      return false;
    }
    state = state.copyWith(isLoading: false);
    return true;
  }

  Future<void> signOut() async => await _authService.signOut();
}

final authFormProvider =
    StateNotifierProvider<AuthFormNotifier, AuthFormState>((ref) {
  return AuthFormNotifier(ref.read(authServiceProvider));
});

class AuthFormState {
  const AuthFormState({
    this.isLogin = true,
    this.isLoading = false,
    this.errorMessage,
  });
  final bool isLogin;
  final bool isLoading;
  final String? errorMessage;

  AuthFormState copyWith({bool? isLogin, bool? isLoading, String? errorMessage}) =>
      AuthFormState(
        isLogin: isLogin ?? this.isLogin,
        isLoading: isLoading ?? this.isLoading,
        errorMessage: errorMessage,
      );
}

// ── Add Entry Form ─────────────────────────────────────────────────────────────
class AddEntryNotifier extends StateNotifier<AddEntryState> {
  AddEntryNotifier(this._firestoreService, this._userId, this._vehicleId)
      : super(AddEntryState(date: DateTime.now()));

  final FirestoreService _firestoreService;
  final String _userId;
  final String _vehicleId;

  void setServiceType(ServiceType? type) =>
      state = state.copyWith(serviceType: type, errorMessage: null);
  void setDate(DateTime date) =>
      state = state.copyWith(date: date, errorMessage: null);
  void clearError() => state = state.copyWith(errorMessage: null);

  Future<bool> submit({
    required String mileageText,
    required String costText,
    required String notes,
  }) async {
    if (state.serviceType == null) {
      state = state.copyWith(errorMessage: 'Please select a service type.');
      return false;
    }
    final mileage = int.tryParse(mileageText.replaceAll(',', ''));
    if (mileage == null || mileage < 0) {
      state = state.copyWith(errorMessage: 'Please enter a valid mileage.');
      return false;
    }
    final cost = double.tryParse(costText.replaceAll(',', ''));
    if (cost == null || cost < 0) {
      state = state.copyWith(errorMessage: 'Please enter a valid cost.');
      return false;
    }

    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final entry = MaintenanceEntry(
        id: '',
        userId: _userId,
        serviceType: state.serviceType!,
        date: state.date,
        mileage: mileage,
        cost: cost,
        notes: notes.trim(),
        createdAt: DateTime.now(),
      );
      await _firestoreService.addEntry(_userId, _vehicleId, entry);
      state = AddEntryState(date: DateTime.now());
      return true;
    } catch (e) {
      state = state.copyWith(
          isLoading: false,
          errorMessage: 'Failed to save entry. Please try again.');
      return false;
    }
  }
}

final addEntryProvider =
    StateNotifierProvider.autoDispose<AddEntryNotifier, AddEntryState>((ref) {
  final user = ref.read(currentUserProvider);
  final vehicle = ref.read(selectedVehicleProvider);
  return AddEntryNotifier(
    ref.read(firestoreServiceProvider),
    user?.uid ?? '',
    vehicle?.id ?? '',
  );
});

class AddEntryState {
  AddEntryState({
    this.serviceType,
    required this.date,
    this.isLoading = false,
    this.errorMessage,
  });

  final ServiceType? serviceType;
  final DateTime date;
  final bool isLoading;
  final String? errorMessage;

  AddEntryState copyWith({
    ServiceType? serviceType,
    DateTime? date,
    bool? isLoading,
    String? errorMessage,
  }) =>
      AddEntryState(
        serviceType: serviceType ?? this.serviceType,
        date: date ?? this.date,
        isLoading: isLoading ?? this.isLoading,
        errorMessage: errorMessage,
      );
}
