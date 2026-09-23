import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:wechat/helper/my_date_util.dart';
import 'package:wechat/models/call.dart';
import '../main.dart';

class CallCard extends StatelessWidget {
  final Call call;

  const CallCard({super.key, required this.call});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(mq.height * .3),
        child: CachedNetworkImage(
          width: mq.height * .055,
          height: mq.height * .055,
          fit: BoxFit.cover,
          imageUrl: call.callerImage,
          errorWidget: (context, url, error) =>
              const CircleAvatar(child: Icon(CupertinoIcons.person)),
        ),
      ),
      title: Text(call.callerName,
          style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: Row(
        children: [
          Icon(
              call.status == 'missed'
                  ? CupertinoIcons.phone_fill_arrow_down_left
                  : CupertinoIcons.phone_fill_arrow_up_right,
              size: 16,
              color: call.status == 'missed' ? Colors.red : Colors.green),
          const SizedBox(width: 5),
          Text(
              MyDateUtil.getLastMessageTime(context: context, time: call.time),
              style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color)),
        ],
      ),
      trailing: Icon(
          call.type == 'video'
              ? CupertinoIcons.video_camera_solid
              : CupertinoIcons.phone_fill,
          color: Colors.blue),
    );
  }
}
