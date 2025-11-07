class AgreementModel {
  final bool termsConditions;
  final bool privacyPolicy;
  final bool pushNotice;
  final bool pushAd;

  AgreementModel({
    required this.termsConditions,
    required this.privacyPolicy,
    required this.pushNotice,
    required this.pushAd,
  });

  AgreementModel.fromJson(Map<String, dynamic> json)
      : termsConditions = json['termsConditions'],
        privacyPolicy = json['privacyPolicy'],
        pushNotice = json['pushNotice'],
        pushAd = json['pushAd'];

  Map<String, dynamic> toJson() {
    return {
      'termsConditions': termsConditions,
      'privacyPolicy': privacyPolicy,
      'pushNotice': pushNotice,
      'pushAd': pushAd,
    };
  }
}
