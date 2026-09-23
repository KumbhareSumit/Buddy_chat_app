class Status {
  Status({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userImage,
    required this.imageUrl,
    required this.createdAt,
  });
  late final String id;
  late final String userId;
  late final String userName;
  late final String userImage;
  late final String imageUrl;
  late final String createdAt;

  Status.fromJson(Map<String, dynamic> json) {
    id = json['id'] ?? '';
    userId = json['user_id'] ?? '';
    userName = json['user_name'] ?? '';
    userImage = json['user_image'] ?? '';
    imageUrl = json['image_url'] ?? '';
    createdAt = json['created_at'] ?? '';
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['user_id'] = userId;
    data['user_name'] = userName;
    data['user_image'] = userImage;
    data['image_url'] = imageUrl;
    data['created_at'] = createdAt;
    return data;
  }
}
