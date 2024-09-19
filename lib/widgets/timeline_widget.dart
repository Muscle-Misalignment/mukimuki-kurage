import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firestore_service.dart';
import '../models/timeline_event.dart';
import 'package:intl/intl.dart';

class TimelineWidget extends StatelessWidget {
  final FirestoreService _firestoreService = FirestoreService();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestoreService.getTimeline(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('エラーが発生しました'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        final events = snapshot.data!.docs
            .map((doc) =>
                TimelineEvent.fromMap(doc.data() as Map<String, dynamic>))
            .toList();

        return ListView.builder(
          itemCount: events.length,
          itemBuilder: (context, index) {
            final event = events[index];
            return ChatBubble(
              message: event.message,
              username: event.username,
              timestamp: event.timestamp,
              isSentByMe: event.username == 'YourUsername', // ユーザー名で条件分岐
            );
          },
        );
      },
    );
  }
}

class ChatBubble extends StatelessWidget {
  final String message;
  final String username;
  final DateTime timestamp;
  final bool isSentByMe;

  const ChatBubble({
    required this.message,
    required this.username,
    required this.timestamp,
    required this.isSentByMe,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 0),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: isSentByMe ? Colors.blue[100] : Color(0xFFFFDEA5),
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(12),
              topRight: const Radius.circular(12),
              bottomLeft: isSentByMe ? const Radius.circular(12) : Radius.zero,
              bottomRight: isSentByMe ? Radius.zero : const Radius.circular(12),
            ),
          ),
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width *
                0.7, // 吹き出しの最大幅をデバイス幅の70%に制限
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                username,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 5,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                message,
                style: const TextStyle(
                  fontSize: 8,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
