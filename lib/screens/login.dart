import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:test_app/data/join_or_login.dart';
import 'package:test_app/screens/forget_pw.dart';
import 'package:google_sign_in/google_sign_in.dart';

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

    try {
      final UserCredential result = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
          email: _emailController.text, password: _passwordController.text);
    } catch(e) {
        final snackBar = SnackBar(content: Text(e.toString()));
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
//    Navigator.push(context,
//        MaterialPageRoute(builder: (context) => MainPage(email: user?.email)));
  }

  void _login(BuildContext context) async {
    try {
      final UserCredential result = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
          email: _emailController.text, password: _passwordController.text);
    } catch (e) {
      final snackBar = SnackBar(content: Text(e.toString()));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
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
                      child: GestureDetector(
                          onTap: joinOrlogin.isJoin
                              ? null
                              : () {
                                  goToForgetPw(context);
                                },
                          child: Text("Forgot Password")));
                })
              ],
            ),
          ),
        ),
      ),
    );
  }

  goToForgetPw(BuildContext context) {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => ForgetPw()));
  }

  Future<UserCredential> signInWithGoogle() async {
    // Trigger the authentication flow
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    // Obtain the auth details from the request
    final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;

    print("google Auth: " +  googleAuth.toString());

    // Create a new credential
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    // Once signed in, return the UserCredential
    return await FirebaseAuth.instance.signInWithCredential(credential);
  }

  Widget _authButton(Size size) {
    return Positioned(
      left: size.width * 0.15,
      right: size.width * 0.15,
      bottom: 0,
      child: Column(
        children: [
          SizedBox(
            height: 50,
            width: size.width,
            child: Consumer<JoinOrLogin>(
              builder: (context, joinOrLogin, child) => ElevatedButton(
                style:
                    ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                      primary: joinOrLogin.isJoin ? Colors.red : Colors.blue,
                    ),
                child: Text(
                  'google',
                  style: TextStyle(fontSize: 20, color: Colors.white),
                ),
                onPressed: signInWithGoogle,

              ),
            ),
          ),
          SizedBox(
            height: 50,
            width: size.width,
            child: Consumer<JoinOrLogin>(
              builder: (context, joinOrLogin, child) => ElevatedButton(
                style:
                ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                  primary: joinOrLogin.isJoin ? Colors.red : Colors.blue,
                ),
                child: Text(
                  joinOrLogin.isJoin ? 'Join' : 'Login',
                  style: TextStyle(fontSize: 20, color: Colors.white),
                ),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    joinOrLogin.isJoin ? _register(context) : _login(context);
                  }
                },

              ),
            ),
          ),
        ],
      ),
    );
  }
}
