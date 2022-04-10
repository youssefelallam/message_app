import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:awesome_dialog/awesome_dialog.dart';

class register extends StatefulWidget {
  const register({Key? key}) : super(key: key);

  @override
  State<register> createState() => _registerState();
}

class _registerState extends State<register> {
  TextEditingController _email = TextEditingController();
  TextEditingController _password = TextEditingController();
  bool isload = false;
  loadfun(bool status) {
    setState(() {
      isload = status;
    });
  }

  //sing up function
  singUp(String email, password) async {
    try {
      final credential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        showDialog("The password provided is too weak.");
      } else if (e.code == 'email-already-in-use') {
        showDialog("The account already exists for that email.");
      }
      return null;
    } catch (e) {
      print(e);
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
                              await singUp(_email.text, _password.text);

                          if (resp!.user!.email != null) {
                            loadfun(false);
                            _email.clear();
                            _password.clear();
                            Navigator.pushReplacementNamed(context, 'home');
                          }
                        } catch (e) {}
                        loadfun(false);
                      },
                      child: Text('Register'),
                      style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: new BorderRadius.circular(30.0),
                          ),
                          primary: Color.fromARGB(255, 17, 66, 151),
                          padding: EdgeInsets.symmetric(
                              horizontal: 65, vertical: 12),
                          textStyle: TextStyle(
                              fontWeight: FontWeight.w900, fontSize: 15)),
                    )
            ],
          ),
        )),
      ),
    );
  }
}
