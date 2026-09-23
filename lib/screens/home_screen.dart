import 'dart:io';
import 'dart:developer' as dev;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import '../api/apis.dart';
import '../main.dart';
import '../models/chat_user.dart';
import '../models/status.dart';
import '../models/call.dart';
import '../widgets/chat_user_card.dart';
import '../widgets/status_card.dart';
import '../widgets/call_card.dart';
import 'profile_screen.dart';

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

  // active navigation tab index
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    APIs.getSelfInfo();

    // for updating user active status according to lifecycle events
    SystemChannels.lifecycle.setMessageHandler((message) {
      dev.log('Message : $message');

      if (APIs.auth.currentUser != null) {
        if (message.toString().contains('resume')) {
          APIs.updateActiveStatus(true);
        }
        if (message.toString().contains('pause')) {
          APIs.updateActiveStatus(false);
        }
      }
      return Future.value(message);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) {
          if (didPop) return;
          if (isSearching) {
            setState(() {
              isSearching = !isSearching;
            });
          } else {
            SystemNavigator.pop();
          }
        },
        child: Scaffold(
          // app bar
          appBar: AppBar(
            leading: Padding(
              padding: const EdgeInsets.only(left: 14),
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => ProfileScreen(user: APIs.me)));
                },
                child: Center(
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFF6C5CE7).withValues(alpha: 0.5),
                        width: 2,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(100),
                      child: CachedNetworkImage(
                        width: 36,
                        height: 36,
                        fit: BoxFit.cover,
                        imageUrl: APIs.me.image,
                        errorWidget: (context, url, error) =>
                            const CircleAvatar(
                          radius: 18,
                          child: Icon(CupertinoIcons.person, size: 18),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            title: isSearching
                ? TextField(
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Search people...',
                      hintStyle: TextStyle(
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                        fontSize: 16,
                      ),
                    ),
                    autofocus: true,
                    style: TextStyle(
                      fontSize: 16,
                      letterSpacing: 0.3,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    onChanged: (val) {
                      searchList.clear();
                      for (var i in list) {
                        if (i.name.toLowerCase().contains(val.toLowerCase()) ||
                            i.email.toLowerCase().contains(val.toLowerCase())) {
                          searchList.add(i);
                        }
                      }
                      setState(() {});
                    },
                  )
                : const Text(
                    'Buddy Chat',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
            actions: [
              // search button
              IconButton(
                onPressed: () {
                  setState(() {
                    isSearching = !isSearching;
                  });
                },
                icon: Icon(
                  isSearching
                      ? CupertinoIcons.clear_circled_solid
                      : CupertinoIcons.search,
                  size: 22,
                ),
              ),

              // theme toggle button
              IconButton(
                onPressed: _showThemeDialog,
                icon: const Icon(CupertinoIcons.circle_lefthalf_fill, size: 22),
              ),

              // popup menu
              PopupMenuButton<String>(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                icon: const Icon(CupertinoIcons.ellipsis_vertical, size: 20),
                onSelected: (value) {
                  if (value == 'profile') {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => ProfileScreen(user: APIs.me)));
                  } else if (value == 'theme') {
                    _showThemeDialog();
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'profile',
                    child: Row(
                      children: [
                        Icon(CupertinoIcons.person_circle, size: 20),
                        SizedBox(width: 10),
                        Text('Profile'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'theme',
                    child: Row(
                      children: [
                        Icon(CupertinoIcons.circle_lefthalf_fill, size: 20),
                        SizedBox(width: 10),
                        Text('Theme'),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 4),
            ],
          ),

          // body content based on selected tab
          body: IndexedStack(
            index: _selectedIndex,
            children: [
              _chatsTab(),
              _statusTab(),
              _callsTab(),
            ],
          ),

          // modern bottom navigation bar
          bottomNavigationBar: _modernBottomNav(isDark),

          // contextual floating button
          floatingActionButton: Padding(
            padding: const EdgeInsets.only(bottom: 75),
            child: FloatingActionButton(
              elevation: 4,
              backgroundColor: const Color(0xFF6C5CE7),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18)),
              onPressed: () async {
                if (_selectedIndex == 1) {
                  // pick image for status
                  final ImagePicker picker = ImagePicker();
                  final XFile? image = await picker.pickImage(
                      source: ImageSource.gallery, imageQuality: 80);
                  if (image != null) {
                    await APIs.addStatus(File(image.path));
                  }
                } else if (_selectedIndex == 0) {
                  setState(() => isSearching = true);
                }
              },
              child: Icon(_selectedIndex == 1
                  ? CupertinoIcons.camera_fill
                  : CupertinoIcons.chat_bubble_text_fill),
            ),
          ),
        ),
      ),
    );
  }

  // Modern Floating Bottom Navigation Bar
  Widget _modernBottomNav(bool isDark) {
    return Container(
      margin: EdgeInsets.only(
        left: mq.width * 0.05,
        right: mq.width * 0.05,
        bottom: mq.height * 0.02,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF161622) : Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.black.withValues(alpha: 0.05),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _navButton(0, CupertinoIcons.chat_bubble_2,
              CupertinoIcons.chat_bubble_2_fill, 'Chats'),
          _navButton(1, CupertinoIcons.circle_grid_hex,
              CupertinoIcons.circle_grid_hex_fill, 'Stories'),
          _navButton(
              2, CupertinoIcons.phone, CupertinoIcons.phone_fill, 'Calls'),
        ],
      ),
    );
  }

  Widget _navButton(
      int index, IconData outlineIcon, IconData filledIcon, String label) {
    final isSelected = _selectedIndex == index;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        padding: EdgeInsets.symmetric(
            horizontal: isSelected ? 18 : 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF6C5CE7).withValues(alpha: 0.14)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? filledIcon : outlineIcon,
              color: isSelected
                  ? const Color(0xFF6C5CE7)
                  : Theme.of(context).textTheme.bodyMedium?.color,
              size: 22,
            ),
            if (isSelected) ...[
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: Color(0xFF6C5CE7),
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }

  // Chats Tab with Stories carousel at top
  Widget _chatsTab() {
    return Column(
      children: [
        // Horizontal Stories Carousel
        _storiesCarousel(),

        const SizedBox(height: 6),

        // Chat list stream
        Expanded(
          child: StreamBuilder(
            stream: APIs.getAllUsers(),
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.waiting:
                case ConnectionState.none:
                  return const Center(child: CircularProgressIndicator());
                case ConnectionState.active:
                case ConnectionState.done:
                  final data = snapshot.data?.docs;
                  list = data
                          ?.map((e) => ChatUser.fromJson(e.data()))
                          .toList() ??
                      [];

                  if (list.isNotEmpty) {
                    return ListView.builder(
                        itemCount:
                            isSearching ? searchList.length : list.length,
                        padding: const EdgeInsets.only(top: 4, bottom: 80),
                        physics: const BouncingScrollPhysics(),
                        itemBuilder: (context, index) {
                          return ChatUserCard(
                              user: isSearching
                                  ? searchList[index]
                                  : list[index]);
                        });
                  } else {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(CupertinoIcons.chat_bubble_2,
                              size: 60,
                              color: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.color
                                  ?.withValues(alpha: 0.4)),
                          const SizedBox(height: 12),
                          Text(
                            'No Connections Found!',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.color,
                            ),
                          ),
                        ],
                      ),
                    );
                  }
              }
            },
          ),
        ),
      ],
    );
  }

  // Top Stories Tray
  Widget _storiesCarousel() {
    return SizedBox(
      height: 100,
      child: StreamBuilder(
        stream: APIs.getAllStatuses(),
        builder: (context, snapshot) {
          final data = snapshot.data?.docs;
          final statusList =
              data?.map((e) => Status.fromJson(e.data())).toList() ?? [];

          return ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 14),
            itemCount: statusList.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                // "My Story" button
                return Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: GestureDetector(
                    onTap: () async {
                      final ImagePicker picker = ImagePicker();
                      final XFile? image = await picker.pickImage(
                          source: ImageSource.gallery, imageQuality: 80);
                      if (image != null) {
                        await APIs.addStatus(File(image.path));
                      }
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Stack(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(2.5),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: const Color(0xFF6C5CE7)
                                      .withValues(alpha: 0.3),
                                  width: 1.5,
                                ),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(100),
                                child: CachedNetworkImage(
                                  width: 54,
                                  height: 54,
                                  fit: BoxFit.cover,
                                  imageUrl: APIs.me.image,
                                  errorWidget: (context, url, error) =>
                                      const CircleAvatar(
                                    radius: 27,
                                    child: Icon(CupertinoIcons.person),
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.all(3),
                                decoration: const BoxDecoration(
                                  color: Color(0xFF6C5CE7),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.add,
                                  color: Colors.white,
                                  size: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        const Text(
                          'Your story',
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              // Contact Story
              final status = statusList[index - 1];
              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: GestureDetector(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (_) => Scaffold(
                        backgroundColor: Colors.black,
                        appBar: AppBar(
                          backgroundColor: Colors.black,
                          iconTheme:
                              const IconThemeData(color: Colors.white),
                        ),
                        body: Center(
                          child: CachedNetworkImage(
                            imageUrl: status.imageUrl,
                            placeholder: (context, url) =>
                                const CircularProgressIndicator(),
                          ),
                        ),
                      ),
                    );
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(2.5),
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [
                              Color(0xFF6C5CE7),
                              Color(0xFFFF7675),
                              Color(0xFFFDCB6E),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(1.5),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Theme.of(context).scaffoldBackgroundColor,
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(100),
                            child: CachedNetworkImage(
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                              imageUrl: status.userImage,
                              errorWidget: (context, url, error) =>
                                  const CircleAvatar(
                                radius: 25,
                                child: Icon(CupertinoIcons.person),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 5),
                      SizedBox(
                        width: 65,
                        child: Text(
                          status.userName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  // Status Tab
  Widget _statusTab() {
    return Column(
      children: [
        ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
          leading: Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(mq.height * .3),
                child: CachedNetworkImage(
                  width: 54,
                  height: 54,
                  fit: BoxFit.cover,
                  imageUrl: APIs.me.image,
                  errorWidget: (context, url, error) =>
                      const CircleAvatar(child: Icon(CupertinoIcons.person)),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(3),
                  decoration: const BoxDecoration(
                      color: Color(0xFF6C5CE7), shape: BoxShape.circle),
                  child:
                      const Icon(Icons.add, color: Colors.white, size: 14),
                ),
              )
            ],
          ),
          title: const Text('My Status',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
          subtitle: Text('Tap to add status update',
              style: TextStyle(
                  color: Theme.of(context).textTheme.bodySmall?.color)),
          onTap: () async {
            final ImagePicker picker = ImagePicker();
            final XFile? image = await picker.pickImage(
                source: ImageSource.gallery, imageQuality: 80);
            if (image != null) {
              await APIs.addStatus(File(image.path));
            }
          },
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text('Recent updates',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    letterSpacing: 0.5,
                    color: Theme.of(context).colorScheme.primary)),
          ),
        ),
        Expanded(
          child: StreamBuilder(
            stream: APIs.getAllStatuses(),
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.waiting:
                case ConnectionState.none:
                  return const SizedBox();
                case ConnectionState.active:
                case ConnectionState.done:
                  final data = snapshot.data?.docs;
                  final statusList = data
                          ?.map((e) => Status.fromJson(e.data()))
                          .toList() ??
                      [];

                  if (statusList.isNotEmpty) {
                    return ListView.builder(
                        itemCount: statusList.length,
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.only(bottom: 80),
                        itemBuilder: (context, index) {
                          return StatusCard(status: statusList[index]);
                        });
                  } else {
                    return const Center(
                        child: Text('No statuses yet!',
                            style: TextStyle(fontSize: 16)));
                  }
              }
            },
          ),
        ),
      ],
    );
  }

  // Calls Tab
  Widget _callsTab() {
    return StreamBuilder(
      stream: APIs.getCallHistory(),
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
          case ConnectionState.none:
            return const Center(child: CircularProgressIndicator());
          case ConnectionState.active:
          case ConnectionState.done:
            final data = snapshot.data?.docs;
            final callList =
                data?.map((e) => Call.fromJson(e.data())).toList() ?? [];

            if (callList.isNotEmpty) {
              return ListView.builder(
                  itemCount: callList.length,
                  padding: const EdgeInsets.only(top: 8, bottom: 80),
                  physics: const BouncingScrollPhysics(),
                  itemBuilder: (context, index) {
                    return CallCard(call: callList[index]);
                  });
            } else {
              return const Center(
                  child: Text('No call logs found!',
                      style: TextStyle(fontSize: 16)));
            }
        }
      },
    );
  }

  // show theme selection dialog
  void _showThemeDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Select Theme',
            style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
              leading: const Icon(CupertinoIcons.sun_max_fill,
                  color: Colors.amber),
              title: const Text('Light'),
              trailing: themeNotifier.value == ThemeMode.light
                  ? const Icon(CupertinoIcons.checkmark_alt,
                      color: Color(0xFF6C5CE7))
                  : null,
              onTap: () {
                themeNotifier.value = ThemeMode.light;
                Navigator.pop(context);
              },
            ),
            ListTile(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
              leading: const Icon(CupertinoIcons.moon_fill,
                  color: Color(0xFF6C5CE7)),
              title: const Text('Dark'),
              trailing: themeNotifier.value == ThemeMode.dark
                  ? const Icon(CupertinoIcons.checkmark_alt,
                      color: Color(0xFF6C5CE7))
                  : null,
              onTap: () {
                themeNotifier.value = ThemeMode.dark;
                Navigator.pop(context);
              },
            ),
            ListTile(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
              leading: const Icon(CupertinoIcons.device_phone_portrait),
              title: const Text('System Default'),
              trailing: themeNotifier.value == ThemeMode.system
                  ? const Icon(CupertinoIcons.checkmark_alt,
                      color: Color(0xFF6C5CE7))
                  : null,
              onTap: () {
                themeNotifier.value = ThemeMode.system;
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
