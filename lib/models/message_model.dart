enum MessageType { text, image, video, audio, document, location }

class MessageModel {
  final String id;
  final String senderId;
  final String senderName;
  final String? senderAvatarUrl;
  final String? receiverId;
  final String content;
  final MessageType type;
  final String? attachmentUrl;
  final DateTime timestamp;
  final String? sessionId;

  const MessageModel({
    required this.id,
    required this.senderId,
    required this.senderName,
    this.senderAvatarUrl,
    this.receiverId,
    required this.content,
    this.type = MessageType.text,
    this.attachmentUrl,
    required this.timestamp,
    this.sessionId,
  });

  /// Alias for backward compatibility
  String get text => content;

  /// Copy with method for updating fields
  MessageModel copyWith({
    String? id,
    String? senderId,
    String? senderName,
    String? senderAvatarUrl,
    String? receiverId,
    String? content,
    MessageType? type,
    String? attachmentUrl,
    DateTime? timestamp,
    String? sessionId,
  }) {
    return MessageModel(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      senderAvatarUrl: senderAvatarUrl ?? this.senderAvatarUrl,
      receiverId: receiverId ?? this.receiverId,
      content: content ?? this.content,
      type: type ?? this.type,
      attachmentUrl: attachmentUrl ?? this.attachmentUrl,
      timestamp: timestamp ?? this.timestamp,
      sessionId: sessionId ?? this.sessionId,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'senderId': senderId,
        'senderName': senderName,
        'senderAvatarUrl': senderAvatarUrl,
        'receiverId': receiverId,
        'content': content,
        'type': type.name,
        'attachmentUrl': attachmentUrl,
        'timestamp': timestamp.toIso8601String(),
        'sessionId': sessionId,
      };

  factory MessageModel.fromJson(Map<String, dynamic> json) => MessageModel(
        id: json['id'] as String,
        senderId: json['senderId'] as String,
        senderName: json['senderName'] as String,
        senderAvatarUrl: json['senderAvatarUrl'] as String?,
        receiverId: json['receiverId'] as String?,
        content: (json['content'] ?? json['text'] ?? '') as String,
        type: MessageType.values.byName(
            json['type'] as String? ?? 'text'),
        attachmentUrl: json['attachmentUrl'] as String?,
        timestamp: json['timestamp'] is String
            ? DateTime.parse(json['timestamp'] as String)
            : (json['timestamp'] as dynamic)?.toDate() ?? DateTime.now(),
        sessionId: json['sessionId'] as String?,
      );
}
