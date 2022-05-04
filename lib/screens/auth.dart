import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:google_sign_in/google_sign_in.dart';

typedef OAuthSignIn = void Function();

final FirebaseAuth _auth = FirebaseAuth.instance;

enum AuthMode { login, register }

extension on AuthMode {
  String get label => this == AuthMode.login ? 'Sign in' : 'Register';
}

class AuthGate extends StatefulWidget {
  const AuthGate({Key? key}) : super(key: key);

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController phoneController = TextEditingController();

  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  String error = '';
  String verificationId = '';

  bool isLoading = false;
  AuthMode mode = AuthMode.login;

  void setIsLoading() {
    setState(() {
      isLoading = !isLoading;
    });
  }

  late Map<Buttons, OAuthSignIn> authButtons;

  @override
  void initState() {
    super.initState();
    if (kIsWeb) {
      authButtons = {
        Buttons.GoogleDark: _signInWithGoogle,
      };
    } else {
      authButtons = {
        if (!Platform.isMacOS) Buttons.GoogleDark: _signInWithGoogle,
      };
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: FocusScope.of(context).unfocus,
      child: Scaffold(
        body: Center(
          child: SingleChildScrollView(
            child: Center(
                child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SafeArea(
                child: Form(
                  key: formKey,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 400),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Visibility(
                            visible: error.isNotEmpty,
                            child: MaterialBanner(
                              backgroundColor: Theme.of(context).errorColor,
                              content: Text(error),
                              actions: [
                                TextButton(
                                    onPressed: () {
                                      setState(() {
                                        error = '';
                                      });
                                    },
                                    child: const Text(
                                      'dismiss',
                                      style: TextStyle(color: Colors.white),
                                    ))
                              ],
                              contentTextStyle:
                                  const TextStyle(color: Colors.white),
                              padding: const EdgeInsets.all(10),
                            )),
                        const SizedBox(height: 20),
                        Column(
                          children: [
                            TextFormField(
                              controller: emailController,
                              decoration: const InputDecoration(
                                hintText: 'Email',
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) =>
                                  value != null && value.isNotEmpty
                                      ? null
                                      : 'Required',
                            ),
                            const SizedBox(height: 20),
                            TextFormField(
                              controller: passwordController,
                              obscureText: true,
                              decoration: const InputDecoration(
                                hintText: 'Password',
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) =>
                                  value != null && value.isNotEmpty
                                      ? null
                                      : 'Required',
                            ),
                          ],
                        ),
                        if (mode == AuthMode.register)
                          const SizedBox(height: 20),
                        if (mode == AuthMode.register)
                          TextFormField(
                            controller: phoneController,
                            decoration: const InputDecoration(
                              hintText: '+12345678910',
                              labelText: 'Phone number',
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) =>
                                value != null && value.isNotEmpty
                                    ? null
                                    : 'Required',
                          ),
                        const SizedBox(height: 20),
                        ...authButtons.keys
                            .map(
                              (button) => Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 5),
                                child: AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 200),
                                  child: isLoading
                                      ? Container(
                                          color: Colors.grey[200],
                                          height: 50,
                                          width: double.infinity,
                                        )
                                      : SizedBox(
                                          width: double.infinity,
                                          height: 50,
                                          child: SignInButton(
                                            button,
                                            onPressed: authButtons[button]!,
                                          ),
                                        ),
                                ),
                              ),
                            )
                            .toList(),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: isLoading ? null : _emailAndPassword,
                            child: isLoading
                                ? const CircularProgressIndicator.adaptive()
                                : Text(mode.label),
                          ),
                        ),
                        TextButton(
                          onPressed: _resetPassword,
                          child: const Text('Forgot password?'),
                        ),
                        RichText(
                          text: TextSpan(
                            style: Theme.of(context).textTheme.bodyText1,
                            children: [
                              TextSpan(
                                text: mode == AuthMode.login
                                    ? "Don't have an account? "
                                    : 'You have an account? ',
                              ),
                              TextSpan(
                                text: mode == AuthMode.login
                                    ? 'Register now'
                                    : 'Click to login',
                                style: const TextStyle(color: Colors.blue),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    setState(() {
                                      mode = mode == AuthMode.login
                                          ? AuthMode.register
                                          : AuthMode.login;
                                    });
                                  },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        RichText(
                          text: TextSpan(
                            style: Theme.of(context).textTheme.bodyText1,
                            children: [
                              const TextSpan(text: 'Or '),
                              TextSpan(
                                text: 'continue as guest',
                                style: const TextStyle(color: Colors.blue),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = _anonymousAuth,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            )),
          ),
        ),
      ),
    );
  }

  Future _resetPassword() async {
    String? email;
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Send'),
            ),
          ],
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Enter your email'),
              const SizedBox(height: 20),
              TextFormField(
                onChanged: (value) {
                  email = value;
                },
              ),
            ],
          ),
        );
      },
    );

    if (email != null) {
      try {
        await _auth.sendPasswordResetEmail(email: email!);

        final snackBar =
            SnackBar(content: Text('Password reset email is sent'));
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      } catch (e) {
        final snackBar = SnackBar(content: Text('Error resetting'));
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    }
  }

  Future<void> _emailAndPassword() async {
    if (formKey.currentState?.validate() ?? false) {
      setIsLoading();

      try {
        if (mode == AuthMode.login) {
          await _auth.signInWithEmailAndPassword(
            email: emailController.text,
            password: passwordController.text,
          );
        } else {
          await _auth.createUserWithEmailAndPassword(
            email: emailController.text,
            password: passwordController.text,
          );
        }
      } on FirebaseAuthException catch (e) {
        setState(() {
          error = '${e.message}';
        });
      } catch (e) {
        setState(() {
          error = '$e';
        });
      } finally {
        setIsLoading();
      }
    }
  }

  Future<String?> getSmsCodeFromUser() async {
    String? smsCode;

    // Update the UI - wait for the user to enter the SMS code
    await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text('SMS code:'),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Sign in'),
            ),
            OutlinedButton(
              onPressed: () {
                smsCode = null;
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
          ],
          content: Container(
            padding: const EdgeInsets.all(20),
            child: TextField(
              onChanged: (value) {
                smsCode = value;
              },
              textAlign: TextAlign.center,
              autofocus: true,
            ),
          ),
        );
      },
    );

    return smsCode;
  }

  Future<void> _signInWithGoogle() async {
    setIsLoading();
    try {
      // Trigger the authentication flow
      final googleUser = await GoogleSignIn().signIn();

      // Obtain the auth details from the request
      final googleAuth = await googleUser?.authentication;

      if (googleAuth != null) {
        // Create a new credential
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        // Once signed in, return the UserCredential
        await _auth.signInWithCredential(credential);
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        error = '${e.message}';
      });
    } finally {
      setIsLoading();
    }
  }

  Future<void> _anonymousAuth() async {
    setIsLoading();

    try {
      await _auth.signInAnonymously();
    } on FirebaseAuthException catch (e) {
      setState(() {
        error = '${e.message}';
      });
    } catch (e) {
      setState(() {
        error = '$e';
      });
    } finally {
      setIsLoading();
    }
  }
}
