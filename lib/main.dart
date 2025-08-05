import 'package:flutter/material.dart';
import 'package:formflow/constants/style.dart';
import 'package:formflow/screens/home_screen.dart';
import 'package:formflow/services/firebase_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await FirebaseService.initializeFirebase();

  // Sign in anonymously for demo
  try {
    final userCredential = await FirebaseService.signInAnonymously();
    print('✅ Signed in anonymously as: ${userCredential.user?.uid}');
  } catch (e) {
    print('❌ Error signing in anonymously: $e');
  }

  // Test Firebase Firestore connection
  try {
    print('🔍 Testing Firebase Firestore connection...');

    // Get the document from test collection
    final doc = await FirebaseFirestore.instance
        .collection('test')
        .doc('mJ28ttuI290')
        .get();

    if (doc.exists) {
      final data = doc.data();
      final name = data?['name'];
      print('✅ Firebase connection WORKING!');
      print('📄 Document ID: ${doc.id}');
      print('📝 Name field value: "$name"');
      print('📊 Full document data: $data');
    } else {
      print('❌ Document does not exist');
      print('🔍 Available documents in test collection:');

      // List all documents in the test collection
      final querySnapshot =
          await FirebaseFirestore.instance.collection('test').get();

      for (var doc in querySnapshot.docs) {
        print('   - Document ID: ${doc.id}');
        print('   - Data: ${doc.data()}');
      }
    }
  } catch (e) {
    print('❌ Firebase connection FAILED!');
    print('🚨 Error: $e');
  }

  runApp(const FormFlowApp());
}

class FormFlowApp extends StatelessWidget {
  const FormFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Form Flow',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: KStyle.cPrimaryColor,
          primary: KStyle.cPrimaryColor,
          background: KStyle.cBgColor,
        ),
        fontFamily: 'Plus Jakarta Sans',
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}
