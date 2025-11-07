import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_compress/video_compress.dart';
import 'package:video_player/video_player.dart';
import 'package:wanna_do/component/main_page.dart';
import 'package:wanna_do/const/colors.dart';
import 'package:wanna_do/container/challenge_detail/challenge_detail_certify_Image.dart';
import 'package:wanna_do/model/user/user_model.dart';
import 'package:wanna_do/style/appbar_style.dart';
import 'package:wanna_do/style/dialog_style.dart';
import 'package:wanna_do/style/loading_style.dart';
import 'package:wanna_do/style/text_style.dart';
import 'package:wanna_do/style/toast_style.dart';
import 'package:wanna_do/util/util_tool.dart';

class ChallengeDetailCertify extends StatefulWidget {
  final String goal;
  final String category;
  final DateTime deadline;
  final String status;
  final int betPoint;
  final String docId;
  final DateTime? certifyAt;
  final List<String>? certifyUrl;
  final DateTime? checkAt;
  final String? checker;
  final String? complainReason;
  final String? failReason;

  const ChallengeDetailCertify({
    super.key,
    required this.goal,
    required this.category,
    required this.deadline,
    required this.status,
    required this.betPoint,
    required this.docId,
    this.certifyAt,
    this.certifyUrl,
    this.checkAt,
    this.checker,
    this.complainReason,
    this.failReason,
  });

  @override
  State<ChallengeDetailCertify> createState() => _ChallengeDetailCertifyState();
}

class _ChallengeDetailCertifyState extends State<ChallengeDetailCertify> {
  final String authUid = FirebaseAuth.instance.currentUser!.uid;
  VideoPlayerController? videoPlayerController;
  final ImagePicker picker = ImagePicker();
  bool isVisible = true;
  bool isUpload = false;
  bool isLink = false;

  Future<void> requestCameraMicrophonePermissions(
    BuildContext context,
    bool isPicture,
  ) async {
    final resp = await [Permission.camera, Permission.microphone].request();

    final cameraPermission = resp[Permission.camera];
    final microphonePermission = resp[Permission.microphone];

    if (isPicture) {
      if (cameraPermission != PermissionStatus.granted ||
          microphonePermission != PermissionStatus.granted) {
        Get.dialog(
          DialogOneButton(
            title: '필수 권한 안내',
            content: Text(
              '앱 설정에서 카메라 및 마이크 권한을 모두 허용해주세요.',
              style: font15w700.copyWith(
                height: 1.5,
              ),
            ),
            buttonText: '앱 설정',
            onButtonPressed: () async {
              await openAppSettings();
              Get.back();
            },
          ),
        );
      } else {
        Get.to(
          () => ChallengeDetailCertifyImage(
            goal: widget.goal,
            category: widget.category,
            deadline: widget.deadline,
            status: widget.status,
            betPoint: widget.betPoint,
            docId: widget.docId,
            certifyAt: widget.certifyAt,
            certifyUrl: widget.certifyUrl,
            checkAt: widget.checkAt,
            checker: widget.checker,
            complainReason: widget.complainReason,
            failReason: widget.failReason,
            isVisible: isVisible,
          ),
        );
      }
    } else if (!isPicture) {
      if (cameraPermission != PermissionStatus.granted) {
        Get.dialog(
          DialogOneButton(
            title: '필수 권한 안내',
            content: Text(
              '앱 설정에서 카메라 및 마이크 권한을 모두 허용해주세요.',
              style: font15w700.copyWith(
                height: 1.5,
              ),
            ),
            buttonText: '앱 설정',
            onButtonPressed: () async {
              await openAppSettings();
              Get.back();
            },
          ),
        );
      }
    }
  }

