String chatIdFor(String uid1, String uid2) {
  final sorted = [uid1, uid2]..sort();
  return '${sorted[0]}-${sorted[1]}';
}

String formatLastSeen(DateTime? lastSeen, String privacy, bool frozen) {
  if (privacy == 'nobody' || frozen || lastSeen == null) {
    return 'last seen recently';
  }
  final now = DateTime.now();
  final diff = now.difference(lastSeen);
  final time = _formatTime(lastSeen);
  if (diff.inMinutes < 1) return 'online';
  if (diff.inHours < 24 && now.day == lastSeen.day) {
    return 'last seen today at $time';
  }
  if (diff.inDays < 2) {
    return 'last seen yesterday at $time';
  }
  if (diff.inDays < 7) {
    return 'last seen ${_weekday(lastSeen)} at $time';
  }
  return 'last seen ${lastSeen.day}/${lastSeen.month}/${lastSeen.year}';
}

String formatChatTime(DateTime dt) {
  final now = DateTime.now();
  final diff = now.difference(dt);
  final time = _formatTime(dt);
  if (diff.inHours < 24 && now.day == dt.day) return time;
  if (diff.inDays < 2) return 'Yesterday';
  if (diff.inDays < 7) return _weekday(dt);
  return '${dt.day}/${dt.month}/${dt.year}';
}

String formatMessageTime(DateTime dt) => _formatTime(dt);

String _formatTime(DateTime dt) {
  int hour = dt.hour;
  final ampm = hour >= 12 ? 'PM' : 'AM';
  hour = hour % 12;
  if (hour == 0) hour = 12;
  final minute = dt.minute.toString().padLeft(2, '0');
  return '$hour:$minute $ampm';
}

String _weekday(DateTime dt) {
  const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  return days[dt.weekday - 1];
}

String initialOf(String name) {
  if (name.isEmpty) return '?';
  return name.trim().substring(0, 1).toUpperCase();
}
