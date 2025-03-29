import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

// استبدل هذا بمسار الصورة الصحيح إن كنت تستخدم أصول (assets) أو رابط شبكة (NetworkImage)
const String tankerImagePath = 'assets/images/fuel_tanker.png';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passController = TextEditingController();

  bool isLoading = false;
  String errorMessage = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // لإخفاء شريط AppBar الأفقي إن أردت شكلاً مندمجًا تمامًا
      backgroundColor: Colors.transparent,
      body: Container(
        // خلفية متدرّجة
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF606060), // لون رمادي غامق (يمكن تغييره)
              Color(0xFF8c8c8c), // لون رمادي أفتح (يمكن تغييره)
            ],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // الصورة الدائرية العلوية
                CircleAvatar(
                  radius: 60,
                   backgroundImage: AssetImage("images/loginphoto.jpg"),
                  // لو عندك رابط شبكة:
                  // backgroundImage: NetworkImage('https://...'),
                ),
                const SizedBox(height: 20),

                // عنوان مرحب
                const Text(
                  'Welcome Back',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 40),

                // حقل اسم المستخدم (في الكود الداخلي Email)
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha((0.2 * 255).toInt()),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: TextField(
                    controller: emailController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Email',
                      labelStyle: const TextStyle(color: Colors.white70),
                      prefixIcon:
                          const Icon(Icons.person, color: Colors.white70),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.all(16),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // حقل كلمة المرور
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha((0.2 * 255).toInt()),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: TextField(
                    controller: passController,
                    obscureText: true,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Password',
                      labelStyle: const TextStyle(color: Colors.white70),
                      prefixIcon: const Icon(Icons.lock, color: Colors.white70),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.all(16),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // إن كان هناك رسالة خطأ
                if (errorMessage.isNotEmpty) ...[
                  Text(
                    errorMessage,
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 10),
                ],

                // زر تسجيل الدخول أو دائرة الانتظار
                isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color(0xFF2A5058), // لون زر (يمكن تغييره)
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: () => login(),
                          child: const Text(
                            'Login',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.white,
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

  Future<void> login() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passController.text.trim(),
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        errorMessage = e.message ?? 'Login error';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }
}
