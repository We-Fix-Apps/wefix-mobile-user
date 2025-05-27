class ProfileModel {
  Profile? profile;

  ProfileModel({
    this.profile,
  });

  ProfileModel.fromJson(Map<String, dynamic> json) {
    profile = (json['profile'] as Map<String, dynamic>?) != null
        ? Profile.fromJson(json['profile'] as Map<String, dynamic>)
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = <String, dynamic>{};
    json['profile'] = profile?.toJson();
    return json;
  }
}

class Profile {
  String? email;
  String? firstname;
  String? lastname;
  String? profileImage;

  Profile({
    this.email,
    this.firstname,
    this.lastname,
    this.profileImage,
  });

  Profile.fromJson(Map<String, dynamic> json) {
    email = json['email'] as String?;
    firstname = json['firstname'] as String?;
    lastname = json['lastname'] as String?;
    profileImage = json['profileImage'] as String?;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = <String, dynamic>{};
    json['email'] = email;
    json['firstname'] = firstname;
    json['lastname'] = lastname;
    json['profileImage'] = profileImage;
    return json;
  }
}
