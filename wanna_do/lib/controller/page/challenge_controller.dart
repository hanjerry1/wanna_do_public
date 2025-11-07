import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class ChallengeController extends GetxController {
  final String authUid = FirebaseAuth.instance.currentUser!.uid;
  List<DocumentSnapshot> docTotalList = [];
  var docStreamMainHomeList = <DocumentSnapshot>[].obs;
  var docStreamMyChallengeList = <DocumentSnapshot>[].obs;
  var selectedButtonIndexMainHome = 0.obs;
  var selectedButtonIndexMyChallenge = 0.obs;
  var selectedDayStart = DateTime.now().obs;
  var endOfDayStart = DateTime.now().obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    isLoading.value = true;
    fetchData();
  }

  void changeSelectedIndexMainHome(int index) {
    selectedButtonIndexMainHome.value = index;
    updateDocStreamMainHomeList();
  }

  void changeSelectedIndexMyChallenge(int index) {
    selectedButtonIndexMyChallenge.value = index;
    updateDocStreamMyChallengeList();
  }

  void fetchData() {
    FirebaseFirestore.instance
        .collection('challenge')
        .doc(authUid)
        .collection('challenge')
        .orderBy('deadline', descending: false)
        .limit(1000)
        .snapshots()
        .listen((data) {
      isLoading.value = true;
      docTotalList = [];
      for (var doc in data.docs) {
        docTotalList.add(doc);
      }
      updateDocStreamMainHomeList();
      isLoading.value = false;
    });
  }

  void updateSelectedDates(DateTime selectedDay) {
    selectedDayStart.value = DateTime(
      selectedDay.year,
      selectedDay.month,
      selectedDay.day,
      0,
      1,
    );
    endOfDayStart.value = DateTime(
      selectedDay.year,
      selectedDay.month,
      selectedDay.day + 1,
      0,
      59,
    );
    updateDocStreamMyChallengeList();
  }

  void updateDocStreamMainHomeList() {
    List<DocumentSnapshot> docApplyList = [];
    List<DocumentSnapshot> docCertifyList = [];
    List<DocumentSnapshot> docComplainList = [];
    List<DocumentSnapshot> docWinList = [];
    List<DocumentSnapshot> docLoseList = [];
    List<DocumentSnapshot> docStreamList = [];

    docApplyList =
        docTotalList.where((doc) => doc.get('status') == 'apply').toList();
    docCertifyList =
        docTotalList.where((doc) => doc.get('status') == 'certify').toList();
    docComplainList =
        docTotalList.where((doc) => doc.get('status') == 'complain').toList();
    docWinList =
        docTotalList.where((doc) => doc.get('status') == 'win').toList();
    docLoseList =
        docTotalList.where((doc) => doc.get('status') == 'lose').toList();

    switch (selectedButtonIndexMainHome.value) {
      case 1:
        docStreamList = docApplyList;
        break;
      case 2:
        docStreamList = docCertifyList + docComplainList;
        break;
      case 3:
        docStreamList = docWinList;
        break;
      case 4:
        docStreamList = docLoseList;
        break;
      default:
        docStreamList = docApplyList +
            docComplainList +
            docCertifyList +
            docWinList +
            docLoseList;
    }
    docStreamMainHomeList.assignAll(docStreamList);
  }

  void updateDocStreamMyChallengeList() {
    List<DocumentSnapshot> docApplyList = [];
    List<DocumentSnapshot> docCertifyList = [];
    List<DocumentSnapshot> docComplainList = [];
    List<DocumentSnapshot> docWinList = [];
    List<DocumentSnapshot> docLoseList = [];
    List<DocumentSnapshot> docStreamList = [];

    docApplyList = docTotalList.where((doc) {
      bool isStatusApply = doc.get('status') == 'apply';
      DateTime deadlineDate = doc.get('deadline').toDate();
      bool isDeadlineInRange = deadlineDate.isAfter(selectedDayStart.value) &&
          deadlineDate.isBefore(endOfDayStart.value);

      return isStatusApply && isDeadlineInRange;
    }).toList();

    docCertifyList = docTotalList.where((doc) {
      bool isStatusApply = doc.get('status') == 'certify';
      DateTime deadlineDate = doc.get('deadline').toDate();
      bool isDeadlineInRange = deadlineDate.isAfter(selectedDayStart.value) &&
          deadlineDate.isBefore(endOfDayStart.value);

      return isStatusApply && isDeadlineInRange;
    }).toList();
    docComplainList = docTotalList.where((doc) {
      bool isStatusApply = doc.get('status') == 'complain';
      DateTime deadlineDate = doc.get('deadline').toDate();
      bool isDeadlineInRange = deadlineDate.isAfter(selectedDayStart.value) &&
          deadlineDate.isBefore(endOfDayStart.value);

      return isStatusApply && isDeadlineInRange;
    }).toList();
    docWinList = docTotalList.where((doc) {
      bool isStatusApply = doc.get('status') == 'win';
      DateTime deadlineDate = doc.get('deadline').toDate();
      bool isDeadlineInRange = deadlineDate.isAfter(selectedDayStart.value) &&
          deadlineDate.isBefore(endOfDayStart.value);

      return isStatusApply && isDeadlineInRange;
    }).toList();

    docLoseList = docTotalList.where((doc) {
      bool isStatusApply = doc.get('status') == 'lose';
      DateTime deadlineDate = doc.get('deadline').toDate();
      bool isDeadlineInRange = deadlineDate.isAfter(selectedDayStart.value) &&
          deadlineDate.isBefore(endOfDayStart.value);

      return isStatusApply && isDeadlineInRange;
    }).toList();

    switch (selectedButtonIndexMyChallenge.value) {
      case 1:
        docStreamList = docApplyList;
        break;
      case 2:
        docStreamList = docCertifyList + docComplainList;
        break;
      case 3:
        docStreamList = docWinList;
        break;
      case 4:
        docStreamList = docLoseList;
        break;
      default:
        docStreamList = docApplyList +
            docComplainList +
            docCertifyList +
            docWinList +
            docLoseList;
    }
    docStreamMyChallengeList.assignAll(docStreamList);
  }
}
