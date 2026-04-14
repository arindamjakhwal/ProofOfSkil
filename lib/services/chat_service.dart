import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/message_model.dart';

/// Chat service — uses Firestore for real-time messaging.
class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _matchesConversation(
    Map<String, dynamic> data,
    String userId1,
    String userId2,
  ) {
    final senderId = data['senderId'] as String?;
    final receiverId = data['receiverId'] as String?;
    final participants = List<String>.from(data['participants'] ?? const []);

    final matchesSenderReceiver =
        (senderId == userId1 && receiverId == userId2) ||
        (senderId == userId2 && receiverId == userId1);
    final matchesParticipants =
        participants.contains(userId1) && participants.contains(userId2);

    return matchesSenderReceiver || matchesParticipants;
  }

  DateTime _timestampFromData(Map<String, dynamic> data) {
    final timestamp = data['timestamp'];
    if (timestamp is Timestamp) {
      return timestamp.toDate();
    }
    if (timestamp is String) {
      return DateTime.tryParse(timestamp) ?? DateTime.now();
    }
    return DateTime.now();
  }

  /// Get messages between two users in real-time.
  Stream<List<MessageModel>> getConversationStream(
      String userId1, String userId2) {
    return _firestore
        .collection('messages')
        .snapshots()
        .map((snapshot) {
      final filtered = snapshot.docs
          .where((doc) {
            return _matchesConversation(doc.data(), userId1, userId2);
          })
          .toList();
      
      // Sort by timestamp
      filtered.sort((a, b) {
        final aTime = _timestampFromData(a.data());
        final bTime = _timestampFromData(b.data());
        return aTime.compareTo(bTime);
      });
      
      final result = filtered
          .map((doc) => MessageModel.fromJson({...doc.data(), 'id': doc.id}))
          .toList();
      return result;
    });
  }

  /// Get messages between two users (one-time fetch).
  Future<List<MessageModel>> getConversation(
      String userId1, String userId2) async {
    try {
      final snapshot = await _firestore
          .collection('messages')
          .get();

      final filtered = snapshot.docs
          .where((doc) {
            return _matchesConversation(doc.data(), userId1, userId2);
          })
          .toList();
      
      // Sort by timestamp
      filtered.sort((a, b) {
        final aTime = _timestampFromData(a.data());
        final bTime = _timestampFromData(b.data());
        return aTime.compareTo(bTime);
      });

      return filtered
          .map((doc) => MessageModel.fromJson({...doc.data(), 'id': doc.id}))
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Delete all messages between two users.
  Future<void> deleteConversation(String userId1, String userId2) async {
    final snapshot = await _firestore.collection('messages').get();

    final docsToDelete = snapshot.docs.where((doc) {
      return _matchesConversation(doc.data(), userId1, userId2);
    }).toList();

    if (docsToDelete.isEmpty) return;

    const batchSize = 400;
    for (var start = 0; start < docsToDelete.length; start += batchSize) {
      final end = (start + batchSize < docsToDelete.length)
          ? start + batchSize
          : docsToDelete.length;
      final chunk = docsToDelete.sublist(start, end);

      final batch = _firestore.batch();
      for (final doc in chunk) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    }
  }

  /// Send a message to Firestore.
  Future<MessageModel> sendMessage(MessageModel message) async {
    try {
      final docRef = await _firestore.collection('messages').add({
        'senderId': message.senderId,
        'senderName': message.senderName,
        'receiverId': message.receiverId,
        'content': message.content,
        'type': message.type.name,
        'attachmentUrl': message.attachmentUrl,
        'timestamp': message.timestamp,
        'sessionId': message.sessionId,
        'participants': [message.senderId, message.receiverId],
      });

      return message.copyWith(id: docRef.id);
    } catch (e) {
      rethrow;
    }
  }

  /// Send an attachment message.
  Future<MessageModel> sendAttachment({
    required String senderId,
    required String senderName,
    required String receiverId,
    required MessageType type,
    required String attachmentUrl,
    required String sessionId,
    String content = '',
  }) async {
    try {
      final message = MessageModel(
        id: '',
        senderId: senderId,
        senderName: senderName,
        receiverId: receiverId,
        content: content.isEmpty ? type.name.toUpperCase() : content,
        type: type,
        attachmentUrl: attachmentUrl,
        timestamp: DateTime.now(),
        sessionId: sessionId,
      );

      return await sendMessage(message);
    } catch (e) {
      rethrow;
    }
  }

  /// Get chat previews (latest message per conversation).
  Stream<List<ChatPreview>> getChatPreviewsStream(String userId) {
    return _firestore
        .collection('messages')
        .snapshots()
        .asyncMap((snapshot) async {
      final Map<String, ChatPreview> previews = {};

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final senderId = data['senderId'] as String?;
        final receiverId = data['receiverId'] as String?;

        if (senderId == null || receiverId == null) continue;
        if (senderId != userId && receiverId != userId) continue;

        final partnerId = senderId == userId ? receiverId : senderId;
        final sessionId = (data['sessionId'] as String?) ?? 'conversation_$partnerId';
        final timestamp = _timestampFromData(data);

        final existing = previews[partnerId];
        if (existing != null && !timestamp.isAfter(existing.time)) {
          continue;
        }

        try {
          final userDoc = await _firestore.collection('users').doc(partnerId).get();
          if (userDoc.exists) {
            final userData = userDoc.data() as Map<String, dynamic>;
            previews[partnerId] = ChatPreview(
              sessionId: sessionId,
              partnerId: partnerId,
              partnerName: userData['name'] ?? 'Unknown',
              partnerInitial: (userData['name'] ?? 'U').toString()[0],
              lastMessage: data['content'] ?? '',
              time: timestamp,
              unreadCount: 0, // TODO: Implement unread count
              isOnline: userData['isOnline'] ?? false,
              skill: userData['skillsOffered']?[0] ?? 'General',
            );
          } else {
            previews[partnerId] = ChatPreview(
              sessionId: sessionId,
              partnerId: partnerId,
              partnerName: 'Unknown',
              partnerInitial: 'U',
              lastMessage: data['content'] ?? '',
              time: timestamp,
              unreadCount: 0,
              isOnline: false,
              skill: 'General',
            );
          }
        } catch (_) {
          previews[partnerId] = ChatPreview(
            sessionId: sessionId,
            partnerId: partnerId,
            partnerName: 'Unknown',
            partnerInitial: 'U',
            lastMessage: data['content'] ?? '',
            time: timestamp,
            unreadCount: 0,
            isOnline: false,
            skill: 'General',
          );
        }
      }

      final result = previews.values.toList()
        ..sort((a, b) => b.time.compareTo(a.time));
      return result;
    });
  }

  /// Get chat previews (one-time fetch).
  Future<List<ChatPreview>> getChatPreviews(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('messages')
          .get();

      final Map<String, ChatPreview> previews = {};

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final senderId = data['senderId'] as String?;
        final receiverId = data['receiverId'] as String?;

        if (senderId == null || receiverId == null) continue;
        if (senderId != userId && receiverId != userId) continue;

        final partnerId = senderId == userId ? receiverId : senderId;
        final sessionId = (data['sessionId'] as String?) ?? 'conversation_$partnerId';
        final timestamp = _timestampFromData(data);

        final existing = previews[partnerId];
        if (existing != null && !timestamp.isAfter(existing.time)) {
          continue;
        }

        try {
          final userDoc = await _firestore.collection('users').doc(partnerId).get();
          if (userDoc.exists) {
            final userData = userDoc.data() as Map<String, dynamic>;
            previews[partnerId] = ChatPreview(
              sessionId: sessionId,
              partnerId: partnerId,
              partnerName: userData['name'] ?? 'Unknown',
              partnerInitial: (userData['name'] ?? 'U').toString()[0],
              lastMessage: data['content'] ?? '',
              time: timestamp,
              unreadCount: 0,
              isOnline: userData['isOnline'] ?? false,
              skill: userData['skillsOffered']?[0] ?? 'General',
            );
          } else {
            previews[partnerId] = ChatPreview(
              sessionId: sessionId,
              partnerId: partnerId,
              partnerName: 'Unknown',
              partnerInitial: 'U',
              lastMessage: data['content'] ?? '',
              time: timestamp,
              unreadCount: 0,
              isOnline: false,
              skill: 'General',
            );
          }
        } catch (_) {
          previews[partnerId] = ChatPreview(
            sessionId: sessionId,
            partnerId: partnerId,
            partnerName: 'Unknown',
            partnerInitial: 'U',
            lastMessage: data['content'] ?? '',
            time: timestamp,
            unreadCount: 0,
            isOnline: false,
            skill: 'General',
          );
        }
      }

      final result = previews.values.toList()
        ..sort((a, b) => b.time.compareTo(a.time));
      return result;
    } catch (e) {
      return [];
    }
  }
}

class ChatPreview {
  final String sessionId;
  final String partnerId;
  final String partnerName;
  final String partnerInitial;
  final String lastMessage;
  final DateTime time;
  final int unreadCount;
  final bool isOnline;
  final String skill;

  const ChatPreview({
    required this.sessionId,
    required this.partnerId,
    required this.partnerName,
    required this.partnerInitial,
    required this.lastMessage,
    required this.time,
    required this.unreadCount,
    required this.isOnline,
    required this.skill,
  });
}
