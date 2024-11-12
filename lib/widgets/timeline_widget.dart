import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firestore_service.dart';
import '../models/timeline_event.dart';
import 'package:intl/intl.dart';

class TimelineWidget extends StatefulWidget {
  final FirestoreService _firestoreService = FirestoreService();
  final String displayName;

  TimelineWidget({required this.displayName});

  @override
  _TimelineWidgetState createState() => _TimelineWidgetState();
}

class _TimelineWidgetState extends State<TimelineWidget>
    with SingleTickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  List<TimelineEvent> _events = [];
  Set<String> _eventIds = Set(); // イベントIDを保存して重複を防ぐ
  StreamSubscription? _subscription; // リスナー用のサブスクリプション

  @override
  void initState() {
    super.initState();

    // Firestoreからデータをリスニング
    _subscription = widget._firestoreService.getTimeline().listen((snapshot) {
      for (var change in snapshot.docChanges) {
        if (change.type == DocumentChangeType.added) {
          final newEvent =
              TimelineEvent.fromMap(change.doc.data() as Map<String, dynamic>);
          if (!_eventIds.contains(newEvent.timestamp.toString())) {
            if (mounted) {
              setState(() {
                _events.add(newEvent);
                _eventIds.add(newEvent.timestamp.toString());

                // イベントをアニメーションで追加
                _listKey.currentState?.insertItem(_events.length - 1);
              });

              // 自動スクロールを最下部に設定
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (_scrollController.hasClients) {
                  _scrollController
                      .jumpTo(_scrollController.position.maxScrollExtent);
                }
              });
            }
          }
        }
      }
    });
  }

  @override
  void dispose() {
    // ウィジェットが破棄されるときにリスナーを解除
    _subscription?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_events.isEmpty) {
      return Center(child: CircularProgressIndicator());
    }

    return AnimatedList(
      key: _listKey,
      controller: _scrollController,
      initialItemCount: _events.length,
      itemBuilder: (context, index, animation) {
        final event = _events[index];
        return SlideTransition(
          position: Tween<Offset>(
            begin: Offset(1, 0), // 右側からの開始位置
            end: Offset(0, 0), // 左端に固定される位置
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeInOut, // イージングを適用
          )),
          child: ChatBubble(
            message: event.message,
            username: event.username,
            timestamp: event.timestamp,
            isSentByMe: event.username == widget.displayName,
            gymmemo: event.gymmemo,
          ),
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
  final String gymmemo;

  const ChatBubble({
    required this.message,
    required this.username,
    required this.timestamp,
    required this.isSentByMe,
    required this.gymmemo,
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
                ? Color.fromARGB(255, 255, 255, 255).withOpacity(0.8)
                : Color(0xFFFFDEA5).withOpacity(0.8),
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
                0.45, // 吹き出しの最大幅をデバイス幅の50%に制限
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
                      "${username}が",
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
                    if (gymmemo.isNotEmpty) ...[
                      const SizedBox(height: 5), // メモとメッセージの間に隙間を追加
                      Text(
                        gymmemo,
                        style: const TextStyle(
                          fontSize: 9, // gymmemoのフォントサイズ
                          fontStyle: FontStyle.italic, // 斜体で表示
                          color: Colors.grey, // メモの文字色
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 1), // メッセージと時刻の間のスペースを1に調整
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
