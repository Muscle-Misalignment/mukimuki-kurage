import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final CollectionReference timelineCollection =
      FirebaseFirestore.instance.collection('timeline');

  // Firestoreにイベントを追加する関数
  Future<void> addEvent(String uid, String username, String message) async {
    // 'add'メソッドを使用して新しいドキュメントを作成
    await timelineCollection.add({
      'uid': uid,
      'username': username,
      'message': message,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  // Firestoreからタイムラインのデータをリアルタイムで取得する関数
  Stream<QuerySnapshot> getTimeline() {
    return timelineCollection
        .orderBy('timestamp', descending: true)
        .snapshots();
  }
}
