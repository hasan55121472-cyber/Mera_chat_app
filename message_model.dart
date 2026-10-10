class MessageModel {
  final String id;
  final String text;
  final String originalText;
  final String senderId;
  final DateTime timestamp;
  final String type; // 'text' | 'voice'
  final String voiceUrl;
  final bool isDeletedForEveryone;
  final List<String> deletedFor;

  MessageModel({
    required this.id,
    required this.text,
    required this.originalText,
    required this.senderId,
    required this.timestamp,
    this.type = 'text',
    this.voiceUrl = '',
    this.isDeletedForEveryone = false,
    this.deletedFor = const [],
  });

  bool isDeletedForMe(String uid) => deletedFor.contains(uid);

  Map<String, dynamic> toMap() {
    return {
      'text': text,
      'originalText': originalText,
      'senderId': senderId,
      'timestamp': timestamp,
      'type': type,
      'voiceUrl': voiceUrl,
      'isDeletedForEveryone': isDeletedForEveryone,
      'deletedFor': deletedFor,
    };
  }

  factory MessageModel.fromMap(Map<String, dynamic> map, String id) {
    return MessageModel(
      id: id,
      text: map['text'] as String? ?? '',
      originalText: map['originalText'] as String? ?? '',
      senderId: map['senderId'] as String? ?? '',
      timestamp: _fromTimestamp(map['timestamp']) ?? DateTime.now(),
      type: map['type'] as String? ?? 'text',
      voiceUrl: map['voiceUrl'] as String? ?? '',
      isDeletedForEveryone: map['isDeletedForEveryone'] as bool? ?? false,
      deletedFor: List<String>.from(map['deletedFor'] as List? ?? []),
    );
  }

  static DateTime? _fromTimestamp(dynamic v) {
    if (v == null) return null;
    if (v is DateTime) return v;
    try {
      return (v as dynamic).toDate() as DateTime;
    } catch (_) {
      return null;
    }
  }
}
