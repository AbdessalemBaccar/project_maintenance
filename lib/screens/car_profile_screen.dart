import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../app_theme.dart';
import '../models/car_profile.dart';
import '../providers/app_providers.dart';
import '../router.dart';

class CarProfileScreen extends ConsumerStatefulWidget {
  final bool isEditing;
  const CarProfileScreen({super.key, this.isEditing = false});

  @override
  ConsumerState<CarProfileScreen> createState() => _CarProfileScreenState();
}

class _CarProfileScreenState extends ConsumerState<CarProfileScreen> {
  final _formKey         = GlobalKey<FormState>();
  final _makeCtrl        = TextEditingController();
  final _modelCtrl       = TextEditingController();
  final _yearCtrl        = TextEditingController();
  final _plateCtrl       = TextEditingController();
  final _mileageCtrl     = TextEditingController();
  final _nextServiceCtrl = TextEditingController();
  final _vinCtrl         = TextEditingController();
  VehicleType _vehicleType = VehicleType.car;
  bool _isLoading  = false;
  bool _initialized = false;

  @override
  void dispose() {
    _makeCtrl.dispose();
    _modelCtrl.dispose();
    _yearCtrl.dispose();
    _plateCtrl.dispose();
    _mileageCtrl.dispose();
    _nextServiceCtrl.dispose();
    _vinCtrl.dispose();
    super.dispose();
  }

  void _initFromVehicle(CarProfile v) {
    if (_initialized) return;
    _initialized = true;
    _makeCtrl.text        = v.make;
    _modelCtrl.text       = v.model;
    _yearCtrl.text        = v.year.toString();
    _plateCtrl.text       = v.licensePlate;
    _mileageCtrl.text     = v.currentMileage > 0
        ? NumberFormat('#,###').format(v.currentMileage) : '';
    _nextServiceCtrl.text = v.nextServiceMileage > 0
        ? NumberFormat('#,###').format(v.nextServiceMileage) : '';
    _vinCtrl.text         = v.vin;
    _vehicleType          = v.vehicleType;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() => _isLoading = true);

