import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/movie.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  String _resolveUserId(String? userId) {
    return userId ?? FirebaseAuth.instance.currentUser?.uid ?? 'guest';
  }

  CollectionReference<Map<String, dynamic>> _collection(String uid) =>
      _db.collection('watchlists').doc(uid).collection('movies');

  Future<void> addMovie(Movie movie, {String? userId}) async {
    final uid = _resolveUserId(userId);
    final doc = _collection(uid).doc(movie.id.toString());
    await doc.set({
      'id': movie.id,
      'title': movie.title,
      'overview': movie.overview,
      'poster_path': movie.posterPath,
      'vote_average': movie.voteAverage,
      'added_at': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> removeMovie(int movieId, {String? userId}) async {
    final uid = _resolveUserId(userId);
    await _collection(uid).doc(movieId.toString()).delete();
  }

  Stream<bool> isInWatchlistStream(int movieId, {String? userId}) {
    final uid = _resolveUserId(userId);
    return _collection(uid)
        .doc(movieId.toString())
        .snapshots()
        .map((doc) => doc.exists);
  }

  Stream<List<Movie>> getWatchlist({String? userId}) {
    final uid = _resolveUserId(userId);
    return _collection(uid)
        .orderBy('added_at', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final data = doc.data();
              return Movie(
                id: data['id'] as int,
                title: data['title'] as String,
                overview: data['overview'] as String,
                posterPath: data['poster_path'] as String,
                voteAverage: (data['vote_average'] as num).toDouble(),
              );
            }).toList());
  }
}
