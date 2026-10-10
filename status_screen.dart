import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../services/firestore_service.dart';
import '../services/storage_service.dart';
import '../models/status_model.dart';
import '../models/user_model.dart';
import '../utils/theme.dart';
import '../utils/helpers.dart';
import '../widgets/avatar.dart';

class StatusScreen extends StatefulWidget {
  const StatusScreen({super.key});

  @override
  State<StatusScreen> createState() => _StatusScreenState();
}

class _StatusScreenState extends State<StatusScreen> {
  final FirestoreService _fs = FirestoreService();
  final StorageService _storage = StorageService();
  late final String _me = FirebaseAuth.instance.currentUser!.uid;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: _fs.allStatusStream(),
      builder: (context, AsyncSnapshot<List<QueryDocumentSnapshot<Map<String, dynamic>>>> snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(
              child: CircularProgressIndicator(color: AppTheme.primary));
        }
        final docs = snap.data ?? [];
        final statuses = docs
            .map((d) => StatusModel.fromMap(d.data(), d.id))
            .where((s) => !s.isExpired)
            .toList();

        final mine = statuses.where((s) => s.uid == _me).toList();
        final others = statuses.where((s) => s.uid != _me).toList();
        // Group others by uid.
        final byUid = <String, List<StatusModel>>{};
        for (final s in others) {
          byUid.putIfAbsent(s.uid, () => []).add(s);
        }

        return ListView(
          children: [
            ListTile(
              leading: Stack(
                children: [
                  Avatar(
                      name: 'You',
                      photoUrl: '',
                      photoPrivacy: 'everyone',
                      radius: 26),
                  if (mine.isEmpty)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(3),
                        decoration: const BoxDecoration(
                            color: AppTheme.primaryLight,
                            shape: BoxShape.circle),
                        child: const Icon(Icons.add,
                            color: Colors.white, size: 14),
                      ),
                    ),
                ],
              ),
              title: const Text('My Status',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              subtitle: Text(mine.isEmpty
                  ? 'Tap to add status update'
                  : 'Updated ${formatChatTime(mine.first.createdAt)}'),
              onTap: _addStatus,
            ),
            const Divider(),
            if (others.isEmpty && mine.isEmpty)
              const Padding(
                padding: EdgeInsets.all(32),
                child: Center(
                  child: Text('No status updates available',
                      style: TextStyle(color: Colors.grey)),
                ),
              )
            else ...[
              for (final entry in byUid.entries)
                FutureBuilder<UserModel?>(
                  future: _fs.getUser(entry.key),
                  builder: (context, uSnap) {
                    final u = uSnap.data;
                    return ListTile(
                      leading: Avatar(
                        name: u?.name ?? '?',
                        photoUrl: entry.value.first.mediaUrl,
                        photoPrivacy: 'everyone',
                        radius: 26,
                      ),
                      title: Text(u?.name ?? 'Unknown',
                          style: const TextStyle(
                              fontWeight: FontWeight.w600)),
                      subtitle: Text(
                          formatChatTime(entry.value.first.createdAt),
                          style: const TextStyle(color: Colors.grey)),
                      onTap: () => _viewStatus(entry.value),
                    );
                  },
                ),
            ],
          ],
        );
      },
    );
  }

  Future<void> _addStatus() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked == null) return;
    final file = File(picked.path);
    final url = await _storage.uploadStatusMedia(_me, file, 'jpg');
    final user = await _fs.getUser(_me);
    await _fs.addStatus({
      'uid': _me,
      'name': user?.name ?? '',
      'photoUrl': user?.photoUrl ?? '',
      'mediaUrl': url,
      'type': 'image',
      'caption': '',
      'createdAt': DateTime.now(),
      'viewedBy': [],
    });
  }

  void _viewStatus(List<StatusModel> statuses) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _StatusViewer(statuses: statuses, me: _me),
      ),
    );
  }
}

class _StatusViewer extends StatefulWidget {
  final List<StatusModel> statuses;
  final String me;
  const _StatusViewer({required this.statuses, required this.me});

  @override
  State<_StatusViewer> createState() => _StatusViewerState();
}

class _StatusViewerState extends State<_StatusViewer> {
  late PageController _pageController;
  int _index = 0;
  final FirestoreService _fs = FirestoreService();

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _markViewed(widget.statuses.first);
  }

  void _markViewed(StatusModel s) {
    if (!s.viewedBy.contains(widget.me)) {
      _fs.markStatusViewed(s.id, widget.me);
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: PageView.builder(
          controller: _pageController,
          itemCount: widget.statuses.length,
          onPageChanged: (i) {
            setState(() => _index = i);
            _markViewed(widget.statuses[i]);
          },
          itemBuilder: (context, i) {
            final s = widget.statuses[i];
            return Stack(
              children: [
                Center(
                  child: CachedNetworkImage(
                      imageUrl: s.mediaUrl, fit: BoxFit.contain),
                ),
                Positioned(
                  top: 12,
                  left: 12,
                  right: 12,
                  child: Row(
                    children: [
                      Expanded(
                        child: LinearProgressIndicator(
                          value: (i + 1) / widget.statuses.length,
                          backgroundColor: Colors.white24,
                          valueColor:
                              const AlwaysStoppedAnimation(Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  top: 28,
                  left: 12,
                  child: Text(s.name,
                      style: const TextStyle(color: Colors.white)),
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
