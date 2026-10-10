import 'package:flutter/material.dart';
import '../utils/theme.dart';

class CallsScreen extends StatelessWidget {
  const CallsScreen({super.key});

  static const _calls = <_CallEntry>[
    _CallEntry(name: 'Ahmed', type: 'voice', incoming: true, time: 'Today, 9:30 AM'),
    _CallEntry(name: 'Sara', type: 'video', incoming: false, time: 'Yesterday, 4:15 PM'),
    _CallEntry(name: 'Ali', type: 'voice', incoming: false, time: 'Mon, 8:00 PM'),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        const SizedBox(height: 8),
        const ListTile(
          leading: CircleAvatar(
            backgroundColor: AppTheme.primaryLight,
            child: Icon(Icons.phone_in_talk, color: Colors.white),
          ),
          title: Text('Start a new call',
              style: TextStyle(fontWeight: FontWeight.w600)),
          subtitle: Text('Voice or video'),
        ),
        const Divider(),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text('Recent',
              style: TextStyle(
                  color: AppTheme.primaryLight,
                  fontWeight: FontWeight.w600,
                  fontSize: 13)),
        ),
        ..._calls.map((c) => ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.grey.shade300,
                child: Text(c.name[0],
                    style: const TextStyle(color: AppTheme.primary)),
              ),
              title: Text(c.name,
                  style: const TextStyle(fontWeight: FontWeight.w600)),
              subtitle: Row(
                children: [
                  Icon(
                    c.incoming ? Icons.call_received : Icons.call_made,
                    size: 14,
                    color: c.incoming ? AppTheme.primaryLight : Colors.red,
                  ),
                  const SizedBox(width: 4),
                  Text(c.time,
                      style: const TextStyle(color: Colors.grey, fontSize: 13)),
                ],
              ),
              trailing: Icon(
                c.type == 'video' ? Icons.videocam : Icons.call,
                color: AppTheme.primaryLight,
              ),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text(
                          'Calls are a placeholder in this demo build')),
                );
              },
            )),
      ],
    );
  }
}

class _CallEntry {
  final String name;
  final String type;
  final bool incoming;
  final String time;
  const _CallEntry({
    required this.name,
    required this.type,
    required this.incoming,
    required this.time,
  });
}
