import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

admin.initializeApp();

// Function to set user roles
export const setUserRole = functions.https.onCall(async (data, context) => {
  // Security check - only admins can modify roles
  if (!context.auth || !context.auth.token.admin) {
    throw new functions.https.HttpsError(
      "permission-denied",
      "Only admins can modify roles"
    );
  }

  try {
    // Set custom claims (user roles)
    await admin.auth().setCustomUserClaims(data.uid, {
      admin: data.role === "admin",
      editor: data.role === "editor",
    });

    // Update Firestore user document
    await admin.firestore().collection("users").doc(data.uid).update({
      role: data.role,
      lastModified: admin.firestore.FieldValue.serverTimestamp(),
    });

    return { success: true };
  } catch (error) {
    throw new functions.https.HttpsError("internal", (error as Error).message);
  }
});

// Function to create new users
export const createFactoryUser = functions.https.onCall(async (data, context) => {
  // Security check - only admins/owner can create users
  if (!context.auth || (!context.auth.token.admin && !context.auth.token.owner)) {
    throw new functions.https.HttpsError(
      "permission-denied",
      "Unauthorized access"
    );
  }

  try {
    // Create user
    const user = await admin.auth().createUser({
      email: data.email,
      password: generateRandomPassword(), // Implement this function
    });

    // Set initial role
    await admin.auth().setCustomUserClaims(user.uid, {
      admin: data.role === "admin",
      editor: data.role === "editor",
      owner: false,
    });

    // Create user document
    await admin.firestore().collection("users").doc(user.uid).set({
      email: data.email,
      role: data.role,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      owner: false,
    });

    // Send password reset email
    const resetLink = await admin.auth().generatePasswordResetLink(data.email);
    // Here you would send the resetLink via your email service

    return { success: true, resetLink };
  } catch (error) {
    throw new functions.https.HttpsError("internal", (error as Error).message);
  }
});

// Helper function to generate random passwords
function generateRandomPassword(length = 12): string {
  const chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789";
  return Array.from(crypto.getRandomValues(new Uint8Array(length)))
    .map((byte) => chars[byte % chars.length])
    .join("");
}