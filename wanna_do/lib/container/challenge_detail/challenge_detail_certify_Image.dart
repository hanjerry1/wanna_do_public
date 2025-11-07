import 'dart:async';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lottie/lottie.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:wanna_do/component/main_page.dart';
import 'package:wanna_do/const/colors.dart';
import 'package:wanna_do/model/user/user_model.dart';
import 'package:wanna_do/style/appbar_style.dart';
import 'package:wanna_do/style/loading_style.dart';
import 'package:wanna_do/style/text_style.dart';
import 'package:wanna_do/style/toast_style.dart';
import 'package:wanna_do/util/util_tool.dart';
import 'package:image/image.dart' as img;

class ChallengeDetailCertifyImage extends StatefulWidget {
  final String goal;
  final String category;
  final String status;
  final String docId;
  final String? checker;
  final String? complainReason;
  final String? failReason;
  final int betPoint;
  final bool isVisible;
  final DateTime deadline;
  final DateTime? certifyAt;
  final DateTime? checkAt;
  final List<String>? certifyUrl;

  const ChallengeDetailCertifyImage({
    super.key,
    required this.goal,
    required this.category,
    required this.deadline,
    required this.status,
    required this.betPoint,
    required this.docId,
    required this.isVisible,
    this.certifyAt,
    this.certifyUrl,
    this.checkAt,
    this.checker,
    this.complainReason,
    this.failReason,
  });

  @override
  State<ChallengeDetailCertifyImage> createState() =>
      _ChallengeDetailCertifyImageState();
}

