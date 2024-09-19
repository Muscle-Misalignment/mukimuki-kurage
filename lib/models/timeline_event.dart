import 'package:cloud_firestore/cloud_firestore.dart';

class TimelineEvent {
  final String uid;
  final String username;
  final String message;
  final DateTime timestamp;

  TimelineEvent({
    required this.uid,
    required this.username,
    required this.message,
    required this.timestamp,
  });

  factory TimelineEvent.fromMap(Map<String, dynamic> data) {
    // 'timestamp' フィールドが存在し、nullでないことを確認
    final timestamp = data['timestamp'] != null
        ? (data['timestamp'] as Timestamp).toDate()
        : DateTime.now(); // nullの場合は現在の日時を使用

    return TimelineEvent(
      uid: data['uid']?.toString() ?? '', // 'uid' を String に変換
      username: data['username']?.toString() ?? '', // 'username' を String に変換
      message: data['message']?.toString() ?? '', // 'message' を String に変換
      timestamp: timestamp,
    );
  }
}
