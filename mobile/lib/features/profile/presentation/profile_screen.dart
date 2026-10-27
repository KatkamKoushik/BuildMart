import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../shared/widgets/buildmart_card.dart';
import '../../../shared/widgets/network_image_widget.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../data/user_repository.dart';
import '../../../core/services/cloudinary_service.dart';
import '../../../core/services/seeder_service.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../core/providers/settings_provider.dart';
import '../../../l10n/app_localizations.dart';
import '../../auth/data/auth_provider.dart';
import '../../../core/constants/admin_constants.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final ImagePicker _picker = ImagePicker();
  final CloudinaryService _cloudinaryService = CloudinaryService();
  bool _isUploading = false;
  bool _isSeeding = false;

  Future<void> _uploadProfilePicture(String uid) async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;

    setState(() {
      _isUploading = true;
    });

    try {
      final imageUrl = await _cloudinaryService.uploadImage(image);
      if (imageUrl != null) {
        await ref
            .read(userRepositoryProvider)
            .updateUserProfileImage(uid, imageUrl);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Profile picture updated successfully!')),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to upload image.')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(userProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.profile),
      ),
      body: userAsync.when(
        data: (user) {
          if (user == null) {
            return EmptyState(
              icon: Icons.person_outline,
              title: 'Not logged in',
              message: 'Please log in to view your profile.',
              buttonText: 'Login',
              onAction: () async {
                // If they are stuck in a state where FirebaseAuth thinks they are logged in
                // but there is no user document, force a logout first to break the loop.
                final repo = ref.read(authRepositoryProvider);
                if (await repo.isAuthenticated()) {
                  await repo.logout();
                }
                if (context.mounted) {
                  context.go('/login');
                }
              },
            );
          }
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              BuildMartCard(
                child: Column(
                  children: [
                    Row(
                      children: [
                        GestureDetector(
                          onTap: _isUploading
                              ? null
                              : () => _uploadProfilePicture(user.id),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                      color: AppColors.primary, width: 2),
                                ),
                                child: NetworkImageWidget(
                                  imageUrl: user.profileImageUrl ??
                                      'https://via.placeholder.com/150',
                                  width: 64,
                                  height: 64,
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(32)),
                                ),
                              ),
                              if (_isUploading)
                                const CircularProgressIndicator(
                                    color: AppColors.primary),
                              if (!_isUploading)
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: const BoxDecoration(
                                      color: AppColors.primary,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.edit,
                                        size: 12, color: Colors.white),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(user.name,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleLarge
                                      ?.copyWith(fontWeight: FontWeight.bold)),
                              const SizedBox(height: 4),
                              Text(
                                user.phone.isNotEmpty ? user.phone : user.email,
                                style: Theme.of(context).textTheme.bodyMedium,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ).animate().fadeIn().slideY(
                  begin: 0.2, end: 0, duration: 400.ms, curve: Curves.easeOut),
              const SizedBox(height: 24),
              _buildSettingsItem(context, Icons.inventory_2_outlined,
                  AppLocalizations.of(context)!.myOrders,
                  delay: 100, onTap: () => context.go('/orders')),
              _buildSettingsItem(context, Icons.favorite_border,
                  AppLocalizations.of(context)!.wishlist,
                  delay: 150, onTap: () => context.push('/wishlist')),
              _buildSettingsItem(context, Icons.history,
                  AppLocalizations.of(context)!.recentlyViewed,
                  delay: 200, onTap: () => context.push('/recently-viewed')),
              _buildSettingsItem(context, Icons.location_on_outlined,
                  AppLocalizations.of(context)!.myAddresses,
                  delay: 250, onTap: () => context.push('/location')),
              _buildSettingsItem(context, Icons.payment_outlined,
                  AppLocalizations.of(context)!.paymentMethods,
                  delay: 300, onTap: () => context.push('/payment-methods')),
              _buildSettingsItem(context, Icons.group_add_outlined,
                  AppLocalizations.of(context)!.referralProgram,
                  delay: 320),
              _buildSettingsItem(
                context,
                Icons.language,
                AppLocalizations.of(context)!.languagePreferences,
                delay: 350,
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text(AppLocalizations.of(context)!.selectLanguage),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ListTile(
                            title: Text(AppLocalizations.of(context)!.english),
                            onTap: () {
                              ref
                                  .read(localeProvider.notifier)
                                  .setLocale(const Locale('en'));
                              Navigator.pop(context);
                            },
                          ),
                          ListTile(
                            title: Text(AppLocalizations.of(context)!.hindi),
                            onTap: () {
                              ref
                                  .read(localeProvider.notifier)
                                  .setLocale(const Locale('hi'));
                              Navigator.pop(context);
                            },
                          ),
                          ListTile(
                            title: Text(AppLocalizations.of(context)!.telugu),
                            onTap: () {
                              ref
                                  .read(localeProvider.notifier)
                                  .setLocale(const Locale('te'));
                              Navigator.pop(context);
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              _buildSettingsItem(
                context,
                Icons.dark_mode_outlined,
                AppLocalizations.of(context)!.themePreferences,
                delay: 375,
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text(AppLocalizations.of(context)!.selectTheme),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ListTile(
                            title: Text(AppLocalizations.of(context)!.system),
                            onTap: () {
                              ref
                                  .read(themeModeProvider.notifier)
                                  .setThemeMode(ThemeMode.system);
                              Navigator.pop(context);
                            },
                          ),
                          ListTile(
                            title: Text(AppLocalizations.of(context)!.light),
                            onTap: () {
                              ref
                                  .read(themeModeProvider.notifier)
                                  .setThemeMode(ThemeMode.light);
                              Navigator.pop(context);
                            },
                          ),
                          ListTile(
                            title: Text(AppLocalizations.of(context)!.dark),
                            onTap: () {
                              ref
                                  .read(themeModeProvider.notifier)
                                  .setThemeMode(ThemeMode.dark);
                              Navigator.pop(context);
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              _buildSettingsItem(context, Icons.help_outline,
                  AppLocalizations.of(context)!.helpCenter,
                  delay: 400, onTap: () => context.push('/help-center')),
              if (AdminConstants.isAdmin(user.email))
                _buildSettingsItem(
                  context,
                  Icons.admin_panel_settings,
                  'Admin Panel',
                  delay: 410,
                  onTap: () => context.push('/admin'),
                ),
              _buildSettingsItem(
                context,
                Icons.refresh,
                _isSeeding
                    ? AppLocalizations.of(context)!.refreshingCatalog
                    : AppLocalizations.of(context)!.refreshCatalog,
                delay: 420,
                onTap: _isSeeding
                    ? null
                    : () async {
                        setState(() => _isSeeding = true);
                        try {
                          await SeederService().seedDatabase();
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                    '✅ Catalog refreshed! Restart the app to see changes.'),
                                backgroundColor: AppColors.success,
                              ),
                            );
                          }
                        } catch (e) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('❌ Error: $e'),
                                backgroundColor: AppColors.error,
                              ),
                            );
                          }
                        } finally {
                          if (mounted) setState(() => _isSeeding = false);
                        }
                      },
              ),
              _buildSettingsItem(
                context,
                Icons.logout,
                AppLocalizations.of(context)!.logout,
                isDestructive: true,
                delay: 450,
                onTap: () async {
                  await ref.read(authRepositoryProvider).logout();
                  if (context.mounted) {
                    context.go('/login');
                  }
                },
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _buildSettingsItem(BuildContext context, IconData icon, String title,
      {bool isDestructive = false, int delay = 0, VoidCallback? onTap}) {
    final color = isDestructive
        ? AppColors.error
        : Theme.of(context).textTheme.titleMedium?.color;
    final iconColor = isDestructive ? AppColors.error : AppColors.primary;
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isDestructive
              ? AppColors.error.withValues(alpha: 0.1)
              : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: iconColor),
      ),
      title: Text(title,
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(color: color, fontWeight: FontWeight.w500)),
      trailing: Icon(Icons.chevron_right,
          color: Theme.of(context)
              .textTheme
              .bodySmall
              ?.color
              ?.withValues(alpha: 0.5)),
      onTap: onTap ??
          () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('$title coming soon!')),
            );
          },
    )
        .animate()
        .fadeIn(delay: delay.ms)
        .slideX(begin: 0.1, end: 0, delay: delay.ms);
  }
}
