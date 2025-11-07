class UserStateModel {
  final String? role;
  final String grade;
  final String checkupState;
  final String spaceState;

  UserStateModel({
    this.role,
    required this.grade,
    required this.checkupState,
    required this.spaceState,
  });

  UserStateModel.fromJson(Map<String, dynamic> json)
      : role = json['role'],
        grade = json['grade'],
        checkupState = json['checkupState'],
        spaceState = json['spaceState'];

  Map<String, dynamic> toJson() {
    return {
      if (role != null) 'role': role,
      'grade': grade,
      'checkupState': checkupState,
      'spaceState': spaceState,
    };
  }
}
