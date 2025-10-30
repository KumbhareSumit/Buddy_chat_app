import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:wechat/api/apis.dart';
import 'package:wechat/helper/my_date_util.dart';
import 'dart:developer' as dev;
import '../main.dart';
import '../models/message.dart';

class MessageCard extends StatefulWidget {
  const MessageCard({super.key, required this.message});

  final Message message;

  @override
  State<MessageCard> createState() => _MessageCardState();
}

class _MessageCardState extends State<MessageCard> {
  @override
  Widget build(BuildContext context) {
    bool isMe = APIs.user.uid == widget.message.fromId ;
    return InkWell(
      onLongPress: (){
        _showBottomSheet();
      },
      child: isMe ? _greenMessage() : _blueMessage(),);
  }
  // sender or another user message
  Widget _blueMessage(){

    //update last message if sender and receiver are different
    if(widget.message.read.isEmpty){
      APIs.updateMessageReadStatus(widget.message);
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      // message content
      children: [
        Flexible(
          child: Container(
            padding: EdgeInsets.all(widget.message.type == Type.image
                ? mq.width*.03
                :mq.width * .04),
            margin: EdgeInsets.symmetric(horizontal: mq.width *.04, vertical: mq.height*.01),
            decoration: BoxDecoration(color: Colors.blue,
              border: Border.all(color: Colors.deepPurpleAccent),
              // making border curved
                borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
              bottomRight: Radius.circular(30))),
            child:
                widget.message.type == Type.text ?
                    // show text
            Text(
              widget.message.msg,
            style: const TextStyle(fontSize: 15, color: Colors.black87),
            )
                    :
                // show image
                ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: CachedNetworkImage(
                    imageUrl:widget.message.msg,
                    placeholder: (context,url)=>Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: CircularProgressIndicator(strokeWidth: 4),
                    ),
                    errorWidget: (context, url ,error)=>
                    const Icon(Icons.image, size: 70,),
                  ),
                ),
          ),
        ),

        Padding(
          padding:  EdgeInsets.only(right: mq.width*.04),
          child:
          Text(
            MyDateUtil.getFormattedTime(context: context, time: widget.message.sent),
          style: TextStyle(fontSize: 13,color: Colors.black54),),
        )
      ],
    );
  }

  //our or user message
  Widget _greenMessage(){
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      // message content
      children: [
        //message time
        Row(
          children: [
            //for adding some space
            SizedBox(width: mq.width *.04),

            //double tick blue icon for message read
            if(widget.message.read.isNotEmpty)
            const Icon(Icons.done_all_rounded, color: Colors.blue,size: 20),

            //for adding some space
            const SizedBox(width: 2,),

            //sent time
            Text(
              MyDateUtil.getFormattedTime(context: context, time: widget.message.sent),
              style: TextStyle(fontSize: 13,color: Colors.black54),
            ),
          ],
        ),
        Flexible(
          child: Container(
            padding: EdgeInsets.all(widget.message.type == Type.image
                ? mq.width*.03
                : mq.width * .04),
            margin: EdgeInsets.symmetric(horizontal: mq.width *.04, vertical: mq.height*.01),
            decoration: BoxDecoration(color: Colors.lightGreen,
                border: Border.all(color: Colors.lightGreen),
                // making border curved
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                    bottomLeft: Radius.circular(30))),
            child: widget.message.type == Type.text ?
            // show text
            Text(
              widget.message.msg,
              style: const TextStyle(fontSize: 15, color: Colors.black87),
            )
                :
            // show image
            ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: CachedNetworkImage(
                imageUrl:widget.message.msg,
                placeholder: (context,url)=>Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CircularProgressIndicator(strokeWidth: 4),
                ),
                errorWidget: (context, url ,error)=>
                const Icon(Icons.image, size: 70,),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // bottom sheet for picking a profile picture for user
  void _showBottomSheet(){
    showModalBottomSheet(context: context,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20))),
        builder: (_) {
          return ListView(
            shrinkWrap: true,

            children: [
              //black divider
              Container(
                height: 4,
                margin: EdgeInsets.symmetric(vertical: mq.height*.015,horizontal: mq.width*.4),
                decoration:BoxDecoration(color: Colors.grey,borderRadius: BorderRadius.circular(8)) ,
              ),
              _OptionItem(
                  icon: Icon(Icons.copy_all_rounded,color: Colors.blue,size: 26,),
                  name: 'Copy Text',
                  onTap:(){}),
            ],
          );
        });

  }

}
class _OptionItem extends StatelessWidget {
  final Icon icon;
  final String name;
  final VoidCallback onTap;
  
  const _OptionItem({required this.icon, required this.name, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onTap(),
        child: Padding(
        padding: EdgeInsets.only(
            left: mq.width*.05,
            top: mq.height*.015,
            bottom: mq.height*.025),
        child: Row(children: [icon,Flexible(child: Text('     $name',
            style: TextStyle(fontSize: 15,color: Colors.black54,letterSpacing: 0.5)))
            ]),
      ));
  }
}


