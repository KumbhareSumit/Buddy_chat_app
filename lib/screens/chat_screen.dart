import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:wechat/helper/my_date_util.dart';
import 'package:wechat/models/message.dart';
import 'package:wechat/screens/home_screen.dart';
import 'package:wechat/screens/view_profile_screen.dart';
import 'package:wechat/widgets/message_card.dart';
import '../api/apis.dart';
import '../main.dart';
import '../models/chat_user.dart';
import 'dart:developer' as dev;


class ChatScreen extends StatefulWidget {
  final ChatUser user;

  const ChatScreen({super.key, required this.user});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  // for storing all message
  List<Message> _list = [];

  //for handling message text changes
  final _textController = TextEditingController();

  // for storing value of showing or hiding emoji
  bool _showEmoji = false, _isuploading = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: SafeArea(
        child: WillPopScope(
          //if emoji are shown & back button is pressed then hide emoji
          // or else simple close current screen on back button click
          onWillPop: () {
            if(_showEmoji){
              setState(() => _showEmoji =! _showEmoji);
              return Future.value(false);

            }else{
              return Future.value(true);
            }


          },
          child: Scaffold(
            appBar: AppBar(
              automaticallyImplyLeading: false,
              flexibleSpace: _appBar(),
            ),
          backgroundColor: Color.fromARGB(255, 234, 248, 255),
          // body
          body: Column(
            children: [
              Expanded(
                child: StreamBuilder(
                  stream: APIs.getAllMessages(widget.user),
                  builder:(context, snapshot) {
                    switch(snapshot.connectionState){
                    // data is loading
                      case ConnectionState.waiting:
                      case ConnectionState.none:
                      return const SizedBox();
                    // if some or all data is loaded then show it
                      case ConnectionState.active:
                      case ConnectionState.done:

                        final data = snapshot.data?.docs;
                        dev.log('Data: ${data != null && data.isNotEmpty ? jsonEncode(data[0].data()) : 'Empty or null'}');

                        _list = data?.map((e) => Message.fromJson(e.data())).toList() ?? [];

                        if(_list.isNotEmpty){
                          return ListView.builder(
                            reverse: true,
                              itemCount: _list.length,
                              padding: EdgeInsets.only(top: mq.height * .01),
                              physics: const BouncingScrollPhysics(),
                              itemBuilder: (context, index) {

                                 return MessageCard(
                                   message: _list[index]
                                 );
                              });
                        }else{
                          return const Center(
                              child: Text('Say Hii! 👋',style: TextStyle(fontSize: 20),));
                        }
                    }


                  },
                ),
              ),
              //showing progress indicator uploading
              if(_isuploading)
              const Align(
                  alignment: Alignment.centerRight,
                  child:
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
                    child: CircularProgressIndicator(strokeWidth: 2,),
                  )),

              // chat input field
              _chatInput(),

              // show emoji on keyboard emoji button click & vice versa
              if(_showEmoji)
              SizedBox(
                height: mq.height *.35,

                child: EmojiPicker(
                textEditingController: _textController, // pass here the same [TextEditingController] that is connected to your input field, usually a [TextFormField]
                config: Config(
                //bgColor: const Color(0xFFF2F2F2),
                checkPlatformCompatibility: true,
                emojiViewConfig: EmojiViewConfig(
                emojiSizeMax: 32 * (Platform.isIOS ?  1.30 :  1.0),),

                    ),
                    ),
              )
            ],
          ),
          ),
        ),
      ),
    );
  }


  //  app bar widget
  Widget _appBar(){
    return InkWell(
      onTap: (){
      Navigator.push(context, MaterialPageRoute(builder: (_) => ViewProfileScreen(user: widget.user)));
      },
      child: StreamBuilder(stream: APIs.getUserInfo(widget.user), builder: (context, snapshot){
        final data = snapshot.data?.docs;
        final list = data?.map((e) => ChatUser.fromJson(e.data())).toList() ?? [];
        return  Row(
          children: [
            // back icon button
            IconButton(onPressed: (){
              Navigator.push(
                  context, MaterialPageRoute(
                  builder: (_) => HomeScreen()));},

                icon: const Icon(
                    Icons.arrow_back,color: Colors.black54)),

            // user profile picture
            ClipRRect(
              borderRadius: BorderRadius.circular(mq.height * .3),
              child: CachedNetworkImage(
                width: mq.height *.05,
                height: mq.height *.05,
                imageUrl: list.isNotEmpty ? list[0].image : widget.user.image,
                placeholder: (context, url) => CircularProgressIndicator(),
                errorWidget: (context, url, error) => CircleAvatar(child: Icon(CupertinoIcons.person)),
              ),
            ),


            //for adding some space
            const SizedBox(width: 10),


            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // user name
                Text(list.isNotEmpty ? list[0].name : widget.user.name ,
                    style: TextStyle(fontSize: 20,
                        color: Colors.white,
                        fontWeight: FontWeight.w500)),
                // last seen time of user
                Text(list.isNotEmpty ?
                list[0].isOnline
                    ?'online'
                    :MyDateUtil.getLastActiveTime(context: context, lastActive: list[0].lastActive) :
                MyDateUtil.getLastActiveTime(context: context, lastActive: widget.user.lastActive),
                    style: const TextStyle(fontSize: 14,
                        color: Colors.white)),
              ],)
          ],
        );

      })   );


  }

  // bottom chat input field
  Widget _chatInput(){
    return Padding(
      padding: EdgeInsets.symmetric(vertical: mq.height*.01,horizontal: mq.width*.03),
      child: Row(
        children: [
          //input field button
          Expanded(
            child: Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              child: Row(
                children: [
                  // emoji button
                  IconButton(onPressed: (){
                    FocusScope.of(context).unfocus();
                    setState(() => _showEmoji = ! _showEmoji);
                  },
                      icon: const Icon(Icons.emoji_emotions,color: Colors.deepPurple,size: 25,)),

                  Expanded(
                      child: TextField(
                        controller: _textController,
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    onTap: (){
                          if(_showEmoji)  setState(() => _showEmoji = ! _showEmoji);
                    },
                    decoration: const InputDecoration(
                        hintText: 'Text Something....',
                        hintStyle: TextStyle(color: Colors.deepPurpleAccent),
                        border: InputBorder.none),
                  )),

                  // pick image from gallery button
                  IconButton(onPressed: () async {
                    final ImagePicker picker = ImagePicker();
                    //picking multiple images
                    final List<XFile> images =
                        await picker.pickMultiImage( imageQuality: 70);
                    //uploading & sending images onr by one
                    for ( var i in images){
                      dev.log('Image Path : ${i.path} ');
                      setState(() => _isuploading = true);
                      await APIs.sendChatImage(widget.user,File(i.path));
                      setState(() => _isuploading = false);
                    }
                  },
                      icon: const Icon(Icons.image,color: Colors.deepPurple,size: 26,)),
                  // take picture from camera button
                  IconButton(onPressed: () async {
                  // pick an image
                  final ImagePicker picker = ImagePicker();
                  final XFile? image =
                  await picker.pickImage(source: ImageSource.camera, imageQuality: 70);
                  if(image != null) {
                    dev.log('Image Path : ${image.path} ');
                    await APIs.sendChatImage(widget.user,File(image.path));
                  }
                  },
                      icon: const Icon(Icons.camera_alt_rounded,color: Colors.deepPurple,size: 26,)),

                  //adding some space
                  SizedBox(width: mq.width*.02,)
                ],
              ),
            ),
          ),


          // send message button

          MaterialButton(onPressed: (){
            if (_textController.text.isNotEmpty){
              APIs.sendMessage(widget.user, _textController.text,Type.text);
              _textController.text = '';
            }
          },
            minWidth: 0,
            padding: const EdgeInsets.only(top: 10,bottom: 10,left: 10,right: 5),
            shape: const CircleBorder(),
            color: Colors.green,
            child: Icon(Icons.send,color: Colors.white,size: 28,),)
        ],
      ),
    );
  }
}
