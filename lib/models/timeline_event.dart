import 'package:cloud_firestore/cloud_firestore.dart';

class TimelineEvent {
  final String uid;
  final String username;
  final String message;
  final DateTime timestamp;
  final String gymmemo;
  final List<String> goodbutton; // いいねボタンを押したユーザーのUIDリスト
  final String documentId; // 追加: ドキュメントID

  TimelineEvent({
    required this.uid,
    required this.username,
    required this.message,
    required this.timestamp,
    required this.gymmemo,
    this.goodbutton = const [], // 初期値を空のリストに設定
    required this.documentId,
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
      gymmemo: data['gymmemo']?.toString() ?? '',
      goodbutton:
          List<String>.from(data['goodbutton'] ?? []), // goodbuttonをリストに変換
      documentId: data['document']?.toString() ?? '', // ドキュメントIDを取得
    );
  }
}
