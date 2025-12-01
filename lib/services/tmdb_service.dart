import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/movie.dart';

class TmdbService {
  // Configuration en dur (à remplacer par vos valeurs si besoin)
  final String apiKey = "dfa79cd3bbc6a08dd13d81382dbe8c95"; // v3
  final String bearerToken = "eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiJkZmE3OWNkM2JiYzZhMDhkZDEzZDgxMzgyZGJlOGM5NSIsIm5iZiI6MTc2MjQxNDYyNy4yNzEwMDAxLCJzdWIiOiI2OTBjNTAyM2U3Njk0MzgyZDdmNmQzOWMiLCJzY29wZXMiOlsiYXBpX3JlYWQiXSwidmVyc2lvbiI6MX0.d2dgXe4Hdzu7uKyk18GD05_NmrkWMc0KX-yjIWn0-9M"; // v4 (Bearer)

  final String baseUrl = "https://api.themoviedb.org/3";
  final String language = "fr-FR";

  Map<String, String> _headers() {
    if (bearerToken.isNotEmpty) {
      return {
        'Authorization': 'Bearer $bearerToken',
        'Content-Type': 'application/json;charset=utf-8',
      };
    }
    return {
      'Content-Type': 'application/json;charset=utf-8',
    };
  }

  Uri _buildUri(String path, [Map<String, String>? query]) {
    final q = {
      'language': language,
      if (bearerToken.isEmpty) 'api_key': apiKey,
      ...?query,
    };
    return Uri.parse('$baseUrl/$path').replace(queryParameters: q);
  }

  Future<List<Movie>> getPopularMovies() async {
    final url = _buildUri('movie/popular');
    final response = await http.get(url, headers: _headers());
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List results = data['results'];
      return results.map((json) => Movie.fromJson(json)).toList();
    } else {
      throw Exception('Erreur lors du chargement des films populaires (${response.statusCode})');
    }
  }

  Future<Movie> getMovieDetails(int movieId) async {
    final url = _buildUri('movie/$movieId');
    final response = await http.get(url, headers: _headers());
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return Movie.fromJson(data);
    } else {
      throw Exception('Erreur lors du chargement des détails du film (${response.statusCode})');
    }
  }

  Future<List<Movie>> searchMovies(String query) async {
    if (query.trim().isEmpty) return [];
    final url = _buildUri('search/movie', {
      'query': query,
      'include_adult': 'false',
    });
    final response = await http.get(url, headers: _headers());
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List results = data['results'];
      return results.map((json) => Movie.fromJson(json)).toList();
    } else {
      throw Exception('Erreur lors de la recherche (${response.statusCode})');
    }
  }
}
