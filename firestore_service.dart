import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/message_model.dart';
import '../utils/helpers.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get usersRef =>
      _db.collection('users');

  // ---------- Users ----------
  Stream<List<UserModel>> usersStream() {
    return usersRef.snapshots().map((snap) =>
        snap.docs.map((d) => UserModel.fromMap(d.data())).toList());
  }

  Stream<UserModel> userStream(String uid) {
    return usersRef.doc(uid).snapshots().map((d) =>
        UserModel.fromMap(d.data()!));
  }

  Future<void> updateUserFields(String uid, Map<String, dynamic> fields) {
    return usersRef.doc(uid).set(fields, SetOptions(merge: true));
  }

  Future<void> updateLastSeen(String uid) {
    return usersRef.doc(uid).set({
      'lastSeen': DateTime.now(),
    }, SetOptions(merge: true));
  }

  // ---------- Chats ----------
  String chatIdOf(String uid1, String uid2) => chatIdFor(uid1, uid2);

  CollectionReference<Map<String, dynamic>> messagesRef(String chatId) =>
      _db.collection('chats').doc(chatId).collection('messages');

  Stream<List<MessageModel>> messagesStream(String chatId) {
    return messagesRef(chatId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => MessageModel.fromMap(d.data(), d.id))
            .toList());
  }

  Future<void> sendMessage(String chatId, MessageModel msg) {
    return messagesRef(chatId).add(msg.toMap());
  }

  /// Delete the whole chat for the current user (removes the subcollection).
  Future<void> deleteChat(String chatId) async {
    final snap = await messagesRef(chatId).get();
    for (final doc in snap.docs) {
      await doc.reference.delete();
    }
  }

  /// Delete for everyone:
  /// - sets isDeletedForEveryone = true
  /// - replaces text with the deleted marker
  /// - keeps originalText intact
  Future<void> deleteForEveryone(String chatId, String messageId) {
    return messagesRef(chatId).doc(messageId).update({
      'text': '🚫 This message was deleted',
      'isDeletedForEveryone': true,
    });
  }

  /// Delete for me: add my uid to the deletedFor array.
  Future<void> deleteForMe(String chatId, String messageId, String uid) {
    return messagesRef(chatId).doc(messageId).update({
      'deletedFor': FieldValue.arrayUnion([uid]),
    });
  }

  // ---------- Status ----------
  CollectionReference<Map<String, dynamic>> get statusRef =>
      _db.collection('statuses');

  Stream<List<QueryDocumentSnapshot<Map<String, dynamic>>>>
      allStatusStream() {
    final cutoff = DateTime.now().subtract(const Duration(hours: 24));
    return statusRef
        .where('createdAt', isGreaterThan: cutoff)
        .snapshots()
        .map((s) => s.docs);
  }

  Future<void> addStatus(Map<String, dynamic> data) {
    return statusRef.add(data);
  }

  Future<void> markStatusViewed(String statusId, String uid) {
    return statusRef.doc(statusId).update({
      'viewedBy': FieldValue.arrayUnion([uid]),
    });
  }
}
