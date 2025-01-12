class UserModel {
  String uid;
  String? username;
  String? email;
  String? category;
  String? phone;
  String? city;
  String? description;
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
      'isFavorite': isFavorite,
      'followers': followers ?? [] ,
      'following': following ?? [],
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
      isFavorite: data['isFavorite'] ?? false,

    );
  }

  // Added copyWith method
  UserModel copyWith({
    String? uid,
    String? username,
    String? email,
    String? category,
    String? phone,
    String? city,
    String? description,
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
      isFavorite: isFavorite ?? this.isFavorite,
      followers: followers ?? this.followers,
      following: following ?? this.following,
      ratings: ratings ?? this.ratings,
    );
  }
}