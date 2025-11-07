import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:crypto/crypto.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart' as kakao;
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:wanna_do/component/start_guide.dart';
import 'package:wanna_do/const/colors.dart';
import 'package:wanna_do/container/help/agreement_home.dart';
import 'package:wanna_do/model/log/delete_user_model.dart';
import 'package:wanna_do/model/point/point_model.dart';
import 'package:wanna_do/model/statistic/statistic_model.dart';
import 'package:wanna_do/model/user/agreement_model.dart';
import 'package:wanna_do/model/user/user_model.dart';
import 'package:wanna_do/model/user/user_state_model.dart';
import 'package:wanna_do/style/dialog_style.dart';
import 'package:wanna_do/style/loading_style.dart';
import 'package:wanna_do/style/text_style.dart';
import 'package:wanna_do/style/toast_style.dart';

class StartLogin extends StatefulWidget {
  const StartLogin({super.key});

  @override
  _StartLoginState createState() => _StartLoginState();
}

class _StartLoginState extends State<StartLogin> {
  String authUid = '';
  String appleUid = '';
  String appleEmail = '';
  String appleGivenName = '';
  double text1Opacity = 0.0;
  double text2Opacity = 0.0;
  double imageOpacity = 0.0;
  bool isLoading = false;
  bool isAppleLogin = true;
  bool isKakaoLogin = true;
  List<int> selectedCheckIndexs = [];
  final List<String> checkTexts = [
    '이용약관 동의',
    '개인정보 이용 동의',
  ];

  @override
  void initState() {
    super.initState();
    remoteConfigLogin();
    Future.delayed(Duration(milliseconds: 200), () {
      setState(() {
        text1Opacity = 1.0;
      });
      Future.delayed(Duration(milliseconds: 800), () {
        setState(() {
          text2Opacity = 1.0;
        });
        Future.delayed(Duration(milliseconds: 1200), () {
          setState(() {
            imageOpacity = 1.0;
          });
        });
      });
    });
  }

