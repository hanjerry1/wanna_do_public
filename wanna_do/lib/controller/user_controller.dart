import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';
import 'package:wanna_do/model/user/user_state_model.dart';

class UserController extends GetxController {
  var isLoading = true.obs;
  var role = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadUserRole();
    launchUserInfo();
  }

  void loadUserRole() async {
    try {
      isLoading(true);
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        return;
      } else {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('user')
            .doc(user.uid)
            .collection('userState')
            .doc(user.uid)
            .get();

        if (userDoc.exists && userDoc.data() != null) {
          UserStateModel data = UserStateModel.fromJson(
            userDoc.data() as Map<String, dynamic>,
          );

          role(data.role);
        } else {
          return;
        }
      }
    } catch (e) {
      isLoading(false);
    } finally {
      isLoading(false);
    }
  }

  void launchUserInfo() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        return;
      } else {
        String deviceId = '';
        final fcmToken = await FirebaseMessaging.instance.getToken();

        if (Platform.isAndroid) {
          AndroidDeviceInfo androidInfo = await DeviceInfoPlugin().androidInfo;
          deviceId = androidInfo.id;
        } else if (Platform.isIOS) {
          IosDeviceInfo iosInfo = await DeviceInfoPlugin().iosInfo;
          deviceId = iosInfo.identifierForVendor!;
        }

        await FirebaseFirestore.instance
            .collection('user')
            .doc(user.uid)
            .update({
          'deviceId': deviceId,
          'fcmToken': fcmToken,
          'loginAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {}
  }
}
