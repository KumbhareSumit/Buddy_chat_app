import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:wechat/api/apis.dart';
import 'package:wechat/helper/my_date_util.dart';
import 'package:wechat/models/chat_user.dart';
import 'package:wechat/models/message.dart';
import 'package:wechat/widgets/dialogs/profile_dialog.dart';

import '../main.dart';
import '../screens/chat_screen.dart';

class ChatUserCard extends StatefulWidget {
  final ChatUser user;
  const ChatUserCard({super.key, required this.user});

  @override
  State<ChatUserCard> createState() => _ChatUserCardState();
}

class _ChatUserCardState extends State<ChatUserCard> {
  // last message info (if null --> no message)
  Message? _message;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: mq.width * .035, vertical: 5),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.06)
              : Colors.black.withValues(alpha: 0.04),
          width: 1,
        ),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => ChatScreen(user: widget.user)));
          },
          child: StreamBuilder(
            stream: APIs.getLastMessage(widget.user),
            builder: (context, snapshot) {
              final data = snapshot.data?.docs;
              final list =
                  data?.map((e) => Message.fromJson(e.data())).toList() ?? [];
              if (list.isNotEmpty) _message = list[0];

              final hasUnread = _message != null &&
                  _message!.read.isEmpty &&
                  _message!.fromId != APIs.user.uid;

              return Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                child: Row(
                  children: [
                    // user avatar with online indicator
                    GestureDetector(
                      onTap: () {
                        showDialog(
                            context: context,
                            builder: (_) => ProfileDialog(
                                  user: widget.user,
                                ));
                      },
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(mq.height * .3),
                            child: Hero(
                              tag: 'profile_${widget.user.id}',
                              child: CachedNetworkImage(
                                width: mq.height * .065,
                                height: mq.height * .065,
                                fit: BoxFit.cover,
                                imageUrl: widget.user.image,
                                placeholder: (context, url) => Container(
                                  width: mq.height * .065,
                                  height: mq.height * .065,
                                  color: Colors.grey.withValues(alpha: 0.1),
                                  child: const Center(
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2),
                                  ),
                                ),
                                errorWidget: (context, url, error) =>
                                    CircleAvatar(
                                  radius: mq.height * .0325,
                                  backgroundColor: const Color(0xFF6C5CE7)
                                      .withValues(alpha: 0.15),
                                  child: const Icon(CupertinoIcons.person_fill,
                                      color: Color(0xFF6C5CE7)),
                                ),
                              ),
                            ),
                          ),
                          if (widget.user.isOnline)
                            Positioned(
                              bottom: 1,
                              right: 1,
                              child: Container(
                                width: 14,
                                height: 14,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF00E676),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Theme.of(context).cardColor,
                                    width: 2.5,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 14),

                    // user name & last message preview
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.user.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontWeight:
                                  hasUnread ? FontWeight.w800 : FontWeight.w700,
                              fontSize: 16,
                              letterSpacing: -0.2,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Row(
                            children: [
                              if (_message != null &&
                                  _message!.fromId == APIs.user.uid) ...[
                                Icon(
                                  _message!.read.isNotEmpty
                                      ? CupertinoIcons.checkmark_seal_fill
                                      : CupertinoIcons.checkmark,
                                  size: 14,
                                  color: _message!.read.isNotEmpty
                                      ? const Color(0xFF6C5CE7)
                                      : Colors.grey,
                                ),
                                const SizedBox(width: 4),
                              ],
                              if (_message != null &&
                                  _message!.type == Type.image) ...[
                                const Icon(CupertinoIcons.photo,
                                    size: 14, color: Color(0xFF6C5CE7)),
                                const SizedBox(width: 4),
                              ],
                              Expanded(
                                child: Text(
                                  _message != null
                                      ? _message!.type == Type.image
                                          ? 'Photo'
                                          : _message!.msg
                                      : widget.user.about,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 13.5,
                                    fontWeight: hasUnread
                                        ? FontWeight.w600
                                        : FontWeight.normal,
                                    color: hasUnread
                                        ? Theme.of(context).colorScheme.onSurface
                                        : Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.color,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 10),

                    // timestamp & unread badge
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        if (_message != null)
                          Text(
                            MyDateUtil.getLastMessageTime(
                                context: context, time: _message!.sent),
                            style: TextStyle(
                              color: hasUnread
                                  ? const Color(0xFF6C5CE7)
                                  : Theme.of(context).textTheme.bodySmall?.color,
                              fontSize: 11.5,
                              fontWeight:
                                  hasUnread ? FontWeight.w700 : FontWeight.w500,
                            ),
                          ),
                        const SizedBox(height: 6),
                        if (hasUnread)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 7, vertical: 2.5),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF6C5CE7), Color(0xFF8E44AD)],
                              ),
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF6C5CE7)
                                      .withValues(alpha: 0.3),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                )
                              ],
                            ),
                            child: const Text(
                              '1',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          )
                        else
                          const SizedBox(height: 16),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
