import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wechat/api/apis.dart';
import 'package:wechat/helper/dialogs.dart';
import 'package:wechat/helper/my_date_util.dart';
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
    bool isMe = APIs.user.uid == widget.message.fromId;
    return InkWell(
      onLongPress: () {
        _showBottomSheet();
      },
      child: isMe ? _outgoingMessage() : _incomingMessage(),
    );
  }

  // Incoming / Received message
  Widget _incomingMessage() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // update last message read status if sender and receiver are different
    if (widget.message.read.isEmpty) {
      APIs.updateMessageReadStatus(widget.message);
    }

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: mq.width * .03,
        vertical: 3,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Flexible(
            child: Container(
              padding: EdgeInsets.all(widget.message.type == Type.image ? 6 : 12),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(18),
                  topRight: Radius.circular(18),
                  bottomRight: Radius.circular(18),
                  bottomLeft: Radius.circular(4),
                ),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.08)
                      : Colors.black.withValues(alpha: 0.05),
                  width: 1,
                ),
                boxShadow: isDark
                    ? []
                    : [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        )
                      ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  widget.message.type == Type.text
                      ? Text(
                          widget.message.msg,
                          style: TextStyle(
                            fontSize: 15.5,
                            height: 1.3,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        )
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: CachedNetworkImage(
                            imageUrl: widget.message.msg,
                            placeholder: (context, url) => const Padding(
                              padding: EdgeInsets.all(24.0),
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                            errorWidget: (context, url, error) =>
                                const Icon(Icons.image, size: 70),
                          ),
                        ),
                  const SizedBox(height: 3),
                  Text(
                    MyDateUtil.getFormattedTime(
                        context: context, time: widget.message.sent),
                    style: TextStyle(
                      fontSize: 10,
                      color: Theme.of(context).textTheme.bodySmall?.color,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 40),
        ],
      ),
    );
  }

  // Outgoing / Sent message
  Widget _outgoingMessage() {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: mq.width * .03,
        vertical: 3,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const SizedBox(width: 40),
          Flexible(
            child: Container(
              padding: EdgeInsets.all(widget.message.type == Type.image ? 6 : 12),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF6C5CE7),
                    Color(0xFF8E44AD),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(18),
                  topRight: Radius.circular(18),
                  bottomLeft: Radius.circular(18),
                  bottomRight: Radius.circular(4),
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF6C5CE7).withValues(alpha: 0.28),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  )
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  widget.message.type == Type.text
                      ? Text(
                          widget.message.msg,
                          style: const TextStyle(
                            fontSize: 15.5,
                            height: 1.3,
                            color: Colors.white,
                          ),
                        )
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: CachedNetworkImage(
                            imageUrl: widget.message.msg,
                            placeholder: (context, url) => const Padding(
                              padding: EdgeInsets.all(24.0),
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white),
                            ),
                            errorWidget: (context, url, error) => const Icon(
                                Icons.image,
                                size: 70,
                                color: Colors.white),
                          ),
                        ),
                  const SizedBox(height: 3),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        MyDateUtil.getFormattedTime(
                            context: context, time: widget.message.sent),
                        style: const TextStyle(
                            fontSize: 10, color: Colors.white70),
                      ),
                      const SizedBox(width: 4),
                      if (widget.message.read.isNotEmpty)
                        const Icon(CupertinoIcons.checkmark_seal_fill,
                            color: Colors.white, size: 13)
                      else
                        const Icon(CupertinoIcons.checkmark,
                            color: Colors.white70, size: 13),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Modern bottom sheet with Emoji Reactions & Action items
  void _showBottomSheet() {
    bool isMe = APIs.user.uid == widget.message.fromId;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF161622) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      builder: (_) {
        return SafeArea(
          child: ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.symmetric(vertical: 12),
            children: [
              // Top drag pill
              Center(
                child: Container(
                  height: 4,
                  width: 40,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white24 : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),

              const SizedBox(height: 14),

              // Quick Emoji Reactions Row
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF20202F)
                        : const Color(0xFFF1F2F6),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: ['❤️', '👍', '😂', '🔥', '😮', '🎉'].map((emoji) {
                      return GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                          Dialogs.showSnackBar(
                              context, 'Reacted $emoji to message');
                        },
                        child: Text(
                          emoji,
                          style: const TextStyle(fontSize: 26),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // Copy text option
              if (widget.message.type == Type.text)
                _OptionItem(
                  icon: const Icon(CupertinoIcons.doc_on_doc,
                      color: Color(0xFF6C5CE7), size: 22),
                  name: 'Copy Text',
                  onTap: () async {
                    await Clipboard.setData(
                        ClipboardData(text: widget.message.msg));
                    if (context.mounted) {
                      Navigator.pop(context);
                      Dialogs.showSnackBar(context, 'Text Copied!');
                    }
                  },
                ),

              // Edit option (if sent by me)
              if (widget.message.type == Type.text && isMe)
                _OptionItem(
                  icon: const Icon(CupertinoIcons.pencil,
                      color: Color(0xFF6C5CE7), size: 22),
                  name: 'Edit Message',
                  onTap: () {
                    Navigator.pop(context);
                    _showMessageUpdateDialog();
                  },
                ),

              // Delete option (if sent by me)
              if (isMe)
                _OptionItem(
                  icon: const Icon(CupertinoIcons.trash,
                      color: Colors.redAccent, size: 22),
                  name: 'Delete Message',
                  onTap: () async {
                    await APIs.deleteMessage(widget.message);
                    if (context.mounted) {
                      Navigator.pop(context);
                      Dialogs.showSnackBar(context, 'Message Deleted!');
                    }
                  },
                ),

              Divider(
                color: isDark ? Colors.white12 : Colors.black12,
                indent: 20,
                endIndent: 20,
              ),

              // Sent timestamp
              _OptionItem(
                icon: const Icon(CupertinoIcons.clock,
                    color: Color(0xFF6C5CE7), size: 22),
                name:
                    'Sent: ${MyDateUtil.getMessageTime(context: context, time: widget.message.sent)}',
                onTap: () {},
              ),

              // Read timestamp
              _OptionItem(
                icon: const Icon(CupertinoIcons.checkmark_seal_fill,
                    color: Colors.green, size: 22),
                name: widget.message.read.isEmpty
                    ? 'Read: Not seen yet'
                    : 'Read: ${MyDateUtil.getMessageTime(context: context, time: widget.message.read)}',
                onTap: () {},
              ),
            ],
          ),
        );
      },
    );
  }

  // Dialog for updating message content
  void _showMessageUpdateDialog() {
    String updatedMsg = widget.message.msg;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        contentPadding:
            const EdgeInsets.only(left: 24, right: 24, top: 20, bottom: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(
              CupertinoIcons.bubble_left_bubble_right,
              color: Color(0xFF6C5CE7),
              size: 24,
            ),
            SizedBox(width: 10),
            Text('Update Message',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          ],
        ),
        content: TextFormField(
          initialValue: updatedMsg,
          maxLines: null,
          onChanged: (value) => updatedMsg = value,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(fontSize: 16)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6C5CE7),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              Navigator.pop(context);
              APIs.updateMessage(widget.message, updatedMsg);
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }
}

class _OptionItem extends StatelessWidget {
  final Icon icon;
  final String name;
  final VoidCallback onTap;

  const _OptionItem(
      {required this.icon, required this.name, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          children: [
            icon,
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                name,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
