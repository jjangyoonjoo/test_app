import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

import 'auth.dart';
import 'profile.dart';

// Requires that the Firebase Auth emulator is running locally
// e.g via `melos run firebase:emulator`.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // We're using the manual installation on non-web platforms since Google sign in plugin doesn't yet support Dart initialization.
  // See related issue: https://github.com/flutter/flutter/issues/96391
  if (!kIsWeb) {
    await Firebase.initializeApp();
  } else {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyBObK1zPz_A-Ecc_VZje5sYwo1GsOBJYTQ",
        authDomain: "fir-auth-18f69.firebaseapp.com",
        projectId: "fir-auth-18f69",
        storageBucket: "fir-auth-18f69.appspot.com",
        messagingSenderId: "57262460722",
        appId: "1:57262460722:web:5207c0bbfbaa8f91b3d12b",
      ),
    );
  }

  // await FirebaseAuth.instance.useAuthEmulator('localhost', 9099);

  runApp(const AuthExampleApp());
}

/// The entry point of the application.
///
/// Returns a [MaterialApp].
class AuthExampleApp extends StatelessWidget {
  const AuthExampleApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Firebase Example App',
      theme: ThemeData(primarySwatch: Colors.amber),
      home: Scaffold(
        body: LayoutBuilder(
          builder: (context, constraines) {
            return Row(
              children: [
                Visibility(
                  visible: constraines.maxWidth >= 1200,
                  child: Expanded(
                    child: Container(
                      height: double.infinity,
                      color: Theme.of(context).colorScheme.primary,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Firebase Auth Desktop',
                              style: Theme.of(context).textTheme.headline4,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: constraines.maxWidth >= 1200
                      ? constraines.maxWidth / 2
                      : constraines.maxWidth,
                  child: StreamBuilder<User?>(
                    stream: FirebaseAuth.instance.authStateChanges(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return const ProfilePage();
                      }
                      return const AuthGate();
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
