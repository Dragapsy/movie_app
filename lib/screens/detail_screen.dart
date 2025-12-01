import 'package:flutter/material.dart';
import '../services/tmdb_service.dart';
import '../models/movie.dart';

class DetailScreen extends StatelessWidget {
  final int movieId;
  const DetailScreen({super.key, required this.movieId});

  static const String _imageBase = 'https://image.tmdb.org/t/p/w500';

  @override
  Widget build(BuildContext context) {
    final tmdb = TmdbService();
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
              ],
            ),
          );
        },
      ),
    );
  }
}

