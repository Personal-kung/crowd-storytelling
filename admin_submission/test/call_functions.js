import dotenv from "dotenv";

import {initializeApp} from "firebase/app";
import {
  getAuth,
  signInWithEmailAndPassword,
} from "firebase/auth";

import {
  getFunctions,
  httpsCallable,
} from "firebase/functions";

dotenv.config({
  path: ".env.local",
});

const {
  FIREBASE_API_KEY,
  FIREBASE_AUTH_DOMAIN,
  FIREBASE_PROJECT_ID,
  FIREBASE_STORAGE_BUCKET,
  FIREBASE_APP_ID,
  FUNCTION_REGION,
  TEST_EMAIL,
  TEST_PASSWORD,
  TEST_STORY_ID,
} = process.env;

const required = [
  "FIREBASE_API_KEY",
  "FIREBASE_AUTH_DOMAIN",
  "FIREBASE_PROJECT_ID",
  "FIREBASE_STORAGE_BUCKET",
  "FIREBASE_APP_ID",
  "TEST_EMAIL",
  "TEST_PASSWORD",
  "TEST_STORY_ID",
];

const missing = required.filter(
  (name) => !process.env[name],
);

if (missing.length > 0) {
  console.error(
    "\nMissing variables in .env.local:\n",
  );

  missing.forEach((v) =>
    console.error(` - ${v}`),
  );

  process.exit(1);
}

const firebaseConfig = {
  apiKey: FIREBASE_API_KEY,
  authDomain: FIREBASE_AUTH_DOMAIN,
  projectId: FIREBASE_PROJECT_ID,
  storageBucket: FIREBASE_STORAGE_BUCKET,
  appId: FIREBASE_APP_ID,
};

const app =
  initializeApp(firebaseConfig);

const auth =
  getAuth(app);

const functions =
  getFunctions(
    app,
    FUNCTION_REGION ??
      "us-central1",
  );

async function main() {
  console.log(
    "\n========== Crowd Story Function Test ==========\n",
  );

  console.log(
    "Project:",
    FIREBASE_PROJECT_ID,
  );

  console.log(
    "Story:",
    TEST_STORY_ID,
  );

  console.log(
    "\nAuthenticating...\n",
  );

  await signInWithEmailAndPassword(
    auth,
    TEST_EMAIL,
    TEST_PASSWORD,
  );

  console.log(
    "✓ Authentication successful\n",
  );

  //
  // Translation
  //

  console.log(
    "Calling generateTranslation...\n",
  );

  const generateTranslation =
    httpsCallable(
      functions,
      "generateTranslation",
    );

  const translationResult =
    await generateTranslation({
      storyId:
        TEST_STORY_ID,
      language: "en",
    });

  console.log(
    "✓ Translation completed",
  );

  console.dir(
    translationResult.data,
    {
      depth: null,
    },
  );

  //
  // Cover
  //

  console.log(
    "\nCalling generateCoverImage...\n",
  );

  const generateCover =
    httpsCallable(
      functions,
      "generateCoverImage",
    );

  const coverResult =
    await generateCover({
      storyId:
        TEST_STORY_ID,
    });

  console.log(
    "✓ Cover completed",
  );

  console.dir(
    coverResult.data,
    {
      depth: null,
    },
  );

  console.log(
    "\n========== Finished ==========\n",
  );
}

main().catch((error) => {
  console.error(
    "\nFunction test failed:\n",
  );

  console.error(error);

  process.exit(1);
});
