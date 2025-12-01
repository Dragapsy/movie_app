import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/tmdb_service.dart';
import '../models/movie.dart';
import '../widgets/movie_card.dart';
import 'detail_screen.dart';
import 'watchlist_screen.dart';
import 'auth_screen.dart';
import '../providers/theme_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final TmdbService _tmdb = TmdbService();
  final TextEditingController _searchController = TextEditingController();
  List<Movie> _searchResults = [];
  bool _searching = false;
  DateTime _lastQueryTime = DateTime.fromMillisecondsSinceEpoch(0);

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() async {
    final query = _searchController.text.trim();
    final now = DateTime.now();
    // Debounce simple (400ms)
    if (now.difference(_lastQueryTime).inMilliseconds < 400) return;
    _lastQueryTime = now;
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
      });
      return;
    }
    setState(() {
      _searching = true;
    });
    try {
      final results = await _tmdb.searchMovies(query);
      if (mounted) {
        setState(() {
          _searchResults = results;
        });
      }
    } catch (e) {
      // Ignorer ou afficher un message léger
    } finally {
      if (mounted) {
        setState(() {
          _searching = false;
        });
      }
    }
  }

  Widget _buildMoviesGrid(List<Movie> movies) {
    if (movies.isEmpty) {
      return const Center(child: Text('Aucun film à afficher'));
    }
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          childAspectRatio: 0.62,
        ),
        itemCount: movies.length,
        itemBuilder: (context, index) {
          final movie = movies[index];
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    Widget body;
    switch (_currentIndex) {
      case 0:
        body = Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            _onSearchChanged();
                          },
                        )
                      : null,
                  hintText: 'Rechercher un film...',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onChanged: (_) => _onSearchChanged(),
              ),
            ),
            Expanded(
              child: _searchController.text.isNotEmpty
                  ? (_searching
                      ? const Center(child: CircularProgressIndicator())
                      : _buildMoviesGrid(_searchResults))
                  : FutureBuilder<List<Movie>>(
                      future: _tmdb.getPopularMovies(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState != ConnectionState.done) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        if (snapshot.hasError) {
                          return Center(child: Text('Erreur: ${snapshot.error}'));
                        }
                        final movies = snapshot.data ?? [];
                        return _buildMoviesGrid(movies);
                      },
                    ),
            ),
          ],
        );
        break;
      case 1:
        body = const WatchlistScreen();
        break;
      case 2:
        body = const AuthScreen();
        break;
      default:
        body = const SizedBox();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _currentIndex == 0
              ? 'Films populaires'
              : _currentIndex == 1
                  ? 'Ma watchlist'
                  : 'Compte',
        ),
        actions: [
          Consumer<ThemeProvider>(
            builder: (context, tp, _) => IconButton(
              tooltip: tp.isDarkMode ? 'Mode clair' : 'Mode sombre',
              icon: Icon(tp.isDarkMode ? Icons.light_mode : Icons.dark_mode),
              onPressed: () => tp.toggleTheme(),
            ),
          ),
        ],
      ),
      body: body,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.movie), label: 'Films'),
          BottomNavigationBarItem(icon: Icon(Icons.bookmark), label: 'Watchlist'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Compte'),
        ],
      ),
    );
  }
}
