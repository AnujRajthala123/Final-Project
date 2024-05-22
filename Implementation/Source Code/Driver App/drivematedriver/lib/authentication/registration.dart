import 'package:drivematedriver/authentication/login.dart';
import 'package:drivematedriver/pages/dashboard.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:drivematedriver/commonres/methods.dart';
// import 'package:firebase_auth/firebase_auth.dart';
import 'package:drivematedriver/widgets/loadingdialog.dart';
import 'package:drivematedriver/pages/dashboard.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';
// import 'package:firebase_database/firebase_database.dart';

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
  XFile? imageFile;
  String urlOfUploadedImage = "";

  checkIfNetworkAvailable(){
    cMethods.connectivityCheck(context);
    // if(imageFile!= null){
    // uploadImageToStorage();
    // }
    // else{
    //   cMethods.displaySnackBar("Please choose image first", context);
    // }

  }

  uploadImageToStorage()async{
    if(imageFile!= null){
    String imageIDName = DateTime.now().millisecondsSinceEpoch.toString();
    Reference referenceImage = FirebaseStorage.instance.ref().child("Images").child(imageIDName);

    UploadTask uploadTask = referenceImage.putFile(File(imageFile!.path));
    TaskSnapshot snapshot = await uploadTask;
    urlOfUploadedImage = await snapshot.ref.getDownloadURL();

    setState((){
      urlOfUploadedImage;
    });
    registerNewDriver();}
    else{
      cMethods.displaySnackBar("Please choose image first", context);
    }
  }

  List <String> registrationFormValidation(){
    List <String> error = [];
    print("validation is called");
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
      print("error is empty");
      uploadImageToStorage();
      print("image file uploaded");
    }

    return error;
    
  }
  
  registerNewDriver() async{
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

    DatabaseReference usersRef = FirebaseDatabase.instance.ref().child('drivers').child(userFirebase!.uid);
    Map driverDataMap =
    {
      "photo": urlOfUploadedImage,
      "name": usernameController.text.trim(),
      "email": emailController.text.trim(),
      "phone": phonenoController.text.trim(),
      "id": userFirebase.uid,
      "blockStatus": "no",
    };
    usersRef.set(driverDataMap);

    Navigator.push(context, MaterialPageRoute(builder: (c)=> Dashboard()));
  }
  
  chooseImageFromGallery()async
  {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if(pickedFile != null)
    {
      setState(() {
        imageFile = pickedFile;
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
              imageFile == null?
              CircleAvatar(
              radius: 86,
              backgroundImage: AssetImage("assets/images/avatarman.png"),
            ): Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey,
                image: DecorationImage(
                  fit: BoxFit.fitHeight,
                  image: FileImage(
                    File(
                      imageFile!.path,
                    ),
                  )
                )
              )
            ),
            GestureDetector(
              onTap: (){
                chooseImageFromGallery();
              },
              child: const Text(
                'Choose Image',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
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
                      print("network checked");
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