class UserModel {
  final int id;
  final String username;
  final bool isAdmin;
  final int? playerId;
  final String? inviteCode;
  final DateTime? createdAt;
  final DateTime? lastLogin;

  UserModel({
    required this.id,
    required this.username,
    this.isAdmin = false,
    this.playerId,
    this.inviteCode,
    this.createdAt,
    this.lastLogin,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? 0,
      username: json['username'] ?? '',
      isAdmin: json['isAdmin'] ?? false,
      playerId: json['playerId'],
      inviteCode: json['inviteCode'],
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      lastLogin: json['lastLogin'] != null ? DateTime.parse(json['lastLogin']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'isAdmin': isAdmin,
      'playerId': playerId,
      'inviteCode': inviteCode,
      'createdAt': createdAt?.toIso8601String(),
      'lastLogin': lastLogin?.toIso8601String(),
    };
  }
}
