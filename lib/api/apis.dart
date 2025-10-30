//import 'dart:math';
import 'dart:convert';
import 'dart:developer' as dev;
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:http/http.dart';
import 'package:wechat/models/chat_user.dart';
import 'package:wechat/models/message.dart';
//import 'package:firebase_core/firebase_core.dart';

class APIs{
  // for authentication
  static FirebaseAuth auth = FirebaseAuth.instance;

  // for accessing cloud firestore database
  static FirebaseFirestore firestore = FirebaseFirestore.instance;

  // for accessing cloud firestore database
  static FirebaseStorage storage = FirebaseStorage.instance;

  // for storing self information
  static late ChatUser me;

  //to return current user
  static User get user => auth.currentUser!;

  //for accessing firebase message (push notifications)
  static FirebaseMessaging fMessaging = FirebaseMessaging.instance;

  //forgetting firebase messaging token
  static Future<void> getFirebaseMessagingToken()async{
      await fMessaging.requestPermission();

      fMessaging.getToken().then((t){
        if(t!=null){
          me.pushToken = t;
          dev.log('Push Token: $t');
        }
      });
      // FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      //   dev.log('Got a message whilst in the foreground!');
      //   dev.log('Message data: ${message.data}');
      //
      //   if (message.notification != null) {
      //     print('Message also contained a notification: ${message.notification}');
      //   }
      // });
  }
  
  //for sending push notifications
  static Future<void> sendPushNotification(ChatUser chatUser, String msg) async {


    try{final body = {
      "to": chatUser.pushToken,
      "notification": {
        "title": chatUser.name,
        "body": msg,"android_channel_id": "chats",
      },
      "data": {
        "some_data" : "User ID: ${me.id}",
      },
    };

    var response = await post(Uri.parse('https://fcm.googleapis.com/fcm/send'),
        headers: {
          HttpHeaders.contentTypeHeader: 'application/json',
          HttpHeaders.authorizationHeader:''
        },
        body: jsonEncode(body));
    dev.log('Response status: ${response.statusCode}');
    dev.log('Response body: ${response.body}');}
    catch(e){
      dev.log('\nsendPushNotificationE: $e');
    }
  }
  

  //for checking if user exits or not ?
  static Future<bool> userExists() async {
    return (await firestore
        .collection('users')
        .doc(user.uid)
        .get())
        .exists;
  }
  // for getting current user info
  static Future<void> getSelfInfo() async {
    await firestore
        .collection('users')
        .doc(user.uid)
        .get()
        .then((userDoc) async {
      if (userDoc.exists) {
        // initialize 'me' first
        me = ChatUser.fromJson(userDoc.data()!);

        // then get token and update status
        await getFirebaseMessagingToken();
        updateActiveStatus(true);

        dev.log('My Data: ${userDoc.data()}');
      } else {
        await createUser().then((value) => getSelfInfo());
      }
    });
  }


  //for creating a new user
  static Future<void> createUser() async {
    final time = DateTime.now().microsecondsSinceEpoch.toString();


    final chatUser = ChatUser(
      id: user.uid,
      name: user.displayName.toString(),
      email: user.email.toString(),
      about: "hey, i'm using Buddy Chat",
      image: user.photoURL.toString(),
      createdAt: time,
      isOnline: false,
      lastActive: time,
      pushToken: ''
    );

      return await firestore
          .collection('users')
          .doc(user.uid)
          .set(chatUser.toJson());

  }
  // for getting all users from firestore database
  static Stream<QuerySnapshot<Map<String, dynamic>>>getAllUsers(){
    return firestore
        .collection('users')
        .where('id',isNotEqualTo: user.uid)
        .snapshots();
  }
  //for checking if user exits or not ?
  static Future<void> updateUserInfo() async {
    await firestore
        .collection('users')
        .doc(user.uid)
        .update({
        'name': me.name,
        'about': me.about,
        });
  }
  // update profile picture of user
  static Future<void> updateProfilePicture(File file) async{

    final ext = file.path.split('.').last;
    dev.log('Extension: $ext');
    final ref = storage.ref().child('profile_picture/${user.uid}.$ext');
    await ref
        .putFile(file, SettableMetadata(contentType: 'image/$ext'))
        .then((p0)=>{
      dev.log('Data Transferred: ${p0.bytesTransferred / 1000} kb'),
    });
    me.image = await ref.getDownloadURL();
    await firestore
        .collection('users')
        .doc(user.uid)
        .update({
      'image': me.image
    });
  }
  // for getting user info
  static Stream<QuerySnapshot<Map<String,dynamic>>> getUserInfo(
      ChatUser chatUser){
    return firestore
        .collection('users')
        .where('id',isEqualTo: chatUser.id)
        .snapshots();
  }
  //update online or last active status user
  static Future<void> updateActiveStatus(bool isonline) async{
    await firestore.collection('users').doc(user.uid).update({
      'is_online': isonline,
      'last_active': DateTime.now().millisecondsSinceEpoch.toString(),
      'push_token': me.pushToken,
    });

  }

  ///******* chat screen related APIs *******

  // useful for getting conversation id
  static String getConversationID(String id) => user.uid.hashCode <= id.hashCode?
      '${user.uid}_$id' :
      '${id}_${user.uid}';

  // for getting all messages of a specific conversation from firestore database
  static Stream<QuerySnapshot<Map<String, dynamic>>>getAllMessages(ChatUser user){
    return firestore
        .collection('chats/${getConversationID(user.id)}/messages')
        .orderBy('sent',descending: true)
        .snapshots();
  }
  // for sending message
  static Future<void>sendMessage(ChatUser chatUser , String msg, Type type) async{
    // message sending time (also used as id)
    final time = DateTime.now().millisecondsSinceEpoch.toString();
    //message to send
    final Message message = Message(
        told: chatUser.id,
        msg: msg, read: '',
        type: type,
        fromId: user.uid,
        sent: time);
    final ref = firestore.collection('chats/${getConversationID(chatUser.id)}/messages');
    await ref.doc(time).set(message.toJson()).then((value) => sendPushNotification(chatUser,type == Type.text ? msg:'image'));
  }

  //update read status of message
  static Future<void>updateMessageReadStatus(Message message) async{
    firestore
        .collection('chats/${getConversationID(message.fromId)}/messages')
        .doc(message.sent)
        .update({'read':DateTime.now().millisecondsSinceEpoch.toString()});
  }

  // get only last message of a specific chat
  static Stream<QuerySnapshot<Map<String, dynamic>>>getLastMessage(
      ChatUser user) {
    return firestore
        .collection('chats/${getConversationID(user.id)}/messages/')
        .orderBy('sent',descending: true)
        .limit(1)
        .snapshots();
  }

  // send chat image
  static Future<void> sendChatImage(ChatUser chatUser , File file) async {
    final ext = file.path.split('.').last;

    final ref = storage.ref().child('images/${getConversationID(chatUser.id)}/${DateTime.now().millisecondsSinceEpoch}.$ext');
    await ref
        .putFile(file, SettableMetadata(contentType: 'image/$ext'))
        .then((p0)=>{
      dev.log('Data Transferred: ${p0.bytesTransferred / 1000} kb'),
    });
    //updating image in firestore database
    final imageUrl = await ref.getDownloadURL();
    await sendMessage(chatUser, imageUrl, Type.image);
  }
}
