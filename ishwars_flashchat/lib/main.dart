import 'dart:math';

import 'package:flutter/material.dart';
import 'package:ishwars_flashchat/screens/login_screen.dart';
import 'package:ishwars_flashchat/screens/registration_screen.dart';
import 'package:ishwars_flashchat/screens/welcome_screen.dart';
import 'package:ishwars_flashchat/screens/chat_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';

//bool loginUser = false;

void main() async {
   WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(FlashChat());

}

bool getLoggedInState()  {
  // SharedPreferences sp = await SharedPreferences.getInstance();
  // //sp.setBool('login', true);
  // return sp.getBool('login');

  final User user = FirebaseAuth.instance.currentUser;

    if(user != null){
      return true;
    }
    else{
      return false;
    }

}

class FlashChat extends StatelessWidget {
  Widget build(BuildContext context) {
    return MaterialApp(
        initialRoute:getLoggedInState() ? ChatScreen.id : WelcomeScreen.id,
        routes: {
          WelcomeScreen.id: (context) => WelcomeScreen(),
          LoginScreen.id: (context) => LoginScreen(),
          RegistrationScreen.id: (context) => RegistrationScreen(),
          ChatScreen.id: (context) => ChatScreen(),
        });
  }
}
