const {initializeApp} = require("firebase-admin/app");
const {getAuth} = require("firebase-admin/auth");
const {getFirestore} = require("firebase-admin/firestore");
const {onCall, HttpsError} = require("firebase-functions/v2/https");
const {defineString} = require("firebase-functions/params");
const {createService} = require("./service");

initializeApp();
const apiKey = defineString("PANEL_WEB_API_KEY", {default: "AIzaSyAPtjO1yd3QtxnZJCU5wZhsY3Fkq8EGkDo"});
const manage = createService({
  auth: getAuth(),
  database: getFirestore(),
  sendInvitation: async (email) => {
    const origin = process.env.FIREBASE_AUTH_EMULATOR_HOST
      ? "http://" + process.env.FIREBASE_AUTH_EMULATOR_HOST + "/identitytoolkit.googleapis.com"
      : "https://identitytoolkit.googleapis.com";
    const response = await fetch(origin + "/v1/accounts:sendOobCode?key=" + apiKey.value(), {
      method: "POST",
      headers: {"Content-Type": "application/json", "X-Firebase-Locale": "es"},
      body: JSON.stringify({requestType: "PASSWORD_RESET", email}),
      signal: AbortSignal.timeout(10000),
    });
    if (!response.ok) throw new Error("invitation-failed");
  },
});

exports.managePanelUsers = onCall({
  region: "southamerica-west1", minInstances: 0, maxInstances: 1,
  concurrency: 1, cpu: "gcf_gen1", memory: "256MiB", timeoutSeconds: 60,
  serviceAccount: "panel-users-runtime@segundaopinion-ea0c8.iam.gserviceaccount.com",
  enforceAppCheck: false,
}, async (request) => {
  try { return await manage(request.auth, request.data); }
  catch (error) {
    if (error instanceof HttpsError) throw error;
    if (error.code === "auth/email-already-exists") throw new HttpsError("already-exists", "email-exists");
    throw new HttpsError("internal", "operation-incomplete");
  }
});
