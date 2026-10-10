class UserModel {
  final String uid;
  final String name;
  final String email;
  final String phone;
  final String photoUrl;
  final String about;
  final DateTime? lastSeen;
  final String lastSeenPrivacy; // 'everyone' | 'nobody'
  final String photoPrivacy; // 'everyone' | 'nobody'
  final bool freezeLastSeen;
  final bool antiDeleteEnabled;
  final List<String> status;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.phone,
    required this.photoUrl,
    required this.about,
    this.lastSeen,
    this.lastSeenPrivacy = 'everyone',
    this.photoPrivacy = 'everyone',
    this.freezeLastSeen = false,
    this.antiDeleteEnabled = false,
    this.status = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'phone': phone,
      'photoUrl': photoUrl,
      'about': about,
      'lastSeen': lastSeen != null ? _toTimestamp(lastSeen!) : null,
      'lastSeenPrivacy': lastSeenPrivacy,
      'photoPrivacy': photoPrivacy,
      'freezeLastSeen': freezeLastSeen,
      'antiDeleteEnabled': antiDeleteEnabled,
      'status': status,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] as String? ?? '',
      name: map['name'] as String? ?? '',
      email: map['email'] as String? ?? '',
      phone: map['phone'] as String? ?? '',
      photoUrl: map['photoUrl'] as String? ?? '',
      about: map['about'] as String? ?? 'Hey there! I am using WhatsApp Clone.',
      lastSeen: _fromTimestamp(map['lastSeen']),
      lastSeenPrivacy: map['lastSeenPrivacy'] as String? ?? 'everyone',
      photoPrivacy: map['photoPrivacy'] as String? ?? 'everyone',
      freezeLastSeen: map['freezeLastSeen'] as bool? ?? false,
      antiDeleteEnabled: map['antiDeleteEnabled'] as bool? ?? false,
      status: List<String>.from(map['status'] as List? ?? []),
    );
  }

  UserModel copyWith({
    String? name,
    String? email,
    String? phone,
    String? photoUrl,
    String? about,
    DateTime? lastSeen,
    String? lastSeenPrivacy,
    String? photoPrivacy,
    bool? freezeLastSeen,
    bool? antiDeleteEnabled,
    List<String>? status,
  }) {
    return UserModel(
      uid: uid,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      photoUrl: photoUrl ?? this.photoUrl,
      about: about ?? this.about,
      lastSeen: lastSeen ?? this.lastSeen,
      lastSeenPrivacy: lastSeenPrivacy ?? this.lastSeenPrivacy,
      photoPrivacy: photoPrivacy ?? this.photoPrivacy,
      freezeLastSeen: freezeLastSeen ?? this.freezeLastSeen,
      antiDeleteEnabled: antiDeleteEnabled ?? this.antiDeleteEnabled,
      status: status ?? this.status,
    );
  }

  static dynamic _toTimestamp(DateTime dt) => dt;
  static DateTime? _fromTimestamp(dynamic v) {
    if (v == null) return null;
    if (v is DateTime) return v;
    // firebase Timestamp has toDate()
    try {
      return (v as dynamic).toDate() as DateTime;
    } catch (_) {
      return null;
    }
  }
}
