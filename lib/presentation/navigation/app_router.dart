import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';
import 'package:mivi/presentation/screens/home_screen.dart';
import 'package:mivi/presentation/screens/movie_detail_screen.dart';
import 'package:mivi/presentation/screens/search_screen.dart';
import 'package:mivi/presentation/screens/favorites_screen.dart';
import 'package:mivi/presentation/screens/watchlist_screen.dart';
import 'package:mivi/presentation/screens/profile_screen.dart';
import 'package:mivi/presentation/screens/edit_profile_screen.dart';
import 'package:mivi/presentation/screens/auth/login_screen.dart';
import 'package:mivi/presentation/screens/auth/register_screen.dart';
import 'package:mivi/data/mock_data/mock_movies.dart';
import 'package:mivi/data/models/movie_model.dart';
import 'package:mivi/data/services/guest_service.dart';
import 'package:mivi/presentation/screens/ai_chat_screen.dart';
import 'package:mivi/presentation/widgets/floating_ai_chat.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AppRouter {
  static final GuestService _guestService = GuestService();
  
  static final router = GoRouter(
    initialLocation: '/loading',
    redirect: (context, state) async {
      // Initialize guest service
      await _guestService.initialize();
      
      final isLoggedIn = Supabase.instance.client.auth.currentUser != null;
      final isGuestMode = _guestService.isGuestMode;
      final isAuthRoute = state.matchedLocation == '/login' || 
                         state.matchedLocation == '/register';
      final isLoadingRoute = state.matchedLocation == '/loading';

      // If on loading route, redirect based on auth status
      if (isLoadingRoute) {
        if (isLoggedIn || isGuestMode) {
          return '/';
        } else {
          return '/login';
        }
      }

      // If not logged in and not guest, redirect to login (except for auth routes)
      if (!isLoggedIn && !isGuestMode && !isAuthRoute) {
        return '/login';
      }

      // If logged in or guest and trying to access auth routes, redirect to home
      if ((isLoggedIn || isGuestMode) && isAuthRoute) {
        return '/';
      }

      return null;
    },
    routes: [
      // Loading route
      GoRoute(
        path: '/loading',
        builder: (context, state) => const LoadingScreen(),
      ),
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
            path: '/watchlist',
            builder: (context, state) => const WatchlistScreen(),
          ),
          GoRoute(
            path: '/profile',
            builder: (context, state) => const ProfileScreen(),
          ),
          GoRoute(
            path: '/edit-profile',
            builder: (context, state) => const EditProfileScreen(),
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
      // AI Chat route
      GoRoute(
        path: '/ai-chat',
        builder: (context, state) => const AIChatScreen(),
      ),
    ],
  );
}

// Loading screen widget
class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Scaffold(
      backgroundColor: colorScheme.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: colorScheme.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.movie_creation_outlined,
                size: 64,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'Mivi',
              style: TextStyle(
                color: colorScheme.onBackground,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            CircularProgressIndicator(
              color: colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'Loading...',
              style: TextStyle(
                color: colorScheme.onBackground.withOpacity(0.7),
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ScaffoldWithBottomNav extends StatelessWidget {
  final Widget child;

  const ScaffoldWithBottomNav({required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Scaffold(
      body: FloatingAIChatProvider(
        child: child,
        showFloatingChat: true,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: colorScheme.surface,
          selectedItemColor: colorScheme.primary,
          unselectedItemColor: colorScheme.onSurface.withOpacity(0.6),
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 12,
          ),
          elevation: 0,
          currentIndex: _calculateSelectedIndex(context),
          onTap: (int index) => _onItemTapped(index, context),
          items: [
            BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
            BottomNavigationBarItem(
            icon: Icon(Icons.search_outlined),
              activeIcon: Icon(Icons.search),
            label: 'Search',
          ),
            BottomNavigationBarItem(
            icon: Icon(Icons.favorite_outline),
              activeIcon: Icon(Icons.favorite),
            label: 'Favorites',
          ),
            BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        ),
      ),
    );
  }

  static int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).matchedLocation;
    if (location.startsWith('/search')) {
      return 1;
    }
    if (location.startsWith('/favorites')) {
      return 2;
    }
    if (location.startsWith('/profile')) {
      return 3;
    }
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