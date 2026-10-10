import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firestore_service.dart';
import '../models/user_model.dart';
import '../models/message_model.dart';
import '../utils/theme.dart';
import '../utils/helpers.dart';
import '../widgets/avatar.dart';
import 'chat_screen.dart';
import 'status_screen.dart';
import 'calls_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _searchController = TextEditingController();
  bool _searching = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _searching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: 'Search by name...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Colors.white60),
                ),
                onChanged: (_) => setState(() {}),
              )
            : const Text('WhatsApp Clone'),
        actions: [
          IconButton(
            icon: Icon(_searching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                _searching = !_searching;
                if (!_searching) _searchController.clear();
              });
            },
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'settings') {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const SettingsScreen()));
              }
            },
            itemBuilder: (_) => [
              const PopupMenuItem(value: 'settings', child: Text('Settings')),
            ],
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          tabs: const [
            Tab(text: 'Chats'),
            Tab(text: 'Status'),
            Tab(text: 'Calls'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          ChatsTab(
            searchQuery: _searchController.text.toLowerCase(),
          ),
          const StatusScreen(),
          const CallsScreen(),
        ],
      ),
    );
  }
}

/// The Chats tab: shows all users except me, with real-time search filtering.
class ChatsTab extends StatefulWidget {
  final String searchQuery;

  const ChatsTab({super.key, required this.searchQuery});

  @override
  State<ChatsTab> createState() => _ChatsTabState();
}

class _ChatsTabState extends State<ChatsTab> {
  final FirestoreService _fs = FirestoreService();
  String get _me => FirebaseAuth.instance.currentUser!.uid;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<UserModel>>(
      stream: _fs.usersStream(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(
              child: CircularProgressIndicator(color: AppTheme.primary));
        }
        if (!snap.hasData || snap.data!.isEmpty) {
          return const Center(child: Text('No contacts yet'));
        }
        var users = snap.data!.where((u) => u.uid != _me).toList();

        // Instant search filtering on name.
        if (widget.searchQuery.isNotEmpty) {
          users = users
              .where((u) =>
                  u.name.toLowerCase().contains(widget.searchQuery))
              .toList();
        }

        if (users.isEmpty) {
          return const Center(child: Text('No matching contacts'));
        }

        return ListView.builder(
          itemCount: users.length,
          itemBuilder: (context, index) {
            final user = users[index];
            return _ChatListTile(
              user: user,
              me: _me,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ChatScreen(otherUser: user),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}

class _ChatListTile extends StatelessWidget {
  final UserModel user;
  final String me;
  final VoidCallback onTap;

  const _ChatListTile({
    required this.user,
    required this.me,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final fs = FirestoreService();
    final chatId = chatIdFor(me, user.uid);
    return Dismissible(
      key: ValueKey(user.uid),
      direction: DismissDirection.horizontal,
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (_) async => _confirmDelete(context),
      onDismissed: (_) async => fs.deleteChat(chatId),
      child: StreamBuilder<List<MessageModel>>(
        stream: fs.messagesStream(chatId),
        builder: (context, snap) {
          String preview = 'Tap to start chatting';
          String timeText = '';
          if (snap.hasData && snap.data!.isNotEmpty) {
            final last = snap.data!.first;
            if (last.isDeletedForMe(me)) {
              preview = '🚫 This message was deleted';
            } else if (last.isDeletedForEveryone) {
              preview = '🚫 This message was deleted';
            } else if (last.type == 'voice') {
              preview = '🎤 Voice message';
            } else {
              preview = last.text;
            }
            timeText = formatChatTime(last.timestamp);
          }
          return ListTile(
            onTap: onTap,
            onLongPress: () => _showOptions(context, chatId, fs),
            leading: Avatar(
              name: user.name,
              photoUrl: user.photoUrl,
              photoPrivacy: user.photoPrivacy,
            ),
            title: Text(user.name,
                style: const TextStyle(fontWeight: FontWeight.w600)),
            subtitle: Text(preview,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.black54)),
            trailing: Text(timeText,
                style: const TextStyle(color: Colors.grey, fontSize: 12)),
          );
        },
      ),
    );
  }

  Future<bool?> _confirmDelete(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete chat?'),
        content: Text('Delete your chat with ${user.name}?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Delete', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
  }

  void _showOptions(BuildContext context, String chatId, FirestoreService fs) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Delete chat'),
              onTap: () async {
                Navigator.pop(ctx);
                await fs.deleteChat(chatId);
              },
            ),
          ],
        ),
      ),
    );
  }
}
