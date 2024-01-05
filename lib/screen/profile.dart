import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:noted/controller/authcontroller.dart';
import 'package:noted/widget/login.dart';
import 'package:noted/widget/register.dart';

class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // This line was removed to clear the unused_local_variable warning
    // final AuthController authController = Get.find();

    return Scaffold(
      appBar: AppBar(title: Text('Profile')),
      body: StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              // User is logged in
              return _buildLoggedInView(
                  context, snapshot.data!.displayName ?? 'No Name');
            } else {
              // User is logged out
              return _buildLoggedOutView(context);
            }
          }),
    );
  }

  Widget _buildLoggedInView(BuildContext context, String username) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text('Welcome, $username'),
        ElevatedButton(
          onPressed: () {
            // Using the auth controller directly within the onPressed callback
            Get.find<AuthController>().logOut();
          },
          child: Text('Log Out'),
        ),
      ],
    );
  }

  Widget _buildLoggedOutView(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Expanded(
          child: Image.asset('images/animate.gif'),
        ),
        SizedBox(height: 24),
        _buildLoginButton(context),
        SizedBox(height: 20),
        _buildRegisterButton(context),
      ],
    );
  }

  Widget _buildLoginButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 50.0),
        child: ElevatedButton(
          onPressed: () {
            Navigator.of(context)
                .push(MaterialPageRoute(builder: (context) => LoginScreen()));
          },
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30.0),
              side: BorderSide(color: Color(0xff1DA1F2), width: 2.0),
            ),
          ),
          child: Text('Log In', style: TextStyle(color: Color(0xff1DA1F2))),
        ),
      ),
    );
  }

  Widget _buildRegisterButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 50.0),
        child: OutlinedButton(
          onPressed: () {
            Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => RegisterScreen()));
          },
          style: OutlinedButton.styleFrom(
            backgroundColor: Color(0xff1DA1F2),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0)),
            side: BorderSide(width: 2.0, color: Color(0xff1DA1F2)),
          ),
          child: Text('Create Account', style: TextStyle(color: Colors.white)),
        ),
      ),
    );
  }
}
