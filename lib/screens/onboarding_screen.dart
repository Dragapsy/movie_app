import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();

  int _currentPage = 0;

  final List<Map<String, dynamic>> _pages = [
    {
      'icon': Icons.movie,
      'title': 'Bienvenue',
      'desc': 'Découvrez les meilleurs films du moment.'
    },
    {
      'icon': Icons.star,
      'title': 'Favoris',
      'desc': 'Ajoutez vos films préférés à votre liste.'
    },
    {
      'icon': Icons.search,
      'title': 'Recherche',
      'desc': 'Trouvez rapidement n’importe quel film.'
    },
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _pages.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemBuilder: (context, index) {
                  final page = _pages[index];
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(page['icon'], size: 100, color: Colors.blue),
                      SizedBox(height: 32),
                      Text(
                        page['title'],
                        style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32.0),
                        child: Text(
                          page['desc'],
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 18, color: Colors.grey[700]),
                        ),
                      ),
                      if (index == _pages.length - 1)
                        Padding(
                          padding: const EdgeInsets.only(top: 40.0),
                          child: ElevatedButton(
                            onPressed: () {
                              // TODO: Navigate to Auth Wrapper
                            },
                            child: Text('Commencer'),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
            SizedBox(height: 24),
            SmoothPageIndicator(
              controller: _controller,
              count: _pages.length,
              effect: WormEffect(
                dotHeight: 12,
                dotWidth: 12,
                activeDotColor: Colors.blue,
                dotColor: Colors.grey.shade300,
              ),
            ),
            SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

