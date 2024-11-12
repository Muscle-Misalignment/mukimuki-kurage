import 'package:cloud_firestore/cloud_firestore.dart';

class TimelineEvent {
  final String uid;
  final String username;
  final String message;
  final DateTime timestamp;
  final String gymmemo;

  TimelineEvent({
    required this.uid,
    required this.username,
    required this.message,
    required this.timestamp,
    required this.gymmemo,
  });

  factory TimelineEvent.fromMap(Map<String, dynamic> data) {
    final timestamp = data['timestamp'] != null
        ? (data['timestamp'] as Timestamp).toDate()
        : DateTime.now();

    return TimelineEvent(
      uid: data['uid']?.toString() ?? '',
      username: data['username']?.toString() ?? '',
      message: data['message']?.toString() ?? '',
      timestamp: timestamp,
      gymmemo: data['gymmemo']?.toString() ?? '', // gymmemoを追加
    );
  }
}
