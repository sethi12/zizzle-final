import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '/Controllers/comment_controller.dart';
import 'package:timeago/timeago.dart' as tago;
import 'package:zizzle/utils/colors.dart';
import 'dart:ui';

class CommentReelScreen extends StatelessWidget {
  final String id;
  CommentReelScreen({super.key, required this.id});
  final TextEditingController _commmentcontroller = TextEditingController();
  final CommentController commentController = Get.put(CommentController());

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    commentController.updatepostid(id);

    return Scaffold(
      backgroundColor:
          Colors.transparent, // Ensure Scaffold background is transparent
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              mobileBackgroundColor,
              Color.fromRGBO(10, 19, 41, 1.0),
              Color.fromRGBO(10, 19, 41, 1.0),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            Expanded(child: Obx(() {
              if (commentController.comments.isEmpty) {
                return const Center(
                  child: Text(
                    "No comments yet. Be the first to comment!",
                    style: TextStyle(color: secondaryColor),
                  ),
                );
              }
              return ListView.builder(
                itemCount: commentController.comments.length,
                itemBuilder: (context, index) {
                  final comment = commentController.comments[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 8.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: secondaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.transparent,
                          backgroundImage: NetworkImage(comment.profilephoto),
                        ),
                        title: RichText(
                          text: TextSpan(children: [
                            TextSpan(
                              text: comment.username,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color: Colors.white),
                            ),
                            TextSpan(
                              text: '  ${comment.comment}',
                              style: const TextStyle(
                                  fontWeight: FontWeight.w400,
                                  fontSize: 14,
                                  color: Colors.white70),
                            ),
                          ]),
                        ),
                        subtitle: Row(
                          children: [
                            Text(
                              tago.format(comment.datepublished.toDate()),
                              style: const TextStyle(
                                  fontSize: 12, color: Colors.white54),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              '${comment.likes.length} likes',
                              style: const TextStyle(
                                  fontSize: 12, color: Colors.white54),
                            ),
                          ],
                        ),
                        trailing: InkWell(
                          onTap: () => commentController.likecomment(
                              comment.id, comment.username),
                          child: Icon(
                            Icons.favorite,
                            size: 25,
                            color: comment.likes.contains(comment.username)
                                ? Colors.redAccent
                                : Colors.white70,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            })),
            const Divider(color: secondaryColor),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              margin: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: secondaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _commmentcontroller,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                      decoration: const InputDecoration(
                          hintText: 'Add a comment...',
                          hintStyle:
                              TextStyle(fontSize: 16, color: Colors.white54),
                          border: InputBorder.none),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      if (_commmentcontroller.text.trim().isNotEmpty) {
                        commentController.postcomment(_commmentcontroller.text);
                        _commmentcontroller.text = "";
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.blueGrey,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'Post',
                        style: TextStyle(
                            fontSize: 14,
                            color: Colors.white,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
