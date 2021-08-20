
import 'package:chitchat/Screens/homeScreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LogInPage extends StatefulWidget {

  @override
  _LogInPageState createState() => _LogInPageState();
}

class _LogInPageState extends State<LogInPage> {

  bool isLoggedIn = false;


  // google signin
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final usersRef = FirebaseFirestore.instance.collection('users');

  Future<User?> loginWithGoogle() async {
    final GoogleSignInAccount account = await (_googleSignIn.signIn() as FutureOr<GoogleSignInAccount>);
    final GoogleSignInAuthentication authentication =
    await account.authentication;

    final GoogleAuthCredential credential = GoogleAuthProvider.credential(
      idToken: authentication.idToken,
      accessToken: authentication.accessToken,
    ) as GoogleAuthCredential;

    final UserCredential authResult =
    await _auth.signInWithCredential(credential);
    final User? user = authResult.user;
    return user;
  }

  checkAuthentification() async {
    _auth.authStateChanges().listen((user) {
      if (user != null) {
        print(user);
        createUserInFireStore();
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) =>HomeScreen()));
      }
    });
  }
  createUserInFireStore() async{
    final User user = _auth.currentUser!;
    DocumentSnapshot doc = await usersRef.doc(user.uid).get();

    usersRef.doc(user.uid).set({
      "name": user.displayName,
      "email": user.email,
      "id": user.uid,
      "photoUrl": user.photoURL
    });

    doc = await usersRef.doc(user.uid).get();
  }
  @override
  void initState() {
    this.checkAuthentification();
    super.initState();
  }
  // google signin end

  //facebook login

  Future<void> fbLogin() async{
    try{


      final LoginResult result = await FacebookAuth.instance.login();


      if (result.status == LoginStatus.success) {

        final AccessToken accessToken = result.accessToken!;

        final userData = await FacebookAuth.i.getUserData();

        print(userData);

        AuthCredential credential = FacebookAuthProvider.credential(accessToken.token);

        _auth.signInWithCredential(credential);

      }

    }catch(e){

      print(e);

    }
  }

  //fb end

    @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            margin: EdgeInsets.only(right: 80,top: 180),
            width:200 ,
            child: Text("Welcome "
                "For ChitChat.", style: TextStyle(fontSize: 60,fontWeight: FontWeight.bold),),
          ),
          SizedBox(height: 130,),
          Container(
            padding: EdgeInsets.all(10),
            child: OutlinedButton.icon(onPressed: (){
              loginWithGoogle().then((User? user) => print(user))
                  .catchError((e) => print(e));
            },
                icon:FaIcon(FontAwesomeIcons.google, color: Colors.red),
                label: Text("SignUp with Google",
                  style: TextStyle(fontSize: 22),),
              style: OutlinedButton.styleFrom(padding: EdgeInsets.symmetric(horizontal: 100,vertical: 16)),

            ),
          ),
          Container(
            padding: EdgeInsets.all(10),
            child: OutlinedButton.icon(onPressed: ()=> fbLogin(),
                icon:FaIcon(FontAwesomeIcons.facebookF, color: Colors.blue),
                label: Text("SignUp With FaceBook",style: TextStyle(fontSize: 22),
                ),
                style: OutlinedButton.styleFrom(padding: EdgeInsets.symmetric(horizontal: 92,vertical: 16)),
            ),
          ),
          Container(
            child: Text("Continue with login",style: TextStyle(fontSize: 16,color: Colors.grey),),
          )

        ],
      ),
    );
  }
}

