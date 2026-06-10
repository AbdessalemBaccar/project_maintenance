import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../app_theme.dart';
import '../models/maintenance_entry.dart';
import '../providers/app_providers.dart';
import '../router.dart';

class AddEntryScreen extends ConsumerStatefulWidget {
  const AddEntryScreen({super.key});

  @override
  ConsumerState<AddEntryScreen> createState() => _AddEntryScreenState();
}

class _AddEntryScreenState extends ConsumerState<AddEntryScreen> {
  final _formKey      = GlobalKey<FormState>();
  final _mileageCtrl  = TextEditingController();
  final _costCtrl     = TextEditingController();
  final _notesCtrl    = TextEditingController();
  final _dateFmt      = DateFormat('MMMM d, yyyy');

  @override
  void dispose() {
    _mileageCtrl.dispose();
    _costCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate(BuildContext context) async {
    final state = ref.read(addEntryProvider);
    final picked = await showDatePicker(
      context: context,
      initialDate: state.date,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: Theme.of(ctx).colorScheme.copyWith(
                primary: AppTheme.neonTeal,
                onPrimary: Colors.black,
                surface: AppTheme.cardSurface,
                onSurface: Colors.white,
              ),
          dialogBackgroundColor: AppTheme.primaryDark,
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      ref.read(addEntryProvider.notifier).setDate(picked);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    final success = await ref.read(addEntryProvider.notifier).submit(
          mileageText: _mileageCtrl.text,
          costText: _costCtrl.text,
          notes: _notesCtrl.text,
        );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(children: [
            Icon(Icons.check_circle, color: AppTheme.neonTeal, size: 18),
            SizedBox(width: 8),
            Text('Service entry saved!'),
          ]),
        ),
      );
      context.go(AppRoutes.dashboard);
    }
  }

  @override
  Widget build(BuildContext context) {
    final entryState = ref.watch(addEntryProvider);
    final isLoading  = entryState.isLoading;
    final vehicle    = ref.watch(selectedVehicleProvider);

    return Scaffold(
      backgroundColor: AppTheme.primaryDark,
      appBar: AppBar(
        title: Text(vehicle != null
            ? 'Log — ${vehicle.vehicleType.emoji} ${vehicle.make}'
            : 'Log Service'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.go(AppRoutes.dashboard),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: TextButton(
              onPressed: isLoading ? null : _submit,
              child: isLoading
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
              _SectionHeader(title: 'Service Details', icon: Icons.build_outlined),
              const SizedBox(height: 12),

              DropdownButtonFormField<ServiceType>(
                value: entryState.serviceType,
                decoration: const InputDecoration(
                  labelText: 'Service Type',
                  prefixIcon: Icon(Icons.category_outlined),
                ),
                dropdownColor: AppTheme.cardSurface,
                style: const TextStyle(color: Colors.white),
                items: ServiceType.values
                    .map((type) => DropdownMenuItem(
                          value: type,
                          child: Text('${type.emoji}  ${type.label}'),
                        ))
                    .toList(),
                onChanged: (v) =>
                    ref.read(addEntryProvider.notifier).setServiceType(v),
                validator: (v) =>
                    v == null ? 'Please select a service type' : null,
              ),
              const SizedBox(height: 14),

              // Date
              GestureDetector(
                onTap: () => _pickDate(context),
                child: AbsorbPointer(
                  child: TextFormField(
                    readOnly: true,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Service Date',
                      prefixIcon: const Icon(Icons.calendar_today_outlined),
                      suffixIcon: const Icon(Icons.arrow_drop_down),
                      hintText: _dateFmt.format(entryState.date),
                    ),
                    controller: TextEditingController(
                        text: _dateFmt.format(entryState.date)),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              _SectionHeader(title: 'Mileage & Cost', icon: Icons.speed),
              const SizedBox(height: 12),

              Row(children: [
                Expanded(
                  child: TextFormField(
                    controller: _mileageCtrl,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      _ThousandsFormatter(),
                    ],
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: 'Mileage (km)',
                      prefixIcon: Icon(Icons.speed),
                      hintText: '0',
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Required';
                      if (int.tryParse(v.replaceAll(',', '')) == null) return 'Invalid';
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: TextFormField(
                    controller: _costCtrl,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,3}')),
                    ],
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: 'Total Cost (DT)',
                      prefixIcon: Icon(Icons.payments_outlined),
                      hintText: '0.000',
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Required';
                      if (double.tryParse(v) == null) return 'Invalid';
                      return null;
                    },
                  ),
                ),
              ]),
              const SizedBox(height: 24),

              _SectionHeader(title: 'Notes', icon: Icons.notes_outlined),
              const SizedBox(height: 12),

              TextFormField(
                controller: _notesCtrl,
                maxLines: 4,
                maxLength: 500,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Additional notes (optional)',
                  prefixIcon: Padding(
                    padding: EdgeInsets.only(bottom: 60),
                    child: Icon(Icons.notes_outlined),
                  ),
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 12),

              if (entryState.errorMessage != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.error.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                    border:
                        Border.all(color: AppTheme.error.withOpacity(0.4)),
                  ),
                  child: Row(children: [
                    const Icon(Icons.error_outline,
                        color: AppTheme.error, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(entryState.errorMessage!,
                          style: const TextStyle(
                              color: AppTheme.error, fontSize: 13)),
                    ),
                  ]),
                ),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: isLoading ? null : _submit,
                  icon: isLoading
                      ? const SizedBox(
                          width: 18, height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                                AppTheme.primaryDark),
                          ))
                      : const Icon(Icons.save_outlined, size: 20),
                  label: Text(isLoading ? 'Saving…' : 'Save Entry'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.icon});
  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Icon(icon, size: 16, color: AppTheme.neonTeal),
      const SizedBox(width: 8),
      Text(title,
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
