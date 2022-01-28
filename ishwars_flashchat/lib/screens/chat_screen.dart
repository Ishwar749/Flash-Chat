
import 'package:flutter/material.dart';
import 'package:ishwars_flashchat/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ishwars_flashchat/screens/welcome_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

User loggedInUser ;
final _firestore = FirebaseFirestore.instance;

class ChatScreen extends StatefulWidget {
  static const String id = 'chat_screen';

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {

  final messageTextController  = TextEditingController();

  final _auth = FirebaseAuth.instance;

  String messageText;


  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }
    void getCurrentUser() async{
      try {
        final user = await _auth.currentUser;

        if (user != null) {
          loggedInUser = user;
          print(loggedInUser.email);
        }
      }
      catch(e){
        print(e);
      }
    }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: null,
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.close),
              onPressed: () async {

                SharedPreferences sp =  await SharedPreferences.getInstance();
                sp.setBool('login', false);
                // //Implement logout functionality
                _auth.signOut();
                Navigator.pushNamed(context, WelcomeScreen.id);
               // messageStream();
              }),
        ],
        title: Text('⚡️Chat'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            StreamBuilder<QuerySnapshot>(
              stream:   _firestore.collection('messages').snapshots(),
              builder: (context, snapshot) {
                if(!snapshot.hasData){
                  return Center(
                    child: CircularProgressIndicator(
                      backgroundColor: Colors.lightBlueAccent,
                    ),
                  );
                }
                  final messages  = snapshot.data.docs.reversed;
                  List<MessageBubble> messageBubbles = [];
                  for(var message in messages){
                    final messageText = message.get('Text');
                    final messageSender = message.get('Sender');
                    final messageTime = message.get("time");
                    final currenUser = loggedInUser.email;

                      final messageBubble = MessageBubble(sender: messageSender,text: messageText, isMe: currenUser==messageSender, time : messageTime);
                      messageBubbles.add(messageBubble);
                      messageBubbles.sort((a,b)=>b.time.compareTo(a.time));
                  }
                  return Expanded(
                    child: ListView(
                      reverse: true,
                      padding: EdgeInsets.symmetric(horizontal: 10.0,vertical: 20.0),
                        children: messageBubbles
                    ),
                  );

              },
            ),
            Container(
              decoration: kMessageContainerDecoration,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: messageTextController,
                      onChanged: (value) {

                        messageText = value;
                        //Do something with the user input.
                      },
                      decoration: kMessageTextFieldDecoration,
                    ),
                  ),
                  FlatButton(
                    onPressed: () {
                      messageTextController.clear();
                      //Implement send functionality.
                      _firestore.collection('messages').add({
                        'Text' : messageText,
                        'Sender' : loggedInUser.email,
                        "time" : DateTime.now(),
                      });
                    },
                    child: Text(
                      'Send',
                      style: kSendButtonTextStyle,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MessageBubble extends StatelessWidget {

  MessageBubble({this.sender,this.text , this.isMe , this.time});

  final String sender;
  final String text;
  final bool isMe;
  final Timestamp time;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(10.0),
      
      child: Column(
        crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Text("$sender ${time.toDate()}", style: TextStyle(
            fontSize: 12.0,
            color:  Colors.black54,
          ),
          ),
          Material(
            borderRadius: isMe ? 
            BorderRadius.only(
                topLeft: Radius.circular(30.0),bottomLeft: Radius.circular(30.0),bottomRight: Radius.circular(30.0)
            ) : BorderRadius.only(
              bottomLeft: Radius.circular(30.0), topRight: Radius.circular(30.0), bottomRight: Radius.circular(30.0)
            ),
            elevation: 5.0,
            color: isMe ?  Colors.lightBlueAccent : Colors.white,
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 10.0,horizontal: 20.0),
              child: Text(
                  text,
                style: TextStyle(
                  color: isMe ? Colors.white : Colors.black54,
                  fontSize:  15.0,
                ),
              ),
            ),
          ),
        ],
      ),
    ) ;
  }
}
