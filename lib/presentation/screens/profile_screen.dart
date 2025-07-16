import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mivi/presentation/widgets/theme_selector_widget.dart';
import 'package:mivi/data/services/guest_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/widgets.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin, RouteAware {
  RouteObserver<ModalRoute<void>>? _routeObserver;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _routeObserver = GoRouter.of(context)
        .routerDelegate
        .navigatorKey
        .currentState
        ?.widget
        .observers
        .whereType<RouteObserver<ModalRoute<void>>>()
        .firstOrNull;
    _routeObserver?.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void dispose() {
    _routeObserver?.unsubscribe(this);
    _animationController.dispose();
    super.dispose();
  }

  @override
  void didPopNext() {
    // Called when coming back to this screen
    if (!_loading && !_isGuest) {
      _fetchProfile();
    }
  }

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  Map<String, dynamic>? _profile;
  bool _loading = true;
  bool _isGuest = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
          CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
        );
    _animationController.forward();
    _checkUserStatus();
  }

  Future<void> _checkUserStatus() async {
    final guestService = GuestService();
    _isGuest = guestService.isGuestMode;

    if (_isGuest) {
      // Get guest profile
      _profile = guestService.getGuestProfile();
      setState(() {
        _loading = false;
      });
    } else {
      // Get user profile from Supabase
      await _fetchProfile();
    }
  }

  Future<void> _fetchProfile() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        setState(() {
          _loading = false;
        });
        return;
      }

      final response = await Supabase.instance.client
          .from('profiles')
          .select()
          .eq('id', user.id)
          .single();
      setState(() {
        _profile = response;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> _handleLogout() async {
    if (_isGuest) {
      // Clear guest data and go to login
      await GuestService().clearGuestData();
      if (mounted) context.go('/login');
    } else {
      // Supabase logout
      await Supabase.instance.client.auth.signOut();
      if (mounted) context.go('/login');
    }
  }

  Future<void> _handleSignUp() async {
    // Go to register screen for guest users
    context.go('/register');
  }

  // @override
  // void dispose() {
  //   _animationController.dispose();
  //   super.dispose();
  // }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (_loading) {
      return Scaffold(
        backgroundColor: colorScheme.background,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: colorScheme.background,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              // Enhanced App Bar
              SliverAppBar(
                backgroundColor: colorScheme.background,
                floating: true,
                expandedHeight: 100,
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          colorScheme.background,
                          colorScheme.background.withOpacity(0.8),
                        ],
                      ),
                    ),
                  ),
                ),
                title: SlideTransition(
                  position: _slideAnimation,
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: colorScheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          _isGuest ? Icons.person_outline : Icons.person,
                          color: colorScheme.primary,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        _isGuest ? 'Guest Profile' : 'Profile',
                        style: TextStyle(
                          color: colorScheme.onBackground,
                          fontWeight: FontWeight.bold,
                          fontSize: 24,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
                actions: [
                  Container(
                    margin: const EdgeInsets.only(right: 16),
                    decoration: BoxDecoration(
                      color: colorScheme.error.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      icon: Icon(
                        _isGuest ? Icons.login_rounded : Icons.logout_rounded,
                        color: colorScheme.error,
                        size: 24,
                      ),
                      onPressed: _handleLogout,
                    ),
                  ),
                ],
                elevation: 0,
              ),
              // Profile Header
              SliverToBoxAdapter(
                child: SlideTransition(
                  position: _slideAnimation,
                  child: _buildProfileHeader(colorScheme),
                ),
              ),
              // Guest Benefits (if guest)
              if (_isGuest)
                SliverToBoxAdapter(
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: _buildGuestBenefits(colorScheme),
                  ),
                ),
              // Main Menu
              SliverToBoxAdapter(
                child: SlideTransition(
                  position: _slideAnimation,
                  child: _buildMainMenu(colorScheme),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(ColorScheme colorScheme) {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colorScheme.surfaceVariant.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.surfaceVariant.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Colors.grey[200],
            ),
            child: _isGuest
                ? Icon(
                    Icons.person_outline,
                    size: 40,
                    color: colorScheme.onSecondary,
                  )
                : (_profile?['avatar_url'] != null &&
                      _profile?['avatar_url'].toString().isNotEmpty == true)
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.network(
                      _profile!['avatar_url'],
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Icon(
                        Icons.person,
                        size: 40,
                        color: colorScheme.onPrimary,
                      ),
                    ),
                  )
                : Icon(Icons.person, size: 40, color: colorScheme.onPrimary),
          ),
          const SizedBox(width: 20),
          // User Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _profile?['username'] ?? 'Guest User',
                  style: TextStyle(
                    color: colorScheme.onBackground,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                if (_isGuest)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.secondary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: colorScheme.secondary.withOpacity(0.3),
                      ),
                    ),
                    child: Text(
                      'Guest Mode',
                      style: TextStyle(
                        color: colorScheme.secondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  )
                else ...[
                  Text(
                    _profile?['email'] ?? '',
                    style: TextStyle(
                      color: colorScheme.onBackground.withOpacity(0.7),
                      fontSize: 14,
                    ),
                  ),
                  if (_profile?['bio'] != null &&
                      _profile?['bio'].toString().isNotEmpty == true)
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        _profile!['bio'],
                        style: TextStyle(
                          color: colorScheme.onBackground.withOpacity(0.6),
                          fontSize: 13,
                          fontStyle: FontStyle.italic,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
                const SizedBox(height: 8),
                if (_isGuest)
                  Text(
                    'Local data only • No sync',
                    style: TextStyle(
                      color: colorScheme.onBackground.withOpacity(0.5),
                      fontSize: 12,
                    ),
                  )
                else
                  Text(
                    'Member since ${DateTime.now().year}',
                    style: TextStyle(
                      color: colorScheme.onBackground.withOpacity(0.5),
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
    // Đã thay thế bằng RouteAware ở phía trên
  }

  Widget _buildGuestBenefits(ColorScheme colorScheme) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.primary.withOpacity(0.05),
            colorScheme.secondary.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.primary.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.account_circle_outlined,
                color: colorScheme.primary,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Create Account',
                style: TextStyle(
                  color: colorScheme.onBackground,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Unlock premium features by creating an account:',
            style: TextStyle(
              color: colorScheme.onBackground.withOpacity(0.7),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 12),
          ...GuestService().getGuestLimitations().map(
            (limitation) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    color: colorScheme.primary,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      limitation,
                      style: TextStyle(
                        color: colorScheme.onBackground.withOpacity(0.7),
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _handleSignUp,
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.account_circle),
              label: const Text(
                'Create Account',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainMenu(ColorScheme colorScheme) {
    return Container(
      margin: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // My Lists
          _buildMenuSection(
            colorScheme,
            title: 'My Lists',
            items: [
              _buildMenuItem(
                colorScheme,
                icon: Icons.favorite_outline,
                title: 'Favorites',
                subtitle: 'Your favorite movies',
                onTap: () {
                  context.push('/favorites');
                },
              ),
            ],
          ),
          Divider(
            color: colorScheme.surfaceVariant.withOpacity(0.5),
            height: 1,
          ),
          // App Settings
          _buildMenuSection(
            colorScheme,
            title: 'App Settings',
            items: [
              _buildMenuItem(
                colorScheme,
                icon: Icons.palette_outlined,
                title: 'Theme Settings',
                subtitle: 'Choose your preferred theme',
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) => const ThemeSelectorWidget(),
                  );
                },
              ),
              _buildMenuItem(
                colorScheme,
                icon: Icons.notifications_outlined,
                title: 'Notifications',
                subtitle: 'Manage your notifications',
                onTap: () {
                  // TODO: Implement notifications settings
                },
                enabled: !_isGuest,
              ),
              _buildMenuItem(
                colorScheme,
                icon: Icons.language_outlined,
                title: 'Language',
                subtitle: 'Change app language',
                onTap: () {
                  // TODO: Implement language settings
                },
              ),
            ],
          ),
          Divider(
            color: colorScheme.surfaceVariant.withOpacity(0.5),
            height: 1,
          ),
          // Account Settings (only for logged users)
          if (!_isGuest) ...[
            _buildMenuSection(
              colorScheme,
              title: 'Account',
              items: [
                _buildMenuItem(
                  colorScheme,
                  icon: Icons.person_outline,
                  title: 'Edit Profile',
                  subtitle: 'Update your personal information',
                  onTap: () async {
                    final result = await context.push('/edit-profile');
                    if (result == true) {
                      _fetchProfile();
                    }
                  },
                ),
                _buildMenuItem(
                  colorScheme,
                  icon: Icons.lock_outline,
                  title: 'Change Password',
                  subtitle: 'Update your login password',
                  onTap: () async {
                    final result = await context.push('/change-password');
                    if (result == true) {
                      // optionally show dialog or refresh user
                    }
                  },
                ),
                _buildMenuItem(
                  colorScheme,
                  icon: Icons.security_outlined,
                  title: 'Privacy & Security',
                  subtitle: 'Manage your privacy settings',
                  onTap: () {
                    // TODO: Implement privacy settings
                  },
                ),
              ],
            ),
            Divider(
              color: colorScheme.surfaceVariant.withOpacity(0.5),
              height: 1,
            ),
          ],
          // Support
          _buildMenuSection(
            colorScheme,
            title: 'Support',
            items: [
              _buildMenuItem(
                colorScheme,
                icon: Icons.help_outline,
                title: 'Help & FAQ',
                subtitle: 'Get help and find answers',
                onTap: () {
                  // TODO: Implement help
                },
              ),
              _buildMenuItem(
                colorScheme,
                icon: Icons.feedback_outlined,
                title: 'Send Feedback',
                subtitle: 'Help us improve the app',
                onTap: () {
                  // TODO: Implement feedback
                },
              ),
              _buildMenuItem(
                colorScheme,
                icon: Icons.info_outline,
                title: 'About',
                subtitle: 'App version and information',
                onTap: () {
                  // TODO: Implement about
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMenuSection(
    ColorScheme colorScheme, {
    required String title,
    required List<Widget> items,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
          child: Text(
            title,
            style: TextStyle(
              color: colorScheme.onSurface,
              fontSize: 16,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ),
        ...items,
      ],
    );
  }

  Widget _buildMenuItem(
    ColorScheme colorScheme, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool enabled = true,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: enabled
              ? colorScheme.primary.withOpacity(0.1)
              : colorScheme.surfaceVariant.withOpacity(0.3),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: enabled
              ? colorScheme.primary
              : colorScheme.onSurface.withOpacity(0.4),
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: enabled
              ? colorScheme.onSurface
              : colorScheme.onSurface.withOpacity(0.4),
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        enabled ? subtitle : '$subtitle (Account required)',
        style: TextStyle(
          color: colorScheme.onSurface.withOpacity(0.6),
          fontSize: 12,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: enabled
            ? colorScheme.onSurface.withOpacity(0.6)
            : colorScheme.onSurface.withOpacity(0.3),
      ),
      onTap: enabled ? onTap : null,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
    );
  }
}