  Future<void> uploadVideo() async {
    try {
      await requestCameraMicrophonePermissions(context, false);

      final XFile? selectedVideo = await picker.pickVideo(
        source: ImageSource.camera,
        maxDuration: Duration(seconds: 20),
      );

      setState(() {
        isUpload = true;
      });

      String deviceId = '';
      if (Platform.isAndroid) {
        AndroidDeviceInfo androidInfo = await DeviceInfoPlugin().androidInfo;
        deviceId = androidInfo.id;
      } else if (Platform.isIOS) {
        IosDeviceInfo iosInfo = await DeviceInfoPlugin().iosInfo;
        deviceId = iosInfo.identifierForVendor!;
      }

      DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
          .collection('user')
          .doc(authUid)
          .get();

      UserModel data = UserModel.fromJson(
        documentSnapshot.data() as Map<String, dynamic>,
      );

      if (data.deviceId != deviceId) {
        Get.offAll(() => MainPage());
        ErrorGetxToast.show(context, '앱을 재시작 해주세요', '앱에서 하나의 기기만 사용해주세요');
        return;
      }

      await getInternetDateTimeDio().then((internetTime) async {
        if (internetTime.isAfter(widget.deadline)) {
          Get.offAll(() => MainPage());
          ErrorGetxToast.show(context, '인증 마감시간 초과', '이미 마감시간이 지났어요');
        } else {
          if (selectedVideo != null) {
            final MediaInfo? compressedVideo =
                await VideoCompress.compressVideo(
              selectedVideo.path,
              quality: VideoQuality.DefaultQuality,
              deleteOrigin: false,
            );

            final File thumbnailFile = await VideoCompress.getFileThumbnail(
              selectedVideo.path,
              quality: 50,
              position: -1,
            );

            var connectivityResult = await (Connectivity().checkConnectivity());
            if (connectivityResult == ConnectivityResult.none) {
              setState(() {
                isUpload = false;
              });
              ErrorGetxToast.show(
                  context, '네트워크를 확인해주세요', '오류가 계속되면 MY탭에서 문의해주세요');
              return;
            }

            if (compressedVideo != null) {
              File videoFile = File(compressedVideo.path!);
              File thumbNailFile = File(thumbnailFile.path);
              String videoPath =
                  'challenge/$authUid/${widget.docId}/${DateTime.now()}.mp4';
              String thumbNailPath =
                  'challenge/$authUid/${widget.docId}/${DateTime.now()}.jpg';

              Reference videoStorageReference =
                  FirebaseStorage.instance.ref().child(videoPath);
              UploadTask videoUploadTask =
                  videoStorageReference.putFile(videoFile);

              Reference thumbStorageReference =
                  FirebaseStorage.instance.ref().child(thumbNailPath);
              UploadTask thumbUploadTask =
                  thumbStorageReference.putFile(thumbNailFile);

              await Future.wait([
                videoUploadTask.whenComplete(() => null),
                thumbUploadTask.whenComplete(() => null),
              ]);

              String videoUrl = await videoStorageReference.getDownloadURL();
              String thumbNailUrl =
                  await thumbStorageReference.getDownloadURL();

              await FirebaseFirestore.instance
                  .runTransaction((transaction) async {
                DocumentReference challengeRef = FirebaseFirestore.instance
                    .collection('challenge')
                    .doc(authUid)
                    .collection('challenge')
                    .doc(widget.docId);

                var challengeDoc = await transaction.get(challengeRef);

                if (challengeDoc['status'] != 'apply') {
                  Get.offAll(() => MainPage());
                  ErrorGetxToast.show(context, '챌린지 인증 실패', '이미 인증된 챌린지에요');
                  return;
                }

                Map<String, dynamic> updateData = {
                  'certifyAt': Timestamp.fromDate(internetTime),
                  'certifyUrl': FieldValue.arrayUnion([videoUrl]),
                  'thumbNailUrl': thumbNailUrl,
                  'isVideo': true,
                  'isVisible': isVisible,
                  'status': 'certify',
                };

                transaction.update(challengeRef, updateData);

                var dataForCheckup = Map<String, dynamic>.from(
                    challengeDoc.data() as Map<String, dynamic>)
                  ..addAll(updateData);
                var checkupDocRef =
                    FirebaseFirestore.instance.collection('checkup').doc();

                transaction.set(checkupDocRef, dataForCheckup);
              }).then((result) {
                Get.offAll(() => MainPage());
                InfoGetxToast.show(
                    context, '챌린지 인증 성공', '열심히 노력하는 당신은 누구보다 빛날거에요!');
              }).catchError((e) {
                setState(() {
                  isUpload = false;
                });
                ErrorGetxToast.show(
                    context, '네트워크를 확인해주세요', '오류가 계속되면 MY탭에서 문의해주세요');
              });
            }
            setState(() {
              isUpload = false;
            });
            return;
          }
          setState(() {
            isUpload = false;
          });
          return;
        }
      });
    } catch (e) {
      setState(() {
        isUpload = false;
      });
    }
  }

  Future<DateTime> getInternetDateTimeDio() async {
    var dio = Dio();
    var url = 'https://worldtimeapi.org/api/timezone/Asia/Seoul';

    try {
      var response = await dio.get(url);
      String dateTime = response.data['datetime'];
      DateTime now = DateTime.parse(dateTime);
      return now.toLocal();
    } catch (e) {
      return DateTime.now();
    }
  }

