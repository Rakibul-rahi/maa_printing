import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'home.dart';
import 'login.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  print('🔥 Starting Firebase initialization...');

  FirebaseApp? firebaseApp;

  try {
    firebaseApp = await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('✅ Firebase initialized successfully: ${firebaseApp.name}');
  } catch (e) {
    print('⚠️ Primary Firebase initialization failed: $e');

    try {
      print('🔄 Attempting fallback Firebase initialization...');
      firebaseApp = await Firebase.initializeApp(
        name: 'FallbackApp',
        options: DefaultFirebaseOptions.currentPlatform,
      );
      print('🟢 Fallback Firebase initialization successful: ${firebaseApp.name}');
    } catch (fallbackError) {
      print('❌ CRITICAL ERROR: Firebase initialization failed completely');
      print('Error details: $fallbackError');
      runApp(const FirebaseErrorApp());
      return;
    }
  }

  print('🔍 Testing Firestore connection...');
  try {
    final firestore = FirebaseFirestore.instance;
    await firestore.collection('connection_test').limit(1).get();
    print('🟢 Firestore connection successful');
  } catch (firestoreError) {
    print('⚠️ Firestore connection test failed: $firestoreError');
    print('💡 This might affect database operations');
  }

  runApp(const MyApp());
}

class FirebaseErrorApp extends StatelessWidget {
  const FirebaseErrorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.red[50],
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(30.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 80, color: Colors.red),
                const SizedBox(height: 20),
                const Text(
                  'Firebase Initialization Failed',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                const Text(
                  'The app cannot connect to Firebase services. Please check:',
                  style: TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 15),
                _buildBulletPoint('Your internet connection'),
                _buildBulletPoint('Firebase configuration files'),
                _buildBulletPoint('Google Services setup'),
                const SizedBox(height: 30),
                ElevatedButton.icon(
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry Initialization'),
                  onPressed: () => main(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.circle, size: 8, color: Colors.red),
          const SizedBox(width: 10),
          Text(text, style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<String> _getUserRoleByUid(String uid) async {
    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      return doc.data()?['role'] ?? 'User';
    } catch (e) {
      print('⚠️ Error fetching user role: $e');
      return 'User';
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Maa Factory App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          ),
        ),
      ),
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          if (snapshot.hasData) {
            final user = snapshot.data!;
            return FutureBuilder<String>(
              future: _getUserRoleByUid(user.uid),
              builder: (context, roleSnapshot) {
                if (roleSnapshot.connectionState == ConnectionState.done) {

                  return HomePage(uid: user.uid);
                }
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              },
            );
          }

          return const LoginPage();
        },
      ),
    );
  }
}