  Future<void> kakaoInstallCheck() async {
    try {
      setState(() {
        isLoading = true;
      });
      bool isInstalled = await kakao.isKakaoTalkInstalled();
      if (isInstalled) {
        await kakao.UserApi.instance.loginWithKakaoTalk();
        await kakaoLoginAndManage();
      } else {
        await kakao.UserApi.instance.loginWithKakaoAccount();
        await kakaoLoginAndManage();
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ErrorGetxToast.show(context, '네트워크를 확인해주세요', '오류가 계속되면 MY탭에서 문의해주세요');
    }
  }

  Future<void> kakaoLoginAndManage() async {
    try {
      kakao.User user = await kakao.UserApi.instance.me();

      final token = await createTokenFirebaseKakaoLogin({
        'uid': user.id.toString(),
        'email': user.kakaoAccount!.email ?? '',
        'phone': user.kakaoAccount!.phoneNumber ?? '',
        'kakaoName': user.kakaoAccount!.name ?? '',
        'photoUrl': user.kakaoAccount!.profile!.profileImageUrl ?? '',
      });

      await FirebaseAuth.instance.signInWithCustomToken(token);

      DocumentReference userRef =
          FirebaseFirestore.instance.collection('user').doc(user.id.toString());
      DocumentSnapshot userDoc = await userRef.get();

      if (userDoc.exists) {
        Get.off(() => StartGuide());
      } else {
        QuerySnapshot querySnapshot = await FirebaseFirestore.instance
            .collection('log')
            .doc('deleteLog')
            .collection('deleteLog')
            .where('uid', isEqualTo: user.id.toString())
            .orderBy('createdAt', descending: true)
            .limit(1)
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          DeleteUserModel data = DeleteUserModel.fromJson(
            querySnapshot.docs.first.data() as Map<String, dynamic>,
          );

          Duration difference =
              DateTime.now().difference(data.createdAt.toDate());

          if (difference.inDays < 90) {
            setState(() {
              isLoading = false;
            });
            await FirebaseAuth.instance.currentUser!
                .delete()
                .catchError((error) {
              print("오류: $error");
            });

            ErrorGetxToast.show(
                context, '탈퇴 3개월 후 재가입할 수 있어요', '문제시 워너두 이메일로 연락해주세요');
            return;
          }
        }
        WriteBatch batch = FirebaseFirestore.instance.batch();

        String deviceId = '';
        if (Platform.isAndroid) {
          AndroidDeviceInfo androidInfo = await DeviceInfoPlugin().androidInfo;
          deviceId = androidInfo.id;
        } else if (Platform.isIOS) {
          IosDeviceInfo iosInfo = await DeviceInfoPlugin().iosInfo;
          deviceId = iosInfo.identifierForVendor!;
          await Future.delayed(Duration(seconds: 1));
        }

        final fcmToken = await FirebaseMessaging.instance.getToken() ?? '';

        UserModel userModel = UserModel(
          uid: user.id.toString(),
          name: user.kakaoAccount!.name ?? '',
          nickname: user.kakaoAccount!.name ?? '',
          email: user.kakaoAccount!.email ?? '',
          phone: user.kakaoAccount!.phoneNumber ?? '',
          birth:
              '${user.kakaoAccount!.birthyear}${user.kakaoAccount!.birthday}',
          gender: user.kakaoAccount!.gender.toString(),
          deviceId: deviceId,
          fcmToken: fcmToken,
          appleUid: '',
          whereLogin: 'kakao',
        );

        UserStateModel userStateModel = UserStateModel(
          grade: '0',
          checkupState: '0',
          spaceState: '0',
        );

        AgreementModel agreementModel = AgreementModel(
          termsConditions: false,
          privacyPolicy: false,
          pushNotice: true,
          pushAd: false,
        );

        PointModel pointModel = PointModel(
          uid: user.id.toString(),
          point: 0,
        );

        StatisticModel statisticModel = StatisticModel(
          uid: user.id.toString(),
          name: user.kakaoAccount!.name ?? '',
          totalChallenge: 0,
          totalWin: 0,
          totalLose: 0,
          monthChallenge: 0,
          monthWin: 0,
          monthLose: 0,
          totalMyPost: 0,
          totalMyLikePost: 0,
          monthMyPost: 0,
          totalCheckup: 0,
          monthCheckup: 0,
          todayCheckup: 10,
          monthPointOutTicket: 1,
          totalMedal: 0,
        );

        batch.set(userRef, userModel.toJson());
        batch.set(userRef.collection('userState').doc(user.id.toString()),
            userStateModel.toJson());
        batch.set(userRef.collection('agreement').doc(user.id.toString()),
            agreementModel.toJson());
        batch.set(
            FirebaseFirestore.instance
                .collection('point')
                .doc(user.id.toString()),
            pointModel.toJson());
        batch.set(
            FirebaseFirestore.instance
                .collection('statistic')
                .doc(user.id.toString()),
            statisticModel.toJson());

        await batch.commit();
        await callUpdateUserStateRole(user.id.toString());

        Get.off(() => StartGuide());
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ErrorGetxToast.show(context, '네트워크를 확인해주세요', '오류가 계속되면 MY탭에서 문의해주세요');
    }
  }

  Future<String> createTokenFirebaseKakaoLogin(
    Map<String, dynamic> kakaoData,
  ) async {
    final String authUrl = dotenv.env['KAKAO_FIREBASE_LOGIN_SERVER'] ?? '';
    final customTokenResponse = await Dio().post(authUrl, data: kakaoData);
    return customTokenResponse.data;
  }

  String generateNonce([int length = 32]) {
    final charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(length, (_) => charset[random.nextInt(charset.length)])
        .join();
  }

  String sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<UserCredential?> appleLogin() async {
    try {
      setState(() {
        isLoading = true;
      });

      final rawNonce = generateNonce();
      final nonce = sha256ofString(rawNonce); // 보안을 강화하기 위한 일회성 토큰번호
      final RegExp emailRegex = RegExp(
        r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+.[a-zA-Z]{2,4}$',
      );

      String redirectURL =
          'https://wanna-do-64b08.firebaseapp.com/__/auth/handler';
      String clientID = 'wannaDo.hst.com';
      // 애플 페이지에서 invalid_client일 경우, 위 2개 변수값이 잘못된거임.

      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: nonce,
        webAuthenticationOptions: WebAuthenticationOptions(
          clientId: clientID,
          redirectUri: Uri.parse(redirectURL),
        ),
      );

      if (appleCredential.email != null &&
          emailRegex.hasMatch(appleCredential.email!)) {
        final List<String> signInMethods = await FirebaseAuth.instance
            .fetchSignInMethodsForEmail(appleCredential.email!);
        if (signInMethods.isNotEmpty) {
          setState(() {
            isLoading = false;
          });
          ErrorGetxToast.show(
              context, '이미 다른 계정에 등록된 이메일이에요', '카카오 계정이나 다른 로그인을 이용해주세요');
          return null;
        }
      }

      final oauthCredential = OAuthProvider("apple.com").credential(
        idToken: appleCredential.identityToken,
        rawNonce: rawNonce,
      );

      final userCredential =
          await FirebaseAuth.instance.signInWithCredential(oauthCredential);

      setState(() {
        appleUid = appleCredential.userIdentifier!;
        appleEmail = appleCredential.email ?? 'appleEmail';
        appleGivenName = appleCredential.givenName ?? '논애플';
        authUid = userCredential.user!.uid;
      });

      appleManage();

      return userCredential;
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ErrorGetxToast.show(context, '네트워크를 확인해주세요', '오류가 계속되면 MY탭에서 문의해주세요');
      return null;
    }
  }

