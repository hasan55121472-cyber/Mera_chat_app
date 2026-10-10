class StatusModel {
  final String id;
  final String uid;
  final String name;
  final String photoUrl;
  final String mediaUrl;
  final String type; // 'image' | 'video'
  final String caption;
  final DateTime createdAt;
  final List<String> viewedBy;

  StatusModel({
    required this.id,
    required this.uid,
    required this.name,
    required this.photoUrl,
    required this.mediaUrl,
    required this.type,
    this.caption = '',
    required this.createdAt,
    this.viewedBy = const [],
  });

  bool get isExpired =>
      DateTime.now().difference(createdAt).inHours >= 24;

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'photoUrl': photoUrl,
      'mediaUrl': mediaUrl,
      'type': type,
      'caption': caption,
      'createdAt': createdAt,
      'viewedBy': viewedBy,
    };
  }

  factory StatusModel.fromMap(Map<String, dynamic> map, String id) {
    return StatusModel(
      id: id,
      uid: map['uid'] as String? ?? '',
      name: map['name'] as String? ?? '',
      photoUrl: map['photoUrl'] as String? ?? '',
      mediaUrl: map['mediaUrl'] as String? ?? '',
      type: map['type'] as String? ?? 'image',
      caption: map['caption'] as String? ?? '',
      createdAt: _fromTimestamp(map['createdAt']) ?? DateTime.now(),
      viewedBy: List<String>.from(map['viewedBy'] as List? ?? []),
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
