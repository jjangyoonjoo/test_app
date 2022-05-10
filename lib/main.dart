import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:test_app/screens/auth.dart';
import 'package:test_app/screens/profile.dart';

import 'data/join_or_login.dart';
import 'screens/login.dart';
import 'screens/main_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

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
            appId: "1:57262460722:web:5207c0bbfbaa8f91b3d12b"));
  }
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: LayoutBuilder(builder: (context, constraines) {
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
                              'Test Auth Desktop',
                              style: Theme.of(context).textTheme.headline4,
                            )
                          ],
                        ),
                      ),
                    ),
                  )),
              SizedBox(
                width: constraines.maxWidth >= 1200
                    ? constraines.maxWidth / 2
                    : constraines.maxWidth,
                child: StreamBuilder<User?>(
                  stream: FirebaseAuth.instance.authStateChanges(),
                  builder: (context, snapshot) {
                    if(snapshot.hasData) {
                      return const ProfilePage();
                    }
                    return AuthGate();
                  },
                ),
              )
            ],
          );
        }),
      ),
    );
  }
}
