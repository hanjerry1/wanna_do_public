const functions = require("firebase-functions").region("asia-northeast3");
const admin = require("firebase-admin");
const Bootpay = require('@bootpay/backend-js').Bootpay;

const serviceAccount = require(
  "./wanna-do-64b08-firebase-adminsdk-gzyvh-23b760c904.json"
);

Bootpay.setConfiguration({
    application_id: '65899eb3d25985001b0cf912',
    private_key: 'Td79j6/UEVKomYPMsYM53BOamjY0LCRmp0rb92H7JoM='
});

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

exports.kakaoFirebaseLogin = functions.https.onRequest(
  async (request, response) => {
    const user = request.body;
    const uid = user.uid;
    const updateParams = {
    uid: user.uid,
    email: user.email,
    phoneNumber: user.phone,
    displayName: user.kakaoName,
    photoURL: user.photoUrl,
    };

    try {
      await admin.auth().updateUser(uid, updateParams);
    } catch (e) {
      updateParams.uid = uid;
      await admin.auth().createUser(updateParams);
    }

    const token = await admin.auth().createCustomToken(uid);
    response.send(token);
  }
);

// 비밀키(환경변수) 등록하는 이유
// 사용자가 회원가입하여 이 함수를 호출시, 오로지 정상적인 클라이언트에서 보낸 요청인지 키를 통해 확인하기 위함.
// 배포하기 전 최초 한번만 해놓으면 되고, 이후 배포시에는 필요없음. 해당 비밀키를 수정하거나 삭제하는 방법도 찾아보면 있음.
// 클라우드 함수에 비밀키 등록방법: firebase functions:config:set userstate.role_secret_key='비밀키 입력'
exports.updateUserStateRole = functions.https.onCall((data, context) => {
  const userId = data.userId;
  const secretKey = data.secretKey;

  if (!context.auth) {
      throw new require('firebase-functions').https.HttpsError('인증되지 않은 사용자', '인증되지 않은 사용자가 요청함.');
    }

  if (secretKey !== require('firebase-functions').config().secret.cloud_functions_secret_key) {
      throw new require('firebase-functions').https.HttpsError('비밀키 오류', '비밀키가 잘못되었음.');
    }

  return admin.firestore().collection('user').doc(userId)
    .collection('userState').doc(userId)
    .set({ role: 'able' }, { merge: true });
});

exports.scheduleMonthRankUpdate = functions.pubsub.schedule('0 0 1 * *')
    .timeZone('Asia/Seoul').onRun(async (context) => {
        const db = admin.firestore();
        const statisticRef = db.collection('statistic');
        const logRef = db.collection('log');
        const userCollectionRef = db.collection('user');

        try {
            const snapshot = await statisticRef.where('monthWin', '>=', 30).orderBy('monthWin', 'desc').limit(100).get();
            const currentTimeStamp = Date.now().toString();
            const monthRankLogDocRef = logRef.doc('monthRankLog').collection('monthRankLog').doc(currentTimeStamp);
            await monthRankLogDocRef.set({ createdAt: admin.firestore.FieldValue.serverTimestamp() });

            for (const doc of snapshot.docs) {
                const docData = doc.data();
                const rankData = {
                    uid: docData.uid,
                    monthWin: docData.monthWin,
                    monthLose: docData.monthLose,
                    monthChallenge: docData.monthChallenge,
                    monthCheckup: docData.monthCheckup,
                    monthMyPost: docData.monthMyPost,
                    monthPointOutTicket: docData.monthPointOutTicket,
                    createdAt: admin.firestore.FieldValue.serverTimestamp(),
                  //  rank: snapshot.docs.indexOf(doc) + 1,
                    monthScore: 0,
                    name: docData.name,
                };
                const newDocRef = monthRankLogDocRef.collection('monthRank').doc();
                await newDocRef.set(rankData);

                await doc.ref.update({
                    monthWin: 0,
                    monthLose: 0,
                    monthChallenge: 0,
                    monthCheckup: 0,
                    monthMyPost: 0,
                    monthPointOutTicket: 1,
                });
            }

            const userDocs = await userCollectionRef.get();
            for (const doc of userDocs.docs) {
                const userStateDocRef = doc.ref.collection('userState').doc(doc.id);
                const userStateDoc = await userStateDocRef.get();
                const userStateData = userStateDoc.data();

                if (userStateData && userStateData.grade !== '0') {
                    await userStateDocRef.update({ grade: '0' });
                }
            }

            console.log('Ranking updated and all user grades reset to 0.');
        } catch (error) {
            console.error('Error updating ranking and resetting grades:', error);
        }
    });