  @override
  Widget build(BuildContext context) {
    isLink = IsTextLink.containLink(widget.goal);
    return WillPopScope(
      onWillPop: () async => !isUpload,
      child: Stack(
        children: [
          Scaffold(
            backgroundColor: Colors.white,
            appBar: SubAppBar(),
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    children: [
                      Column(
                        children: [
                          Divider(
                            thickness: 0.3,
                          ),
                          Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        widget.category,
                                        style: font15w700,
                                      ),
                                      SizedBox(height: 7),
                                      Text(
                                        DateFormatUtilsThird.formatDay(
                                            widget.deadline),
                                        style: font13w400,
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  '${NumberFormat('#,###').format(
                                    widget.betPoint,
                                  )}원',
                                  style: font15w700.copyWith(
                                    color: mainColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Divider(
                            thickness: 0.3,
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      Row(
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Image.asset(
                                CategoryIconAssetUtils.getIcon(widget.category),
                                fit: BoxFit.cover,
                              ),
                            ),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: CategoryBackgroundColorUtils.getColor(
                                  widget.category),
                            ),
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: Linkify(
                              linkStyle: font15w700.copyWith(
                                color: mainColor,
                                height: 1.5,
                              ),
                              onOpen: (link) async {
                                final Uri url = Uri.parse(link.url);
                                if (await canLaunchUrl(url)) {
                                  await launchUrl(url);
                                } else {
                                  throw 'Could not launch $url';
                                }
                              },
                              text: widget.goal,
                              style: font15w700.copyWith(height: 1.5),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 25),
                Container(
                  width: MediaQuery.of(context).size.width,
                  height: 10,
                  color: greyColor.withOpacity(0.3),
                ),
                SizedBox(height: 25),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                '인증방법 선택',
                                style: font23w800,
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  isVisible = !isVisible;
                                });
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    child: Image.asset(
                                      'asset/img/check_mini2.png',
                                      color:
                                          isVisible ? orangeColor : greyColor,
                                      height: 18,
                                    ),
                                  ),
                                  SizedBox(width: 5),
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 4.0),
                                    child: Text(
                                      '체크업 등록',
                                      style: font18w700.copyWith(
                                        color:
                                            isVisible ? orangeColor : greyColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 30),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          GestureDetector(
                            onTap: () async {
                              await requestCameraMicrophonePermissions(
                                  context, true);
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: subColorLight,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16.0,
                                  vertical: 24.0,
                                ),
                                child: Row(
                                  children: [
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '사진 인증',
                                          style: font20w800.copyWith(
                                            color: subColorDark,
                                          ),
                                        ),
                                        SizedBox(height: 7),
                                        Text(
                                          '30장 이내 사진으로\n인증해주세요',
                                          style: font13w700.copyWith(
                                            color: charcoalColor,
                                            height: 1.5,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(width: 7),
                                    Icon(
                                      Icons.chevron_right_rounded,
                                      size: 30,
                                      color: Colors.black.withOpacity(0.3),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 10),
                          GestureDetector(
                            onTap: () async {
                              await uploadVideo();
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: mainColorLight,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16.0,
                                  vertical: 24.0,
                                ),
                                child: Row(
                                  children: [
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '영상 인증',
                                          style: font20w800.copyWith(
                                            color: mainColor,
                                          ),
                                        ),
                                        SizedBox(height: 7),
                                        Text(
                                          '20초 이내 영상으로\n인증해주세요*',
                                          style: font13w700.copyWith(
                                            color: charcoalColor,
                                            height: 1.5,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(width: 7),
                                    Icon(
                                      Icons.chevron_right_rounded,
                                      size: 30,
                                      color: Colors.black.withOpacity(0.3),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      if (isLink)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Text(
                            '+ SNS 링크 인증인 경우, 아무 사진이나 1장만 올려주세요',
                            style: font13w400.copyWith(
                              color: charcoalColor,
                            ),
                          ),
                        ),
                      if (!isLink)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Text(
                            '*소리는 들리지 않음',
                            style: font13w400.copyWith(
                              color: Colors.black.withOpacity(0.3),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Image.asset(
                            'asset/img/guide.png',
                            height: 20,
                            color: Colors.black.withOpacity(0.7),
                          ),
                          SizedBox(width: 10),
                          Text(
                            '체크업 등록이란?',
                            style: font15w700.copyWith(
                              color: Colors.black.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      Text(
                        '체크업에 올리면 다른 사용자가 내 챌린지를 검사하여 빠르면 5분내로 판정 받을 수 있어요.\n'
                        '공개하기 어려운 챌린지라면 위의 체크업 등록 표시를 해제 해주세요.',
                        style: font15w400.copyWith(
                          height: 1.5,
                          color: Colors.black.withOpacity(0.5),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
              ],
            ),
          ),
          if (isUpload)
            LongLoadingFirst(
              title: '챌린지를 인증할 \n'
                  '영상을 업로드하고 있어요',
              subTitle: '오래 걸리지 않으니 조금만 기다려주세요',
            ),
        ],
      ),
    );
  }
}
