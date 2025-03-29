//import 'package:flutter/foundation.dart';
import 'package:finalproject/screen/realtimeAndfirestone.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; // سينشأ تلقائيا إذا استخدمت الأمر flutterfire configure
import 'root_app.dart'; // سننشئ هذا الملف لاحقًا

//import 'package:firebase_messaging/firebase_messaging.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform, // أو تهيئة يدوية
  );
  // بدء خدمة نقل البيانات
  DataBridgeService().startMonitoring();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Fuel Tanker App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const AppRoot(),
      // يبدأ بالتأكد هل المستخدم مسجل دخول أم لا
    );
  }
}
