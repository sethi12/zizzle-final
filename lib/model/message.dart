import 'package:cloud_firestore/cloud_firestore.dart';

enum Messagetype { Text, Image, Post }

class Message {
  String? senderid;
  String? content;
  Messagetype? messagetype;
  Timestamp? sentat;
  String? lastmessage;
  String? recieverid;
  bool? read;
  Message(
      {required this.senderid,
      required this.content,
      required this.messagetype,
      required this.sentat,
      this.lastmessage,
      required this.recieverid,
      required this.read});

  Message.fromjson(Map<String, dynamic> json) {
    senderid = json['senderid'];
    content = json['content'];
    sentat = json['sentat'];
    lastmessage = json['lastmessage'];
    recieverid = json['recieverid'];
    read = json['read'];
    messagetype = Messagetype.values.byName(json['messagetype']);
  }

  Map<String, dynamic> tojson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['senderid'] = senderid;
    data['content'] = content;
    data['sentat'] = sentat;
    data['lastmessage'] = lastmessage;
    data['messagetype'] = messagetype!.name;
    data['recieverid'] = recieverid;
    data['read'] = read;
    return data;
  }
}
