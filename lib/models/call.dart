class Call {
  Call({
    required this.id,
    required this.callerId,
    required this.callerName,
    required this.callerImage,
    required this.receiverId,
    required this.type, // 'audio' or 'video'
    required this.time,
    required this.status, // 'missed', 'incoming', 'outgoing'
  });
  late final String id;
  late final String callerId;
  late final String callerName;
  late final String callerImage;
  late final String receiverId;
  late final String type;
  late final String time;
  late final String status;

  Call.fromJson(Map<String, dynamic> json) {
    id = json['id'] ?? '';
    callerId = json['caller_id'] ?? '';
    callerName = json['caller_name'] ?? '';
    callerImage = json['caller_image'] ?? '';
    receiverId = json['receiver_id'] ?? '';
    type = json['type'] ?? 'audio';
    time = json['time'] ?? '';
    status = json['status'] ?? 'incoming';
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['caller_id'] = callerId;
    data['caller_name'] = callerName;
    data['caller_image'] = callerImage;
    data['receiver_id'] = receiverId;
    data['type'] = type;
    data['time'] = time;
    data['status'] = status;
    return data;
  }
}
