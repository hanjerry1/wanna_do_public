import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:get/get.dart';
import 'package:wanna_do/component/main_page.dart';
import 'package:wanna_do/const/colors.dart';
import 'package:wanna_do/controller/page/main_page_controller.dart';
import 'package:wanna_do/model/point/point_log_model.dart';
import 'package:wanna_do/model/point/point_out_model.dart';
import 'package:wanna_do/model/user/user_model.dart';
import 'package:wanna_do/style/appbar_style.dart';
import 'package:wanna_do/style/button_style.dart';
import 'package:wanna_do/style/loading_style.dart';
import 'package:wanna_do/style/text_style.dart';
import 'package:wanna_do/style/toast_style.dart';

import '../../util/util_tool.dart';

class PointAccount extends StatefulWidget {
  final int outPoint;

  const PointAccount({
    super.key,
    required this.outPoint,
  });

  @override
  State<PointAccount> createState() => _PointAccountState();
}

class _PointAccountState extends State<PointAccount> {
  final String authUid = FirebaseAuth.instance.currentUser!.uid;
  final TextEditingController textEditingController1 = TextEditingController();
  final TextEditingController textEditingController2 = TextEditingController();
  final TextEditingController textEditingController3 = TextEditingController();
  final GlobalKey<FormState> formkey = GlobalKey();
  bool isLoading = false;

