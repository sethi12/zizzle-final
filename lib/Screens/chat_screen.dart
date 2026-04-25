import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '/model/message.dart';
import '/model/user.dart';
import '/services/auth_message_service.dart';
import '/services/database_service.dart';
import '/services/media_service.dart';
import '/services/storage_service.dart';
import 'dart:io';
import 'dart:ui';
import '../model/chat.dart';
import '../utils/utils.dart';

class ChatPage extends StatefulWidget {
  final User? chatuser;
  const ChatPage({super.key, required this.chatuser});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  late AuthService _authService;
  final GetIt _getIt = GetIt.instance;
  late DatabaseService _databaseService;
  late MediaService _mediaService;
  late StorageService _storageService;
  ChatUser? currentuser, otheruser;

  @override
  void initState() {
    super.initState();
    _authService = _getIt.get<AuthService>();
    _databaseService = _getIt.get<DatabaseService>();
    _mediaService = _getIt.get<MediaService>();
    _storageService = _getIt.get<StorageService>();
    currentuser = ChatUser(
        id: _authService.getCurrentUser()!.uid,
        firstName: _authService.getCurrentUser()!.displayName);
    otheruser = ChatUser(
        id: widget.chatuser!.uid,
        firstName: widget.chatuser!.username,
        profileImage: widget.chatuser!.photourl);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          widget.chatuser!.username,
          style:
              const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              color: Colors.black.withOpacity(0.2),
            ),
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF1E1E1E),
              Color(0xFF0D0D0D),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: _buildUI(),
      ),
    );
  }

  Widget _buildUI() {
    return StreamBuilder(
      stream: _databaseService.getchatdata(currentuser!.id, otheruser!.id),
      builder: (context, snapshot) {
        Chat? chat = snapshot.data?.data();
        List<ChatMessage> messages = [];
        if (chat != null && chat.messages != null) {
          messages = _generateChatmessageslist(chat.messages!);
        }

        final double appBarHeight =
            AppBar().preferredSize.height + MediaQuery.of(context).padding.top;

        return Padding(
          padding: EdgeInsets.only(top: appBarHeight),
          child: DashChat(
            messageOptions: const MessageOptions(
              showOtherUsersAvatar: true,
              showTime: true,
              currentUserContainerColor: Color(0xFF42A5F5), // Blue shade
              currentUserTextColor: Colors.white,
              // otherMessageOptions: OtherMessageOptions(
              //   messageTextColor: Colors.white,
              //   containerColor: Color(0xFF2C2C2C),
            ),
            inputOptions: InputOptions(
              sendButtonBuilder: _buildSendButton,
              autocorrect: true,
              trailing: [
                _mediamessagebutton(),
              ],
              inputTextStyle: const TextStyle(
                color: Colors.white,
                fontSize: 19,
                fontWeight: FontWeight.w500,
              ),
              inputDecoration: InputDecoration(
                hintText: "Type your message...",
                hintStyle: const TextStyle(color: Colors.white54),
                fillColor: Colors.white.withOpacity(0.1),
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
            ),
            currentUser: currentuser!,
            onSend: _sendmessage,
            messages: messages,
          ),
        );
      },
    );
  }

  Widget _buildSendButton(void Function() onSend) {
    return Container(
      margin: const EdgeInsets.only(left: 8),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF42A5F5), Color(0xFF1976D2)],
        ),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        onPressed: onSend,
        icon: const Icon(
          Icons.send,
          color: Colors.white,
        ),
      ),
    );
  }

  Future<void> _sendmessage(ChatMessage chatMessage) async {
    String messageContent = '';
    Messagetype messageType;

    if (chatMessage.medias?.isNotEmpty ?? false) {
      if (chatMessage.medias!.first.type == MediaType.image) {
        messageContent = '📷 Image';
        messageType = Messagetype.Image;
        Message message = Message(
            senderid: chatMessage.user.id,
            content: chatMessage.medias!.first.url,
            recieverid: otheruser!.id,
            messagetype: messageType,
            sentat: Timestamp.fromDate(chatMessage.createdAt),
            lastmessage: messageContent,
            read: false);
        await _databaseService.sendchatmessages(
            currentuser!.id, otheruser!.id, message);
      }
    } else {
      messageContent = chatMessage.text;
      messageType = Messagetype.Text;
      Message message = Message(
          senderid: currentuser!.id,
          content: messageContent,
          messagetype: messageType,
          recieverid: otheruser!.id,
          sentat: Timestamp.fromDate(chatMessage.createdAt),
          lastmessage: messageContent,
          read: false);
      await _databaseService.sendchatmessages(
          currentuser!.id, otheruser!.id, message);
    }

    await _databaseService.updateChatLastMessage(
      currentuser!.id,
      otheruser!.id,
      messageContent,
      Timestamp.now(),
    );
  }

  List<ChatMessage> _generateChatmessageslist(List<Message> messages) {
    List<ChatMessage> chatmessages = messages.map((e) {
      if (e.messagetype == Messagetype.Image) {
        return ChatMessage(
            user: e.senderid == currentuser!.id ? currentuser! : otheruser!,
            createdAt: e.sentat!.toDate(),
            medias: [
              ChatMedia(url: e.content!, fileName: "", type: MediaType.image)
            ]);
      } else {
        return ChatMessage(
            user: e.senderid == currentuser!.id ? currentuser! : otheruser!,
            createdAt: e.sentat!.toDate(),
            text: e.content!);
      }
    }).toList();
    chatmessages.sort((a, b) {
      return b.createdAt.compareTo(a.createdAt);
    });
    return chatmessages;
  }

  Widget _mediamessagebutton() {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF42A5F5), Color(0xFF1976D2)],
        ),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        onPressed: () async {
          File? file = await _mediaService.getimagefromgallery();
          if (file != null) {
            String chatid =
                generatechatid(uid1: currentuser!.id, uid2: otheruser!.id);
            String? downloadurl = await _storageService.uploadimagetochat(
                file: file, chatid: chatid);
            if (downloadurl != null) {
              ChatMessage chatMessage = ChatMessage(
                  user: currentuser!,
                  createdAt: DateTime.now(),
                  medias: [
                    ChatMedia(
                        url: downloadurl, fileName: "", type: MediaType.image)
                  ]);
              _sendmessage(chatMessage);
            }
          }
        },
        icon: const Icon(
          Icons.image,
          color: Colors.white,
        ),
      ),
    );
  }
}
