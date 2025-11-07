import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:wanna_do/component/main_page.dart';
import 'package:wanna_do/const/colors.dart';
import 'package:wanna_do/container/help/role_home.dart';
import 'package:wanna_do/controller/page/main_page_controller.dart';
import 'package:wanna_do/model/space/space_model.dart';
import 'package:wanna_do/model/user/user_model.dart';
import 'package:wanna_do/model/user/user_state_model.dart';
import 'package:wanna_do/style/appbar_style.dart';
import 'package:wanna_do/style/dialog_style.dart';
import 'package:wanna_do/style/loading_style.dart';
import 'package:wanna_do/style/text_style.dart';
import 'package:wanna_do/util/util_tool.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:wanna_do/style/toast_style.dart';

class SpaceWriting extends StatefulWidget {
  final DocumentSnapshot userStateDocument;
  final String category;

  SpaceWriting({
    super.key,
    required this.category,
    required this.userStateDocument,
  });

  @override
  State<SpaceWriting> createState() => _SpaceWritingState();
}

class _SpaceWritingState extends State<SpaceWriting> {
  final String authUid = FirebaseAuth.instance.currentUser!.uid;
  List<XFile> selectedImages = [];
  final ImagePicker picker = ImagePicker();
  final ScrollController scrollController = ScrollController();
  final TextEditingController titleController = TextEditingController();
  final TextEditingController contentController = TextEditingController();
  bool get isInputValid =>
      titleController.text.isNotEmpty && contentController.text.isNotEmpty;
  bool isUpload = false;
  bool isUnknown = true;

