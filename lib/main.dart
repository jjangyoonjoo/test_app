import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:test_app/screens/login.dart';

import 'data/join_or_login.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: ChangeNotifierProvider<JoinOrLogin>.value(
            value: JoinOrLogin(),
            child: AuthPage()));
  }
}
