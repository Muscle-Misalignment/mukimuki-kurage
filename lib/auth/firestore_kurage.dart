import 'package:cloud_firestore/cloud_firestore.dart';

//firestoreにアクセスして、ユーザーのコミュニティの成長値を取得する

Future<int?> getCommunityGrowth(String? uid) async {
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  print("getCommunityGrowth:::uid : $uid");

  // 1. ユーザーのコミュニティを取得
  DocumentSnapshot userDoc = await firestore.collection('users').doc(uid).get();

  String community = userDoc['community'];

  // 2. コミュニティのgrowthを取得
  DocumentSnapshot? communityDoc = await firestore
      .collection('communities')
      .get()
      .then((QuerySnapshot snapshot) {
    for (var doc in snapshot.docs) {
      if (doc['community_name'] == community) {
        return doc;
      }
    }
    return null;
  });

  if (communityDoc != null && communityDoc.exists) {
    print("community_name : ${communityDoc['community_name']}");
    print("feed_count : ${communityDoc['feed_count']}");
    print("kurage_level : ${communityDoc['kurage_level']}");
    return communityDoc['kurage_level'];
  } else {
    return null;
  }
}

//現在ログインしてるユーザーの情報を取得する
Future<DocumentSnapshot> getCurrentUser(String uid) async {
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  // 1. ユーザーのコミュニティを取得
  DocumentSnapshot userDoc = await firestore.collection('users').doc(uid).get();
  return userDoc;
}

//firestoreにアクセスして、ユーザーを登録する
Future<void> registerUser(String uid, String username, String photoURL) async {
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  // 新しいユーザーを登録
  await firestore.collection('users').doc(uid).set({
    'uid': uid,
    'username': username,
    'pphotoURL': photoURL,
    'community': 'watnow',
  });
}
