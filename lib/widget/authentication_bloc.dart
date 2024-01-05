import 'package:animated_snack_bar/animated_snack_bar.dart';
import 'package:collection/collection.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:noted/bloc/authentication/authentication_event.dart';
import 'package:noted/bloc/authentication/authentication_state.dart';
import 'package:noted/data/add_data.dart';

class AuthenticationBloc
    extends Bloc<AuthenticationEvent, AuthenticationState> {
  final Function(String, AnimatedSnackBarType) showSnackBar;

  AuthenticationBloc({required this.showSnackBar}) : super(Guest()) {
    on<LoginRequested>(_onLoginRequested);
    on<LogoutRequested>(_onLogoutRequested);
    on<RegisterRequested>(_onRegisterRequested);
  }

  Future<void> _onLoginRequested(
      LoginRequested event, Emitter<AuthenticationState> emit) async {
    if (event.username == 'admin' && event.password == 'admin') {
      emit(AdminAuthenticated(username: event.username));
      showSnackBar('Admin login successful.', AnimatedSnackBarType.success);
      return;
    }

    // Untuk pengguna biasa, lanjutkan dengan pengecekan ke Hive box
    var box = await Hive.openBox<AddData>('data');
    var user = box.values.firstWhereOrNull(
        (u) => u.username == event.username && u.password == event.password);

    try {
      // Melakukan login menggunakan Firebase Auth
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: event.username, // asumsikan username adalah email
        password: event.password,
      );

      // Cek apakah user berhasil login
      if (userCredential.user != null) {
        emit(Authenticated(username: event.username, isAdmin: false));
        showSnackBar('User login successful.', AnimatedSnackBarType.success);
      }
    } on FirebaseAuthException catch (e) {
      // Menangani error dari Firebase Auth
      emit(Unauthenticated());
      showSnackBar('Login failed: ${e.message}', AnimatedSnackBarType.error);
    }
  }
}

Future<void> _onLogoutRequested(
    LogoutRequested event, Emitter<AuthenticationState> emit) async {
  await FirebaseAuth.instance.signOut();
  emit(Unauthenticated());
  // Kode tambahan untuk mengatur ulang state atau membersihkan data pengguna saat logout, jika diperlukan
}

Future<void> _onRegisterRequested(
    RegisterRequested event, Emitter<AuthenticationState> emit) async {
  var box = await Hive.openBox<AddData>('data');
  var existingUser =
      box.values.firstWhereOrNull((u) => u.username == event.username);

  if (existingUser != null) {
    // Jika pengguna sudah ada, tidak lanjutkan dengan proses registrasi dan tampilkan pesan error.
    emit(Unauthenticated());
  } else {
    try {
      // Mendaftarkan user baru menggunakan Firebase Auth
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: event.username, // asumsikan username adalah email
        password: event.password,
      );

      // Cek apakah user berhasil didaftarkan
      if (userCredential.user != null) {
        // Setelah berhasil mendaftar di Firebase Auth, tambahkan pengguna ke Hive box
        var newUser = AddData(
          '', // name
          '0', // amount
          '', // IN
          DateTime.now(), // datetime
          '', // selectedItem
          event.username, // username
          event.password, // password
        );
        await box.add(newUser);

        emit(Authenticated(username: event.username, isAdmin: false));
      }
    } on FirebaseAuthException catch (e) {
      // Menangani error dari Firebase Auth
      emit(Unauthenticated());
    }
  }
}