exports.scheduleTodayCheckupUpdate = functions.pubsub.schedule('0 0 * * *')
    .timeZone('Asia/Seoul')
    .onRun(async (context) => {
        const db = admin.firestore();
        const statisticRef = db.collection('statistic');

        try {
            const snapshot = await statisticRef.get();

            for (const doc of snapshot.docs) {
                const docData = doc.data();
                if (docData.todayCheckup !== 10) {
                    await doc.ref.update({ todayCheckup: 10 });
                }
            }

            console.log('todayCheckup updated to 10 for applicable documents.');
        } catch (error) {
            console.error('Error selectively updating todayCheckup:', error);
        }
    });



exports.deleteUserAccount = functions.https.onCall(async (data, context) => {
  const uid = data.uid;
  const secretKey = data.secretKey;
  const expectedKey = require('firebase-functions').config().secret ? require('firebase-functions').config().secret.cloud_functions_secret_key : null;


    if (!context.auth) {
        throw new functions.https.HttpsError('인증되지 않은 사용자', '인증되지 않은 사용자가 요청함.');
      }

    if (secretKey !== expectedKey) {
        throw new functions.https.HttpsError('비밀키 오류', '비밀키가 잘못되었음.');
      }

  await admin.firestore().runTransaction(async (transaction) => {
    const userRef = admin.firestore().collection('user').doc(uid);
    const userDoc = await transaction.get(userRef);

    if (!userDoc.exists) {
      throw new functions.https.HttpsError('not-found', 'User not found');
    }

    const userData = userDoc.data();
    const logRef = admin.firestore().collection('log').doc('deleteLog')
      .collection('deleteLog').doc();
    const logData = {
        uid: userData.uid,
        name: userData.name,
        nickname: userData.nickname,
        email: userData.email,
        phone: userData.phone,
        birth: userData.birth,
        appleUid: userData.appleUid,
        whereLogin: userData.whereLogin,
        loginAt: userData.loginAt,
        signupAt: userData.createdAt,
        createdAt: admin.firestore.FieldValue.serverTimestamp()
    };
    transaction.set(logRef, logData);

    const checkupQuerySnapshot = await admin.firestore().collection('checkup')
      .where('uid', '==', uid).get();

      for (const doc of checkupQuerySnapshot.docs) {
          const requestQueueSnapshot = await doc.ref.collection('requestQueue').get();
          requestQueueSnapshot.forEach(subDoc => {
            transaction.delete(subDoc.ref);
          });
          transaction.delete(doc.ref);
        }

    const challengeComplainQuerySnapshot = await admin.firestore().collection('service')
         .doc('challengeComplain').collection('challengeComplain')
         .where('uid', '==', uid).get();

       for (const doc of challengeComplainQuerySnapshot.docs) {
         const requestQueueSnapshot = await doc.ref.collection('requestQueue').get();
         requestQueueSnapshot.forEach(subDoc => {
           transaction.delete(subDoc.ref);
         });
         transaction.delete(doc.ref);
       }

    const spaceQuerySnapshot = await admin.firestore().collection('space')
      .where('uid', '==', uid).get();

    spaceQuerySnapshot.forEach(doc => {
      transaction.update(doc.ref, { uid: 'none' });
    });

    const spaceLikeUidsQuerySnapshot = await admin.firestore().collection('space')
      .where('likeUids', 'array-contains', uid).get();

    spaceLikeUidsQuerySnapshot.forEach(doc => {
      const likeUids = doc.data().likeUids;
      const updatedLikeUids = likeUids.map(id => id === uid ? 'none' : id);
      transaction.update(doc.ref, { likeUids: updatedLikeUids });
    });
   });

     await admin.auth().deleteUser(uid);

     return { message: 'User account deleted successfully' };
});


exports.cancelBootpayPayment = functions.https.onCall(async (data, context) => {
  const secretKey = data.secretKey;
  const expectedKey = require('firebase-functions').config().secret ? require('firebase-functions').config().secret.cloud_functions_secret_key : null;


    if (!context.auth) {
        throw new functions.https.HttpsError('인증되지 않은 사용자', '인증되지 않은 사용자가 요청함.');
      }

    if (secretKey !== expectedKey) {
        throw new functions.https.HttpsError('비밀키 오류', '비밀키가 잘못되었음.');
      }

    try {
        await Bootpay.getAccessToken();
        const response = await Bootpay.cancelPayment({
            receipt_id: data.receipt_id,
            cancel_price: data.cancel_price,
            cancel_id: data.cancel_id,
        });
         console.log(response);
    } catch (error) {
         console.error("오류 발생:", error);
    }
});
