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
  });

  /// Alias for backward compatibility
  String get text => content;

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
        timestamp: DateTime.parse(json['timestamp'] as String),
      );
}
