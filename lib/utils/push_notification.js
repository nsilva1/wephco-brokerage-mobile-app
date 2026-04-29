const admin = require('firebase-admin');

async function sendNotification(userId, title, body) {
  const userDoc = await admin.firestore().collection('users').doc(userId).get();
  const token = userDoc.data()?.fcmToken;
  if (!token) return;

  await admin.messaging().send({
    token,
    notification: { title, body },
    data: {
        path: '/wallet'     // modify path as needed for specific screen.
    },
    android: { priority: 'high' },
    apns: { payload: { aps: { sound: 'default' } } },
  });
}

// On withdrawal approved:
sendNotification(userId, 'Withdrawal Approved ✅', 'Your withdrawal of ₦50,000 has been processed.');

// On withdrawal rejected:
sendNotification(userId, 'Withdrawal Rejected', 'Your withdrawal request was declined. Reason: Incomplete bank details.');