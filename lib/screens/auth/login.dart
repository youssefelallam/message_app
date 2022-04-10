import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:awesome_dialog/awesome_dialog.dart';

class login extends StatefulWidget {
  const login({Key? key}) : super(key: key);

  @override
  State<login> createState() => _loginState();
}

class _loginState extends State<login> {
  TextEditingController _email = TextEditingController();
  TextEditingController _password = TextEditingController();
  bool isload = false;
  loadfun(bool status) {
    setState(() {
      isload = status;
    });
  }

  //sing in function
  singIN(String email, password) async {
    try {
      final credential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      return credential;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        showDialog("No user found for that email.");
      } else if (e.code == 'wrong-password') {
        showDialog("Wrong password provided for that user.");
      }
      return null;
    }
  }

  showDialog(String message) {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.ERROR,
      animType: AnimType.BOTTOMSLIDE,
      desc: message,
    )..show();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: SingleChildScrollView(
            child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Message',
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.w900,
                  )),
              SizedBox(height: 15),
              TextField(
                controller: _email,
                decoration: InputDecoration(
                  hintText: 'Email',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: _password,
                obscureText: true,
                decoration: InputDecoration(
                  hintText: 'Password',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
              SizedBox(height: 20),
              isload
                  ? CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: () async {
                        loadfun(true);
                        try {
                          UserCredential? resp =
                              await singIN(_email.text, _password.text);
                          if (resp!.user!.email != null) {
                            loadfun(false);
                            _email.clear();
                            _password.clear();
                            Navigator.pushReplacementNamed(context, 'home');
                          }
                        } catch (e) {}
                        loadfun(false);
                      },
                      child: Text('Login'),
                      style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: new BorderRadius.circular(30.0),
                          ),
                          padding: EdgeInsets.symmetric(
                              horizontal: 70, vertical: 12),
                          textStyle: TextStyle(
                              fontWeight: FontWeight.w900, fontSize: 20)),
                    ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, 'register');
                },
                child: Text('Register'),
                style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: new BorderRadius.circular(30.0),
                    ),
                    primary: Color.fromARGB(255, 17, 66, 151),
                    padding: EdgeInsets.symmetric(horizontal: 65, vertical: 12),
                    textStyle:
                        TextStyle(fontWeight: FontWeight.w900, fontSize: 15)),
              )
            ],
          ),
        )),
      ),
    );
  }
}
