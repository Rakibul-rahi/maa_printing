import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'l10n/l10n.dart';
class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({super.key});

  @override
  _VerifyEmailScreenState createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  final User? user = FirebaseAuth.instance.currentUser;
  bool isEmailVerified = false;

  Future<void> checkEmailVerification() async {
    await user?.reload();
    setState(() {
      isEmailVerified = user?.emailVerified ?? false;
    });

    if (isEmailVerified) {
      // Update Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .update({'emailVerified': true});

      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  Future<void> resendVerification() async {
    try {
      await user?.sendEmailVerification();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.verificationResent)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.errorWithMessage(e))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.verifyEmail)),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.email_outlined, size: 80, color: Colors.blue),
            const SizedBox(height: 20),
            Text(
              context.l10n.checkYourEmail,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Text(
              context.l10n.verifyEmailInfo,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              icon: const Icon(Icons.email),
              label: Text(context.l10n.resendVerification),
              onPressed: resendVerification,
            ),
            const SizedBox(height: 15),
            ElevatedButton(
              child: Text(context.l10n.iVerified),
              onPressed: checkEmailVerification,
            ),
            const SizedBox(height: 15),
            TextButton(
              child: Text(context.l10n.signOut),
              onPressed: () => FirebaseAuth.instance.signOut(),
            ),
          ],
        ),
      ),
    );
  }
}