import 'package:flutter/material.dart';

class StatusScreen extends StatelessWidget {
  const StatusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              leading: Stack(
                children: [
                  const CircleAvatar(
                    radius: 28,
                    backgroundColor: Color(0xFF075E54),
                    child: Icon(Icons.person, color: Colors.white, size: 30),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Color(0xFF25D366),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.add, color: Colors.white, size: 20),
                    ),
                  ),
                ],
              ),
              title: const Text("My Status", style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: const Text("Tap to add status update"),
              onTap: () {},
            ),
            const Divider(),
            const Padding(
              padding: EdgeInsets.all(12.0),
              child: Text("Recent updates", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w500)),
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF25D366), width: 2),
                ),
                child: const CircleAvatar(
                  backgroundColor: Colors.grey,
                  child: Icon(Icons.person, color: Colors.white),
                ),
              ),
              title: const Text("Ali Khan"),
              subtitle: const Text("Today, 10:30 AM"),
              onTap: () {},
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF25D366), width: 2),
                ),
                child: const CircleAvatar(
                  backgroundColor: Colors.grey,
                  child: Icon(Icons.person, color: Colors.white),
                ),
              ),
              title: const Text("Sara Malik"),
              subtitle: const Text("Today, 9:15 AM"),
              onTap: () {},
            ),
          ],
        ),
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton.small(
            backgroundColor: Colors.grey[200],
            onPressed: () {},
            child: const Icon(Icons.edit, color: Colors.black87),
          ),
          const SizedBox(height: 12),
          FloatingActionButton(
            backgroundColor: const Color(0xFF25D366),
            onPressed: () {},
            child: const Icon(Icons.camera_alt),
          ),
        ],
      ),
    );
  }
}
