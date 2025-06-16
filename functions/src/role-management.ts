import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
admin.initializeApp();

// Create user with role
exports.createUserWithRole = functions.https.onCall(async (data, context) => {
  // Verify admin status
  if (!context.auth?.token.admin) {
    throw new functions.https.HttpsError(
      'permission-denied',
      'Only admins can create users'
    );
  }

  try {
    // Create user
    const user = await admin.auth().createUser({
      email: data.email,
      password: generatePassword(12),
    });

    // Set custom claims
    await admin.auth().setCustomUserClaims(user.uid, {
      admin: data.role === 'admin',
      editor: data.role === 'editor',
      owner: data.role === 'owner'
    });

    // Create Firestore document
    await admin.firestore().collection('users').doc(user.uid).set({
      email: data.email,
      role: data.role,
      createdAt: admin.firestore.FieldValue.serverTimestamp()
    });

    // Send password reset email
    const resetLink = await admin.auth().generatePasswordResetLink(data.email);
    return { success: true, resetLink };
  } catch (error) {
    throw new functions.https.HttpsError('internal', error.message);
  }
});

// Update user role
exports.updateUserRole = functions.https.onCall(async (data, context) => {
  if (!context.auth?.token.admin) {
    throw new functions.https.HttpsError(
      'permission-denied',
      'Unauthorized access'
    );
  }

  try {
    await admin.auth().setCustomUserClaims(data.uid, {
      admin: data.role === 'admin',
      editor: data.role === 'editor'
    });

    await admin.firestore().collection('users').doc(data.uid).update({
      role: data.role,
      updatedAt: admin.firestore.FieldValue.serverTimestamp()
    });

    return { success: true };
  } catch (error) {
    throw new functions.https.HttpsError('internal', error.message);
  }
});

// Helper function
function generatePassword(length: number): string {
  const charset = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
  let password = '';
  for (let i = 0; i < length; i++) {
    password += charset.charAt(Math.floor(Math.random() * charset.length));
  }
  return password;
}