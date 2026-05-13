class AppUser {
  final String id;
  final String name;
  final String email;
  final String? profilePicture;
  final bool isGuest;
  final DateTime? createdAt;
  final String? role;

  AppUser({
    required this.id,
    required this.name,
    required this.email,
    this.profilePicture,
    this.isGuest = false,
    this.createdAt,
    this.role = 'user',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'profilePicture': profilePicture,
      'isGuest': isGuest ? 1 : 0,
      'createdAt': createdAt?.toIso8601String(),
      'role': role,
    };
  }

  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      id: map['id']?.toString() ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      profilePicture: map['profilePicture'],
      isGuest: (map['isGuest'] == 1 || map['isGuest'] == true),
      createdAt: map['createdAt'] != null ? DateTime.parse(map['createdAt']) : null,
      role: map['role'] ?? 'user',
    );
  }

  AppUser copyWith({
    String? id,
    String? name,
    String? email,
    String? profilePicture,
    bool? isGuest,
    DateTime? createdAt,
    String? role,
  }) {
    return AppUser(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      profilePicture: profilePicture ?? this.profilePicture,
      isGuest: isGuest ?? this.isGuest,
      createdAt: createdAt ?? this.createdAt,
      role: role ?? this.role,
    );
  }
}
