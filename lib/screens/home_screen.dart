//import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:wechat/models/chat_user.dart';
import 'package:wechat/screens/profile_screen.dart';
import 'package:wechat/widgets/chat_user_card.dart';
import '../api/apis.dart';
import '../main.dart';
import 'dart:developer' as dev;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // for storing all users
  List<ChatUser> list = [];

  // for storing searched items
  final List<ChatUser> searchList = [];
  // for storing search status
  bool isSearching = false;

  @override
  void initState() {
    super.initState();
    APIs.getSelfInfo();


    //for updateing user active status according to lifecycle events
    //resume -- active or online
    //pause -- inactive or offline
    SystemChannels.lifecycle.setMessageHandler((message){
      dev.log('Message : $message');

      if(APIs.auth.currentUser != null){
        if(message.toString().contains('resume')){
          APIs.updateActiveStatus(true);}
          if(message.toString().contains('pause')){
            APIs.updateActiveStatus(false);
        }
      }
      return Future.value(message);
    });
  }

  @override
  Widget build(BuildContext context) {

    return GestureDetector(
      // for hiding keyboard when tap is detected on screen
      onTap: () => FocusScope.of(context).unfocus(),
      child: WillPopScope(
        onWillPop: () {
          if(isSearching){
            setState(() {
              isSearching =! isSearching;
            });
            return Future.value(false);

          }else{
            return Future.value(true);
          }


        },
        child: Scaffold(
          //app bar
          appBar: AppBar(
            leading: Icon(CupertinoIcons.home),
            title: isSearching ? TextField(
              decoration: const InputDecoration(
                  border: InputBorder.none ,hintText: 'Name,Email,.... '),
              autofocus: true,
              style: TextStyle(fontSize: 17, letterSpacing: 0.5,color: Colors.white),
              //when search text changes then upload search list
              onChanged: (val){
                //search logic
                searchList.clear();

                for(var i in list){
                  if(i.name.toLowerCase().contains(val.toLowerCase()) || i.email.toLowerCase().contains(val.toLowerCase())){}
                  searchList.add(i);
                }
                setState(() {
                  searchList;
                });
              },

            ) : Text('Buddy Chat'),
            actions: [
              //search user button
              IconButton(onPressed: (){
              setState(() {
               isSearching = ! isSearching;
              });
              },
                  icon: Icon(isSearching ?
              CupertinoIcons.clear_circled_solid:
              Icons.search)),


              // more features button
              IconButton(onPressed: (){
                Navigator.push(
                    context, MaterialPageRoute(
                    builder: (_) => ProfileScreen(user:APIs.me)));
              },
                  icon: Icon(Icons.more_vert))
            ],
          ),
          //floating button to add new user
          floatingActionButton: Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: FloatingActionButton(
              onPressed: () async{
              await APIs.auth.signOut();
              await GoogleSignIn().signOut();
            },
            child: const Icon(Icons.add_comment_rounded)
            ),
          ),
          // body
          body: StreamBuilder(
            stream: APIs.getAllUsers(),
            builder:(context, snapshot) {
              switch(snapshot.connectionState){
                // data is loading
                case ConnectionState.waiting:
                case ConnectionState.none:
                  return const Center(child: CircularProgressIndicator(),);
                // if some or all data is loaded then show it
                case ConnectionState.active:
                case ConnectionState.done:




                  final data = snapshot.data?.docs;
                  list = data?.map((e) => ChatUser.fromJson(e.data())).toList() ?? [];



                if(list.isNotEmpty){
                  return ListView.builder(
                      itemCount: isSearching ? searchList.length:list.length,
                      padding: EdgeInsets.only(top: mq.height * .01),
                      physics: BouncingScrollPhysics(),
                      itemBuilder: (context, index) {
                        return  ChatUserCard(user: isSearching ? searchList[index] : list[index]);
                        // return Text('Name: ${list[index]}');
                      });
                }else{
                  return const Center(
                      child: Text('NO Connection Found !',style: TextStyle(fontSize: 20),));
                }
              }


            },
          ),
        ),
      ),
    );
  }
}
