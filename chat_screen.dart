import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:record/record.dart';
import 'package:just_audio/just_audio.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';

import '../models/user_model.dart';
import '../models/message_model.dart';
import '../services/firestore_service.dart';
import '../services/storage_service.dart';
import '../utils/theme.dart';
import '../utils/helpers.dart';
import '../widgets/chat_bubble.dart';

class ChatScreen extends StatefulWidget {
  final UserModel otherUser;
  const ChatScreen({super.key, required this.otherUser});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final FirestoreService _fs = FirestoreService();
  final StorageService _storage = StorageService();
  final TextEditingController _textController = TextEditingController();
  final AudioRecorder _recorder = AudioRecorder();
  final AudioPlayer _player = AudioPlayer();

  late final String _me = FirebaseAuth.instance.currentUser!.uid;
  late final String _chatId = chatIdFor(_me, widget.otherUser.uid);

  bool _recording = false;
  bool _recordingCancelled = false;
  Duration _recordDuration = Duration.zero;
  String? _recordPath;

  MessageModel? _selectedMessage;
  bool _antiDeleteOn = false;

  @override
  void initState() {
    super.initState();
    _loadMyUser();
  }

  void _loadMyUser() {
    _fs.userStream(_me).listen((u) {
      if (mounted) setState(() => _antiDeleteOn = u.antiDeleteEnabled);
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _recorder.dispose();
    _player.dispose();
    super.dispose();
  }

  // ---------- Send text ----------
  void _sendText() {
    final text = _textController.text.trim();
    if (text.isEmpty) return;
    final msg = MessageModel(
      id: '',
      text: text,
      originalText: text,
      senderId: _me,
      timestamp: DateTime.now(),
      type: 'text',
    );
    _fs.sendMessage(_chatId, msg);
    _textController.clear();
  }

  // ---------- Voice recording ----------
  Future<void> _startRecording() async {
    final status = await Permission.microphone.request();
    if (!status.isGranted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Microphone permission denied')),
      );
      return;
    }
    final dir = await getTemporaryDirectory();
    _recordPath =
        '${dir.path}/voice_${DateTime.now().millisecondsSinceEpoch}.m4a';
    await _recorder.start(
      const RecordConfig(),
      path: _recordPath!,
    );
    setState(() {
      _recording = true;
      _recordingCancelled = false;
      _recordDuration = Duration.zero;
    });
    // Tick timer.
    _tickTimer();
  }

  void _tickTimer() async {
    while (_recording && !_recordingCancelled) {
      await Future.delayed(const Duration(seconds: 1));
      if (_recording && !_recordingCancelled) {
        setState(() => _recordDuration += const Duration(seconds: 1));
      }
    }
  }

  Future<void> _stopAndSendRecording() async {
    if (!_recording) return;
    final path = _recordPath;
    await _recorder.stop();
    setState(() => _recording = false);
    if (_recordingCancelled || path == null) return;
    final file = File(path);
    if (!await file.exists()) return;
    final url = await _storage.uploadVoiceNote(_chatId, file);
    final msg = MessageModel(
      id: '',
      text: '🎤 Voice message',
      originalText: '🎤 Voice message',
      senderId: _me,
      timestamp: DateTime.now(),
      type: 'voice',
      voiceUrl: url,
    );
    _fs.sendMessage(_chatId, msg);
  }

  Future<void> _cancelRecording() async {
    if (!_recording) return;
    setState(() => _recordingCancelled = true);
    await _recorder.stop();
    setState(() => _recording = false);
    // Delete the local temp file.
    if (_recordPath != null) {
      final f = File(_recordPath!);
      if (await f.exists()) await f.delete();
    }
  }

  Future<void> _playVoice(String url) async {
    try {
      await _player.setUrl(url);
      await _player.play();
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Cannot play voice: $e')));
    }
  }

  // ---------- Delete ----------
  void _showDeleteOptions(MessageModel msg) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.red),
              title: const Text('Delete for Me'),
              onTap: () async {
                Navigator.pop(ctx);
                await _fs.deleteForMe(_chatId, msg.id, _me);
                setState(() => _selectedMessage = null);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_forever, color: Colors.red),
              title: const Text('Delete for Everyone'),
              onTap: () async {
                Navigator.pop(ctx);
                await _fs.deleteForEveryone(_chatId, msg.id);
                setState(() => _selectedMessage = null);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Row(
          children: [
            Avatar(
              name: widget.otherUser.name,
              photoUrl: widget.otherUser.photoUrl,
              photoPrivacy: widget.otherUser.photoPrivacy,
              radius: 18,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.otherUser.name,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w600)),
                  StreamBuilder<UserModel>(
                    stream: _fs.userStream(widget.otherUser.uid),
                    builder: (context, snap) {
                      final u = snap.data;
                      final lastSeen = u == null
                          ? ''
                          : formatLastSeen(u.lastSeen, u.lastSeenPrivacy,
                              u.freezeLastSeen);
                      return Text(lastSeen,
                          style: const TextStyle(
                              fontSize: 12, color: Colors.white70));
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.videocam), onPressed: () {}),
          IconButton(icon: const Icon(Icons.call), onPressed: () {}),
          IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              color: AppTheme.chatBackground,
              child: StreamBuilder<List<MessageModel>>(
                stream: _fs.messagesStream(_chatId),
                builder: (context, snap) {
                  if (!snap.hasData) {
                    return const Center(
                        child: CircularProgressIndicator(
                            color: AppTheme.primary));
                  }
                  final messages = snap.data!;
                  return ListView.builder(
                    reverse: true,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final msg = messages[index];
                      final isMe = msg.senderId == _me;
                      return GestureDetector(
                        onLongPress: () {
                          setState(() => _selectedMessage = msg);
                          _showDeleteOptions(msg);
                        },
                        child: ChatBubble(
                          message: msg,
                          isMe: isMe,
                          viewerUid: _me,
                          // Only meaningful for incoming: the receiver's
                          // anti-delete setting. If the other user has it ON,
                          // the original deleted text is revealed to them.
                          antiDeleteOn: !isMe && widget
                              .otherUser.antiDeleteEnabled,
                          onPlayVoice: msg.type == 'voice'
                              ? (url) => _playVoice(url)
                              : null,
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
          _inputBar(),
        ],
      ),
    );
  }

  // ---------- Input bar ----------
  Widget _inputBar() {
    if (_recording) {
      return _recordingBar();
    }
    return SafeArea(
      child: Container(
        color: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(24),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                child: Row(
                  children: [
                    const Icon(Icons.emoji_emotions_outlined,
                        color: Colors.grey),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _textController,
                        minLines: 1,
                        maxLines: 5,
                        decoration: const InputDecoration(
                          hintText: 'Message',
                          border: InputBorder.none,
                        ),
                        onChanged: (_) => setState(() {}),
                      ),
                    ),
                    const Icon(Icons.attach_file, color: Colors.grey),
                    const SizedBox(width: 6),
                    const Icon(Icons.camera_alt_outlined, color: Colors.grey),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 6),
            GestureDetector(
              onTap: () {
                if (_textController.text.isNotEmpty) _sendText();
              },
              onLongPressStart: (_) {
                if (_textController.text.isEmpty) _startRecording();
              },
              onLongPressEnd: (_) => _stopAndSendRecording(),
              child: Container(
                decoration: const BoxDecoration(
                  color: AppTheme.primaryLight,
                  shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.all(12),
                child: Icon(
                  _textController.text.isEmpty ? Icons.mic : Icons.send,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _recordingBar() {
    return SafeArea(
      child: Container(
        color: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            GestureDetector(
              onTap: _cancelRecording,
              child: const Icon(Icons.delete, color: Colors.red),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Row(
                children: [
                  const Icon(Icons.fiber_manual_record,
                      color: Colors.red, size: 18),
                  const SizedBox(width: 6),
                  Text(_formatDuration(_recordDuration),
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, color: Colors.black87)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _recordingCancelled
                          ? 'Cancelled — slide left to discard'
                          : 'Recording... slide to cancel',
                      style: const TextStyle(color: Colors.grey, fontSize: 13),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: _stopAndSendRecording,
              child: Container(
                decoration: const BoxDecoration(
                  color: AppTheme.primaryLight,
                  shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.all(12),
                child: const Icon(Icons.send, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }
}

