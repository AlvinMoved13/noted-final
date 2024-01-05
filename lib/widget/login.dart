import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:noted/bloc/authentication/authentication_event.dart';
import 'package:noted/bloc/authentication/authentication_state.dart';
import 'package:noted/controller/authcontroller.dart';
import 'package:noted/main.dart';
import 'package:noted/screen/admin.dart';

import 'authentication_bloc.dart';

class LoginScreen extends StatefulWidget {
  // Gunakan StatefulWidget
  LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _passwordVisible = false; // Gunakan final di sini

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login')),
      body: BlocListener<AuthenticationBloc, AuthenticationState>(
        listener: (context, state) {
          if (state is Authenticated) {
            final authController = Get.find<AuthController>();
            authController.logIn(
                _usernameController.text.trim()); // Gunakan username dari input
            final navigationController = Get.find<NavigationController>();
            navigationController.changePage(0); // 0 untuk HomePage
            Get.offAll(() => MainApp());
          } else if (state is AdminAuthenticated) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => AdminPage()),
            );
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Login berhasil sebagai admin.')));
          } else if (state is Unauthenticated) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content:
                    Text('Login Gagal. Silakan periksa kredensial Anda.')));
          }
        },
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Implementasi dari AddPage
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: TextField(
                  controller: _usernameController,
                  decoration: InputDecoration(
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                    labelText: 'Username', // Ganti label sesuai kebutuhan
                    labelStyle: TextStyle(
                      fontSize: 17,
                      color: Colors.grey.shade500,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        width: 2,
                        color: Color(0xffC5C5C5),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        width: 2,
                        color: Color(0xff1DA1F2),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                    labelText: 'Password', // Ganti label sesuai kebutuhan
                    labelStyle: TextStyle(
                      fontSize: 17,
                      color: Colors.grey.shade500,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        width: 2,
                        color: Color(0xffC5C5C5),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        width: 2,
                        color: Color(0xff1DA1F2),
                      ),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _passwordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _passwordVisible = !_passwordVisible;
                        });
                      },
                    ),
                  ),
                  obscureText: !_passwordVisible,
                ),
              ),
              SizedBox(height: 16),
              // Implementasi dari AddPage
              GestureDetector(
                onTap: () {
                  context.read<AuthenticationBloc>().add(
                        LoginRequested(
                          username: _usernameController.text.trim(),
                          password: _passwordController.text.trim(),
                        ),
                      );
                },
                child: Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: Color(0xff1DA1F2),
                  ),
                  width: 120,
                  height: 50,
                  child: Text(
                    'Login', // Ganti teks sesuai kebutuhan
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      fontSize: 17,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
