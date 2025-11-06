import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/movie.dart';

class TmdbService {
  final String apiKey = "dfa79cd3bbc6a08dd13d81382dbe8c95";
  final String baseUrl = "https://api.themoviedb.org/3";

  Future<List<Movie>> getPopularMovies() async {
    final url = Uri.parse('$baseUrl/movie/popular?api_key=$apiKey&language=fr-FR');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List results = data['results'];
      return results.map((json) => Movie.fromJson(json)).toList();
    } else {
      throw Exception('Erreur lors du chargement des films populaires');
    }
  }

  Future<Movie> getMovieDetails(int movieId) async {
    final url = Uri.parse('$baseUrl/movie/$movieId?api_key=$apiKey&language=fr-FR');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return Movie.fromJson(data);
    } else {
      throw Exception('Erreur lors du chargement des détails du film');
    }
  }
}
