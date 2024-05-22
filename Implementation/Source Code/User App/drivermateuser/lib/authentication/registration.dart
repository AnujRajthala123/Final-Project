import 'package:drivermateuser/authentication/login.dart';
import 'package:flutter/material.dart';
import 'package:drivermateuser/commonres/methods.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:drivermateuser/widgets/loadingdialog.dart';
import 'package:drivermateuser/pages/homepage.dart';
import 'package:firebase_database/firebase_database.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  TextEditingController usernameController = TextEditingController();
  TextEditingController phonenoController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  Methods cMethods = Methods();
  List <String> errors = [];

  checkIfNetworkAvailable(){
    cMethods.connectivityCheck(context);

  }

  List <String> registrationFormValidation(){
    List <String> error = [];
    if(usernameController.text.trim().length<4){
      error.add('Username must be atleast 4 or more characters.');
      
    }
    if(phonenoController.text.trim().length!=10){
      error.add('Phone no must be of 10 digits.');
    }
    if(!emailController.text.contains('@') || emailController.text.isEmpty){
      error.add('Please provide valid email address.');
    }
    if(passwordController.text.trim().length<6){
      error.add('Password must be atleast 6 or more characters.');
    }
    if(error.isEmpty){
      registerNewUser();
      
    }

    return error;
    
  }
  
  registerNewUser() async{
    showDialog(context: context,
    barrierDismissible: false,
     builder: (BuildContext context)=> LoadingDialog(messageText: "Registering your Account..."),);
    
    final User? userFirebase = (
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      ).catchError((errorMsg){
        cMethods.displaySnackBar(errorMsg.toString(),context);
      })
    ).user;
    if(!context.mounted) return;
    Navigator.pop(context);

    DatabaseReference usersRef = FirebaseDatabase.instance.ref().child('users').child(userFirebase!.uid);
    Map userDataMap =
    {
      "name": usernameController.text.trim(),
      "email": emailController.text.trim(),
      "phone": phonenoController.text.trim(),
      "id": userFirebase.uid,
      "blockStatus": "no",
    };
    usersRef.set(userDataMap);

    Navigator.push(context, MaterialPageRoute(builder: (c)=> HomePage()));
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
              'Register',
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
                    controller: usernameController,
                    keyboardType: TextInputType.text,
                    decoration:  InputDecoration(
                      labelText: 'User Name',
                      errorText: errors.contains('Username must be atleast 4 or more characters.')?'Username must be atleast 4 or more characters.':null,
                      labelStyle:const TextStyle(
                        fontSize: 20,

                      ),

                    ),
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                    ),

                  ),
                  const SizedBox(height: 22,),
                  TextField(
                    controller: phonenoController,
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                      labelText: 'Phone No',
                      errorText: errors.contains('Phone no must be of 10 digits.')?'Phone no must be of 10 digits.':null,
                      labelStyle:const TextStyle(
                        fontSize: 20,

                      ),

                    ),
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                    ),

                  ),
                  const SizedBox(height: 22,),
                  TextField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      errorText: errors.contains('Please provide valid email address.')?'Please provide valid email address.':null ,
                      labelStyle: const TextStyle(
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
                      labelStyle:const TextStyle(
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
                        errors = registrationFormValidation();
                        // print(errors);
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
                      'Sign Up',
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
                  builder: (c) => LoginScreen(),
                ),
              );
            },
            child: RichText(
              text: const TextSpan(
                style: TextStyle(color: Colors.grey),
                children: [
                  TextSpan(text: 'Don\'t have an Account? '),
                  TextSpan(
                    text: 'Login here',
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