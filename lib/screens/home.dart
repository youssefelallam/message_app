import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:message/widget/messege_line.dart';

final _firestor = FirebaseFirestore.instance;
late User singInUser;

class home extends StatefulWidget {
  const home({Key? key}) : super(key: key);

  @override
  _homeState createState() => _homeState();
}

class _homeState extends State<home> {
  final _auth = FirebaseAuth.instance;
  String? messageText;
  TextEditingController _msg = TextEditingController();
  void getCurrentUser() {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        singInUser = user;
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  void initState() {
    getCurrentUser();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 224, 224, 224),
      appBar: AppBar(
        title: Text('Message'),
        actions: [
          IconButton(
            onPressed: () {
              _auth.signOut();
              Navigator.pushNamedAndRemoveUntil(
                  context, "login", ModalRoute.withName("/"));
            },
            icon: Icon(Icons.exit_to_app),
          )
        ],
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            MessageStreamBuilder(),
            Container(
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: Colors.deepOrange,
                    width: 2,
                  ),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: TextField(
                      controller: _msg,
                      onChanged: (value) {
                        messageText = value;
                      },
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.symmetric(
                          vertical: 10,
                          horizontal: 20,
                        ),
                        hintText: 'Write your message here...',
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      _firestor.collection('messages').add({
                        'text': messageText,
                        'sender': singInUser.email,
                        'time': FieldValue.serverTimestamp(),
                      });
                      _msg.clear();
                    },
                    child: Text(
                      'send',
                      style: TextStyle(
                        color: Colors.blue[800],
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MessageStreamBuilder extends StatelessWidget {
  const MessageStreamBuilder({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: _firestor.collection('messages').orderBy('time').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          return Expanded(
            child: ListView.builder(
              reverse: true,
              itemCount: snapshot.data!.docs.length,
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
              itemBuilder: (context, index) {
                final currentUser = singInUser.email;
                DocumentSnapshot message = snapshot.data!.docs[index];
                return MessageLine(
                  sender: message['sender'],
                  text: message['text'],
                  isMe: message['sender'] == currentUser,
                );
              },
            ),
          );
        });
  }
}
