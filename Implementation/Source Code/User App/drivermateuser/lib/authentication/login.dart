import 'package:drivermateuser/authentication/registration.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:drivermateuser/pages/homepage.dart';
import 'package:flutter/material.dart';
import 'package:drivermateuser/commonres/methods.dart';
import 'package:drivermateuser/global/globalvar.dart';
import 'package:drivermateuser/widgets/loadingdialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  Methods cMethods = Methods();
  List <String> errors = [];

  checkIfNetworkAvailable(){
    cMethods.connectivityCheck(context);

  }
  List <String> loginFormValidation(){
    List <String> error = [];
    if(!emailController.text.contains('@') || emailController.text.isEmpty){
      error.add('Please provide valid email address.');
    }
    if(passwordController.text.trim().length<6){
      error.add('Password must be atleast 6 or more characters.');
    }
    if(error.isEmpty){
      loginUser();
    }
    return error;
    }
  loginUser()async{
    showDialog(context: context,
    barrierDismissible: false,
     builder: (BuildContext context)=> LoadingDialog(messageText: "Logging in your Account..."),);
    
    final User? userFirebase = (
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      ).catchError((errorMsg){
        cMethods.displaySnackBar(errorMsg.toString(),context);
      })
    ).user;

    if(!context.mounted) return;
    Navigator.pop(context);

    if(userFirebase != null){
      DatabaseReference usersRef = FirebaseDatabase.instance.ref().child('users').child(userFirebase.uid);
      await usersRef.once().then((snap){
        if(snap.snapshot.value != null){
          if((snap.snapshot.value as Map)["blockStatus"]=="no"){
            userName = (snap.snapshot.value as Map)["name"];
            Navigator.push(context, MaterialPageRoute(builder: (c)=> HomePage()));
          }
          else{
             FirebaseAuth.instance.signOut();
          cMethods.displaySnackBar("Your account has been blocked.", context);

          }
        }
        else{
          FirebaseAuth.instance.signOut();
          cMethods.displaySnackBar("Your Account is not registered as user.", context);
        }
      });
    }
  }


  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
            Padding(padding: EdgeInsets.only(top: 20)),
            Image.asset('assets/images/logo.png'),
            const Text(
              'Login',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
              ),
            //FORM TEXT FIELDS AND BUTTONS
            Padding(
              padding: const EdgeInsets.all(22),
              child: Column(
                children: [
                  TextField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      errorText: errors.contains('Please provide valid email address.')?'Please provide valid email address.':null ,
                      labelStyle:TextStyle(
                        fontSize: 20,

                      ),

                    ),
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 15,
                    ),

                  ),
                  const SizedBox(height: 22,),
                  TextField(
                    controller: passwordController,
                    obscureText: true,
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      errorText: errors.contains('Password must be atleast 6 or more characters.')?'Password must be atleast 6 or more characters.':null ,
                      labelStyle:TextStyle(
                        fontSize: 20,

                      ),

                    ),
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 15,
                    ),

                  ),
                  const SizedBox(height: 22,),
                  ElevatedButton(
                    onPressed:(){
                       checkIfNetworkAvailable();
                      setState(() {
                        errors = loginFormValidation();
                    });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey,
                      padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5.0),
                    )
                    ),
                    child: const Text(
                      'Login',
                      style: TextStyle(color: Colors.white),
                      
                    ),
                    ),
                ],),
            ),
            const SizedBox(height: 12,),
            //TEXT BUTTON
           TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (c) => RegistrationScreen(),
                ),
              );
            },
            child: RichText(
              text: const TextSpan(
                style: TextStyle(color: Colors.grey),
                children: [
                  TextSpan(text: 'Don\'t have an Account? '),
                  TextSpan(
                    text: 'Register here',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          )
          ],
          ),
          ),
    ));
  }
}