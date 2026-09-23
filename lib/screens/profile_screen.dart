import 'dart:developer' as dev;
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';
import 'package:wechat/helper/dialogs.dart';
import 'package:wechat/models/chat_user.dart';
import 'package:wechat/screens/auth/login_screen.dart';
import '../api/apis.dart';
import '../main.dart';

// profile screen -- to show signed in user info
class ProfileScreen extends StatefulWidget {
  final ChatUser user;

  const ProfileScreen({super.key,required this.user});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  String? _image;


  @override
  Widget build(BuildContext context) {

    return GestureDetector(
      // for hiding keyboard
      onTap:() => FocusScope.of(context).unfocus(),
      child: Scaffold(
        //app bar
        appBar: AppBar(
      
          title: const Text('Profile Screen'),
      
        ),
        //floating button to logout
        floatingActionButton: Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: FloatingActionButton.extended(
            elevation: 0,
            backgroundColor: const Color.fromARGB(255, 255, 235, 235),
            onPressed: () async {
              //for showing progress dialog
              Dialogs.showProgressBar(context);

              await APIs.updateActiveStatus(false);

              // sign out from app
              await APIs.auth.signOut().then((value) async {
                await GoogleSignIn().signOut().then((value) {
                  // for hiding progress dialog
                  Navigator.pop(context);

                  // for moving to home screen
                  Navigator.pop(context);

                  APIs.auth = FirebaseAuth.instance;

                  //replacing home screen with login screen
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()));
                });
              });
            },
            icon: const Icon(CupertinoIcons.power, color: Colors.redAccent),
            label: const Text(
              'Logout',
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
        ),
      
        body: Form(
          key: _formKey,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: mq.width * .05),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // for adding some space
                  SizedBox(width: mq.width, height: mq.height * .03),

                  // user profile image
                  Stack(
                    children: [
                      //profile picture
                      _image != null
                          ?
                          //local image
                          ClipRRect(
                              borderRadius: BorderRadius.circular(mq.height * .1),
                              child: Image.file(
                                File(_image!),
                                width: mq.height * .2,
                                height: mq.height * .2,
                                fit: BoxFit.cover,
                              ))
                          :
                          //image from server
                          ClipRRect(
                              borderRadius: BorderRadius.circular(mq.height * .1),
                              child: Hero(
                                tag: 'profile_${widget.user.id}',
                                child: CachedNetworkImage(
                                  width: mq.height * .2,
                                  height: mq.height * .2,
                                  fit: BoxFit.cover,
                                  imageUrl: widget.user.image,
                                  placeholder: (context, url) =>
                                      const CircularProgressIndicator(),
                                  errorWidget: (context, url, error) =>
                                      const CircleAvatar(
                                          child: Icon(CupertinoIcons.person)),
                                ),
                              ),
                            ),

                      // edit image button
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: MaterialButton(
                          elevation: 2,
                          onPressed: () {
                            _showBottomSheet();
                          },
                          shape: const CircleBorder(),
                          color: Colors.white,
                          child: const Icon(CupertinoIcons.camera_fill, color: Color.fromARGB(255, 100, 50, 255),),
                        ),
                      )
                    ],
                  ),
                  // for adding some space
                  SizedBox(height: mq.height * .03),

                  // user email field
                  Text(widget.user.email,
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontSize: 16,
                          letterSpacing: 0.5)),

                  // for adding some space
                  SizedBox(height: mq.height * .05),

                  //name input field
                  TextFormField(
                    initialValue: widget.user.name,
                    onSaved: (val) => APIs.me.name = val ?? '',
                    validator: (val) =>
                        val != null && val.isNotEmpty ? null : 'Required Field',
                    style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                    decoration: InputDecoration(
                        prefixIcon: const Icon(CupertinoIcons.person),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20)),
                        hintText: 'Your name',
                        label: const Text('Name')),
                  ),

                  // for adding some space
                  SizedBox(height: mq.height * .02),

                  //about input field
                  TextFormField(
                    initialValue: widget.user.about,
                    onSaved: (val) => APIs.me.about = val ?? '',
                    validator: (val) =>
                        val != null && val.isNotEmpty ? null : 'Required Field',
                    style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                    decoration: InputDecoration(
                        prefixIcon: const Icon(CupertinoIcons.info),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20)),
                        hintText: 'Something about you...',
                        label: const Text('About')),
                  ),

                  // for adding some space
                  SizedBox(height: mq.height * .05),

                  //update profile button
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 100, 50, 255),
                        foregroundColor: Colors.white,
                        minimumSize: Size(mq.width * .8, mq.height * .065),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _formKey.currentState!.save();
                        APIs.updateUserInfo().then((value) {
                          Dialogs.showSnackBar(
                              context, 'Profile Updated Successfully');
                        });
                      }
                    },
                    child: const Text(
                      'SAVE CHANGES',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  )
                ],
              ),
            ),
          ),
        )
      ),
    );
  }
  // bottom sheet for picking a profile picture for user
  void _showBottomSheet(){
    showModalBottomSheet(context: context,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.only(topLeft: Radius.circular(20),topRight: Radius.circular(20))),
        builder: (_) {
      return ListView(
        shrinkWrap: true,
        padding: EdgeInsets.only(top: mq.height * .03, bottom: mq.height * .05),
        children: [
          // pick profile picture label
          const Text('Pick Profile Picture',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 20 , fontWeight: FontWeight.w500),),
          SizedBox(height: mq.height * .02),
          // button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
            // pick from gallery button
            ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              shape: const CircleBorder(),
              fixedSize: Size(mq.width * .3, mq.height * .15),
            ),
            onPressed: () async {
              final ImagePicker picker = ImagePicker();
              // pick an image
              final XFile? image =
              await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
              if(image != null){
                dev.log('Image Path : ${image.path} -- MimeType: ${image.mimeType}');
                setState(() {
                  _image = image.path;
                });

                APIs.updateProfilePicture(File(_image!));
                //for hiding bottom sheet
                Navigator.pop(context);
              }
            },
            child: Image.asset('images/add_image.png'),),

            // take photo from camera button
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                shape: const CircleBorder(),
                fixedSize: Size(mq.width * .3, mq.height * .15),
              ),
              onPressed: () async {
              final ImagePicker picker = ImagePicker();
              // pick an image
              final XFile? image =
              await picker.pickImage(source: ImageSource.camera, imageQuality: 80);
              if(image != null) {
                dev.log('Image Path : ${image.path} ');
                setState(() {
                  _image = image.path;
                });
                APIs.updateProfilePicture(File(_image!));
                //for hiding bottom sheet
                Navigator.pop(context);
              }
              },
              child: Image.asset('images/camera.png'),)
        ],
          )
        ],
      );
    });

  }

}
