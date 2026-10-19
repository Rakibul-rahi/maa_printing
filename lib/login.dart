import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'home.dart'; // Make sure to import your HomePage
import 'request_access_screen.dart';
import 'l10n/l10n.dart';
import 'settings/settings_sheet.dart';
import 'theme/app_theme.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      final uid = userCredential.user!.uid;

      // Fetch user role from Firestore
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();

      if (!userDoc.exists) {
        await _handleInvalidUser(context);
        return;
      }

      final role = userDoc.data()?['role']?.toString().toLowerCase() ?? '';
      final allowedRoles = {'admin', 'editor', 'owner'};

      if (!allowedRoles.contains(role)) {
        await _handleInvalidUser(context);
        return;
      }

      // Navigate to HomePage passing uid
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomePage(uid: uid),
        ),
      );
    } on FirebaseAuthException catch (e) {
      _showErrorSnackbar(context, context.l10n.loginFailed(_getFriendlyErrorMessage(e.code)));
    } catch (e) {
      _showErrorSnackbar(context, context.l10n.unexpectedError);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _getFriendlyErrorMessage(String code) {
    final l10n = context.l10n;
    switch (code) {
      case 'user-not-found':
        return l10n.errUserNotFound;
      case 'wrong-password':
        return l10n.errWrongPassword;
      case 'invalid-email':
        return l10n.errInvalidEmail;
      case 'user-disabled':
        return l10n.errUserDisabled;
      default:
        return l10n.errAuthFailed;
    }
  }

  Future<void> _handleInvalidUser(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    _showErrorSnackbar(
      context,
      context.l10n.accessDenied,
      duration: const Duration(seconds: 5),
    );
  }

  Future<void> _showForgotPasswordDialog() async {
    final sentTo = await showDialog<String>(
      context: context,
      builder: (context) => _ForgotPasswordDialog(initialEmail: _emailController.text.trim()),
    );
    if (sentTo == null || !mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(context.l10n.resetEmailSent(sentTo)),
        backgroundColor: Colors.green[700],
        duration: const Duration(seconds: 5),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showErrorSnackbar(BuildContext context, String message, {Duration duration = const Duration(seconds: 3)}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red[700],
        duration: duration,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        actions: const [SettingsButton()],
      ),
      extendBodyBehindAppBar: true,
      body: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height,
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                _buildLogoSection(),
                const SizedBox(height: 40),
                _buildLoginForm(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogoSection() {
    return Column(
      children: [
        Image.asset(
          'assets/maa.png',
          height: 120,
          width: 120,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) => const Icon(
            Icons.factory,
            size: 100,
            color: Colors.blue,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          context.l10n.appNameCaps,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
            color: context.brandTextColor,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          context.l10n.managementSystem,
          style: TextStyle(
            fontSize: 16,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildLoginForm(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.emailAddress,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _emailController,
            decoration: InputDecoration(
              hintText: context.l10n.emailHint,
              prefixIcon: const Icon(Icons.email_outlined),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.grey),
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Theme.of(context).colorScheme.outline),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.indigo, width: 1.5),
              ),
            ),
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return context.l10n.enterEmail;
              }
              if (!value.contains('@')) {
                return context.l10n.enterValidEmail;
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          Text(
            context.l10n.password,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            decoration: InputDecoration(
              hintText: context.l10n.enterPasswordHint,
              prefixIcon: const Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                  color: Colors.grey,
                ),
                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.grey),
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Theme.of(context).colorScheme.outline),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.indigo, width: 1.5),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return context.l10n.enterPassword;
              }
              if (value.length < 6) {
                return context.l10n.passwordMinLength;
              }
              return null;
            },
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: _isLoading ? null : _showForgotPasswordDialog,
              child: Text(
                context.l10n.forgotPassword,
                style: TextStyle(color: context.brandTextColor),
              ),
            ),
          ),
          const SizedBox(height: 25),
          SizedBox(
            height: 55,
            child: ElevatedButton(
              onPressed: _isLoading ? null : () => _login(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: context.brandButtonColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 3,
              ),
              child: _isLoading
                  ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
                  : Text(
                context.l10n.signIn,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.1,
                ),
              ),
            ),
          ),
          const SizedBox(height: 25),
          Center(
            child: TextButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => RequestAccessScreen(initialEmail: _emailController.text.trim()),
                ),
              ),
              child: RichText(
                text: TextSpan(
                  text: context.l10n.noAccount,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: 14,
                  ),
                  children: [
                    TextSpan(
                      text: context.l10n.requestAccess,
                      style: TextStyle(
                        color: context.brandTextColor,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ForgotPasswordDialog extends StatefulWidget {
  final String initialEmail;
  const _ForgotPasswordDialog({required this.initialEmail});

  @override
  State<_ForgotPasswordDialog> createState() => _ForgotPasswordDialogState();
}

class _ForgotPasswordDialogState extends State<_ForgotPasswordDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _emailController = TextEditingController(text: widget.initialEmail);
  bool _sending = false;
  String? _error;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _sendResetEmail() async {
    if (!_formKey.currentState!.validate()) return;
    final email = _emailController.text.trim();

    setState(() {
      _sending = true;
      _error = null;
    });
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      if (mounted) Navigator.pop(context, email);
    } on FirebaseAuthException catch (e) {
      setState(() {
        final l10n = context.l10n;
        _error = switch (e.code) {
          'invalid-email' => l10n.errInvalidEmail,
          'user-not-found' => l10n.errUserNotFound,
          'too-many-requests' => l10n.errTooManyRequests,
          'network-request-failed' => l10n.errNoInternet,
          _ => l10n.errResetFailed(e.code),
        };
      });
    } catch (_) {
      setState(() => _error = context.l10n.unexpectedError);
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(context.l10n.resetPassword),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(context.l10n.resetPasswordInfo),
            const SizedBox(height: 16),
            TextFormField(
              controller: _emailController,
              autofocus: widget.initialEmail.isEmpty,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: context.l10n.emailAddress,
                prefixIcon: const Icon(Icons.email_outlined),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              validator: (value) {
                final v = value?.trim() ?? '';
                if (v.isEmpty) return context.l10n.enterEmail;
                if (!v.contains('@')) return context.l10n.enterValidEmail;
                return null;
              },
              onFieldSubmitted: (_) => _sendResetEmail(),
            ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(_error!, style: TextStyle(color: context.dangerColor)),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _sending ? null : () => Navigator.pop(context),
          child: Text(context.l10n.cancel),
        ),
        ElevatedButton(
          onPressed: _sending ? null : _sendResetEmail,
          style: ElevatedButton.styleFrom(
            backgroundColor: context.brandButtonColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
          ),
          child: _sending
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : Text(context.l10n.sendLink),
        ),
      ],
    );
  }
}