  Future<void> sendPointOut() async {
    try {
      var connectivityResult = await (Connectivity().checkConnectivity());
      if (connectivityResult == ConnectivityResult.none) {
        ErrorGetxToast.show(context, '네트워크를 확인해주세요', '오류가 계속되면 MY탭에서 문의해주세요');
        return;
      }

      setState(() {
        isLoading = true;
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
        Get.offAll(() => MainPage(), binding: BindingsBuilder(() {
          Get.put(MainPageController(initialTabIndex: 3));
        }));
        ErrorGetxToast.show(
            context, '이번달 출금 티켓을 이미 사용했어요', '다음달이 곧 다가오니 조금만 기다려주세요!');
        return;
      }

      PointLogModel pointLogModel = PointLogModel(
        uid: authUid,
        inout: 'out',
        pointFrom: 'out',
        point: widget.outPoint,
      );

      PointOutModel pointOutModel = PointOutModel(
        uid: authUid,
        name: textEditingController1.text,
        account: textEditingController3.text,
        bank: textEditingController2.text,
        point: widget.outPoint,
        isFinish: false,
      );

      DocumentReference pointLogRef = FirebaseFirestore.instance
          .collection('point')
          .doc(authUid)
          .collection('pointLog')
          .doc();

      DocumentReference pointRef =
          FirebaseFirestore.instance.collection('point').doc(authUid);

      DocumentReference statisticRef =
          FirebaseFirestore.instance.collection('statistic').doc(authUid);

      DocumentReference pointOutRef = FirebaseFirestore.instance
          .collection('service')
          .doc('pointOut')
          .collection('pointOut')
          .doc();

      await FirebaseFirestore.instance.runTransaction((transaction) async {
        transaction.set(pointLogRef, pointLogModel.toJson());
        transaction.update(pointRef, {
          'point': FieldValue.increment(-widget.outPoint),
        });
        transaction.update(statisticRef, {
          'monthPointOutTicket': FieldValue.increment(-1),
        });
        transaction.set(pointOutRef, pointOutModel.toJson());
      }).then((result) {
        Get.offAll(() => MainPage(), binding: BindingsBuilder(() {
          Get.put(MainPageController(initialTabIndex: 3));
        }));
        InfoGetxToast.show(context, '출금 요청 완료', '문제가 없다면 해당 계좌로 입금해드릴께요');
      }).catchError((e) {
        setState(() {
          isLoading = false;
        });
        ErrorGetxToast.show(context, '네트워크를 확인해주세요', '오류가 계속되면 MY탭에서 문의해주세요');
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ErrorGetxToast.show(context, '네트워크를 확인해주세요', '오류가 계속되면 MY탭에서 문의해주세요');
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: WillPopScope(
        onWillPop: () async => !isLoading,
        child: KeyboardVisibilityBuilder(builder: (context, isKeyboardVisible) {
          return Stack(
            children: [
              Scaffold(
                backgroundColor: Colors.white,
                resizeToAvoidBottomInset: false,
                appBar: SubAppBar(),
                body: Column(
                  children: [
                    Expanded(
                      child: ScrollConfiguration(
                        behavior: NoGlowScrollBehavior(),
                        child: SingleChildScrollView(
                          child: Stack(
                            children: [
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Form(
                                  key: formkey,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(height: 10),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 16.0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              width: 60,
                                              height: 60,
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(4.0),
                                                child: Image.asset(
                                                  'asset/img/atm-card.png',
                                                ),
                                              ),
                                            ),
                                            SizedBox(height: 20),
                                            Text(
                                              '어디로 출금할까요?',
                                              style: font23w800,
                                            ),
                                            SizedBox(height: 10),
                                            Text(
                                              '이름과 계좌정보를 정확히 적어주세요',
                                              style: font20w700,
                                            ),
                                            SizedBox(height: 20),
                                            Text(
                                              '출금까지 최대 7일이 소요되고, 정보가 올바르지 않을 경우 요청이 취소될 수 있어요',
                                              style: font15w700.copyWith(
                                                color: mainColor,
                                                height: 1.3,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(height: 20),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 16.0),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: TextFormField(
                                                controller:
                                                    textEditingController1,
                                                onChanged: (String? val) {
                                                  setState(() {});
                                                },
                                                validator: (String? val) {
                                                  if (val == null ||
                                                      val.isEmpty) {
                                                    return '';
                                                  }
                                                  return null;
                                                },
                                                decoration: InputDecoration(
                                                  border: InputBorder.none,
                                                  hintStyle:
                                                      font37w700.copyWith(
                                                          color: greyColor),
                                                  hintText: '예금주명',
                                                  counterText: '',
                                                ),
                                                style: font37w800,
                                                cursorColor: mainColor,
                                                cursorWidth: 4,
                                                maxLines: 1,
                                                maxLength: 10,
                                                keyboardType:
                                                    TextInputType.multiline,
                                              ),
                                            ),
                                            SizedBox(width: 15),
                                            Expanded(
                                              child: TextFormField(
                                                controller:
                                                    textEditingController2,
                                                onChanged: (String? val) {
                                                  setState(() {});
                                                },
                                                validator: (String? val) {
                                                  if (val == null ||
                                                      val.isEmpty) {
                                                    return '';
                                                  }
                                                  return null;
                                                },
                                                decoration: InputDecoration(
                                                  border: InputBorder.none,
                                                  hintStyle:
                                                      font37w700.copyWith(
                                                          color: greyColor),
                                                  hintText: '은행명',
                                                  counterText: '',
                                                ),
                                                style: font37w800,
                                                cursorColor: mainColor,
                                                cursorWidth: 4,
                                                maxLines: 1,
                                                maxLength: 10,
                                                keyboardType:
                                                    TextInputType.multiline,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(height: 10),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 16.0),
                                        child: TextFormField(
                                          controller: textEditingController3,
                                          onChanged: (String? val) {
                                            setState(() {});
                                          },
                                          validator: (String? val) {
                                            if (val == null || val.isEmpty) {
                                              return '';
                                            }
                                            return null;
                                          },
                                          decoration: InputDecoration(
                                            border: InputBorder.none,
                                            hintStyle: font37w700.copyWith(
                                                color: greyColor),
                                            hintText: '계좌번호',
                                            counterText: '',
                                          ),
                                          style: font37w800,
                                          cursorColor: mainColor,
                                          cursorWidth: 4,
                                          maxLines: 1,
                                          maxLength: 18,
                                          keyboardType: TextInputType.number,
                                          inputFormatters: [
                                            FilteringTextInputFormatter
                                                .digitsOnly,
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    if (textEditingController1.text.isNotEmpty &&
                        textEditingController2.text.isNotEmpty &&
                        textEditingController3.text.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 20.0),
                        child: BigButtonFirst(
                          buttonText: '출금 요청하기',
                          onPressed: () async {
                            if (formkey.currentState == null) {
                              return;
                            }
                            if (formkey.currentState!.validate()) {
                              formkey.currentState!.save();

                              await sendPointOut();
                            }
                          },
                        ),
                      ),
                  ],
                ),
              ),
              if (isLoading) ShortLoadingFirst(),
            ],
          );
        }),
      ),
    );
  }
}
