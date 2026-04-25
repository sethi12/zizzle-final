class NotificationModel {
  final String username;
  final List<String>? postlikes;
  final List<String>? postcomments;
  final List<String>? reelLikes;
  final List<String>? reelComments;
  final List<String>? followers;

  const NotificationModel({
    required this.username,
    this.postlikes,
    this.postcomments,
    this.reelLikes,
    this.reelComments,
    this.followers,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      username: json['username'] ?? '',
      postlikes: List<String>.from(json['likes'] ?? []),
      postcomments: List<String>.from(json['comments'] ?? []),
      reelLikes: List<String>.from(json['reelLikes'] ?? []),
      reelComments: List<String>.from(json['reelComments'] ?? []),
      followers: List<String>.from(json['followers'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'Postlikes': postlikes,
      'Postcomments': postcomments,
      'reelLikes': reelLikes,
      'reelComments': reelComments,
      'followers': followers,
    };
  }
}
