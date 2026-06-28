import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/token_model.dart';

/// Centralizes all Firestore CRUD operations.
class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ─── Users ───

  /// Fetches a single user by email. Returns null if not found.
  Future<UserModel?> getUser(String email) async {
    var doc = await _db.collection('users').doc(email).get();
    if (!doc.exists) return null;
    return UserModel.fromMap(email, doc.data()!);
  }

  /// Creates or overwrites a user document.
  Future<void> createUser(UserModel user) async {
    await _db.collection('users').doc(user.email).set(user.toMap());
  }

  /// Streams providers filtered by role.
  /// [filter] can be 'All', 'Hotelier', or 'Cab Driver'.
  Stream<List<UserModel>> getProvidersStream(String filter) {
    Query<Map<String, dynamic>> query;
    if (filter == 'All') {
      query = _db.collection('users').where('role', whereIn: ['Hotelier', 'Cab Driver']);
    } else {
      query = _db.collection('users').where('role', isEqualTo: filter);
    }
    return query.snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => UserModel.fromMap(doc.id, doc.data())).toList());
  }

  // ─── Tokens ───

  /// Streams tokens for a user, sorted by createdAt descending.
  Stream<List<TokenModel>> getTokensStream(String queryField, String email) {
    return _db
        .collection('tokens')
        .where(queryField, isEqualTo: email)
        .snapshots()
        .map((snapshot) {
      var tokens = snapshot.docs.map((doc) => TokenModel.fromDoc(doc)).toList();
      tokens.sort((a, b) {
        if (a.createdAt == null && b.createdAt == null) return 0;
        if (a.createdAt == null) return 1;
        if (b.createdAt == null) return -1;
        return b.createdAt!.compareTo(a.createdAt!);
      });
      return tokens;
    });
  }

  /// Creates a new token document.
  Future<void> createToken(Map<String, dynamic> data) async {
    await _db.collection('tokens').add(data);
  }

  /// Updates a single field on a token document.
  Future<void> updateTokenField(String tokenId, String field, dynamic value) async {
    await _db.collection('tokens').doc(tokenId).update({field: value});
  }

  /// Updates multiple fields on a token document.
  Future<void> updateTokenFields(String tokenId, Map<String, dynamic> fields) async {
    await _db.collection('tokens').doc(tokenId).update(fields);
  }

  /// Reads a fresh copy of a token document.
  Future<TokenModel> getToken(String tokenId) async {
    var doc = await _db.collection('tokens').doc(tokenId).get();
    return TokenModel.fromDoc(doc);
  }

  /// Fetches all tokens for a user (one-shot, not a stream).
  Future<List<TokenModel>> getTokensOnce(String queryField, String email) async {
    var snapshot = await _db
        .collection('tokens')
        .where(queryField, isEqualTo: email)
        .get();
    return snapshot.docs.map((doc) => TokenModel.fromDoc(doc)).toList();
  }
}
