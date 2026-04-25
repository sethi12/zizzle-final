import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:zizzle/Ai/AiChatScreen.dart';
import 'package:zizzle/resources/firestoremethods.dart';
import 'package:zizzle/widgets/pulseloader.dart';
import 'package:zizzle/widgets/text_feild_input.dart';
import '/Screens/chat_screen.dart';
import '/services/alert_service.dart';
import '/services/auth_message_service.dart';
import '/services/database_service.dart';
import '/services/navigation_service.dart';
import '/utils/colors.dart';
import '../model/user.dart';
import '../widgets/chat_tile.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  final GetIt _getIt = GetIt.instance;
  late AuthService _authService;
  late Navigationservice _navigationservice;
  late AlertService _alertService;
  late DatabaseService _databaseService;
  late TextEditingController _createpasswordcontroller =
      TextEditingController();
  late TextEditingController _confirmpasswordcontroller =
      TextEditingController();
  late TextEditingController _checkpasswordcontroller = TextEditingController();
  @override
  void initState() {
    super.initState();
    _authService = _getIt.get<AuthService>();
    _navigationservice = _getIt.get<Navigationservice>();
    _alertService = _getIt.get<AlertService>();
    _databaseService = _getIt.get<DatabaseService>();
  }

  Future<Map<String, dynamic>> getLockedChatDetails(String? chatId) async {
    if (chatId == null || chatId.isEmpty) {
      print("Invalid chatId: $chatId");
      return {
        'locked': false,
        'password': null,
      }; // Allow proceeding to the chat page
    }

    try {
      final docSnapshot = await FirebaseFirestore.instance
          .collection("chats")
          .doc(chatId)
          .get();

      if (docSnapshot.exists) {
        final data = docSnapshot.data() as Map<String, dynamic>;
        return {
          'locked': data['locked'] as bool? ??
              false, // Default to false if not present
          'password': data['password'] as String?, // Password might be null
        };
      } else {
        print("Chat document does not exist for chatId: $chatId");
        return {
          'locked': false,
          'password': null,
        }; // Allow proceeding to the chat page
      }
    } catch (e) {
      print("Error fetching chat details: $e");
      return {
        'locked': false,
        'password': null,
      }; // Allow proceeding to the chat page in case of errors
    }
  }

  Future<Map<String, String?>> getChatIdsAndLastMessages() async {
    final String? myUid = _authService.getCurrentUser()?.uid;
    if (myUid == null) {
      print("User is not logged in");
      return {};
    }

    final QuerySnapshot chatSnapshot = await FirebaseFirestore.instance
        .collection("chats")
        .where("participants", arrayContains: myUid)
        .get();

    final Map<String, String?> chatData = {};
    for (var doc in chatSnapshot.docs) {
      final chatId = doc.id;
      final lastMessage = doc.data() as Map<String, dynamic>?;
      chatData[chatId] = lastMessage?['lastmessage'] as String?;
    }

    print("Chat Data: $chatData");
    return chatData;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Messages"),
        backgroundColor: mobileBackgroundColor,
      ),
      body: _buildUI(),
    );
  }

  @override
  Widget _buildUI() {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            // Main UI: The chats list
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 15.0, vertical: 20.0),
              child: _chatsList(),
            ),

            // Floating Action Button for AI Chat
            // Floating Action Button for AI Chat
            Positioned(
              right: 20,
              bottom: 20,
              child: FloatingActionButton(
                onPressed: () {
                  // Navigate to the Zizzle AI chat screen
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ZizzleAIChatScreen()),
                  );
                },
                backgroundColor: Colors.transparent,
                elevation: 0,
                shape: const CircleBorder(),
                child: Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.blue.shade500, Colors.purple.shade600],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons
                          .auto_awesome, // Modern and attractive AI-themed icon
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _chatsList() {
    return StreamBuilder<List<User>>(
      stream: _databaseService.getFollowingUsersStream(),
      builder: (context, AsyncSnapshot<List<User>> userSnapshot) {
        if (userSnapshot.hasError) {
          print("Snapshot has error: ${userSnapshot.error}");
          return Center(child: Text("Unable to load data"));
        }
        if (userSnapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: ParticleBurstLoaderr(),
          );
        }
        final combinedUsersList = userSnapshot.data;
        if (combinedUsersList != null && combinedUsersList.isNotEmpty) {
          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection("chats")
                .where("participants",
                    arrayContains: _authService.getCurrentUser()?.uid)
                .snapshots(),
            builder: (context, chatSnapshot) {
              if (chatSnapshot.connectionState == ConnectionState.waiting) {
                return Center(child: ParticleBurstLoaderr());
              } else if (chatSnapshot.hasError) {
                print("Chat Snapshot error: ${chatSnapshot.error}");
                return Text("Error loading chat data");
              } else {
                final chatDocs = chatSnapshot.data?.docs ?? [];
                final chatData = {
                  for (var doc in chatDocs)
                    doc.id: (doc.data() as Map<String, dynamic>)['lastmessage']
                        as String?
                };

                return ListView.builder(
                  itemCount: combinedUsersList.length,
                  itemBuilder: (context, index) {
                    final user = combinedUsersList[index];
                    final chatId = chatData.keys.firstWhere(
                        (id) => chatData[id] != null && id.contains(user.uid),
                        orElse: () => '');
                    final lastMessage = chatData[chatId];

                    // Determine if this is the current user's chat for special styling
                    final isCurrentUserChat =
                        user.uid == _authService.getCurrentUser()?.uid;

                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 8.0),
                      child: GestureDetector(
                        onLongPress: () {
                          showDialog(
                            context: context,
                            builder: (context) => Dialog(
                              backgroundColor: Colors
                                  .transparent, // Make dialog background transparent
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: BackdropFilter(
                                  filter: ImageFilter.blur(
                                      sigmaX: 15,
                                      sigmaY: 15), // Glassmorphism effect
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade900.withOpacity(
                                          0.8), // Dark translucent background
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                          color: Colors.white.withOpacity(
                                              0.1)), // Subtle border
                                    ),
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        ListTile(
                                          leading: const Icon(
                                              Icons.delete_sweep,
                                              color: Colors.redAccent),
                                          title: Text(
                                            "Delete Chat for ${user.username}",
                                            style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 16),
                                          ),
                                          onTap: () async {
                                            if (chatId.isNotEmpty) {
                                              String result =
                                                  await Firestoremethods()
                                                      .deletechat(chatId, "h");
                                              if (result == "done") {
                                                _alertService.showToast(
                                                    text:
                                                        "Chats Deleted for ${user.username}",
                                                    icon: Icons.check_circle);
                                              }
                                            } else {
                                              _alertService.showToast(
                                                  text: "No chats Found",
                                                  icon: Icons.error);
                                            }
                                            Navigator.pop(context);
                                          },
                                        ),
                                        const Divider(
                                            color: Colors.white12,
                                            thickness: 1),
                                        ListTile(
                                          leading: const Icon(
                                              Icons.lock_outline,
                                              color: Colors.blueAccent),
                                          title: Text(
                                            "Lock Chat of ${user.username}",
                                            style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 16),
                                          ),
                                          onTap: () async {
                                            if (chatId.isNotEmpty) {
                                              Navigator.pop(context);
                                              showModalBottomSheet(
                                                context: context,
                                                isScrollControlled: true,
                                                backgroundColor:
                                                    Colors.transparent,
                                                builder:
                                                    (BuildContext context) {
                                                  return Padding(
                                                    padding: EdgeInsets.only(
                                                      bottom:
                                                          MediaQuery.of(context)
                                                              .viewInsets
                                                              .bottom,
                                                    ),
                                                    child: ClipRRect(
                                                      borderRadius:
                                                          const BorderRadius
                                                              .vertical(
                                                              top: Radius
                                                                  .circular(
                                                                      30)),
                                                      child: BackdropFilter(
                                                        filter:
                                                            ImageFilter.blur(
                                                                sigmaX: 15,
                                                                sigmaY: 15),
                                                        child: Container(
                                                          decoration:
                                                              BoxDecoration(
                                                            color: Colors
                                                                .grey.shade900
                                                                .withOpacity(
                                                                    0.8),
                                                            borderRadius:
                                                                const BorderRadius
                                                                    .vertical(
                                                                    top: Radius
                                                                        .circular(
                                                                            30)),
                                                            border: Border.all(
                                                                color: Colors
                                                                    .white
                                                                    .withOpacity(
                                                                        0.1)),
                                                          ),
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(20.0),
                                                          child: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            mainAxisSize:
                                                                MainAxisSize
                                                                    .min,
                                                            children: [
                                                              Center(
                                                                child: Text(
                                                                  "Lock Chat of ${user.username}",
                                                                  style: const TextStyle(
                                                                      fontSize:
                                                                          22,
                                                                      color: Colors
                                                                          .white,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold),
                                                                ),
                                                              ),
                                                              const Divider(
                                                                  height: 30,
                                                                  thickness: 1,
                                                                  color: Colors
                                                                      .white24),
                                                              const SizedBox(
                                                                  height: 10),
                                                              TextFeildInput(
                                                                textInputType:
                                                                    TextInputType
                                                                        .text,
                                                                textEditingController:
                                                                    _createpasswordcontroller,
                                                                hinttext:
                                                                    "Create password",
                                                              ),
                                                              const SizedBox(
                                                                  height: 15),
                                                              TextFeildInput(
                                                                textInputType:
                                                                    TextInputType
                                                                        .text,
                                                                textEditingController:
                                                                    _confirmpasswordcontroller,
                                                                hinttext:
                                                                    "Confirm password",
                                                              ),
                                                              const SizedBox(
                                                                  height: 30),
                                                              SizedBox(
                                                                width: double
                                                                    .infinity,
                                                                child:
                                                                    ElevatedButton(
                                                                  onPressed:
                                                                      () async {
                                                                    if (_createpasswordcontroller
                                                                            .text ==
                                                                        _confirmpasswordcontroller
                                                                            .text) {
                                                                      FirebaseFirestore
                                                                          .instance
                                                                          .collection(
                                                                              "chats")
                                                                          .doc(
                                                                              chatId)
                                                                          .update({
                                                                        "locked":
                                                                            true,
                                                                        "password":
                                                                            _confirmpasswordcontroller.text
                                                                      });
                                                                      _alertService.showToast(
                                                                          text:
                                                                              "Chat Locked",
                                                                          icon:
                                                                              Icons.thumb_up);
                                                                      setState(
                                                                          () {
                                                                        _createpasswordcontroller.text =
                                                                            "";
                                                                        _confirmpasswordcontroller.text =
                                                                            "";
                                                                      });
                                                                      Navigator.pop(
                                                                          context);
                                                                    } else {
                                                                      _alertService.showToast(
                                                                          text:
                                                                              "Passwords don't match",
                                                                          icon:
                                                                              Icons.thumb_down);
                                                                    }
                                                                  },
                                                                  style: ElevatedButton
                                                                      .styleFrom(
                                                                    padding: const EdgeInsets
                                                                        .symmetric(
                                                                        vertical:
                                                                            15),
                                                                    backgroundColor:
                                                                        Colors
                                                                            .transparent,
                                                                    shape: RoundedRectangleBorder(
                                                                        borderRadius:
                                                                            BorderRadius.circular(30)),
                                                                    elevation:
                                                                        8,
                                                                    shadowColor: Colors
                                                                        .blue
                                                                        .withOpacity(
                                                                            0.4), // Make button transparent
                                                                  ).copyWith(
                                                                    overlayColor: MaterialStateProperty.all(Colors
                                                                        .white
                                                                        .withOpacity(
                                                                            0.1)),
                                                                  ),
                                                                  child: Ink(
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      gradient:
                                                                          const LinearGradient(
                                                                        colors: [
                                                                          Color(
                                                                              0xFF42A5F5),
                                                                          Color(
                                                                              0xFF1976D2)
                                                                        ],
                                                                        begin: Alignment
                                                                            .topLeft,
                                                                        end: Alignment
                                                                            .bottomRight,
                                                                      ),
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              30),
                                                                    ),
                                                                    child:
                                                                        Container(
                                                                      alignment:
                                                                          Alignment
                                                                              .center,
                                                                      constraints:
                                                                          const BoxConstraints(
                                                                              minHeight: 50.0),
                                                                      child:
                                                                          const Text(
                                                                        "Submit",
                                                                        style: TextStyle(
                                                                            color: Colors
                                                                                .white,
                                                                            fontSize:
                                                                                18,
                                                                            fontWeight:
                                                                                FontWeight.bold),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  );
                                                },
                                              );
                                            } else {
                                              _alertService.showToast(
                                                  text: "No chats Found",
                                                  icon: Icons.error);
                                            }
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: isCurrentUserChat
                                ? const LinearGradient(
                                    colors: [
                                      Color(0xFF42A5F5),
                                      Color(0xFF1976D2)
                                    ], // Vibrant blue gradient
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  )
                                : LinearGradient(
                                    colors: [
                                      Colors.grey.shade900.withOpacity(
                                          0.7), // Darker, subtle gradient for others
                                      Colors.grey.shade800.withOpacity(0.7),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                            borderRadius: BorderRadius.circular(20.0),
                            boxShadow: [
                              BoxShadow(
                                color: (isCurrentUserChat
                                        ? Colors.blue
                                        : Colors.black)
                                    .withOpacity(0.3),
                                spreadRadius: 1,
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                            border: Border.all(
                              color: isCurrentUserChat
                                  ? Colors.blue.withOpacity(0.5)
                                  : Colors.white.withOpacity(0.1),
                              width: 1.5,
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20.0),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(
                                  sigmaX: 10,
                                  sigmaY: 10), // Glassmorphism for chat tiles
                              child: ChatTile(
                                user: user,
                                senderid: user.uid,
                                ontap: () async {
                                  final chatexists =
                                      await _databaseService.checkchatexists(
                                    _authService.getCurrentUser()!.uid,
                                    user.uid,
                                  );
                                  if (!chatexists) {
                                    await _databaseService.createchats(
                                      _authService.getCurrentUser()!.uid,
                                      user.uid,
                                    );
                                  }

                                  final chatdetails =
                                      await getLockedChatDetails(chatId);
                                  bool isLocked = chatdetails['locked'] as bool;
                                  String? password =
                                      chatdetails['password'] as String?;
                                  if (isLocked == true) {
                                    showModalBottomSheet(
                                      context: context,
                                      isScrollControlled: true,
                                      backgroundColor: Colors.transparent,
                                      builder: (BuildContext context) {
                                        return Padding(
                                          padding: EdgeInsets.only(
                                            bottom: MediaQuery.of(context)
                                                .viewInsets
                                                .bottom,
                                          ),
                                          child: ClipRRect(
                                            borderRadius:
                                                const BorderRadius.vertical(
                                                    top: Radius.circular(30)),
                                            child: BackdropFilter(
                                              filter: ImageFilter.blur(
                                                  sigmaX: 15, sigmaY: 15),
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  color: Colors.grey.shade900
                                                      .withOpacity(0.8),
                                                  borderRadius:
                                                      const BorderRadius
                                                          .vertical(
                                                          top: Radius.circular(
                                                              30)),
                                                  border: Border.all(
                                                      color: Colors.white
                                                          .withOpacity(0.1)),
                                                ),
                                                padding:
                                                    const EdgeInsets.all(20.0),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Center(
                                                      child: Text(
                                                        "Chat of ${user.username} is locked",
                                                        style: const TextStyle(
                                                            fontSize: 22,
                                                            color: Colors.white,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                    ),
                                                    const Divider(
                                                        height: 30,
                                                        thickness: 1,
                                                        color: Colors.white24),
                                                    const SizedBox(height: 10),
                                                    TextFeildInput(
                                                      textInputType:
                                                          TextInputType.text,
                                                      textEditingController:
                                                          _checkpasswordcontroller,
                                                      hinttext:
                                                          "Enter password",
                                                    ),
                                                    const SizedBox(height: 15),
                                                    SizedBox(
                                                      width: double.infinity,
                                                      child: ElevatedButton(
                                                        onPressed: () async {
                                                          if (_checkpasswordcontroller
                                                                  .text ==
                                                              password) {
                                                            Navigator.pop(
                                                                context);
                                                            setState(() {
                                                              _checkpasswordcontroller
                                                                  .text = "";
                                                            });
                                                            Navigator.of(
                                                                    context)
                                                                .push(
                                                              MaterialPageRoute(
                                                                builder: (context) =>
                                                                    ChatPage(
                                                                        chatuser:
                                                                            user),
                                                              ),
                                                            );
                                                          } else {
                                                            _alertService.showToast(
                                                                text:
                                                                    "Wrong Password",
                                                                icon: Icons
                                                                    .error);
                                                          }
                                                        },
                                                        style: ElevatedButton
                                                            .styleFrom(
                                                          padding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                                  vertical: 15),
                                                          backgroundColor:
                                                              Colors
                                                                  .transparent,
                                                          shape: RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          30)),
                                                          elevation: 8,
                                                          shadowColor: Colors
                                                              .blue
                                                              .withOpacity(0.4),
                                                        ).copyWith(
                                                          overlayColor:
                                                              MaterialStateProperty
                                                                  .all(Colors
                                                                      .white
                                                                      .withOpacity(
                                                                          0.1)),
                                                        ),
                                                        child: Ink(
                                                          decoration:
                                                              BoxDecoration(
                                                            gradient:
                                                                const LinearGradient(
                                                              colors: [
                                                                Color(
                                                                    0xFF42A5F5),
                                                                Color(
                                                                    0xFF1976D2)
                                                              ],
                                                              begin: Alignment
                                                                  .topLeft,
                                                              end: Alignment
                                                                  .bottomRight,
                                                            ),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        30),
                                                          ),
                                                          child: Container(
                                                            alignment: Alignment
                                                                .center,
                                                            constraints:
                                                                const BoxConstraints(
                                                                    minHeight:
                                                                        50.0),
                                                            child: const Text(
                                                              "Submit",
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .white,
                                                                  fontSize: 18,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    );
                                  } else {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            ChatPage(chatuser: user),
                                      ),
                                    );
                                  }
                                },
                                chatIds: chatData.keys.toList(),
                                lastMessage: lastMessage,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              }
            },
          );
        } else {
          return Center(child: Text("No users found"));
        }
      },
    );
  }
}
