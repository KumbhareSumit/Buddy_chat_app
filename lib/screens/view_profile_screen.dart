import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:wechat/helper/my_date_util.dart';
import 'package:wechat/models/chat_user.dart';
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

          floatingActionButton: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Joined on: ',
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontWeight: FontWeight.bold,
                      fontSize: 15)),
              Text(
                MyDateUtil.getLastMessageTime(
                    context: context,
                    time: widget.user.createdAt,
                    showYear: true),
                style: TextStyle(
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                    fontSize: 16),
              ),
            ],
          ),
          body: Padding(
            padding: EdgeInsets.symmetric(horizontal: mq.width * .05),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // for adding some space
                  SizedBox(width: mq.width, height: mq.height * .03),

                  // user profile image
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
                            const CircleAvatar(child: Icon(CupertinoIcons.person)),
                      ),
                    ),
                  ),
                  // for adding some space
                  SizedBox(height: mq.height * .03),

                  // user email field
                  Text(
                    widget.user.email,
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontSize: 16),
                  ),

                  // for adding some space
                  SizedBox(height: mq.height * .02),

                  //user about
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('About: ',
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface,
                              fontWeight: FontWeight.bold,
                              fontSize: 15)),
                      Text(widget.user.about,
                          style: TextStyle(
                              color: Theme.of(context).textTheme.bodyMedium?.color,
                              fontSize: 15)),
                    ],
                  ),
                ],
              ),
            ),
          )),
    );
  }

}
