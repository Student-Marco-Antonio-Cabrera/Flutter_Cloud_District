import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/address.dart';
import '../providers/auth_provider.dart';
import '../providers/app_settings_provider.dart';
import '../providers/user_profile_provider.dart';
import '../widgets/gradient_scaffold.dart';
import '../widgets/vape_shop_logo_image.dart';
import 'addresses_screen.dart';
import 'login_screen.dart';
import 'profile_edit_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  static const String routeName = '/profile';

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _twoFactorEnabled = false;
  bool _notificationsEnabled = true;
  String _language = 'English';

  static const List<String> _languages = ['English', 'Filipino', 'Spanish'];

  Address? _defaultAddress(List<Address> addresses) {
    for (final address in addresses) {
      if (address.isDefault) return address;
    }
    if (addresses.isEmpty) return null;
    return addresses.first;
  }

  Route<void> _buildTransitionRoute(Widget page) {
    return PageRouteBuilder<void>(
      transitionDuration: const Duration(milliseconds: 260),
      reverseTransitionDuration: const Duration(milliseconds: 220),
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final fade = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        );
        final slide = Tween<Offset>(
          begin: const Offset(0.05, 0),
          end: Offset.zero,
        ).animate(fade);
        return FadeTransition(
          opacity: fade,
          child: SlideTransition(position: slide, child: child),
        );
      },
    );
  }

  Future<void> _openFeature(
    BuildContext context, {
    required String title,
    required String description,
    IconData icon = Icons.dashboard_customize_outlined,
  }) async {
    await Navigator.of(context).push(
      _buildTransitionRoute(
        _FeatureDetailsScreen(
          title: title,
          description: description,
          icon: icon,
        ),
      ),
    );
  }

  Future<void> _openProfileEdit(BuildContext context) async {
    await Navigator.of(
      context,
    ).push(_buildTransitionRoute(const ProfileEditScreen()));
  }

  Future<void> _openAddresses(BuildContext context) async {
    await Navigator.of(
      context,
    ).push(_buildTransitionRoute(const AddressesScreen()));
  }

  Future<void> _pickLanguage() async {
    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface;
    final onSurfaceVariant = theme.colorScheme.onSurfaceVariant;
    final primary = theme.colorScheme.primary;

    final selected = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: theme.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: onSurfaceVariant.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              Text(
                'Select Language',
                style: TextStyle(
                  color: onSurface,
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 12),
              ..._languages.map((language) {
                final isSelected = language == _language;
                return ListTile(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  leading: Icon(
                    Icons.language,
                    color: isSelected ? primary : onSurfaceVariant,
                  ),
                  title: Text(language, style: TextStyle(color: onSurface)),
                  trailing: isSelected
                      ? Icon(Icons.check_circle, color: primary)
                      : null,
                  onTap: () => Navigator.pop(context, language),
                );
              }),
            ],
          ),
        ),
      ),
    );

    if (!mounted || selected == null) return;
    setState(() => _language = selected);
  }

  Future<void> _logout(AuthProvider auth) async {
    await auth.logout();
    if (!mounted) return;
    Navigator.of(
      context,
    ).pushNamedAndRemoveUntil(LoginScreen.routeName, (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final profile = context.watch<UserProfileProvider>();
    final settings = context.watch<AppSettingsProvider>();
    final user = auth.user;

    if (user == null) {
      return GradientScaffold(
        extendBodyBehindAppBar: false,
        appBar: AppBar(
          leadingWidth: 130,
          title: const Text('Profile'),
          leading: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context),
              ),
              const SizedBox(
                width: 72,
                height: 28,
                child: VapeShopLogoImage(maxWidth: 72, maxHeight: 28),
              ),
            ],
          ),
        ),
        body: const SafeArea(
          top: false,
          child: Center(
            child: Text(
              'Not logged in',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
        ),
      );
    }

    final addresses = profile.addresses;
    final defaultAddress = _defaultAddress(addresses);
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return GradientScaffold(
      extendBodyBehindAppBar: false,
      appBar: AppBar(
        leadingWidth: 130,
        title: const Text('Profile'),
        leading: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context),
            ),
            const SizedBox(
              width: 72,
              height: 28,
              child: VapeShopLogoImage(maxWidth: 72, maxHeight: 28),
            ),
          ],
        ),
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: EdgeInsets.fromLTRB(16, 16, 16, 24 + bottomPadding),
          children: [
            _ProfileHeaderCard(
              displayName: profile.displayName ?? user.displayName,
              email: user.email,
              phone: profile.phone,
              profileImagePath: profile.profileImagePath,
              defaultAddress: defaultAddress,
              onEditProfile: () => _openProfileEdit(context),
            ),
            const SizedBox(height: 16),
            _SettingsSection(
              title: 'Account',
              children: [
                _SettingsActionTile(
                  icon: Icons.edit_outlined,
                  title: 'Edit Profile',
                  subtitle: 'Update your personal details and avatar',
                  onTap: () => _openProfileEdit(context),
                ),
                _SettingsActionTile(
                  icon: Icons.location_on_outlined,
                  title: 'Addresses',
                  subtitle: addresses.isEmpty
                      ? 'No addresses saved yet'
                      : '${addresses.length} saved · '
                            'Default: ${defaultAddress?.label ?? addresses.first.label}',
                  onTap: () => _openAddresses(context),
                  trailing: defaultAddress != null
                      ? const _PillLabel(text: 'Default')
                      : null,
                ),
              ],
            ),
            _SettingsSection(
              title: 'Order Management',
              children: [
                _SettingsActionTile(
                  icon: Icons.inventory_2_outlined,
                  title: 'My Orders',
                  subtitle: 'View active and upcoming orders',
                  onTap: () => _openFeature(
                    context,
                    title: 'My Orders',
                    description:
                        'Track all currently active marketplace orders.',
                    icon: Icons.inventory_2_outlined,
                  ),
                ),
                _SettingsActionTile(
                  icon: Icons.history_outlined,
                  title: 'Order History',
                  subtitle: 'Review your completed purchases',
                  onTap: () => _openFeature(
                    context,
                    title: 'Order History',
                    description:
                        'Review previously completed and canceled orders.',
                    icon: Icons.history_outlined,
                  ),
                ),
                _SettingsActionTile(
                  icon: Icons.local_shipping_outlined,
                  title: 'Track Orders',
                  subtitle: 'Get live shipping and delivery updates',
                  onTap: () => _openFeature(
                    context,
                    title: 'Track Orders',
                    description:
                        'Get real-time shipping status and milestones.',
                    icon: Icons.local_shipping_outlined,
                  ),
                ),
              ],
            ),
            _SettingsSection(
              title: 'Payment & Wallet',
              children: [
                _SettingsActionTile(
                  icon: Icons.credit_card_outlined,
                  title: 'Saved Payment Methods',
                  subtitle: 'Manage cards and preferred payment options',
                  onTap: () => _openFeature(
                    context,
                    title: 'Saved Payment Methods',
                    description:
                        'Add, remove, and prioritize checkout methods.',
                    icon: Icons.credit_card_outlined,
                  ),
                ),
                _SettingsActionTile(
                  icon: Icons.receipt_long_outlined,
                  title: 'Transaction History',
                  subtitle: 'See all wallet and payment activity',
                  onTap: () => _openFeature(
                    context,
                    title: 'Transaction History',
                    description: 'View receipts, refunds, and payment records.',
                    icon: Icons.receipt_long_outlined,
                  ),
                ),
              ],
            ),
            _SettingsSection(
              title: 'Address Management',
              children: [
                _SettingsActionTile(
                  icon: Icons.add_location_alt_outlined,
                  title: 'Add New Address',
                  subtitle: 'Save a new shipping destination',
                  onTap: () => _openAddresses(context),
                ),
                _SettingsActionTile(
                  icon: Icons.edit_location_alt_outlined,
                  title: 'Edit / Delete Address',
                  subtitle: 'Maintain your saved delivery addresses',
                  onTap: () => _openAddresses(context),
                ),
                _SettingsActionTile(
                  icon: Icons.verified_outlined,
                  title: 'Default Address',
                  subtitle: defaultAddress == null
                      ? 'Set your default shipping address'
                      : '${defaultAddress.label} • ${defaultAddress.city}',
                  onTap: () => _openAddresses(context),
                  trailing: defaultAddress != null
                      ? const _PillLabel(text: 'Active')
                      : null,
                ),
              ],
            ),
            _SettingsSection(
              title: 'Security',
              children: [
                _SettingsActionTile(
                  icon: Icons.lock_reset_outlined,
                  title: 'Change Password',
                  subtitle: 'Update your sign-in credentials',
                  onTap: () => _openFeature(
                    context,
                    title: 'Change Password',
                    description: 'Update your password and recovery options.',
                    icon: Icons.lock_reset_outlined,
                  ),
                ),
                _SettingsToggleTile(
                  icon: Icons.security_outlined,
                  title: 'Two-Factor Authentication',
                  subtitle: 'Protect your account with extra verification',
                  value: _twoFactorEnabled,
                  onChanged: (value) =>
                      setState(() => _twoFactorEnabled = value),
                ),
                _SettingsActionTile(
                  icon: Icons.privacy_tip_outlined,
                  title: 'Privacy Settings',
                  subtitle: 'Manage account visibility and data permissions',
                  onTap: () => _openFeature(
                    context,
                    title: 'Privacy Settings',
                    description:
                        'Control privacy, consent, and visibility options.',
                    icon: Icons.privacy_tip_outlined,
                  ),
                ),
              ],
            ),
            _SettingsSection(
              title: 'Engagement',
              children: [
                _SettingsActionTile(
                  icon: Icons.favorite_border,
                  title: 'Wishlist / Favorites',
                  subtitle: 'Access products you saved for later',
                  onTap: () => _openFeature(
                    context,
                    title: 'Wishlist / Favorites',
                    description: 'Organize and manage your saved products.',
                    icon: Icons.favorite_border,
                  ),
                ),
                _SettingsActionTile(
                  icon: Icons.history_toggle_off_outlined,
                  title: 'Recently Viewed',
                  subtitle: 'Continue browsing where you left off',
                  onTap: () => _openFeature(
                    context,
                    title: 'Recently Viewed',
                    description: 'Review recently visited product pages.',
                    icon: Icons.history_toggle_off_outlined,
                  ),
                ),
              ],
            ),
            _SettingsSection(
              title: 'Preferences',
              children: [
                _SettingsToggleTile(
                  icon: Icons.notifications_outlined,
                  title: 'Notifications',
                  subtitle: 'Order updates, promos, and alerts',
                  value: _notificationsEnabled,
                  onChanged: (value) =>
                      setState(() => _notificationsEnabled = value),
                ),
                _SettingsToggleTile(
                  icon: Icons.dark_mode_outlined,
                  title: 'Dark Mode',
                  subtitle: 'Use a darker theme at night',
                  value: settings.isDarkMode,
                  onChanged: settings.setDarkMode,
                ),
                _SettingsActionTile(
                  icon: Icons.language_outlined,
                  title: 'Language',
                  subtitle: 'Current: $_language',
                  onTap: _pickLanguage,
                ),
              ],
            ),
            const SizedBox(height: 8),
            FilledButton.icon(
              onPressed: () => _logout(auth),
              icon: const Icon(Icons.logout),
              label: const Text('Logout'),
              style: FilledButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Theme.of(context).colorScheme.primary,
                minimumSize: const Size.fromHeight(52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileHeaderCard extends StatelessWidget {
  const _ProfileHeaderCard({
    required this.displayName,
    required this.email,
    required this.phone,
    required this.profileImagePath,
    required this.defaultAddress,
    required this.onEditProfile,
  });

  final String displayName;
  final String email;
  final String? phone;
  final String? profileImagePath;
  final Address? defaultAddress;
  final VoidCallback onEditProfile;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withValues(alpha: 0.28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 34,
                backgroundColor: Colors.white24,
                backgroundImage: profileImagePath != null
                    ? FileImage(File(profileImagePath!))
                    : null,
                child: profileImagePath == null
                    ? const Icon(Icons.person, size: 34, color: Colors.white70)
                    : null,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      email,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.92),
                        fontSize: 14,
                      ),
                    ),
                    if (phone != null && phone!.trim().isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        phone!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.86),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Edit profile',
                onPressed: onEditProfile,
                icon: const Icon(Icons.edit_outlined),
                style: IconButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.white.withValues(alpha: 0.18),
                ),
              ),
            ],
          ),
          if (defaultAddress != null) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.place_outlined,
                    size: 18,
                    color: Colors.white.withValues(alpha: 0.95),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Default address: ${defaultAddress!.label} (${defaultAddress!.city})',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.95),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const _PillLabel(text: 'Default'),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  const _SettingsSection({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final tiles = <Widget>[];
    for (var i = 0; i < children.length; i++) {
      tiles.add(children[i]);
      if (i < children.length - 1) {
        tiles.add(
          Divider(
            height: 1,
            thickness: 0.7,
            color: Colors.white.withValues(alpha: 0.22),
            indent: 62,
            endIndent: 12,
          ),
        );
      }
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 0, 4, 8),
            child: Text(
              title,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.96),
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.white.withValues(alpha: 0.24)),
            ),
            child: Column(children: tiles),
          ),
        ],
      ),
    );
  }
}

