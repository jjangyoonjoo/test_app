import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ForgetPw extends StatefulWidget {
  const ForgetPw({Key? key}) : super(key: key);

  @override
  State<ForgetPw> createState() => _ForgetPwState();
}

class _ForgetPwState extends State<ForgetPw> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text("Forget Password")),
        body: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  icon: Icon(Icons.account_circle),
                  labelText: 'Email',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please input correct Email.";
                  }
                  return null;
                },
              ),
              ElevatedButton(
                  onPressed: () async {
                    FirebaseAuth.instance
                        .sendPasswordResetEmail(email: _emailController.text)
                        .whenComplete(() {
                      SnackBar snackBar = SnackBar(
                          content: Text('Check your email for pw reset.'));
                      ScaffoldMessenger.of(_formKey.currentContext!).showSnackBar(snackBar);
                    });
                  },
                  child: Text('Reset Password'))
            ],
          ),
        ));
  }
}
