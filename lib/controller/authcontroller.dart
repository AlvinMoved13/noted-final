import 'package:get/get.dart';

class AuthController extends GetxController {
  var isLoggedIn = false.obs;
  var username = ''.obs;

  void logIn(String user) {
    isLoggedIn.value = false;
    username.value = user;
  }

  void logOut() {
    isLoggedIn.value = false;
    username.value = '';
  }
}