class _ChallengeDetailCertifyImageState
    extends State<ChallengeDetailCertifyImage> {
  final String authUid = FirebaseAuth.instance.currentUser!.uid;
  StreamSubscription<AccelerometerEvent>? accelerometerSubscription;
  List<XFile> imageFiles = [];
  final ImagePicker picker = ImagePicker();
  final ScrollController scrollController = ScrollController();
  late CameraController cameraController;
  late Future<void> initCameraSettingFuture;
  FlashMode flashMode = FlashMode.off;
  int cameraDirection = 0;
  bool isLoading = false;
  bool isUpload = false;
  double currentZoom = 1.0;
  double minAvailableZoom = 1.0;
  double maxAvailableZoom = 1.0;
  double rotationAngle = 0;

  // initCameraSetting을 바로 Futurebuilder에 줘버리면 카메라가 안켜지는 오류가 생김.
  // 그 이유에 대한 챗gpt 답변
  // 직접 FutureBuilder의 future에 initCameraSetting을 넣지 않고 변수를 통해 거치는 이유는
  // 상태 관리 및 위젯 생명주기와 관련이 있습니다. FutureBuilder의 future에 직접 메서드를 넣으면,
  // 위젯이 다시 빌드될 때마다 initCameraSetting이 호출될 수 있습니다. 이는 불필요한 자원 사용을 초래하고
  // 예기치 않은 버그를 발생시킬 수 있습니다.
  // 하지만 initState에서 Future를 초기화하고 이를 FutureBuilder에 전달하면,
  // 위젯이 다시 빌드되더라도 Future는 처음 상태 그대로 유지됩니다.
  // 따라서 카메라 초기화는 한 번만 수행되며, UI는 Future의 상태에 따라 적절히 업데이트됩니다.

  @override
  void initState() {
    super.initState();
    initCameraSettingFuture = initCameraSetting();
    accelerometerSubscription =
        accelerometerEvents.listen((AccelerometerEvent event) {
      if (!mounted) return;
      double newRotationAngle;

      if (cameraDirection == 0) {
        if (event.x.abs() > event.y.abs()) {
          if (event.x > 0) {
            newRotationAngle = -90;
          } else {
            newRotationAngle = 90;
          }
        } else {
          newRotationAngle = 0;
        }
      } else {
        if (event.x.abs() > event.y.abs()) {
          if (event.x > 0) {
            newRotationAngle = 90;
          } else {
            newRotationAngle = -90;
          }
        } else {
          newRotationAngle = 0;
        }
      }

      if (rotationAngle != newRotationAngle) {
        setState(() {
          rotationAngle = newRotationAngle;
        });
      }
    });
  }

  @override
  void dispose() {
    accelerometerSubscription?.cancel();
    scrollController.dispose();
    cameraController.dispose();
    super.dispose();
  }

  Future<void> initCameraSetting() async {
    List<CameraDescription> cameras = [];

    try {
      cameras = await availableCameras();
    } on CameraException catch (e) {
      ErrorGetxToast.show(context, '카메라가 인식되지 않아요', '내장 카메라가 고장이 났을 가능성이 높아요');
      Get.back();
      return;
    }
    cameraController = CameraController(
      cameras[cameraDirection],
      ResolutionPreset.veryHigh,
      enableAudio: false,
    );

    cameraController.initialize().then((_) async {
      if (!mounted) {
        return;
      }
      cameraController.setFlashMode(flashMode);
      minAvailableZoom = await cameraController.getMinZoomLevel();
      maxAvailableZoom = await cameraController.getMaxZoomLevel();
      setState(() {});
    });
  }

  Future<void> uploadImage() async {
    try {
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
          var compressedImagesFutures = imageFiles.map((imageFile) async {
            return FlutterImageCompress.compressWithFile(
              imageFile.path,
              quality: 80,
            );
          }).toList();

          var compressedImages = await Future.wait(compressedImagesFutures);

          var connectivityResult = await (Connectivity().checkConnectivity());
          if (connectivityResult == ConnectivityResult.none) {
            setState(() {
              isUpload = false;
            });
            ErrorGetxToast.show(
                context, '네트워크를 확인해주세요', '오류가 계속되면 MY탭에서 문의해주세요');
            return;
          }

          var uploadFutures = compressedImages.map((compressedImage) async {
            if (compressedImage != null) {
              String imagePath =
                  'challenge/$authUid/${widget.docId}/${DateTime.now()}.jpg';
              Reference storageReference =
                  FirebaseStorage.instance.ref().child(imagePath);
              UploadTask uploadTask = storageReference.putData(compressedImage);
              await uploadTask.whenComplete(() => null);
              return await storageReference.getDownloadURL();
            }
            return null;
          }).toList();

          var imageUrls = await Future.wait(uploadFutures);
          imageUrls.removeWhere((url) => url == null);

          await FirebaseFirestore.instance.runTransaction((transaction) async {
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
              'certifyUrl': FieldValue.arrayUnion(imageUrls),
              'thumbNailUrl': imageUrls.first,
              'isVideo': false,
              'isVisible': widget.isVisible,
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
      });
    } catch (e) {
      setState(() {
        isUpload = false;
      });
      ErrorGetxToast.show(context, '네트워크를 확인해주세요', '오류가 계속되면 MY탭에서 문의해주세요');
    }
  }

  Future<void> getImageGallery() async {
    if (imageFiles.length >= 30) {
      ErrorGetxToast.show(context, '사진은 30장까지 가능해요', '분량이 많다면 영상 인증을 이용해보세요');
      return;
    }
    final List<XFile>? images = await picker.pickMultiImage();
    if (images != null) {
      if (imageFiles.length + images.length > 30) {
        ErrorGetxToast.show(context, '사진은 30장까지 가능해요', '분량이 많다면 영상 인증을 이용해보세요');
        return;
      }
      setState(() {
        imageFiles.addAll(images);
      });

      await scrollController.animateTo(
        scrollController.position.maxScrollExtent + 1000,
        duration: Duration(milliseconds: 100),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> cameraShot() async {
    try {
      if (imageFiles.length >= 30) {
        ErrorGetxToast.show(context, '사진은 30장까지 가능해요', '분량이 많다면 영상 인증을 이용해보세요');
        return;
      }
      setState(() {
        isLoading = true;
      });
      XFile file = await cameraController.takePicture();
      File rotatedFile = await rotateImage(file.path, rotationAngle);
      XFile rotatedXFile = XFile(rotatedFile.path);

      setState(() {
        imageFiles.add(rotatedXFile);
        isLoading = false;
      });

      await scrollController.animateTo(
        scrollController.position.maxScrollExtent + 1000,
        duration: Duration(milliseconds: 100),
        curve: Curves.easeOut,
      );
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ErrorGetxToast.show(context, '촬영을 다시 시도해주세요', '오류가 계속되면 MY탭에서 문의해주세요');
    }
  }

  Future<File> rotateImage(String path, double angle) async {
    File imageFile = File(path);
    img.Image? image = img.decodeImage(imageFile.readAsBytesSync());
    img.Image rotated = img.copyRotate(image!, angle: angle);

    await imageFile.writeAsBytes(img.encodeJpg(rotated));

    return imageFile;
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
    List<Widget> pickImages = imageFiles.asMap().entries.map(
      (entry) {
        int index = entry.key;
        XFile img = entry.value;
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Stack(
            children: [
              Image.file(
                File(img.path),
                width: 80,
                height: 80,
                fit: BoxFit.cover,
              ),
              Positioned(
                top: 5,
                right: 5,
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      imageFiles.removeAt(index);
                    });
                  },
                  child: Container(
                    height: 22,
                    width: 22,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: redColorLight.withOpacity(0.4),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.close,
                        size: 18,
                        color: redColor,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    ).toList();

    return WillPopScope(
      onWillPop: () async => !isUpload,
      child: Stack(
        children: [
          Scaffold(
            backgroundColor: Colors.white,
            appBar: SubAppBar(
              title: '${pickImages.length}/30',
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: GestureDetector(
                    onTap: () async {
                      pickImages.length == 0 ? null : await uploadImage();
                    },
                    child: Center(
                      child: Text(
                        '완료',
                        style: font18w800.copyWith(
                          color: pickImages.length == 0
                              ? Colors.black.withOpacity(0.5)
                              : mainColor,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            body: Stack(
              alignment: Alignment.center,
              children: [
                FutureBuilder(
                  future: initCameraSettingFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Container(
                            width: MediaQuery.of(context).size.width,
                            child: AspectRatio(
                              aspectRatio: 9 / 16,
                              child: GestureDetector(
                                onScaleUpdate:
                                    (ScaleUpdateDetails detail) async {
                                  double newZoom =
                                      currentZoom + (detail.scale - 1.0) * 0.05;

                                  currentZoom = newZoom.clamp(
                                      minAvailableZoom, maxAvailableZoom);

                                  await cameraController
                                      .setZoomLevel(currentZoom);
                                },
                                child: CameraPreview(cameraController),
                              ),
                            ),
                          ),
                        ],
                      );
                    } else {
                      return Container();
                    }
                  },
                ),
                Positioned(
                  bottom: 60,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        height: 100,
                        width: MediaQuery.of(context).size.width,
                        child: ScrollConfiguration(
                          behavior: NoGlowScrollBehavior(),
                          child: SingleChildScrollView(
                            controller: scrollController,
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: pickImages,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      Container(
                        width: MediaQuery.of(context).size.width,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: GestureDetector(
                            onTap: () async {
                              await getImageGallery();
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  flex: 1,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        width: 2,
                                        color: mainColor,
                                      ),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 4.0),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          SvgPicture.asset(
                                            'asset/svg/challenge_detail_gallery.svg',
                                            width: 30,
                                            height: 30,
                                            color: mainColor,
                                          ),
                                          SizedBox(width: 5),
                                          Text(
                                            '갤러리',
                                            style: font16w800.copyWith(
                                              color: mainColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: GestureDetector(
                                    onTap: () async {
                                      await cameraShot();
                                    },
                                    child: Container(
                                      height: 70,
                                      width: 70,
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.2),
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          width: 5,
                                          color: greyColor,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      GestureDetector(
                                        onTap: () async {
                                          setState(() {
                                            cameraDirection == 0
                                                ? cameraDirection = 1
                                                : cameraDirection = 0;
                                          });
                                          initCameraSettingFuture =
                                              initCameraSetting();
                                        },
                                        child: Icon(
                                          Icons.screen_rotation_rounded,
                                          size: 35,
                                          color: greyColor,
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () async {
                                          setState(() {
                                            if (flashMode != FlashMode.off) {
                                              flashMode = FlashMode.off;
                                            } else if (flashMode ==
                                                FlashMode.off) {
                                              flashMode = FlashMode.torch;
                                            }
                                          });
                                          await cameraController
                                              .setFlashMode(flashMode);
                                        },
                                        child: Icon(
                                          Icons.flashlight_on_outlined,
                                          size: 40,
                                          color: flashMode == FlashMode.off
                                              ? greyColor
                                              : subColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (isLoading)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.1),
                child: Center(
                  child: Lottie.asset(
                    'asset/lottie/short_loading_first_animation.json',
                    height: 100,
                  ),
                ),
              ),
            ),
          if (isUpload)
            LongLoadingFirst(
              title: '챌린지를 인증할 \n'
                  '사진을 업로드하고 있어요',
              subTitle: '오래 걸리지 않으니 조금만 기다려주세요',
            ),
        ],
      ),
    );
  }
}
