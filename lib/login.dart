import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LoginPage extends StatelessWidget {
  LoginPage({super.key});

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _login(BuildContext context) async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("❌ Please enter both email and password"),
        ),
      );
      return;
    }

    try {
      final userCredential =
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;

      if (user == null) {
        await _handleInvalidUser(context);
        return;
      }

      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (!userDoc.exists) {
        await _handleInvalidUser(context);
        return;
      }

      final userData = userDoc.data();
      final role = userData?['role'] ?? '';

      final allowedRoles = {'admin', 'editor', 'owner'};

      if (allowedRoles.contains(role)) {
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        await _handleInvalidUser(context);
      }
    } on FirebaseAuthException catch (e) {
      debugPrint("Firebase Auth Error Code: ${e.code}");
      debugPrint("Firebase Auth Error Message: ${e.message}");

      String errorMessage;

      switch (e.code) {
        case 'invalid-email':
          errorMessage = "Invalid email format.";
          break;
        case 'user-disabled':
          errorMessage = "This account has been disabled.";
          break;
        case 'user-not-found':
          errorMessage = "No account found with this email.";
          break;
        case 'wrong-password':
          errorMessage = "Incorrect password.";
          break;
        case 'invalid-credential':
          errorMessage = "Email or password is incorrect.";
          break;
        case 'too-many-requests':
          errorMessage = "Too many failed attempts. Please try again later.";
          break;
        case 'network-request-failed':
          errorMessage = "Network error. Please check your internet connection.";
          break;
        default:
          errorMessage = e.message ?? "Login failed.";
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ $errorMessage")),
      );
    } catch (e) {
      debugPrint("Unexpected Login Error: $e");

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("❌ Unexpected error occurred"),
        ),
      );
    }
  }

  Future<void> _handleInvalidUser(BuildContext context) async {
    await FirebaseAuth.instance.signOut();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("❌ Access denied: Contact administrator"),
        duration: Duration(seconds: 5),
      ),
    );
  }

  Future<void> _resetPassword(BuildContext context) async {
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("❌ Please enter your email first"),
        ),
      );
      return;
    }

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("✅ Password reset email sent. Check your inbox."),
        ),
      );
    } on FirebaseAuthException catch (e) {
      debugPrint("Password Reset Error Code: ${e.code}");
      debugPrint("Password Reset Error Message: ${e.message}");

      String errorMessage;

      switch (e.code) {
        case 'invalid-email':
          errorMessage = "Invalid email format.";
          break;
        case 'user-not-found':
          errorMessage = "No account found with this email.";
          break;
        case 'network-request-failed':
          errorMessage = "Network error. Please check your internet connection.";
          break;
        default:
          errorMessage = e.message ?? "Failed to send password reset email.";
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ $errorMessage")),
      );
    } catch (e) {
      debugPrint("Unexpected Password Reset Error: $e");

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("❌ Unexpected error occurred"),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              _buildLogoSection(),
              const SizedBox(height: 40),
              _buildLoginForm(context),
            ],
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
          errorBuilder: (context, error, stackTrace) {
            return const Icon(
              Icons.factory,
              size: 100,
              color: Colors.blue,
            );
          },
        ),
        const SizedBox(height: 20),
        const Text(
          "FACTORY MANAGEMENT",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          "Secure Login Portal",
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildLoginForm(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Email Address",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _emailController,
          decoration: InputDecoration(
            hintText: "your@email.com",
            prefixIcon: const Icon(Icons.email_outlined),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            contentPadding: const EdgeInsets.symmetric(
              vertical: 15,
              horizontal: 15,
            ),
          ),
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 20),
        const Text(
          "Password",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _passwordController,
          decoration: InputDecoration(
            hintText: "Enter your password",
            prefixIcon: const Icon(Icons.lock_outline),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            contentPadding: const EdgeInsets.symmetric(
              vertical: 15,
              horizontal: 15,
            ),
          ),
          obscureText: true,
        ),
        const SizedBox(height: 10),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () => _resetPassword(context),
            child: const Text("Forgot Password?"),
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          height: 55,
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => _login(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[800],
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 3,
            ),
            child: const Text(
              "SIGN IN",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }
}