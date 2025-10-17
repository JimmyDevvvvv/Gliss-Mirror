import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/theme/app_theme.dart';
import 'package:frontend/core/theme/design_system.dart';
import 'package:frontend/core/theme/gliss_ui.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppTheme.lightGrey,
      body: CustomScrollView(
        slivers: [
          // Premium app bar with gradient
          SliverAppBar(
            expandedHeight: 200,
            floating: false,
            pinned: true,
            backgroundColor: AppTheme.darkBlue,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppTheme.darkBlue, AppTheme.deepViolet],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // Profile avatar with border
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppTheme.pureWhite,
                            width: 3,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: CircleAvatar(
                          radius: 45,
                          backgroundColor: AppTheme.pureWhite,
                          child: Icon(
                            Icons.person_rounded,
                            size: 50,
                            color: AppTheme.deepViolet,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Guest User',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.pureWhite,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Tap below to create your account',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppTheme.pureWhite.withOpacity(0.8),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(DesignTokens.spacing2),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Sign in CTA card
                  GlissUI.card(
                    padding: EdgeInsets.all(DesignTokens.spacing3),
                    backgroundColor: AppTheme.pureWhite,
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppTheme.softPeach.withOpacity(0.3),
                                AppTheme.softMint.withOpacity(0.3),
                              ],
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.login_rounded,
                            size: 40,
                            color: AppTheme.deepViolet,
                          ),
                        ),
                        SizedBox(height: DesignTokens.spacing2),
                        const Text(
                          'Sign In to Unlock More',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.darkBlue,
                          ),
                        ),
                        SizedBox(height: DesignTokens.spacing1),
                        Text(
                          'Save your progress, get personalized recommendations, and access exclusive features',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: AppTheme.darkBlue.withOpacity(0.7),
                            height: 1.5,
                          ),
                        ),
                        SizedBox(height: DesignTokens.spacing3),
                        GlissUI.primaryButton(
                          text: 'Create Account',
                          onPressed: () {
                            // TODO: Navigate to sign up
                          },
                          icon: Icons.person_add_rounded,
                          fullWidth: true,
                        ),
                        SizedBox(height: DesignTokens.spacing1),
                        GlissUI.secondaryButton(
                          text: 'Sign In',
                          onPressed: () {
                            // TODO: Navigate to sign in
                          },
                          fullWidth: true,
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: DesignTokens.spacing3),

                  // Stats section (if logged in, show real stats)
                  const Text(
                    'Your Hair Journey',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.darkBlue,
                    ),
                  ),
                  SizedBox(height: DesignTokens.spacing2),

                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          icon: Icons.camera_alt_rounded,
                          value: '0',
                          label: 'Scans',
                          color: AppTheme.freshBlue,
                        ),
                      ),
                      SizedBox(width: DesignTokens.spacing2),
                      Expanded(
                        child: _buildStatCard(
                          icon: Icons.trending_up_rounded,
                          value: '0',
                          label: 'Progress',
                          color: AppTheme.sageGreen,
                        ),
                      ),
                      SizedBox(width: DesignTokens.spacing2),
                      Expanded(
                        child: _buildStatCard(
                          icon: Icons.shopping_bag_rounded,
                          value: '0',
                          label: 'Products',
                          color: AppTheme.deepViolet,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: DesignTokens.spacing3),

                  // Settings section
                  const Text(
                    'Settings',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.darkBlue,
                    ),
                  ),
                  SizedBox(height: DesignTokens.spacing2),

                  GlissUI.card(
                    padding: EdgeInsets.zero,
                    child: Column(
                      children: [
                        _buildMenuTile(
                          icon: Icons.person_outline_rounded,
                          title: 'Account Settings',
                          subtitle: 'Manage your account preferences',
                          color: AppTheme.freshBlue,
                          onTap: () {
                            // TODO: Navigate to account settings
                          },
                        ),
                        _buildDivider(),
                        _buildMenuTile(
                          icon: Icons.notifications_outlined,
                          title: 'Notifications',
                          subtitle: 'Manage notification preferences',
                          color: AppTheme.brightOrange,
                          onTap: () {
                            // TODO: Navigate to notifications
                          },
                        ),
                        _buildDivider(),
                        _buildMenuTile(
                          icon: Icons.language_rounded,
                          title: 'Language',
                          subtitle: 'English (US)',
                          color: AppTheme.deepGreen,
                          onTap: () {
                            // TODO: Show language picker
                          },
                        ),
                        _buildDivider(),
                        _buildMenuTile(
                          icon: Icons.palette_outlined,
                          title: 'Appearance',
                          subtitle: 'Customize app theme',
                          color: AppTheme.deepViolet,
                          onTap: () {
                            // TODO: Navigate to appearance settings
                          },
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: DesignTokens.spacing3),

                  // Support section
                  const Text(
                    'Support',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.darkBlue,
                    ),
                  ),
                  SizedBox(height: DesignTokens.spacing2),

                  GlissUI.card(
                    padding: EdgeInsets.zero,
                    child: Column(
                      children: [
                        _buildMenuTile(
                          icon: Icons.help_outline_rounded,
                          title: 'Help Center',
                          subtitle: 'FAQs and tutorials',
                          color: AppTheme.brightAqua,
                          onTap: () {
                            // TODO: Navigate to help center
                          },
                        ),
                        _buildDivider(),
                        _buildMenuTile(
                          icon: Icons.chat_bubble_outline_rounded,
                          title: 'Contact Support',
                          subtitle: 'Get help from our team',
                          color: AppTheme.softMint,
                          onTap: () {
                            // TODO: Open contact support
                          },
                        ),
                        _buildDivider(),
                        _buildMenuTile(
                          icon: Icons.rate_review_outlined,
                          title: 'Rate App',
                          subtitle: 'Share your feedback',
                          color: AppTheme.freshYellow,
                          onTap: () {
                            // TODO: Open app store rating
                          },
                        ),
                        _buildDivider(),
                        _buildMenuTile(
                          icon: Icons.share_outlined,
                          title: 'Share App',
                          subtitle: 'Invite your friends',
                          color: AppTheme.softPeach,
                          onTap: () {
                            // TODO: Open share dialog
                          },
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: DesignTokens.spacing3),

                  // About section
                  const Text(
                    'About',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.darkBlue,
                    ),
                  ),
                  SizedBox(height: DesignTokens.spacing2),

                  GlissUI.card(
                    padding: EdgeInsets.zero,
                    child: Column(
                      children: [
                        _buildMenuTile(
                          icon: Icons.info_outline_rounded,
                          title: 'About Gliss Mirror',
                          subtitle: 'Version 1.0.0',
                          color: AppTheme.darkBlue,
                          onTap: () {
                            // TODO: Show about dialog
                          },
                        ),
                        _buildDivider(),
                        _buildMenuTile(
                          icon: Icons.description_outlined,
                          title: 'Terms of Service',
                          subtitle: 'Read our terms',
                          color: AppTheme.warmGrey,
                          onTap: () {
                            // TODO: Navigate to terms
                          },
                        ),
                        _buildDivider(),
                        _buildMenuTile(
                          icon: Icons.privacy_tip_outlined,
                          title: 'Privacy Policy',
                          subtitle: 'How we protect your data',
                          color: AppTheme.sageGreen,
                          onTap: () {
                            // TODO: Navigate to privacy policy
                          },
                        ),
                        _buildDivider(),
                        _buildMenuTile(
                          icon: Icons.business_outlined,
                          title: 'Powered by Henkel',
                          subtitle: 'Learn about Gliss products',
                          color: AppTheme.henkelRed,
                          onTap: () {
                            // TODO: Navigate to Henkel page
                          },
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: DesignTokens.spacing4),

                  // Logout button (if logged in)
                  // For now, show as disabled
                  Opacity(
                    opacity: 0.5,
                    child: GlissUI.card(
                      padding: EdgeInsets.symmetric(
                        horizontal: DesignTokens.spacing3,
                        vertical: DesignTokens.spacing2,
                      ),
                      backgroundColor: AppTheme.warmGreyLight,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.logout_rounded,
                            color: AppTheme.darkBlue.withOpacity(0.5),
                          ),
                          SizedBox(width: DesignTokens.spacing1),
                          Text(
                            'Sign In to Enable',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.darkBlue.withOpacity(0.5),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: DesignTokens.spacing2),

                  // Footer
                  Center(
                    child: Text(
                      'Made with ❤️ for healthier hair',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.darkBlue.withOpacity(0.5),
                      ),
                    ),
                  ),

                  SizedBox(height: DesignTokens.spacing4),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return GlissUI.card(
      padding: EdgeInsets.all(DesignTokens.spacing2),
      backgroundColor: color.withOpacity(0.1),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          SizedBox(height: DesignTokens.spacing1),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: color,
              height: 1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppTheme.darkBlue.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(DesignTokens.spacing2),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              SizedBox(width: DesignTokens.spacing2),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.darkBlue,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.darkBlue.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: AppTheme.darkBlue.withOpacity(0.3),
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: DesignTokens.spacing2),
      child: Divider(height: 1, thickness: 1, color: AppTheme.warmGreyLight),
    );
  }
}
