import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:medicines_reminder/Screens/login_screen.dart';
import 'package:medicines_reminder/Services/signup_services.dart';

class SignUp extends StatefulWidget {
  const SignUp({Key? key}) : super(key: key);

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  bool isPasswordVisible = false;

  void togglePasswordVisibility() {
    setState(() {
      isPasswordVisible = !isPasswordVisible;
    });
  }

  TextEditingController userFirstNameController = TextEditingController();
  TextEditingController userLastNameController = TextEditingController();
  TextEditingController userEmailController = TextEditingController();
  TextEditingController userPhoneController = TextEditingController();
  TextEditingController userPasswordController = TextEditingController();

  User? currentUser = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SignUp'),
        centerTitle: true,
        elevation: 0.0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
                alignment: Alignment.center,
                height: 150.0,
                child: Lottie.asset('assets/134945-zpunet-icon.json')),
            const SizedBox(
              height: 20.0,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 30.0, right: 30.0),
              child: Row(
                children: [
                  Expanded(
                    flex: 5,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: userFirstNameController,
                          decoration: const InputDecoration(
                            hintText: 'First Name',
                            enabledBorder: OutlineInputBorder(),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    width: 5.0,
                  ),
                  Expanded(
                    flex: 5,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: userLastNameController,
                          decoration: const InputDecoration(
                            hintText: 'Last Name',
                            enabledBorder: OutlineInputBorder(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10.0),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 30.0),
              child: TextFormField(
                controller: userEmailController,
                decoration: const InputDecoration(
                  hintText: 'Email',
                  prefixIcon: Icon(Icons.email),
                  enabledBorder: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(height: 10.0),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 30.0),
              child: TextFormField(
                controller: userPhoneController,
                decoration: const InputDecoration(
                  hintText: 'Phone Number',
                  prefixIcon: Icon(Icons.phone),
                  enabledBorder: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(height: 10.0),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 30.0),
              child: TextFormField(
                controller: userPasswordController,
                obscureText: !isPasswordVisible,
                decoration: InputDecoration(
                  hintText: 'Password',
                  prefixIcon: const Icon(Icons.password_rounded),
                  suffixIcon: GestureDetector(
                    onTap: togglePasswordVisibility,
                    child: Icon(isPasswordVisible
                        ? Icons.visibility
                        : Icons.visibility_off),
                  ),
                  enabledBorder: const OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(height: 10.0),
            ElevatedButton(
              onPressed: () async {
                EasyLoading.show();
                var userFirstName = userFirstNameController.text.trim();
                var userLastName = userLastNameController.text.trim();
                var userEmail = userEmailController.text.trim();
                var userPhone = userPhoneController.text.trim();
                var userPassword = userPasswordController.text.trim();
                try {
                  await FirebaseAuth.instance
                      .createUserWithEmailAndPassword(
                          email: userEmail, password: userPassword)
                      .then((value) => {
                            SignUpUser(userFirstName, userLastName, userEmail,
                                userPhone, userPassword),
                          });
                } on FirebaseAuthException catch (e) {
                  print("Error $e");
                  // ignore: use_build_context_synchronously
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text('Error'),
                        content: Text('$e'),
                        actions: [
                          TextButton(
                            child: const Text('OK'),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                          ),
                        ],
                      );
                    },
                  );
                }
                EasyLoading.dismiss();
              },
              child: const Text('SignUp'),
            ),
            const SizedBox(height: 10.0),
            GestureDetector(
              onTap: () {
                EasyLoading.show();
                Get.to(() => const LoginScreen());
                EasyLoading.dismiss();
              },
              child: const Card(
                child: Padding(
                  padding: EdgeInsets.all(10.0),
                  child: Text("Already have account LogIn"),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
