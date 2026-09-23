import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:wechat/helper/my_date_util.dart';
import 'package:wechat/models/status.dart';
import '../main.dart';

class StatusCard extends StatelessWidget {
  final Status status;

  const StatusCard({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.blue, width: 2)),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(mq.height * .3),
          child: CachedNetworkImage(
            width: mq.height * .06,
            height: mq.height * .06,
            fit: BoxFit.cover,
            imageUrl: status.userImage,
            errorWidget: (context, url, error) =>
                const CircleAvatar(child: Icon(CupertinoIcons.person)),
          ),
        ),
      ),
      title: Text(status.userName,
          style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: Text(
          MyDateUtil.getLastMessageTime(context: context, time: status.createdAt),
          style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color)),
      onTap: () {
        // show status image in a dialog or new screen
        showDialog(
            context: context,
            builder: (_) => Scaffold(
                  backgroundColor: Colors.black,
                  appBar: AppBar(
                    backgroundColor: Colors.black,
                    iconTheme: const IconThemeData(color: Colors.white),
                  ),
                  body: Center(
                    child: CachedNetworkImage(
                      imageUrl: status.imageUrl,
                      placeholder: (context, url) =>
                          const CircularProgressIndicator(),
                    ),
                  ),
                ));
      },
    );
  }
}
