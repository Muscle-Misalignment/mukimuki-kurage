import 'package:cloud_firestore/cloud_firestore.dart';

class UserEvent {
  final String uid;
  final String username;
  final String sex;
  final num age;
  final String goal;
  final String mygym;
  final String mukimukiage;
  final String community; // いいねボタンを押したユーザーのUIDリスト
  final String onecomment; // 追加: ドキュメントID

  UserEvent(
      {required this.uid,
      required this.username,
      required this.sex,
      required this.age,
      required this.goal,
      required this.mygym,
      required this.mukimukiage,
      required this.community,
      required this.onecomment}) {
    // Add function body here if needed
  }

  factory UserEvent.fromMap(Map<String, dynamic> data) {
    return UserEvent(
      uid: data['uid']?.toString() ?? '',
      username: data['username']?.toString() ?? '',
      sex: data['sex']?.toString() ?? '',
      age: data['age']?.toNum() ?? '',
      goal: data['goal']?.toString() ?? '',
      mygym: data['mygym']?.toString() ?? '',
      mukimukiage: data['mukimukiage']?.toString() ?? '',
      community: data['community']?.toString() ?? '',
      onecomment: data['onecomment']?.toString() ?? '',
    );
  }
}
