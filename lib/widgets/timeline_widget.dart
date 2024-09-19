import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firestore_service.dart';
import '../models/timeline_event.dart';
import 'package:intl/intl.dart';

class TimelineWidget extends StatelessWidget {
  final FirestoreService _firestoreService = FirestoreService();
  final String displayName; // displayNameを受け取る

  // コンストラクタでdisplayNameを受け取るようにする

  TimelineWidget({required this.displayName});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestoreService.getTimeline(),
      builder: (context, snapshot) {
        // エラーが発生した場合
        if (snapshot.hasError) {
          return Center(child: Text('エラーが発生しました'));
        }

        // データがまだ来ていない場合 (nullチェック)
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator()); // ローディング表示
        }

        // データが取得できた場合
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
              isSentByMe: event.username == displayName, // displayNameを使って判定
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
    // 日時をフォーマットする
    String formattedTime = DateFormat('HH:mm').format(timestamp);

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: isSentByMe
                ? Color.fromARGB(255, 255, 255, 255)
                : Color(0xFFFFDEA5),
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(12),
              topRight: isSentByMe ? Radius.zero : const Radius.circular(12),
              bottomLeft: isSentByMe
                  ? const Radius.circular(12)
                  : const Radius.circular(12),
              bottomRight: isSentByMe
                  ? const Radius.circular(12)
                  : const Radius.circular(12),
            ),
            // 自分の投稿にだけ枠線を追加
            border: isSentByMe
                ? Border.all(color: Color(0xFFFFDEA5), width: 2) // 枠線の色と幅
                : null, // 他人の投稿には枠線を付けない
          ),
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width *
                0.5, // 吹き出しの最大幅をデバイス幅の50%に制限
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end, // メッセージと時刻を底揃えにする
            children: [
              // メッセージ部分
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      username,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 8, // サイズを少し大きく
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      message,
                      style: const TextStyle(
                        fontSize: 10, // メッセージのフォントサイズ
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8), // メッセージと時刻の間にスペースを追加
              // 時刻部分
              Text(
                formattedTime,
                style: TextStyle(
                  fontSize: 8, // 時刻のフォントサイズ
                  color: Colors.grey, // 時刻の色
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
