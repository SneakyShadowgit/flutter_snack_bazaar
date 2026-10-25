import 'package:flutter/material.dart';
import 'package:snack_bazaar/features/seller/services/seller_application_repository.dart';

class SellerApplicationScreen extends StatefulWidget {
  const SellerApplicationScreen({super.key});

  @override
  State<SellerApplicationScreen> createState() => _SellerApplicationScreenState();
}

class _SellerApplicationScreenState extends State<SellerApplicationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _businessName = TextEditingController();
  final _phone = TextEditingController();
  final _location = TextEditingController();
  final _category = TextEditingController();
  final _repository = SellerApplicationRepository();
  bool _saving = false;

  @override
  void dispose() {
    _businessName.dispose();
    _phone.dispose();
    _location.dispose();
    _category.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || _saving) return;
    setState(() => _saving = true);
    try {
      await _repository.submit(
        businessName: _businessName.text,
        phone: _phone.text,
        location: _location.text,
        category: _category.text,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Application submitted for review.')),
      );
      Navigator.pop(context);
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not submit application: $error')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Apply to sell')),
        body: SafeArea(
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                const Text(
                  'Tell us about your snack business. An admin will review your application.',
                ),
                const SizedBox(height: 20),
                _field(_businessName, 'Business name'),
                _field(_phone, 'Phone number', keyboardType: TextInputType.phone),
                _field(_location, 'City / service area'),
                _field(_category, 'Products you sell'),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: _saving ? null : _submit,
                  child: _saving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Submit application'),
                ),
              ],
            ),
          ),
        ),
      );

  Widget _field(
    TextEditingController controller,
    String label, {
    TextInputType? keyboardType,
  }) => Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            labelText: label,
            border: const OutlineInputBorder(),
          ),
          validator: (value) =>
              value == null || value.trim().isEmpty ? 'Required' : null,
        ),
      );
}
