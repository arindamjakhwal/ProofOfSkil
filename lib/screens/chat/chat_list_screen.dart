import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/helpers.dart';
import '../../providers/auth_provider.dart';
import '../../services/chat_service.dart';
import '../../widgets/avatar_widget.dart';

class ChatListScreen extends StatelessWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final chatService = ChatService();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Messages',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Search
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.search_rounded,
                        color: AppColors.textMuted, size: 20),
                    SizedBox(width: 10),
                    Text('Search conversations...',
                        style: TextStyle(
                            color: AppColors.textMuted, fontSize: 14)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Chat list
            Expanded(
              child: Builder(
                builder: (context) {
                  final currentUser = context.watch<AuthProvider>().user;
                  if (currentUser == null) {
                    return const Center(
                      child: Text('Please log in to view messages'),
                    );
                  }
                  return StreamBuilder<List<ChatPreview>>(
                    stream: chatService.getChatPreviewsStream(currentUser.id),
                    builder: (context, snap) {
                      if (snap.connectionState == ConnectionState.waiting) {
                        return const Center(
                            child: CircularProgressIndicator(
                                color: AppColors.primary));
                      }
                      final chats = snap.data ?? [];
                      if (chats.isEmpty) {
                        return const Center(
                          child: Text(
                            'No conversations yet',
                            style: TextStyle(color: AppColors.textMuted),
                          ),
                        );
                      }
                      return ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: chats.length,
                        separatorBuilder: (context, index) =>
                            const Divider(height: 1, color: AppColors.divider),
                        itemBuilder: (context, i) {
                          final chat = chats[i];
                          return Dismissible(
                            key: ValueKey('chat_${chat.partnerId}'),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 20),
                              decoration: BoxDecoration(
                                color: AppColors.error.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.delete_rounded,
                                color: AppColors.error,
                              ),
                            ),
                            confirmDismiss: (_) async {
                              final shouldDelete = await showDialog<bool>(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: const Text('Delete conversation?'),
                                  content: Text(
                                    'This will permanently remove your chat with ${chat.partnerName}.',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(ctx, false),
                                      child: const Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () => Navigator.pop(ctx, true),
                                      style: TextButton.styleFrom(
                                        foregroundColor: AppColors.error,
                                      ),
                                      child: const Text('Delete'),
                                    ),
                                  ],
                                ),
                              );

                              if (shouldDelete == true) {
                                await chatService.deleteConversation(
                                  currentUser.id,
                                  chat.partnerId,
                                );
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Conversation with ${chat.partnerName} deleted',
                                      ),
                                    ),
                                  );
                                }
                                return true;
                              }
                              return false;
                            },
                            child: _ChatTile(
                              chat: chat,
                              onTap: () {
                                Navigator.pushNamed(context, '/chat',
                                    arguments: {
                                      'partnerId': chat.partnerId,
                                      'partnerName': chat.partnerName
                                    });
                              },
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showNewChatDialog(context),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.edit_rounded, color: Colors.white),
      ),
    );
  }

  void _showNewChatDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => _NewChatDialog(),
    );
  }
}

class _ChatTile extends StatelessWidget {
  final ChatPreview chat;
  final VoidCallback onTap;

