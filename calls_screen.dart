import 'package:flutter/material.dart';

class CallsScreen extends StatelessWidget {
  const CallsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> calls = [
      {"name": "Ali Khan", "time": "Today, 2:30 PM", "type": "incoming", "isVideo": false},
      {"name": "Ahmed Raza", "time": "Today, 11:15 AM", "type": "outgoing", "isVideo": true},
      {"name": "Sara Malik", "time": "Yesterday, 9:45 PM", "type": "missed", "isVideo": false},
      {"name": "Usman", "time": "Yesterday, 5:20 PM", "type": "incoming", "isVideo": true},
    ];

    return Scaffold(
      body: ListView.separated(
        itemCount: calls.length,
        separatorBuilder: (c, i) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final call = calls[index];
          IconData callIcon;
          Color iconColor;
          if (call['type'] == 'missed') {
            callIcon = Icons.call_received;
            iconColor = Colors.red;
          } else if (call['type'] == 'outgoing') {
            callIcon = Icons.call_made;
            iconColor = Colors.green;
          } else {
            callIcon = Icons.call_received;
            iconColor = Colors.green;
          }

          return ListTile(
            leading: const CircleAvatar(
              backgroundColor: Color(0xFF075E54),
              child: Icon(Icons.person, color: Colors.white),
            ),
            title: Text(call['name'], style: const TextStyle(fontWeight: FontWeight.w500)),
            subtitle: Row(
              children: [
                Icon(callIcon, size: 16, color: iconColor),
                const SizedBox(width: 4),
                Text(call['time']),
              ],
            ),
            trailing: Icon(call['isVideo']? Icons.videocam : Icons.call, color: const Color(0xFF075E54)),
            onTap: () {},
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF25D366),
        onPressed: () {},
        child: const Icon(Icons.add_call),
      ),
    );
  }
}