  Future<void> appleManage() async {
    try {
      DocumentReference userRef =
          FirebaseFirestore.instance.collection('user').doc(authUid);
      DocumentSnapshot userDoc = await userRef.get();

      if (userDoc.exists) {
        Get.off(() => StartGuide());
      } else {
        QuerySnapshot querySnapshot = await FirebaseFirestore.instance
            .collection('log')
            .doc('deleteLog')
            .collection('deleteLog')
            .where('appleUid', isEqualTo: appleUid)
            .orderBy('createdAt', descending: true)
            .limit(1)
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          DeleteUserModel data = DeleteUserModel.fromJson(
            querySnapshot.docs.first.data() as Map<String, dynamic>,
          );

          Duration difference =
              DateTime.now().difference(data.createdAt.toDate());

          if (difference.inDays < 90) {
            setState(() {
              isLoading = false;
            });
            await FirebaseAuth.instance.currentUser!
                .delete()
                .catchError((error) {
              print("오류: $error");
            });

            ErrorGetxToast.show(
                context, '탈퇴 3개월 후 재가입할 수 있어요', '문제시 워너두 이메일로 연락해주세요');
            return;
          }
        }
        WriteBatch batch = FirebaseFirestore.instance.batch();

        String deviceId = '';
        final fcmToken = await FirebaseMessaging.instance.getToken();
        if (Platform.isAndroid) {
          AndroidDeviceInfo androidInfo = await DeviceInfoPlugin().androidInfo;
          deviceId = androidInfo.id;
        } else if (Platform.isIOS) {
          IosDeviceInfo iosInfo = await DeviceInfoPlugin().iosInfo;
          deviceId = iosInfo.identifierForVendor!;
        }

        UserModel userModel = UserModel(
          uid: authUid,
          name: appleGivenName,
          nickname: appleGivenName,
          email: appleEmail,
          phone: 'applePhone',
          birth: 'appleBirth',
          gender: 'appleGender',
          deviceId: deviceId,
          fcmToken: fcmToken,
          appleUid: appleUid,
          whereLogin: 'apple',
        );

        UserStateModel userStateModel = UserStateModel(
          grade: '0',
          checkupState: '0',
          spaceState: '0',
        );

        AgreementModel agreementModel = AgreementModel(
          termsConditions: false,
          privacyPolicy: false,
          pushNotice: true,
          pushAd: false,
        );

        PointModel pointModel = PointModel(
          uid: authUid,
          point: 0,
        );

        StatisticModel statisticModel = StatisticModel(
          uid: authUid,
          name: appleGivenName,
          totalChallenge: 0,
          totalWin: 0,
          totalLose: 0,
          monthChallenge: 0,
          monthWin: 0,
          monthLose: 0,
          totalMyPost: 0,
          totalMyLikePost: 0,
          monthMyPost: 0,
          totalCheckup: 0,
          monthCheckup: 0,
          todayCheckup: 10,
          monthPointOutTicket: 1,
          totalMedal: 0,
        );

        batch.set(userRef, userModel.toJson());
        batch.set(userRef.collection('userState').doc(authUid),
            userStateModel.toJson());
        batch.set(userRef.collection('agreement').doc(authUid),
            agreementModel.toJson());
        batch.set(FirebaseFirestore.instance.collection('point').doc(authUid),
            pointModel.toJson());
        batch.set(
            FirebaseFirestore.instance.collection('statistic').doc(authUid),
            statisticModel.toJson());

        await batch.commit();
        await callUpdateUserStateRole(authUid);

        Get.off(() => StartGuide());
      }
    } catch (e) {
      print(e);
      setState(() {
        isLoading = false;
      });
      ErrorGetxToast.show(
        context,
        '네트워크 확인 후 다시 시도해주세요',
        '오류3 $e',
      );
    }
  }

  Future<void> callUpdateUserStateRole(String userId) async {
    await FirebaseFunctions.instanceFor(region: 'asia-northeast3')
        .httpsCallable('updateUserStateRole')
        .call(<String, dynamic>{
      'userId': userId,
      'secretKey': dotenv.env['CLOUD_FUNCTIONS_SECRET_KEY'] ?? '',
    });
  }

  Future<void> remoteConfigLogin() async {
    final FirebaseRemoteConfig remoteConfig = FirebaseRemoteConfig.instance;
    try {
      await remoteConfig.setConfigSettings(
        RemoteConfigSettings(
          fetchTimeout: Duration(seconds: 10),
          minimumFetchInterval: Duration(minutes: 1),
        ),
      );
      await remoteConfig.fetchAndActivate();
      isAppleLogin = remoteConfig.getBool('isAppleLogin');
      isKakaoLogin = remoteConfig.getBool('isKakaoLogin');
      return;
    } catch (exception) {
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => !isLoading,
      child: Stack(
        children: [
          Scaffold(
            backgroundColor: Colors.white,
            body: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                SizedBox(height: 100),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedOpacity(
                        duration: Duration(seconds: 1),
                        opacity: imageOpacity,
                        child: Image.asset(
                          'asset/img/wanna_do_logo_white.png',
                          width: 150,
                          height: 150,
                        ),
                      ),
                      SizedBox(height: 50),
                      AnimatedOpacity(
                        duration: Duration(seconds: 1),
                        opacity: text1Opacity,
                        child: Text(
                          '무엇이든 해낼 수 있도록 도와줄게',
                          style: font20w400.copyWith(
                            fontFamily: 'NanumSquareAc',
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                      AnimatedOpacity(
                        duration: Duration(seconds: 1),
                        opacity: text2Opacity,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '나를 위한 챌린지 ',
                              style: font25w800,
                            ),
                            Text(
                              'Wanna Do',
                              style: fontAppLogo.copyWith(
                                color: mainColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                if (Platform.isAndroid)
                  Padding(
                    padding: const EdgeInsets.only(
                        left: 16.0, right: 16.0, bottom: 20.0),
                    child: GestureDetector(
                      onTap: () async {
                        await kakaoInstallCheck();
                      },
                      child: AnimatedOpacity(
                        duration: Duration(seconds: 1),
                        opacity: imageOpacity,
                        child:
                            Image.asset('asset/img/kakao_login_large_wide.png'),
                      ),
                    ),
                  ),
                if (Platform.isIOS)
                  Padding(
                    padding: const EdgeInsets.only(
                        left: 16.0, right: 16.0, bottom: 20.0),
                    child: Column(
                      children: [
                        if (isAppleLogin)
                          GestureDetector(
                            onTap: () async {
                              Get.dialog(
                                DialogOneButton(
                                  title: 'Wanna Do 필수 동의',
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      SizedBox(height: 10),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8.0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              width: MediaQuery.of(context)
                                                  .size
                                                  .width,
                                              decoration: BoxDecoration(
                                                color:
                                                    greyColor.withOpacity(0.2),
                                                borderRadius:
                                                    BorderRadius.circular(16),
                                              ),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(16.0),
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: List.generate(
                                                    2,
                                                    (index) {
                                                      return Column(
                                                        children: [
                                                          GestureDetector(
                                                            onTap: () {
                                                              Get.to(() =>
                                                                  AgreementHome());
                                                            },
                                                            child: Row(
                                                              children: [
                                                                Expanded(
                                                                  child:
                                                                      Container(
                                                                    color: greyColor
                                                                        .withOpacity(
                                                                            0.0),
                                                                    child:
                                                                        Padding(
                                                                      padding: const EdgeInsets
                                                                          .symmetric(
                                                                          vertical:
                                                                              8.0),
                                                                      child:
                                                                          Row(
                                                                        children: [
                                                                          Image
                                                                              .asset(
                                                                            'asset/img/check_mini2.png',
                                                                            color:
                                                                                mainColor,
                                                                            height:
                                                                                17,
                                                                          ),
                                                                          SizedBox(
                                                                              width: 10),
                                                                          Text(
                                                                            checkTexts[index],
                                                                            style:
                                                                                font15w700,
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                                Icon(
                                                                  Icons
                                                                      .chevron_right_rounded,
                                                                  size: 30,
                                                                  color: Colors
                                                                      .black
                                                                      .withOpacity(
                                                                          0.4),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ],
                                                      );
                                                    },
                                                  ),
                                                ),
                                              ),
                                            ),
                                            SizedBox(height: 10),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  buttonText: '동의하고 시작하기',
                                  onButtonPressed: () async {
                                    Get.back();
                                    await appleLogin();
                                  },
                                ),
                              );
                            },
                            child: AnimatedOpacity(
                              duration: Duration(seconds: 1),
                              opacity: imageOpacity,
                              child: Image.asset(
                                'asset/img/apple_login.png',
                              ),
                            ),
                          ),
                        SizedBox(height: 10),
                        if (isKakaoLogin)
                          GestureDetector(
                            onTap: () async {
                              await kakaoInstallCheck();
                            },
                            child: AnimatedOpacity(
                              duration: Duration(seconds: 1),
                              opacity: imageOpacity,
                              child: Image.asset(
                                  'asset/img/kakao_login_large_wide.png'),
                            ),
                          ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          if (isLoading) ShortLoadingFirst(opacity: 0.1),
        ],
      ),
    );
  }
}
