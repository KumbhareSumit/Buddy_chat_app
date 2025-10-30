class ChatUser {
  ChatUser({
    required this.image,
    required this.email ,
    required this.about,
    required this.name,
    required this.createdAt,
    required this.lastActive,
    required this.isOnline,
    required this.id,
    required this.pushToken,
  });
  late  String image;
  late  String email ;
  late  String about;
  late  String name;
  late  String createdAt;
  late  String lastActive;
  late  bool isOnline;
  late  String id;
  late  String pushToken;

  ChatUser.fromJson(Map<String, dynamic> json){
    image = json['image'] ?? '';
    email  = json['email '] ?? '';
    about = json['about'] ?? '';
    name = json['name'] ?? '';
    createdAt = json['created_at'] ?? '';
    lastActive = json['last_active'] ?? '';
    isOnline = json['is_online'] ?? '';
    id = json['id'] ?? '';
    pushToken = json['push_token'] ?? '';
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['image'] = image;
    _data['email '] = email ;
    _data['about'] = about;
    _data['name'] = name;
    _data['created_at'] = createdAt;
    _data['last_active'] = lastActive;
    _data['is_online'] = isOnline;
    _data['id'] = id;
    _data['push_token'] = pushToken;
    return _data;
  }
}