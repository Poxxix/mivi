import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mivi/presentation/core/app_colors.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
      ),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
      ),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              // Enhanced App Bar
              SliverAppBar(
                backgroundColor: AppColors.background,
                floating: true,
                expandedHeight: 100,
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          AppColors.background,
                          AppColors.background.withOpacity(0.8),
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
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.person_outline,
                          color: AppColors.primary,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Profile',
                        style: TextStyle(
                          color: AppColors.onBackground,
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
                      color: AppColors.error.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      icon: Icon(
                        Icons.logout_rounded,
                        color: AppColors.error,
                        size: 24,
                      ),
                      onPressed: () {
                        // TODO: Implement logout logic
                        context.go('/login');
                      },
                    ),
                  ),
                ],
                elevation: 0,
              ),
              // Profile Header
              SliverToBoxAdapter(
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Container(
                    margin: const EdgeInsets.all(20),
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.surfaceVariant.withOpacity(0.2),
                      ),
                    ),
                    child: Row(
                      children: [
                        // Avatar
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                AppColors.primary,
                                AppColors.primary.withOpacity(0.7),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Icon(
                            Icons.person,
                            size: 40,
                            color: AppColors.onPrimary,
                          ),
                        ),
                        const SizedBox(width: 20),
                        // User Info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'John Doe',
                                style: TextStyle(
                                  color: AppColors.onBackground,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'john.doe@email.com',
                                style: TextStyle(
                                  color: AppColors.onBackground.withOpacity(0.7),
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  'Premium Member',
                                  style: TextStyle(
                                    color: AppColors.primary,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // Account Section
              SliverToBoxAdapter(
                child: SlideTransition(
                  position: _slideAnimation,
                  child: _buildSection(
                    'Account',
                    [
                      _buildMenuItem(
                        icon: Icons.edit_outlined,
                        title: 'Edit Profile',
                        subtitle: 'Update your personal information',
                        onTap: () {},
                      ),
                      _buildMenuItem(
                        icon: Icons.lock_outline,
                        title: 'Change Password',
                        subtitle: 'Update your password',
                        onTap: () {},
                      ),
                      _buildMenuItem(
                        icon: Icons.notifications_outlined,
                        title: 'Notifications',
                        subtitle: 'Manage your notification preferences',
                        onTap: () {},
                      ),
                    ],
                  ),
                ),
              ),
              // App Settings Section
              SliverToBoxAdapter(
                child: SlideTransition(
                  position: _slideAnimation,
                  child: _buildSection(
                    'Preferences',
                    [
                      _buildMenuItem(
                        icon: Icons.language_outlined,
                        title: 'Language',
                        subtitle: 'English',
                        onTap: () {},
                      ),
                      _buildMenuItem(
                        icon: Icons.dark_mode_outlined,
                        title: 'Dark Mode',
                        subtitle: 'Always enabled',
                        onTap: () {},
                      ),
                      _buildMenuItem(
                        icon: Icons.info_outline,
                        title: 'About',
                        subtitle: 'App version and information',
                        onTap: () {},
                      ),
                    ],
                  ),
                ),
              ),
              // Bottom Spacing
              const SliverToBoxAdapter(
                child: SizedBox(height: 100),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> items) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 8, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 16),
            child: Text(
              title,
              style: TextStyle(
                color: AppColors.onBackground,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant.withOpacity(0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.surfaceVariant.withOpacity(0.1),
              ),
            ),
            child: Column(
              children: items,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: AppColors.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: AppColors.onBackground,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: AppColors.onBackground.withOpacity(0.6),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: AppColors.onBackground.withOpacity(0.4),
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
