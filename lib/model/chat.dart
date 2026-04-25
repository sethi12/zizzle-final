import 'message.dart';

class Chat {
  String? id;
  List<String>? participants;
  List<Message>? messages;

  Chat({required this.id, required this.participants, required this.messages});

  Chat.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    participants = List<String>.from(json['participants']);
    messages = (json['messages'] as List<dynamic>?)
        ?.map((message) => Message.fromjson(message))
        .toList();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['participants'] = participants;
    data['messages'] = messages?.map((message) => message.tojson()).toList();
    return data;
  }
}
