class User {
  final int id;
  final String name;
  final String email;
  final String? profileImageUrl;

  const User({
    required this.id,
    required this.name,
    required this.email,
    this.profileImageUrl,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json['id'] as int,
    name: json['name'] as String,
    email: json['email'] as String,
    profileImageUrl: json['profile_image_url'] as String?,
  );
}
