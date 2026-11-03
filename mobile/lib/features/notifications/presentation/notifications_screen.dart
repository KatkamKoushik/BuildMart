import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/constants/app_colors.dart';
import '../../../shared/widgets/empty_state.dart';

class NotificationModel {
  final String id;
  final String title;
  final String description;
  final String time;
  final bool isUnread;

  const NotificationModel({
    required this.id,
    required this.title,
    required this.description,
    required this.time,
    this.isUnread = false,
  });
}

final userNotificationsProvider = StreamProvider<List<NotificationModel>>((ref) async* {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) {
    yield const [];
    return;
  }

  try {
    yield* FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('notifications')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return NotificationModel(
          id: doc.id,
          title: data['title']?.toString() ?? 'Notification',
          description: data['description']?.toString() ?? '',
          time: data['time']?.toString() ?? 'Just now',
          isUnread: data['isUnread'] == true,
        );
      }).toList();
    }).handleError((_) => const <NotificationModel>[]);
  } catch (_) {
    yield const [];
  }
});

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsAsync = ref.watch(userNotificationsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
      ),
      body: notificationsAsync.when(
        data: (notifications) {
          if (notifications.isEmpty) {
            return const Center(
              child: EmptyState(
                icon: Icons.notifications_none_outlined,
                title: 'No Notifications',
                message: 'You have no new notifications right now.',
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: notifications.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final item = notifications[index];
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkCard : Theme.of(context).cardTheme.color,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: item.isUnread
                        ? AppColors.primary.withValues(alpha: 0.5)
                        : (isDark ? AppColors.darkBorder : AppColors.border.withValues(alpha: 0.5)),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.notifications_active, color: AppColors.primary, size: 24),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  item.title,
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        fontWeight: item.isUnread ? FontWeight.bold : FontWeight.normal,
                                        color: isDark ? AppColors.darkText : AppColors.text,
                                      ),
                                ),
                              ),
                              if (item.isUnread)
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    color: AppColors.primary,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item.description,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: isDark ? AppColors.darkTextLight : AppColors.textLight,
                                ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            item.time,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: isDark ? AppColors.darkTextLight : AppColors.textLight,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => const Center(
          child: EmptyState(
            icon: Icons.notifications_none_outlined,
            title: 'No Notifications',
            message: 'You have no new notifications right now.',
          ),
        ),
      ),
    );
  }
}
