import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:message/screens/widget/messege_line.dart';

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

  // void getMessages() async {
  //   await _firestor.collection('messages').snapshots().forEach((element) {
  //     element.docs.forEach((e) {
  //       print(e.data());
  //     });
  //   });
  // }

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
          List<MessageLine> messagesWidgets = [];
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          snapshot.data!.docs.reversed.forEach((element) {
            final text = element.get('text');
            final sender = element.get('sender');
            final currentUser = singInUser.email;
            final messageWidget = MessageLine(
              sender: sender,
              text: text,
              isMe: sender == currentUser,
            );
            messagesWidgets.add(messageWidget);
          });
          return Expanded(
            child: ListView(
              reverse: true,
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
              children: messagesWidgets,
            ),
          );
        });
  }
}
