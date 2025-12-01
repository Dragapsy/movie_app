import 'package:flutter/material.dart';
import '../services/tmdb_service.dart';
import '../models/movie.dart';
import '../services/firestore_service.dart';

class DetailScreen extends StatelessWidget {
  final int movieId;
  const DetailScreen({super.key, required this.movieId});

  static const String _imageBase = 'https://image.tmdb.org/t/p/w500';

  @override
  Widget build(BuildContext context) {
    final tmdb = TmdbService();
    final firestore = FirestoreService();
    return Scaffold(
      appBar: AppBar(title: const Text('Détails du film')),
      body: FutureBuilder<Movie>(
        future: tmdb.getMovieDetails(movieId),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Erreur: ${snapshot.error}'));
          }
          final movie = snapshot.data;
          if (movie == null) {
            return const Center(child: Text('Film introuvable'));
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network('$_imageBase${movie.posterPath}', height: 300, fit: BoxFit.cover),
                ),
                const SizedBox(height: 16),
                Text(
                  movie.title,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text('Note: ${movie.voteAverage.toStringAsFixed(1)} / 10'),
                const SizedBox(height: 16),
                const Text('Résumé', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Text(movie.overview),
                const SizedBox(height: 24),
                StreamBuilder<bool>(
                  stream: firestore.isInWatchlistStream(movie.id),
                  builder: (context, inSnap) {
                    final inWatchlist = inSnap.data ?? false;
                    return SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          try {
                            if (inWatchlist) {
                              await firestore.removeMovie(movie.id);
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('${movie.title} retiré de la watchlist')),
                                );
                              }
                            } else {
                              await firestore.addMovie(movie);
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('${movie.title} ajouté à la watchlist')),
                                );
                              }
                            }
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Erreur: $e')),
                              );
                            }
                          }
                        },
                        icon: Icon(inWatchlist ? Icons.bookmark_remove : Icons.bookmark_add),
                        label: Text(inWatchlist ? 'Retirer de la watchlist' : 'Ajouter à la watchlist'),
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
