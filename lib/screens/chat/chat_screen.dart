import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/calendar/v3.dart' as calendar;
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/helpers.dart';
import '../../models/message_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/chat_provider.dart';
import '../../providers/session_provider.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/avatar_widget.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _msgCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  String? _partnerId;
  String? _partnerName;
  String? _activeConversationKey;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Get partner ID from navigation arguments
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      _partnerId = args?['partnerId'] as String?;
      _partnerName = args?['partnerName'] as String?;

      _startConversationListenerIfReady();
    });
  }

  void _startConversationListenerIfReady() {
    final currentUser = context.read<AuthProvider>().user;
    if (currentUser == null || _partnerId == null) return;

    final conversationKey = '${currentUser.id}::$_partnerId';
    if (_activeConversationKey == conversationKey) return;

    _activeConversationKey = conversationKey;
    context.read<ChatProvider>().listenToConversation(currentUser.id, _partnerId!);
  }

  @override
  void dispose() {
    _msgCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final auth = context.read<AuthProvider>();
    final user = auth.user;
    if (user == null || _partnerId == null) return;

    final text = _msgCtrl.text.trim();
    if (text.isEmpty) return;

    context.read<ChatProvider>().sendMessage(
          senderId: user.id,
          senderName: user.name,
          receiverId: _partnerId!,
          content: text,
          sessionId: 'conv_${user.id}_${_partnerId!}',
        );
    _msgCtrl.clear();

    // Scroll to bottom
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _showAttachmentSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Send Attachment',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _AttachOption(
                  icon: Icons.image_rounded,
                  label: 'Image',
                  color: AppColors.primary,
                  onTap: () {
                    Navigator.pop(ctx);
                    _sendAttachmentMock(MessageType.image, '📷 Photo');
                  },
                ),
                _AttachOption(
                  icon: Icons.videocam_rounded,
                  label: 'Video',
                  color: AppColors.secondary,
                  onTap: () {
                    Navigator.pop(ctx);
                    _sendAttachmentMock(MessageType.video, '🎬 Video');
                  },
                ),
                _AttachOption(
                  icon: Icons.description_rounded,
                  label: 'Document',
                  color: AppColors.success,
                  onTap: () {
                    Navigator.pop(ctx);
                    _sendAttachmentMock(MessageType.document, '📄 Document');
                  },
                ),
                _AttachOption(
                  icon: Icons.mic_rounded,
                  label: 'Audio',
                  color: AppColors.warning,
                  onTap: () {
                    Navigator.pop(ctx);
                    _sendAttachmentMock(MessageType.audio, '🎵 Audio');
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _AttachOption(
                  icon: Icons.location_on_rounded,
                  label: 'Location',
                  color: AppColors.error,
                  onTap: () {
                    Navigator.pop(ctx);
                    _sendAttachmentMock(
                        MessageType.location, '📍 Current Location');
                  },
                ),
                const SizedBox(width: 60),
                const SizedBox(width: 60),
                const SizedBox(width: 60),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _sendAttachmentMock(MessageType type, String content) {
    final auth = context.read<AuthProvider>();
    final user = auth.user;
    if (user == null || _partnerId == null) return;

    context.read<ChatProvider>().sendAttachment(
          senderId: user.id,
          senderName: user.name,
          receiverId: _partnerId!,
          type: type,
          attachmentUrl: 'mock://${type.name}_${DateTime.now().millisecondsSinceEpoch}',
          sessionId: 'conv_${user.id}_${_partnerId!}',
          content: content,
        );
  }

  Future<Uri> _createGoogleMeetLink() async {
    final googleSignIn = GoogleSignIn(
      scopes: [
        calendar.CalendarApi.calendarScope,
        calendar.CalendarApi.calendarEventsScope,
      ],
    );

    GoogleSignInAccount? account = await googleSignIn.signInSilently();
    account ??= await googleSignIn.signIn();
    if (account == null) {
      throw Exception('Google sign-in was cancelled.');
    }

    final granted = await googleSignIn.requestScopes([
      calendar.CalendarApi.calendarScope,
      calendar.CalendarApi.calendarEventsScope,
    ]);

    if (!granted) {
      throw Exception('Google Calendar permission was not granted.');
    }

    final headers = await account.authHeaders;
    if (!headers.containsKey('Authorization')) {
      throw Exception('Missing Google authorization token.');
    }

    final authClient = _GoogleAuthClient(headers);
    final calendarApi = calendar.CalendarApi(authClient);

    final now = DateTime.now().toUtc();
    final event = calendar.Event(
      summary: 'ProofOfSkil Video Call',
      description: 'Auto-created from chat',
      start: calendar.EventDateTime(dateTime: now),
      end: calendar.EventDateTime(dateTime: now.add(const Duration(hours: 1))),
      conferenceData: calendar.ConferenceData(
        createRequest: calendar.CreateConferenceRequest(
          requestId: 'proof_call_${DateTime.now().millisecondsSinceEpoch}',
          conferenceSolutionKey:
              calendar.ConferenceSolutionKey(type: 'hangoutsMeet'),
        ),
      ),
    );

    final created = await calendarApi.events.insert(
      event,
      'primary',
      conferenceDataVersion: 1,
      sendUpdates: 'none',
    );

    final hangoutLink = created.hangoutLink;
    if (hangoutLink != null && hangoutLink.isNotEmpty) {
      return Uri.parse(hangoutLink);
    }

    final entryPoints = created.conferenceData?.entryPoints ?? const [];
    final videoEntry = entryPoints.cast<calendar.EntryPoint?>().firstWhere(
          (entry) => entry?.entryPointType == 'video' &&
              (entry?.uri?.isNotEmpty ?? false),
          orElse: () => null,
        );

    final uri = videoEntry?.uri;
    if (uri != null && uri.isNotEmpty) {
      return Uri.parse(uri);
    }

    throw Exception(
      'Google Meet link was not returned. Enable Google Calendar API in your Google Cloud project and try again.',
    );
  }

  Future<void> _startVideoCall() async {
    final user = context.read<AuthProvider>().user;
    final chatProvider = context.read<ChatProvider>();
    if (user == null || _partnerId == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to start call right now.')),
      );
      return;
    }

    Uri callUri;
    try {
      callUri = await _createGoogleMeetLink();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Could not create Google Meet link: ${error.toString().replaceFirst('Exception: ', '')}',
          ),
        ),
      );
      return;
    }

    await chatProvider.sendMessage(
      senderId: user.id,
      senderName: user.name,
      receiverId: _partnerId!,
      content: '📹 Join video call: ${callUri.toString()}',
      sessionId: 'conv_${user.id}_${_partnerId!}',
    );

    final launched = await launchUrl(
      callUri,
      mode: LaunchMode.externalApplication,
    );

    if (!launched && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open video call. Please try again.')),
      );
    }
  }

  void _showVideoCallDialog() {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.secondaryLight,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.videocam_rounded,
                    color: AppColors.secondary, size: 28),
              ),
              const SizedBox(height: 16),
              const Text(
                'Video Call',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                _partnerName == null
                  ? 'Start a Google Meet call and send a join link in chat automatically.'
                  : 'Start a Google Meet call with $_partnerName and auto-send the join link.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    height: 1.4),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: PrimaryButton(
                      text: 'Cancel',
                      isOutlined: true,
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: PrimaryButton(
                      text: 'Start Call',
                      onPressed: () async {
                        Navigator.pop(ctx);
                        await _startVideoCall();
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showRatingDialog() {
    int rating = 0;
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => Dialog(
          backgroundColor: AppColors.surface,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppColors.successLight,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.check_rounded,
                      color: AppColors.success, size: 28),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Session Complete!',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Rate your experience',
                  style: TextStyle(
                      fontSize: 14, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (i) {
                    return GestureDetector(
                      onTap: () => setS(() => rating = i + 1),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: AnimatedScale(
                          duration: const Duration(milliseconds: 200),
                          scale: i < rating ? 1.15 : 1.0,
                          child: Icon(
                            i < rating
                                ? Icons.star_rounded
                                : Icons.star_outline_rounded,
                            color: i < rating
                                ? AppColors.warning
                                : AppColors.border,
                            size: 36,
                          ),
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 12),
                Text(
                  rating > 0
                      ? ['', 'Poor', 'Fair', 'Good', 'Great', 'Excellent!'][rating]
                      : 'Tap to rate',
                  style: TextStyle(
                    fontSize: 14,
                    color: rating > 0
                        ? AppColors.textPrimary
                        : AppColors.textMuted,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.bolt_rounded,
                          color: AppColors.primary, size: 16),
                      SizedBox(width: 4),
                      Text('+100 points earned',
                          style: TextStyle(
                              color: AppColors.primary,
                              fontSize: 13,
                              fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                PrimaryButton(
                  text: 'Submit',
                  onPressed: () => Navigator.pop(ctx),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final chat = context.watch<ChatProvider>();
    final session = context.watch<SessionProvider>();
    final currentUser = context.watch<AuthProvider>().user;

    if (currentUser != null && _partnerId != null) {
      final conversationKey = '${currentUser.id}::$_partnerId';
      if (_activeConversationKey != conversationKey) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          final latestUser = context.read<AuthProvider>().user;
          if (latestUser == null || _partnerId == null) return;

          final latestConversationKey = '${latestUser.id}::$_partnerId';
          if (_activeConversationKey == latestConversationKey) return;

          _activeConversationKey = latestConversationKey;
          context
              .read<ChatProvider>()
              .listenToConversation(latestUser.id, _partnerId!);
        });
      }
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: GestureDetector(
          onTap: () {
            // Navigate to partner's profile - placeholder
          },
          child: Row(
            children: [
              Stack(
                children: [
                  AvatarWidget(
                      name: _partnerName ?? 'User',
                      size: 34,
                      backgroundColor: AppColors.primary),
                  // Online indicator
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: AppColors.success,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.surface, width: 2),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_partnerName ?? 'User',
                      style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary)),
                  const Text('Online',
                      style:
                          TextStyle(fontSize: 12, color: AppColors.success)),
                ],
              ),
            ],
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.videocam_outlined,
                color: AppColors.primary),
            onPressed: _showVideoCallDialog,
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.border),
        ),
      ),
      body: Column(
        children: [
          // Deep Focus Session banner
          _buildSessionBanner(session),
          // Messages
          Expanded(
            child: chat.isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                        color: AppColors.primary))
                : ListView.builder(
                    controller: _scrollCtrl,
                    padding: const EdgeInsets.all(16),
                    itemCount: chat.messages.length,
                    itemBuilder: (_, i) {
                      final msg = chat.messages[i];
                      final currentUser = context.read<AuthProvider>().user;
                      final isMe = currentUser != null && msg.senderId == currentUser.id;
                      return _Bubble(msg: msg, isMe: isMe);
                    },
                  ),
          ),
          // Input
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surface,
              border: Border(
                top: BorderSide(color: AppColors.border.withValues(alpha: 0.5)),
              ),
            ),
            child: SafeArea(
              child: Row(
                children: [
                  // Attachment button
                  GestureDetector(
                    onTap: _showAttachmentSheet,
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: const Icon(Icons.attach_file_rounded,
                          color: AppColors.textSecondary, size: 18),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: TextField(
                        controller: _msgCtrl,
                        style: const TextStyle(
                            color: AppColors.textPrimary, fontSize: 14),
                        decoration: const InputDecoration(
                          hintText: 'Type a message...',
                          border: InputBorder.none,
                          contentPadding:
                              EdgeInsets.symmetric(vertical: 10),
                        ),
                        onSubmitted: (_) => _sendMessage(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: _sendMessage,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.send_rounded,
                          color: Colors.white, size: 18),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSessionBanner(SessionProvider session) {
    // Active timer
    if (session.isSessionActive) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        color: AppColors.successLight,
        child: Row(
          children: [
            const Icon(Icons.timer_rounded,
                color: AppColors.success, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Deep Focus Session Active',
                    style: TextStyle(
                      color: AppColors.success,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    Helpers.formatDuration(session.elapsedSeconds),
                    style: const TextStyle(
                      color: AppColors.success,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () async {
                final completed = await session.endSession();
                if (completed != null && mounted) {
                  _showRatingDialog();
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.error,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'End Session',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Waiting for readiness
    if (session.isUser1Ready || session.isUser2Ready) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        color: AppColors.warningLight,
        child: Row(
          children: [
            const Icon(Icons.hourglass_top_rounded,
                color: AppColors.warning, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Waiting for partner...',
                    style: TextStyle(
                      color: AppColors.warning,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      _ReadyDot(
                          label: 'You',
                          isReady: session.isUser1Ready),
                      const SizedBox(width: 12),
                      _ReadyDot(
                          label: 'Partner',
                          isReady: session.isUser2Ready),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    // Default: Start session banner
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: AppColors.primaryLight,
      child: Row(
        children: [
          const Icon(Icons.school_rounded,
              color: AppColors.primary, size: 18),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              'Flutter Session · Ready to start',
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              final sessionProv = context.read<SessionProvider>();
              sessionProv.confirmReady(isUser1: true);
              sessionProv.simulatePartnerReady();
            },
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'Start Session',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Ready Indicator Dot ────────────────────────────────────
class _ReadyDot extends StatelessWidget {
  final String label;
  final bool isReady;
  const _ReadyDot({required this.label, required this.isReady});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: isReady ? AppColors.success : AppColors.border,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          '$label ${isReady ? "✓" : "..."}',
          style: TextStyle(
            fontSize: 11,
            color: isReady ? AppColors.success : AppColors.textMuted,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

// ─── Attachment Option ──────────────────────────────────────
class _AttachOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _AttachOption({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 6),
          Text(label,
              style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

// ─── Message Bubble ─────────────────────────────────────────
class _Bubble extends StatelessWidget {
  final MessageModel msg;
  final bool isMe;

  const _Bubble({required this.msg, required this.isMe});

  static final RegExp _urlRegExp = RegExp(r'https?://[^\s]+');

  String? _extractFirstUrl(String value) {
    final match = _urlRegExp.firstMatch(value);
    return match?.group(0);
  }

  @override
  Widget build(BuildContext context) {
    final isAttachment = msg.type != MessageType.text;
    final link = _extractFirstUrl(msg.content);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Sender avatar (non-me only)
          if (!isMe) ...[
            AvatarWidget(
              name: msg.senderName,
              size: 28,
              backgroundColor: AppColors.primary,
            ),
            const SizedBox(width: 8),
          ],
          Container(
            constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.68),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isMe ? AppColors.primary : AppColors.surface,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(18),
                topRight: const Radius.circular(18),
                bottomLeft: Radius.circular(isMe ? 18 : 4),
                bottomRight: Radius.circular(isMe ? 4 : 18),
              ),
              border: isMe ? null : Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Attachment indicator
                if (isAttachment) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 8),
                    margin: const EdgeInsets.only(bottom: 6),
                    decoration: BoxDecoration(
                      color: isMe
                          ? Colors.white.withValues(alpha: 0.15)
                          : AppColors.background,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _getAttachmentIcon(msg.type),
                          size: 18,
                          color: isMe
                              ? Colors.white70
                              : AppColors.textSecondary,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          msg.type.name.toUpperCase(),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: isMe
                                ? Colors.white70
                                : AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                if (link == null)
                  Text(
                    msg.content,
                    style: TextStyle(
                      color: isMe ? Colors.white : AppColors.textPrimary,
                      fontSize: 14,
                      height: 1.4,
                    ),
                  )
                else ...[
                  Text(
                    msg.content.replaceFirst(link, '').trim(),
                    style: TextStyle(
                      color: isMe ? Colors.white : AppColors.textPrimary,
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () async {
                      final uri = Uri.tryParse(link);
                      if (uri == null) return;
                      await launchUrl(uri, mode: LaunchMode.externalApplication);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      decoration: BoxDecoration(
                        color: isMe
                            ? Colors.white.withValues(alpha: 0.2)
                            : AppColors.background,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isMe
                              ? Colors.white.withValues(alpha: 0.35)
                              : AppColors.border,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.videocam_rounded,
                            size: 16,
                            color: isMe ? Colors.white : AppColors.primary,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Join Call',
                            style: TextStyle(
                              color: isMe ? Colors.white : AppColors.primary,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 4),
                Align(
                  alignment: Alignment.bottomRight,
                  child: Text(
                    Helpers.timeAgo(msg.timestamp),
                    style: TextStyle(
                      color: isMe ? Colors.white70 : AppColors.textMuted,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Sender avatar (me only)
          if (isMe) ...[
            const SizedBox(width: 8),
            AvatarWidget(
              name: msg.senderName,
              size: 28,
              backgroundColor: AppColors.primaryDark,
            ),
          ],
        ],
      ),
    );
  }

  IconData _getAttachmentIcon(MessageType type) {
    switch (type) {
      case MessageType.image:
        return Icons.image_rounded;
      case MessageType.video:
        return Icons.videocam_rounded;
      case MessageType.audio:
        return Icons.mic_rounded;
      case MessageType.document:
        return Icons.description_rounded;
      case MessageType.location:
        return Icons.location_on_rounded;
      default:
        return Icons.attach_file_rounded;
    }
  }
}

class _GoogleAuthClient extends http.BaseClient {
  final Map<String, String> _headers;
  final http.Client _inner = http.Client();

  _GoogleAuthClient(this._headers);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    request.headers.addAll(_headers);
    return _inner.send(request);
  }

  @override
  void close() {
    _inner.close();
    super.close();
  }
}