  const _ChatTile({required this.chat, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          children: [
            Stack(
              children: [
                AvatarWidget(
                    name: chat.partnerName,
                    size: 48,
                    backgroundColor: AppColors.primary),
                if (chat.isOnline)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: AppColors.success,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.surface, width: 2),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        chat.partnerName,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: chat.unreadCount > 0
                              ? FontWeight.w700
                              : FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        Helpers.timeAgo(chat.time),
                        style: TextStyle(
                          fontSize: 12,
                          color: chat.unreadCount > 0
                              ? AppColors.primary
                              : AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          chat.lastMessage,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13,
                            color: chat.unreadCount > 0
                                ? AppColors.textPrimary
                                : AppColors.textSecondary,
                          ),
                        ),
                      ),
                      if (chat.unreadCount > 0) ...[
                        const SizedBox(width: 8),
                        Container(
                          width: 20,
                          height: 20,
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '${chat.unreadCount}',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NewChatDialog extends StatefulWidget {
  @override
  State<_NewChatDialog> createState() => _NewChatDialogState();
}

class _NewChatDialogState extends State<_NewChatDialog> {
  final _searchCtrl = TextEditingController();
  List<Map<String, dynamic>> _users = [];
  List<Map<String, dynamic>> _filteredUsers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUsers();
    _searchCtrl.addListener(_filterUsers);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadUsers() async {
    try {
      final currentUser = context.read<AuthProvider>().user;
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .get();

      final users = snapshot.docs
          .map((doc) {
            final data = doc.data();
            final uid = (data['uid'] as String?)?.trim();
            final resolvedId = (uid != null && uid.isNotEmpty) ? uid : doc.id;
            return {
              'id': resolvedId,
              'name': data['name'] ?? 'Unknown User',
              'skillsOffered': List<String>.from(data['skillsOffered'] ?? []),
              'email': data['email'] ?? '',
              'hasUid': uid != null && uid.isNotEmpty,
            };
          })
          .where((user) => user['hasUid'] == true)
          .where((user) => user['id'] != currentUser?.id) // Exclude current user
          .toList();

      // Sort by name
      users.sort((a, b) => (a['name'] as String).compareTo(b['name'] as String));

      setState(() {
        _users = users;
        _filteredUsers = users;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _filterUsers() {
    final query = _searchCtrl.text.toLowerCase().trim();
    
    setState(() {
      if (query.isEmpty) {
        _filteredUsers = _users;
      } else {
        _filteredUsers = _users.where((user) {
          final name = (user['name'] ?? '').toString().toLowerCase();
          final skills = (user['skillsOffered'] ?? []) as List;
          
          // Check if name contains query
          if (name.contains(query)) {
            return true;
          }
          
          // Check if any skill contains query
          for (var skill in skills) {
            if (skill.toString().toLowerCase().contains(query)) {
              return true;
            }
          }
          
          return false;
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Start New Conversation',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            // Search field
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.border),
              ),
              child: TextField(
                controller: _searchCtrl,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: const InputDecoration(
                  hintText: 'Search users by name or skill...',
                  hintStyle: TextStyle(color: AppColors.textMuted),
                  border: InputBorder.none,
                  prefixIcon: Icon(Icons.search_rounded,
                      color: AppColors.textMuted, size: 20),
                  contentPadding: EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Users list
            if (_isLoading)
              const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              )
            else if (_filteredUsers.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Text(
                    'No users found',
                    style: TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 14,
                    ),
                  ),
                ),
              )
            else
              SizedBox(
                height: 250,
                child: ListView.separated(
                  itemCount: _filteredUsers.length,
                  separatorBuilder: (_, i) => const Divider(
                    height: 1,
                    color: AppColors.border,
                  ),
                  itemBuilder: (context, index) {
                    final user = _filteredUsers[index];
                    return _UserTile(
                      name: user['name'],
                      skill: (user['skillsOffered'] as List).isNotEmpty
                          ? user['skillsOffered'][0]
                          : 'General',
                      initial: user['name'][0],
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, '/chat',
                            arguments: {
                              'partnerId': user['id'],
                              'partnerName': user['name']
                            });
                      },
                    );
                  },
                ),
              ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.border,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Cancel',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UserTile extends StatelessWidget {
  final String name;
  final String skill;
  final String initial;
  final VoidCallback onTap;

  const _UserTile({
    required this.name,
    required this.skill,
    required this.initial,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            AvatarWidget(
              name: name,
              size: 44,
              backgroundColor: AppColors.primary,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    skill,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded,
                size: 14, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }
}
