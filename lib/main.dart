import 'package:flutter/material.dart';
import 'package:formflow/constants/style.dart';
import 'package:formflow/screens/my_forms_screen.dart';
import 'package:formflow/services/firebase_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyBlPlYZKa2jtYb2uNEKHNexpk07IFSRJuo",
      authDomain: "formflow-b0484.firebaseapp.com",
      projectId: "formflow-b0484",
      storageBucket: "formflow-b0484.firebasestorage.app",
      messagingSenderId: "951373712327",
      appId: "1:951373712327:web:45c7f78e3ed2b783f9a7e2",
      measurementId: "G-BG0G0MHPGG",
    ),
  );

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
      home: const MyFormsScreen(),
    );
  }
}
