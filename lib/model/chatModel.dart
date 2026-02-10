class ChatMessage {
    String key;
    String senderId;
    String message;
    bool seen;
    String createdAt;
    String timeStamp;
    String senderName;
    String receiverId;

    ChatMessage({
        this.key = '',
        this.senderId = '',
        this.message = '',
        this.seen = false,
        this.createdAt = '',
        this.receiverId = '',
        this.senderName = '',
        this.timeStamp = ''
    });

    factory ChatMessage.fromJson(Map<dynamic, dynamic> json) => ChatMessage(
        key: json["key"]?.toString() ?? '',
        senderId: json["sender_id"]?.toString() ?? '',
        message: json["message"]?.toString() ?? '',
        seen: json["seen"] == true,
        createdAt: json["created_at"]?.toString() ?? '',
        timeStamp: json['timeStamp']?.toString() ?? '',
        senderName: json["senderName"]?.toString() ?? '',
        receiverId: json["receiverId"]?.toString() ?? ''
    );

    Map<String, dynamic> toJson() => {
        "key": key,
        "sender_id": senderId,
        "message": message,
        "receiverId": receiverId,
        "seen": seen,
        "created_at": createdAt,
        "senderName": senderName,
        "timeStamp":timeStamp
    };
}
