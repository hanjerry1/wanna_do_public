class PointModel {
  final String uid;
  final int point;

  PointModel({
    required this.uid,
    required this.point,
  });

  PointModel.fromJson(Map<String, dynamic> json)
      : uid = json['uid'],
        point = json['point'];

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'point': point,
    };
  }
}