    try {
      final user           = ref.read(currentUserProvider)!;
      final selectedVehicle = ref.read(selectedVehicleProvider);
      final mileage        = int.parse(_mileageCtrl.text.replaceAll(',', ''));
      final nextService    = int.parse(_nextServiceCtrl.text.replaceAll(',', ''));

      final vehicle = CarProfile(
        id: widget.isEditing ? (selectedVehicle?.id ?? '') : '',
        userId: user.uid,
        make: _makeCtrl.text.trim(),
        model: _modelCtrl.text.trim(),
        year: int.parse(_yearCtrl.text.trim()),
        licensePlate: _plateCtrl.text.trim(),
        currentMileage: mileage,
        nextServiceMileage: nextService,
        vin: _vinCtrl.text.trim(),
        vehicleType: _vehicleType,
        updatedAt: DateTime.now(),
      );

      if (widget.isEditing) {
        await ref.read(firestoreServiceProvider).updateVehicle(vehicle);
      } else {
        final saved = await ref.read(firestoreServiceProvider).addVehicle(vehicle);
        ref.read(selectedVehicleIdProvider.notifier).state = saved.id;
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Row(children: [
            const Icon(Icons.check_circle, color: AppTheme.neonTeal, size: 18),
            const SizedBox(width: 8),
            Text(widget.isEditing ? 'Vehicle updated!' : 'Vehicle added!'),
          ]),
        ));
        context.go(AppRoutes.vehicles);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Failed to save. Please try again.'),
          backgroundColor: AppTheme.error,
        ));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isEditing) {
      final v = ref.read(selectedVehicleProvider);
      if (v != null) _initFromVehicle(v);
    }

    return Scaffold(
      backgroundColor: AppTheme.primaryDark,
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Edit Vehicle' : 'Add Vehicle'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.go(AppRoutes.vehicles),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: TextButton(
              onPressed: _isLoading ? null : _save,
              child: _isLoading
                  ? const SizedBox(
                      width: 18, height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Save'),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
        physics: const BouncingScrollPhysics(),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Vehicle Type Selector ──────────────────────────────────
              _SectionLabel(label: 'Vehicle Type', icon: Icons.category_outlined),
              const SizedBox(height: 12),

              Row(
                children: VehicleType.values.map((type) {
                  final isSelected = _vehicleType == type;
                  final isLast = type == VehicleType.values.last;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _vehicleType = type),
                      child: Container(
                        margin: EdgeInsets.only(right: isLast ? 0 : 10),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppTheme.neonTeal.withOpacity(0.15)
                              : const Color(0xFF1E2D4A),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? AppTheme.neonTeal
                                : const Color(0xFF3A4A5C),
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Column(children: [
                          Text(type.emoji,
                              style: const TextStyle(fontSize: 24)),
                          const SizedBox(height: 4),
                          Text(
                            type.label.split('/').first,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: isSelected
                                  ? AppTheme.neonTeal
                                  : const Color(0xFF7B8FA6),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ]),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),

              // ── Vehicle Info ───────────────────────────────────────────
              _SectionLabel(
                  label: 'Vehicle Information',
                  icon: Icons.directions_car_outlined),
              const SizedBox(height: 12),

              Row(children: [
                Expanded(
                  child: TextFormField(
                    controller: _makeCtrl,
                    textCapitalization: TextCapitalization.words,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                        labelText: 'Make', hintText: 'Toyota'),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Required' : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _modelCtrl,
                    textCapitalization: TextCapitalization.words,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                        labelText: 'Model', hintText: 'Camry'),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Required' : null,
                  ),
                ),
              ]),
              const SizedBox(height: 14),

              Row(children: [
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    controller: _yearCtrl,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(4),
                    ],
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                        labelText: 'Year', hintText: '2020'),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Required';
                      final y = int.tryParse(v);
                      if (y == null || y < 1900 || y > DateTime.now().year + 1) {
                        return 'Invalid';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 3,
                  child: TextFormField(
                    controller: _plateCtrl,
                    textCapitalization: TextCapitalization.characters,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                        labelText: 'License Plate', hintText: 'Optional'),
                  ),
                ),
              ]),
              const SizedBox(height: 14),

              TextFormField(
                controller: _vinCtrl,
                textCapitalization: TextCapitalization.characters,
                style: const TextStyle(color: Colors.white),
                maxLength: 17,
                decoration: const InputDecoration(
                  labelText: 'VIN (optional)',
                  prefixIcon: Icon(Icons.tag_outlined),
                ),
              ),
              const SizedBox(height: 20),

              // ── Mileage ────────────────────────────────────────────────
              _SectionLabel(label: 'Mileage Tracking', icon: Icons.speed),
              const SizedBox(height: 12),

              TextFormField(
                controller: _mileageCtrl,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  _ThousandsFormatter(),
                ],
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Current Mileage (km)',
                  prefixIcon: Icon(Icons.speed),
                  hintText: '50,000',
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Required';
                  if (int.tryParse(v.replaceAll(',', '')) == null) return 'Invalid';
                  return null;
                },
              ),
              const SizedBox(height: 14),

              TextFormField(
                controller: _nextServiceCtrl,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  _ThousandsFormatter(),
                ],
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Next Service at (km)',
                  prefixIcon: Icon(Icons.build_outlined),
                  hintText: '55,000',
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Required';
                  if (int.tryParse(v.replaceAll(',', '')) == null) return 'Invalid';
                  return null;
                },
              ),
              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _save,
                  icon: const Icon(Icons.save_outlined, size: 20),
                  label: Text(_isLoading
                      ? 'Saving…'
                      : widget.isEditing
                          ? 'Update Vehicle'
                          : 'Add Vehicle'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label, required this.icon});
  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Icon(icon, size: 16, color: AppTheme.neonTeal),
      const SizedBox(width: 8),
      Text(label.toUpperCase(),
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: AppTheme.neonTeal, letterSpacing: 0.8)),
      const SizedBox(width: 12),
      const Expanded(child: Divider()),
    ]);
  }
}

class _ThousandsFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) return newValue;
    final digits = newValue.text.replaceAll(',', '');
    final number = int.tryParse(digits);
    if (number == null) return oldValue;
    final formatted = NumberFormat('#,###').format(number);
    return newValue.copyWith(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