  Future<void> requestCameraPermissions(
    BuildContext context,
    bool isGallery,
  ) async {
    final resp = await [Permission.camera].request();

    final cameraPermission = resp[Permission.camera];

    if (isGallery) {
      if (cameraPermission != PermissionStatus.granted) {
        Get.dialog(
          DialogOneButton(
            title: '필수 권한 안내',
            content: Text(
              '앱 설정에서 카메라 권한을 허용해주세요.',
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
        await getImageGallery();
      }
    } else if (!isGallery) {
      if (cameraPermission != PermissionStatus.granted) {
        Get.dialog(
          DialogOneButton(
            title: '필수 권한 안내',
            content: Text(
              '앱 설정에서 카메라 권한을 허용해주세요.',
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
        await getImageCamera();
      }
    }
  }

  Future<void> getImageGallery() async {
    if (selectedImages.length >= 10) {
      ErrorGetxToast.show(
          context, '사진 업로드는 10개까지 가능해요', '사진 수를 조금만 줄이는 건 어때요?');
      return;
    }
    final List<XFile>? images = await picker.pickMultiImage();
    if (images != null) {
      if (selectedImages.length + images.length > 10) {
        ErrorGetxToast.show(
            context, '사진 업로드는 10개까지 가능해요', '사진 수를 조금만 줄이는 건 어때요?');
        return;
      }
      setState(() {
        selectedImages.addAll(images);
      });

      await scrollController.animateTo(
        scrollController.position.maxScrollExtent + 1000,
        duration: Duration(milliseconds: 100),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> getImageCamera() async {
    if (selectedImages.length >= 10) {
      ErrorGetxToast.show(
          context, '사진 업로드는 10개까지 가능해요', '사진 수를 조금만 줄이는 건 어때요?');
      return;
    }
    final XFile? image = await picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      setState(() {
        selectedImages.add(image);
      });

      await scrollController.animateTo(
        scrollController.position.maxScrollExtent + 1000,
        duration: Duration(milliseconds: 100),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> uploadPost() async {
    try {
      setState(() {
        isUpload = true;
      });
      WriteBatch batch = FirebaseFirestore.instance.batch();

      String docId = FirebaseFirestore.instance.collection('space').doc().id;

      var compressedImagesFutures = selectedImages.map((imageFile) async {
        return FlutterImageCompress.compressWithFile(
          imageFile.path,
          quality: 80,
        );
      }).toList();

      var compressedImages = await Future.wait(compressedImagesFutures);

      var uploadFutures = compressedImages.map((compressedImage) async {
        if (compressedImage != null) {
          String imagePath = 'space/$docId/${DateTime.now()}.jpg';
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

      var nonNullableImageUrls = imageUrls.whereType<String>().toList();

      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('user')
          .doc(authUid)
          .get();

      UserModel data = UserModel.fromJson(
        userDoc.data() as Map<String, dynamic>,
      );

      String gradeNickname(String grade) {
        switch (grade) {
          case '0':
            return data.nickname!;
          case '1':
            return '🥇 ${data.nickname!}';
          case '2':
            return '🥈 ${data.nickname!}';
          case '3':
            return '🥉 ${data.nickname!}';
          default:
            return data.nickname!;
        }
      }

      UserStateModel userStateData = UserStateModel.fromJson(
        widget.userStateDocument.data() as Map<String, dynamic>,
      );

      SpaceModel spaceModel = SpaceModel(
        docId: docId,
        uid: authUid,
        category: widget.category,
        nickname: gradeNickname(userStateData.grade),
        title: titleController.text,
        content: contentController.text,
        reportState: 'able',
        isUnknown: isUnknown,
        postUrl: nonNullableImageUrls,
        chatCount: 0,
        likeCount: 0,
      );

      DocumentReference spaceRef =
          FirebaseFirestore.instance.collection('space').doc(docId);
      DocumentReference statisticRef =
          FirebaseFirestore.instance.collection('statistic').doc(authUid);

      batch.set(spaceRef, spaceModel.toJson());
      batch.update(statisticRef, {
        'totalMyPost': FieldValue.increment(1),
        'monthMyPost': FieldValue.increment(1),
      });

      await batch.commit();

      Get.offAll(() => MainPage(), binding: BindingsBuilder(() {
        Get.put(MainPageController(initialTabIndex: 2));
      }));
      InfoGetxToast.show(context, '게시물 등록 완료', '스페이스에 글이 등록되었어요');
    } catch (e) {
      setState(() {
        isUpload = false;
      });
      ErrorGetxToast.show(context, '네트워크를 확인해주세요', '오류가 계속되면 MY탭에서 문의해주세요');
    }
  }

  @override
  void dispose() {
    scrollController.dispose();
    titleController.dispose();
    contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> writingImages = selectedImages.asMap().entries.map(
      (entry) {
        int index = entry.key;
        XFile img = entry.value;

        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Stack(
            children: [
              Image.file(
                File(img.path),
                width: 100,
                height: 100,
                fit: BoxFit.cover,
              ),
              Positioned(
                top: 5,
                right: 5,
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedImages.removeAt(index);
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
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: Stack(
          children: [
            Scaffold(
              backgroundColor: Colors.white,
              resizeToAvoidBottomInset: true,
              appBar: SubAppBar(
                title: widget.category == 'free' ? '자유' : '학습자료',
                actions: [
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 16.0),
                      child: GestureDetector(
                        onTap: !isInputValid
                            ? null
                            : () async {
                                FocusScope.of(context)
                                    .requestFocus(FocusNode());
                                await uploadPost();
                              },
                        child: Text(
                          '게시',
                          style: font18w800.copyWith(
                            color: isInputValid
                                ? mainColor
                                : Colors.black.withOpacity(0.5),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              body: ScrollConfiguration(
                behavior: NoGlowScrollBehavior(),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: '제목을 입력하세요',
                            hintStyle: font18w800,
                            counterText: '',
                            border: InputBorder.none,
                          ),
                          controller: titleController,
                          onChanged: (String? val) {
                            setState(() {});
                          },
                          cursorColor: mainColor,
                          style: font18w800,
                          maxLines: 1,
                          maxLength: 30,
                          keyboardType: TextInputType.multiline,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Divider(
                          thickness: 0.3,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: '내용을 입력하세요\n\n\n\n\n\n\n\n\n\n\n',
                            hintStyle: font15w400,
                            counterText: '',
                            border: InputBorder.none,
                          ),
                          controller: contentController,
                          onChanged: (String? val) {
                            setState(() {});
                          },
                          cursorColor: mainColor,
                          style: font15w400,
                          maxLines: null,
                          maxLength: 10000,
                          keyboardType: TextInputType.multiline,
                        ),
                      ),
                      if (selectedImages.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                '${selectedImages.length}/10',
                                style: font15w700.copyWith(
                                  color: mainColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        controller: scrollController,
                        child: Row(
                          children: writingImages,
                        ),
                      ),
                      SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    '커뮤니티 이용 규칙',
                                    style: font15w800.copyWith(
                                      color: Colors.black.withOpacity(0.5),
                                    ),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    Get.to(() => RoleHome());
                                  },
                                  child: Text(
                                    '자세히 보기',
                                    style: font15w700.copyWith(
                                      color: Colors.black.withOpacity(0.5),
                                    ),
                                  ),
                                ),
                                Icon(
                                  Icons.chevron_right_rounded,
                                  size: 20,
                                  color: Colors.black.withOpacity(0.5),
                                ),
                              ],
                            ),
                            SizedBox(height: 20),
                            Text(
                              '워너두는 건전한 커뮤니티를 만들기 위해 커뮤니티 이용 규정을 제정하여 운영하고 있습니다. '
                              '위반 시 게시물이 삭제되고 서비스 이용이 일정 기간 제한될 수 있습니다.\n'
                              '아래는 이 게시판에 해당하는 핵심 내용에 대한 요약 사항이며, '
                              '커뮤니티 활동전 이용 규칙 전문을 반드시 확인하시기 바랍니다.',
                              style: font13w700.copyWith(
                                color: Colors.black.withOpacity(0.5),
                                height: 1.5,
                              ),
                            ),
                            SizedBox(height: 20),
                            Text(
                              '(1) 도배 행위 금지',
                              style: font15w700.copyWith(
                                color: Colors.black.withOpacity(0.5),
                              ),
                            ),
                            SizedBox(height: 5),
                            Text(
                              '- 악의적인 목적으로 유사한 글을 반복해서 올리는 행위',
                              style: font15w400.copyWith(
                                color: Colors.black.withOpacity(0.5),
                              ),
                            ),
                            SizedBox(height: 10),
                            Text(
                              '(2) 홍보 및 판매 관련 행위 금지',
                              style: font15w700.copyWith(
                                color: Colors.black.withOpacity(0.5),
                              ),
                            ),
                            SizedBox(height: 5),
                            Text(
                              '- 영리 여부와 관계 없이 사업체, 기관, 단체, 개인에게 직간접적으로 영향을 줄 수 있는 모든 행위',
                              style: font15w400.copyWith(
                                color: Colors.black.withOpacity(0.5),
                              ),
                            ),
                            SizedBox(height: 10),
                            Text(
                              '(3) 범죄, 불법 행위 등 법령을 위반하는 행위 금지',
                              style: font15w700.copyWith(
                                color: Colors.black.withOpacity(0.5),
                              ),
                            ),
                            SizedBox(height: 5),
                            Text(
                              '- 불법 촬영물 유통을 포함한 모든 범죄 행위',
                              style: font15w400.copyWith(
                                color: Colors.black.withOpacity(0.5),
                              ),
                            ),
                            SizedBox(height: 10),
                            Text(
                              '(4) 타인의 권리를 침해하거나 불쾌감을 주는 행위 금지',
                              style: font15w700.copyWith(
                                color: Colors.black.withOpacity(0.5),
                              ),
                            ),
                            SizedBox(height: 5),
                            Text(
                              '- 욕설, 비하, 차별, 혐오, 자살, 폭력 관련 내용을 포함한 타인에게 피해를 주는 모든 행위',
                              style: font15w400.copyWith(
                                color: Colors.black.withOpacity(0.5),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              bottomNavigationBar: Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0 ,vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(bottom: 2.0),
                              child: GestureDetector(
                                onTap: () async {
                                  await requestCameraPermissions(context, true);
                                },
                                child: Icon(
                                  Icons.photo,
                                  size: 25,
                                  color: Colors.black.withOpacity(0.3),
                                ),
                              ),
                            ),
                            SizedBox(width: 15),
                            GestureDetector(
                              onTap: () async {
                                await requestCameraPermissions(context, false);
                              },
                              child: Icon(
                                Icons.camera_alt_rounded,
                                size: 25,
                                color: Colors.black.withOpacity(0.3),
                              ),
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            isUnknown = !isUnknown;
                          });
                        },
                        child: Row(
                          children: [
                            Image.asset(
                              'asset/img/check_mini2.png',
                              color: isUnknown ? mainColor : greyColor,
                              height: 15,
                            ),
                            SizedBox(width: 5),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 2.0),
                              child: Text(
                                '익명',
                                style: font15w700.copyWith(
                                  color: isUnknown ? Colors.black : greyColor,
                                ),
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
            if (isUpload)
              LongLoadingFirst(
                title: '워너두 스페이스에 \n'
                    '글을 업로드하고 있어요',
                subTitle: '오래 걸리지 않으니 조금만 기다려주세요',
              ),
          ],
        ),
      ),
    );
  }
}