class _SettingsActionTile extends StatelessWidget {
  const _SettingsActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.trailing,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      leading: _TileIcon(icon: icon),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        subtitle,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.85),
          fontSize: 12,
        ),
      ),
      trailing:
          trailing ??
          Icon(
            Icons.chevron_right,
            color: Colors.white.withValues(alpha: 0.75),
          ),
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    );
  }
}

class _SettingsToggleTile extends StatelessWidget {
  const _SettingsToggleTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      leading: _TileIcon(icon: icon),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        subtitle,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.85),
          fontSize: 12,
        ),
      ),
      trailing: Switch.adaptive(
        value: value,
        onChanged: onChanged,
        activeThumbColor: Theme.of(context).colorScheme.primary,
        activeTrackColor: Theme.of(
          context,
        ).colorScheme.primary.withValues(alpha: 0.45),
        inactiveTrackColor: Colors.white38,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    );
  }
}

class _TileIcon extends StatelessWidget {
  const _TileIcon({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: Colors.white, size: 20),
    );
  }
}

class _PillLabel extends StatelessWidget {
  const _PillLabel({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.24),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _FeatureDetailsScreen extends StatelessWidget {
  const _FeatureDetailsScreen({
    required this.title,
    required this.description,
    required this.icon,
  });

  final String title;
  final String description;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      extendBodyBehindAppBar: false,
      appBar: AppBar(
        title: Text(title),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withValues(alpha: 0.28)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.22),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Icon(icon, color: Colors.white, size: 30),
                ),
                const SizedBox(height: 14),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.92),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  'Feature screen scaffold is ready for API integration.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
