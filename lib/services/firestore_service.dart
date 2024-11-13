import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final CollectionReference timelineCollection =
      FirebaseFirestore.instance.collection('timeline');

  // Firestoreにイベントを追加する関数
  Future<void> addEvent(String uid, String username, String message) async {
    await timelineCollection.add({
      'uid': uid,
      'username': username,
      'message': message,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  // メモ付きのジムイベントをFirestoreに追加する関数
  Future<void> addEventWithMemo(
      String uid, String username, String message, String gymmemo) async {
    final room = FirebaseFirestore.instance.collection('timeline').doc();
    await room.set({
      'uid': uid,
      'username': username,
      'message': message,
      'gymmemo': gymmemo, // gymmemoフィールドを追加
      'timestamp': FieldValue.serverTimestamp(),
      'goodbutton': [], // goodbuttonフィールドを追加,
      'document': room.id,
    });
  }
//final room = FirebaseFirestore.instance.collection('room').doc();

  // room.set({
  //   'URL': url,
  //   'roomTitle': roomTitle,
  //   'roomCategory': roomCategory,
  //   'roomAtmosphere': roomAtmosphere,
  //   'roomDescription': roomDescription,
  //   'roomMaster': roomMasterName,
  //   'created_at': DateTime.now(),
  //   'roomCount': 1,
  //   'documentID': room.id
  // });

  Stream<QuerySnapshot> getTimeline() {
    return timelineCollection
        .orderBy('timestamp', descending: false)
        .snapshots();
  }
}
