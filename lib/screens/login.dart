import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:test_app/data/join_or_login.dart';

import '../helper/login_background.dart';

class AuthPage extends StatelessWidget {
  AuthPage({Key? key}) : super(key: key);

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
        body: Stack(
      alignment: Alignment.center,
      children: [
        CustomPaint(
          size: size,
          painter:
              LoginBackground(isJoin: Provider.of<JoinOrLogin>(context).isJoin),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            _logoImage,
            Stack(
              children: [
                _inputForm(size),
                _authButton(size),
              ],
            ),
            SizedBox(
              height: size.height * 0.1,
            ),
            Consumer<JoinOrLogin>(
              builder: (context, joinOrLogin, child) => GestureDetector(
                onTap: () {
                  joinOrLogin.toggle();
                },
                child: Text(
                    joinOrLogin.isJoin
                        ? "Already Have an Account? Sign in"
                        : "Don't Have an Account? Create One",
                    style: TextStyle(
                        color: joinOrLogin.isJoin ? Colors.red : Colors.blue)),
              ),
            ),
            SizedBox(
              height: size.height * 0.05,
            )
          ],
        )
      ],
    ));
  }

  void _register(BuildContext context) async {
    final UserCredential result = await FirebaseAuth.instance
        .createUserWithEmailAndPassword(
            email: _emailController.text, password: _passwordController.text);
    final User? user = result.user;

    if (user == null) {
      final snacBar = SnackBar(content: Text('Please try again later.'));
      Scaffold.of(context).showSnackBar(snacBar);
    }
//    Navigator.push(context,
//        MaterialPageRoute(builder: (context) => MainPage(email: user?.email)));
  }

  void _login(BuildContext context) async {
    final UserCredential result = await FirebaseAuth.instance
        .signInWithEmailAndPassword(
            email: _emailController.text, password: _passwordController.text);
    final User? user = result.user;

    if (user == null) {
      final snacBar = SnackBar(content: Text('Please try again later.'));
      Scaffold.of(context).showSnackBar(snacBar);
    }
//    Navigator.push(context,
//        MaterialPageRoute(builder: (context) => MainPage(email: user?.email)));
  }

  Widget get _logoImage => Expanded(
        child: Padding(
          padding: const EdgeInsets.only(top: 40, left: 24, right: 24),
          child: FittedBox(
            fit: BoxFit.contain,
            child: CircleAvatar(
              backgroundImage: AssetImage(
                "assets/login.gif",
              ),
            ),
          ),
        ),
      );

  Widget _inputForm(Size size) {
    return Padding(
      padding: EdgeInsets.all(size.width * 0.05),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 6,
        child: Padding(
          padding:
              const EdgeInsets.only(left: 12.0, right: 12, top: 12, bottom: 32),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
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
                TextFormField(
                  obscureText: true,
                  controller: _passwordController,
                  decoration: InputDecoration(
                    icon: Icon(Icons.vpn_key),
                    labelText: 'Password',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please input correct Password.";
                    }
                    return null;
                  },
                ),
                SizedBox(
                  height: 10,
                ),
                Consumer<JoinOrLogin>(builder: (context, joinOrlogin, child) {
                  return Opacity(
                      opacity: joinOrlogin.isJoin ? 0 : 1,
                      child: Text("Forgot Password"));
                })
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _authButton(Size size) {
    return Positioned(
      left: size.width * 0.15,
      right: size.width * 0.15,
      bottom: 0,
      child: SizedBox(
        height: 50,
        child: Consumer<JoinOrLogin>(
          builder: (context, joinOrLogin, child) => RaisedButton(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
            child: Text(
              joinOrLogin.isJoin ? 'Join' : 'Login',
              style: TextStyle(fontSize: 20, color: Colors.white),
            ),
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                joinOrLogin.isJoin ? _register(context) : _login(context);
              }
            },
            color: joinOrLogin.isJoin ? Colors.red : Colors.blue,
          ),
        ),
      ),
    );
  }
}
