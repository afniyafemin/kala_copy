class UserModel {
  String uid;
  String? username;
  String? email;
  String? category;
  String? phone;
  String? city;
  String? description;
  String? profileImageUrl; // Added field for profile picture URL
  bool isFavorite;
  List<String> followers;
  List<String> following;
  List<dynamic> ratings;

  UserModel({
    required this.uid,
    required this.username,
    required this.email,
    required this.category,
    required this.phone,
    required this.city,
    this.description,
    this.profileImageUrl, // Initialize with null (optional)
    this.isFavorite = false,
    this.followers = const [],
    this.following = const [],
    this.ratings = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'username': username,
      'email': email,
      'category': category,
      'phone': phone,
      'city': city,
      'description': description ?? "when art meets technology",
      'profileImageUrl': profileImageUrl, // Add profile picture URL to map
      'isFavorite': isFavorite,
      'followers': followers,
      'following': following,
      'ratings': ratings,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> data) {
    return UserModel(
      uid: data['uid'],
      email: data['email'],
      username: data['username']?.toString(),
      phone: data['phoneNo'],
      city: data['city'],
      category: data['category'],
      description: data['description'] ?? "when art meets technology",
      profileImageUrl: data['profileImageUrl']?.toString(), // Extract profile picture URL
      isFavorite: data['isFavorite'] ?? false,
      followers: List<String>.from(data['followers'] ?? []),
      following: List<String>.from(data['following'] ?? []),
      ratings: data['ratings'] ?? [],
    );
  }

  UserModel copyWith({
    String? uid,
    String? username,
    String? email,
    String? category,
    String? phone,
    String? city,
    String? description,
    String? profileImageUrl,
    bool? isFavorite,
    List<String>? followers,
    List<String>? following,
    List<dynamic>? ratings,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      username: username ?? this.username,
      email: email ?? this.email,
      category: category ?? this.category,
      phone: phone ?? this.phone,
      city: city ?? this.city,
      description: description ?? this.description,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl, // Handle profile picture URL
      isFavorite: isFavorite ?? this.isFavorite,
      followers: followers ?? this.followers,
      following: following ?? this.following,
      ratings: ratings ?? this.ratings,
    );
  }
}
