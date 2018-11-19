class User {
  User({this.name, this.city, this.avatarId});

  String name;
  String city;
  int avatarId;

  User copy({String name, String city, int avatarId}) => User(
        name: name ?? this.name,
        city: city ?? this.city,
        avatarId: avatarId ?? this.avatarId,
      );
}
