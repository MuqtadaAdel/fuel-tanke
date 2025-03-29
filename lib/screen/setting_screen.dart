import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  void _logout(BuildContext context) {
    FirebaseAuth.instance.signOut();
    // إذا كنت تستخدم نظام التنقل بالروتات (Routes):
    // Navigator.pushReplacementNamed(context, '/login');
    // أو يمكنك الرجوع مباشرة:
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1C1C1C), // خلفية داكنة
      appBar: AppBar(
        backgroundColor: const Color(0xFF2C2C2C), // شريط علوي داكن
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          // عنصر "Language"
          ListTile(
            leading: const Icon(Icons.language, color: Colors.white),
            title: const Text(
              'Language',
              style: TextStyle(color: Colors.white),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Text(
                  'English',
                  style: TextStyle(color: Colors.white70),
                ),
                Icon(Icons.arrow_drop_down, color: Colors.white70),
              ],
            ),
          ),
          const Divider(color: Colors.grey),

          // عنصر "Account Info"
          ListTile(
            leading: const Icon(Icons.person, color: Colors.white),
            title: const Text(
              'Account Info',
              style: TextStyle(color: Colors.white),
            ),
            onTap: () {
              // هنا يمكن نقل المستخدم إلى صفحة معلومات الحساب (إن وُجِدَت)
            },
          ),
          const Divider(color: Colors.grey),

          // عنصر "Log Out"
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text(
              'Log Out',
              style: TextStyle(color: Colors.red),
            ),
            onTap: () => _logout(context),
          ),
        ],
      ),
    );
  }
}