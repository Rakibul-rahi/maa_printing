import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'l10n/l10n.dart';
import 'theme/app_theme.dart';

/// Lets someone without an account ask the owner/admin for access.
/// Saves the request to `accessRequests` and notifies owner + admin
/// through the existing `notifications` collection.
class RequestAccessScreen extends StatefulWidget {
  final String initialEmail;
  const RequestAccessScreen({super.key, this.initialEmail = ''});

  @override
  State<RequestAccessScreen> createState() => _RequestAccessScreenState();
}

class _RequestAccessScreenState extends State<RequestAccessScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  late final _emailController = TextEditingController(text: widget.initialEmail);
  final _phoneController = TextEditingController();
  final _reasonController = TextEditingController();
  String _requestedRole = 'editor';
  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() => _isSubmitting = true);

    final db = FirebaseFirestore.instance;
    final name = _nameController.text.trim();
    final email = _emailController.text.trim().toLowerCase();

    try {
      final batch = db.batch();
      batch.set(db.collection('accessRequests').doc(), {
        'name': name,
        'email': email,
        'phone': _phoneController.text.trim(),
        'requestedRole': _requestedRole,
        'reason': _reasonController.text.trim(),
        'status': 'pending',
        'timestamp': FieldValue.serverTimestamp(),
      });
      for (final role in ['owner', 'admin']) {
        batch.set(db.collection('notifications').doc(), {
          'to': role,
          'message': '🔑 Access request: $name ($email) wants $_requestedRole access',
          'timestamp': FieldValue.serverTimestamp(),
        });
      }
      await batch.commit();

      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          icon: const Icon(Icons.check_circle, color: Colors.green, size: 48),
          title: Text(context.l10n.requestSent),
          content: Text(context.l10n.requestSentInfo),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text(context.l10n.ok)),
          ],
        ),
      );
      if (mounted) Navigator.pop(context);
    } catch (e) {
      _showErrorSnackbar(context.l10n.requestFailed);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _showErrorSnackbar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red[700], behavior: SnackBarBehavior.floating),
    );
  }

  InputDecoration _decoration(String label, IconData icon, {String? hint}) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icon),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Theme.of(context).colorScheme.outline),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.indigo, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.requestAccess), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                context.l10n.requestAccessInfo,
                style: TextStyle(fontSize: 15, color: Theme.of(context).colorScheme.onSurfaceVariant),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _nameController,
                textCapitalization: TextCapitalization.words,
                decoration: _decoration(context.l10n.fullName, Icons.person_outline),
                validator: (v) => (v == null || v.trim().isEmpty) ? context.l10n.enterName : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: _decoration(context.l10n.emailAddress, Icons.email_outlined, hint: context.l10n.emailHint),
                validator: (v) {
                  final value = v?.trim() ?? '';
                  if (value.isEmpty) return context.l10n.enterEmail;
                  if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value)) {
                    return context.l10n.enterValidEmail;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: _decoration(context.l10n.phoneNumber, Icons.phone_outlined, hint: '01XXXXXXXXX'),
                validator: (v) {
                  final digits = (v ?? '').replaceAll(RegExp(r'\D'), '');
                  return digits.length < 10 ? context.l10n.enterValidPhone : null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _requestedRole,
                decoration: _decoration(context.l10n.requestedRole, Icons.badge_outlined),
                items: [
                  DropdownMenuItem(value: 'editor', child: Text(context.l10n.roleEditor)),
                  DropdownMenuItem(value: 'admin', child: Text(context.l10n.roleAdmin)),
                ],
                onChanged: (v) => setState(() => _requestedRole = v ?? 'editor'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _reasonController,
                maxLines: 3,
                textCapitalization: TextCapitalization.sentences,
                decoration: _decoration(context.l10n.reasonOptional, Icons.notes_outlined),
              ),
              const SizedBox(height: 28),
              SizedBox(
                height: 55,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: context.brandButtonColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 3,
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : Text(
                          context.l10n.sendRequest,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.1),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
