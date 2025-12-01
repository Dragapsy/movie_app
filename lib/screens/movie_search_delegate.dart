import 'package:flutter/material.dart';
import '../services/tmdb_service.dart';
import '../models/movie.dart';
import '../widgets/movie_card.dart';
import 'detail_screen.dart';

class MovieSearchDelegate extends SearchDelegate<Movie?> {
  final TmdbService _tmdb = TmdbService();

  @override
  String get searchFieldLabel => 'Rechercher un film';

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          icon: const Icon(Icons.clear),
            tooltip: 'Effacer',
          onPressed: () {
            query = '';
            showSuggestions(context);
          },
        ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      tooltip: 'Retour',
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    if (query.trim().isEmpty) {
      return const Center(child: Text('Entrez un mot-clé pour rechercher.'));
    }
    return FutureBuilder<List<Movie>>(
      future: _tmdb.searchMovies(query.trim()),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Erreur: ${snapshot.error}'));
        }
        final results = snapshot.data ?? [];
        if (results.isEmpty) {
          return const Center(child: Text('Aucun résultat'));
        }
        return GridView.builder(
          padding: const EdgeInsets.all(8),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 0.62,
          ),
          itemCount: results.length,
          itemBuilder: (context, index) {
            final movie = results[index];
            return MovieCard(
              movie: movie,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DetailScreen(movieId: movie.id),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    // Suggestions simples : afficher des résultats en direct si >= 2 caractères.
    if (query.trim().length < 2) {
      return const Center(child: Text('Tapez au moins 2 caractères...'));
    }
    return FutureBuilder<List<Movie>>(
      future: _tmdb.searchMovies(query.trim()),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Erreur: ${snapshot.error}'));
        }
        final results = snapshot.data ?? [];
        if (results.isEmpty) {
          return const Center(child: Text('Aucun résultat'));
        }
        return ListView.builder(
          itemCount: results.length,
          itemBuilder: (context, index) {
            final movie = results[index];
            return ListTile(
              leading: const Icon(Icons.movie),
              title: Text(movie.title),
              onTap: () {
                query = movie.title;
                showResults(context);
              },
            );
          },
        );
      },
    );
  }
}

