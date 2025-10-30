import 'dart:developer' as dev;
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';
import 'package:wechat/helper/dialogs.dart';
import 'package:wechat/helper/my_date_util.dart';
import 'package:wechat/models/chat_user.dart';
import 'package:wechat/screens/auth/login_screen.dart';
import '../api/apis.dart';
import '../main.dart';

// view profile screen -- to show signed in user info
class ViewProfileScreen extends StatefulWidget {
  final ChatUser user;

  const ViewProfileScreen({super.key,required this.user});

  @override
  State<ViewProfileScreen> createState() => _ViewProfileScreenState();
}

class _ViewProfileScreenState extends State<ViewProfileScreen> {


  @override
  Widget build(BuildContext context) {

    return GestureDetector(
      // for hiding keyboard
      onTap:() => FocusScope.of(context).unfocus(),
      child: Scaffold(
        //app bar
          appBar: AppBar(

            title:  Text(widget.user.name)),

          floatingActionButton:  Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Joined on: ',
                style: TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.w500,
                    fontSize: 15)),
              Text(MyDateUtil.getLastMessageTime(
                  context: context,
                  time: widget.user.createdAt,
                  showYear: true),
                style: const TextStyle(color: Colors.black87,fontSize: 16),),
            ],
          ),

          body: Padding(
            padding: EdgeInsets.symmetric(horizontal: mq.width * .05),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // for adding some space
                  SizedBox(width: mq.width,height: mq.height * .03),

                  // user profile image
                  ClipRRect(
                    borderRadius: BorderRadius.circular(mq.height * .1),
                    child: CachedNetworkImage(
                      width: mq.height *.2,
                      height: mq.height *.2,
                      fit: BoxFit.fill,
                      imageUrl: widget.user.image,
                      placeholder: (context, url) => CircularProgressIndicator(),
                      errorWidget: (context, url, error) => CircleAvatar(child: Icon(CupertinoIcons.person)),
                    ),
                  ),
                  // for adding some space
                  SizedBox(height: mq.height * .03),

                  // user email field
                  Text(widget.user.email,
                    style: const TextStyle(color: Colors.black87,fontSize: 16),),

                  // for adding some space
                  SizedBox(height: mq.height * .02),

                  //user about
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('About: ',
                        style: TextStyle(
                            color: Colors.black87,
                            fontWeight: FontWeight.w500,
                            fontSize: 15)),
                      Text(widget.user.about,
                        style: const TextStyle(color: Colors.black87,fontSize: 15)),
                    ],
                  ),

                ],),
            ),
          )
      ),
    );
  }

}
