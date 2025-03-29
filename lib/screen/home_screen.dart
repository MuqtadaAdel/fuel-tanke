import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'alert_screen.dart';
import 'setting_screen.dart';
import 'drivers_screen.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  void logout() {
    FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // نجعل خلفية الصفحة شفافة لأننا سنضع الخلفية داخل الـ body
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text(
          'Management',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ), // أو أي نص تريده
        actions: [
          IconButton(
            onPressed: logout,
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
          )
        ],
        backgroundColor: const Color(0xFF2C2C2C), // لون داكن في الـ AppBar
      ),
      body: Container(
        // خلفية متدرّجة (Gradient) تغطي الشاشة
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF2C2C2C), // رمادي غامق
              Color(0xFF444444), // رمادي أفتح قليلًا
            ],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              // تمركز العناصر في الوسط
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // عنوان كبير في منتصف الصفحة
                const Text(
                  'Search & Management', // أو 'Home - Fuel Tanker'
                  style: TextStyle(
                    fontSize: 24,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 32),

                // زر Drivers
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton.icon(
                    onPressed: () {
                    Navigator.push(
                       context,
                        MaterialPageRoute(
                            builder: (_) => const DriversListPage()),
                      );
                    },
                    icon: const Icon(Icons.people, color: Colors.white),
                    label: const Text(
                      'Drivers Management',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue, // اللون الأزرق
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // زر Alerts
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const AlertsPage()),
                      );
                    },
                    icon: const Icon(Icons.warning, color: Colors.white),
                    label: const Text(
                      'View Alerts',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red, // اللون الأحمر
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // زر Settings
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const SettingsPage()),
                      );
                    },
                    icon: const Icon(Icons.settings, color: Colors.white),
                    label: const Text(
                      'Settings',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey, // اللون الرمادي
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
