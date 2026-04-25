import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get_it/get_it.dart';
import '/model/chat.dart';
import '/model/message.dart';
import '/utils/utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../model/user.dart';
import 'auth_message_service.dart';

class DatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  CollectionReference? _chatscollection;
  final GetIt _getIt = GetIt.instance;
  late AuthService _authService = _authService = _getIt.get<AuthService>();
  DatabaseService() {
    _setup();
  }
  void _setup() {
    _chatscollection = _firestore.collection('chats').withConverter<Chat>(
          fromFirestore: (snapshot, _) => Chat.fromJson(snapshot.data()!),
          toFirestore: (chat, _) => chat.toJson(), // Use instance method here
        );
  }

  Stream<List<User>> getFollowingUsersStream() async* {
    print("Starting getFollowingUsersStream");

    final prefs = await SharedPreferences.getInstance();
    final myUsername = prefs.getString('username');
    print("Retrieved username from SharedPreferences: $myUsername");

    if (myUsername == null) {
      print("Username is null");
      return;
    }

    // Get the document of the current user based on username
    final QuerySnapshot userSnapshot = await _firestore
        .collection("users")
        .where("username", isEqualTo: myUsername)
        .get();
    print("User snapshot retrieved");

    if (userSnapshot.docs.isEmpty) {
      print("User not found");
      return;
    }

    // Get the user document
    final userDoc = userSnapshot.docs.first;
    final myUid = _authService.getCurrentUser()!.uid;
    print("User document ID (UID): $myUid");

    // Get the following list from the user document
    final List<String> followingUsernames =
        List<String>.from(userDoc.get("following"));
    print("Following Usernames from Firestore: $followingUsernames");

    List<User> followingUsersList = [];

    if (followingUsernames.isNotEmpty) {
      // Query users collection to fetch users with the usernames in the following list
      final QuerySnapshot followingUsersSnapshot = await _firestore
          .collection("users")
          .where("username", whereIn: followingUsernames)
          .get();
      print("Following users snapshot retrieved");

      followingUsersList =
          followingUsersSnapshot.docs.map((doc) => User.fromsnap(doc)).toList();
      print("Following Users List: $followingUsersList");
    } else {
      print("No following usernames found");
    }

    // Query chats collection to find chats involving the current user
    final QuerySnapshot chatsSnapshot = await _firestore
        .collection("chats")
        .where("participants", arrayContains: myUid)
        .get();
    print("Chats snapshot retrieved");

    // Extract unique user IDs from the chats (excluding the current user's UID)
    final Set<String> chatUserIds = chatsSnapshot.docs
        .expand((doc) => List<String>.from(doc.get("participants")))
        .where((id) => id != myUid)
        .toSet();
    print("Chat User IDs: $chatUserIds");

    List<User> chatUsersList = [];

    if (chatUserIds.isNotEmpty) {
      for (final chatUserId in chatUserIds) {
        final QuerySnapshot userSnapshot = await _firestore
            .collection("users")
            .where("uid", isEqualTo: chatUserId)
            .get();

        if (userSnapshot.docs.isNotEmpty) {
          final userDoc = userSnapshot.docs.first;
          final user = User.fromsnap(
              userDoc); // Assuming User.fromsnap method to create a user object from a DocumentSnapshot
          chatUsersList.add(user);
        } else {
          print("User not found for ID: $chatUserId");
        }
      }
      print("Chat Users List: $chatUsersList");
    } else {
      print("No chat user IDs found");
    }
    List<User> combinedUsersList = [];

    // Combine following users and chat users, ensuring no duplicates
    combinedUsersList.addAll(followingUsersList);
    for (final chatUser in chatUsersList) {
      if (!combinedUsersList.any((user) => user.uid == chatUser.uid)) {
        combinedUsersList.add(chatUser);
      }
    }
    print("Combined Users List: $combinedUsersList");

    // Yield the combined users list
    yield combinedUsersList;
    print("Yielded combined users list");
  }

  Future<bool> checkchatexists(String uid1, String uid2) async {
    String chatid = generatechatid(uid1: uid1, uid2: uid2);
    final result = await _chatscollection!.doc(chatid).get();
    if (result != null) {
      return result.exists;
    }
    return false;
  }

  Future<String> createchats(String uid1, String uid2) async {
    String chatid = generatechatid(uid1: uid1, uid2: uid2);
    final docref = _chatscollection!.doc(chatid);
    final chat = Chat(id: chatid, participants: [uid1, uid2], messages: []);
    await docref.set(chat);
    return chatid;
  }

  Future<void> sendchatmessages(
      String uid1, String uid2, Message message) async {
    String chatid = generatechatid(uid1: uid1, uid2: uid2);
    final docref = _chatscollection!.doc(chatid);
    await docref.update({
      "messages": FieldValue.arrayUnion([message.tojson()])
    });
  }

  Stream<DocumentSnapshot<Chat>> getchatdata(String uid1, String uid2) {
    String chatid = generatechatid(uid1: uid1, uid2: uid2);
    return _chatscollection?.doc(chatid).snapshots()
        as Stream<DocumentSnapshot<Chat>>;
  }

  Future<void> updateChatLastMessage(String senderId, String receiverId,
      String lastMessage, Timestamp timestamp) async {
    String chatId = generatechatid(uid1: senderId, uid2: receiverId);
    await FirebaseFirestore.instance.collection('chats').doc(chatId).update({
      'lastmessage': lastMessage,
      'lastsentat': timestamp,
    });
  }
}
