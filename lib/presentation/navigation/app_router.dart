import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mivi/presentation/screens/home_screen.dart';
import 'package:mivi/presentation/screens/movie_detail_screen.dart';
import 'package:mivi/presentation/screens/search_screen.dart';
import 'package:mivi/presentation/screens/favorites_screen.dart';
import 'package:mivi/presentation/screens/profile_screen.dart';
import 'package:mivi/presentation/screens/auth/login_screen.dart';
import 'package:mivi/presentation/screens/auth/register_screen.dart';
import 'package:mivi/data/mock_data/mock_movies.dart';
import 'package:mivi/data/models/movie_model.dart';

class AppRouter {
  static final router = GoRouter(
    initialLocation: '/login',
    // Temporarily disable redirect logic for testing
    // redirect: (context, state) {
    //   // TODO: Implement actual auth state check
    //   final isLoggedIn = false; // This should come from your auth state management
    //   final isAuthRoute = state.matchedLocation == '/login' || state.matchedLocation == '/register';

    //   if (!isLoggedIn && !isAuthRoute) {
    //     return '/login';
    //   }

    //   if (isLoggedIn && isAuthRoute) {
    //     return '/';
    //   }

    //   return null;
    // },
    routes: [
      // Auth routes
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      // Main app routes
      ShellRoute(
        builder: (context, state, child) {
          return ScaffoldWithBottomNav(child: child);
        },
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: '/search',
            builder: (context, state) => const SearchScreen(),
          ),
          GoRoute(
            path: '/favorites',
            builder: (context, state) => const FavoritesScreen(),
          ),
          GoRoute(
            path: '/profile',
            builder: (context, state) => const ProfileScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/movie/:id',
        builder: (context, state) {
          final movie = state.extra as Movie? ?? 
              MockMovies.movies.firstWhere(
                (m) => m.id.toString() == state.pathParameters['id'],
                orElse: () => MockMovies.movies.first,
              );
          return MovieDetailScreen(movie: movie);
        },
      ),
    ],
  );
}

class ScaffoldWithBottomNav extends StatelessWidget {
  const ScaffoldWithBottomNav({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _calculateSelectedIndex(context),
        onDestinationSelected: (int idx) => _onItemTapped(idx, context),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.search_outlined),
            selectedIcon: Icon(Icons.search),
            label: 'Search',
          ),
          NavigationDestination(
            icon: Icon(Icons.favorite_outline),
            selectedIcon: Icon(Icons.favorite),
            label: 'Favorites',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  int _calculateSelectedIndex(BuildContext context) {
    final String path = GoRouterState.of(context).uri.path;
    if (path.startsWith('/search')) return 1;
    if (path.startsWith('/favorites')) return 2;
    if (path.startsWith('/profile')) return 3;
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        GoRouter.of(context).go('/');
        break;
      case 1:
        GoRouter.of(context).go('/search');
        break;
      case 2:
        GoRouter.of(context).go('/favorites');
        break;
      case 3:
        GoRouter.of(context).go('/profile');
        break;
    }
  }
} 