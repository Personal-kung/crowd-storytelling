import { initializeApp } from 'firebase/app';
import { getFirestore } from 'firebase/firestore';
import { getStorage } from 'firebase/storage';
import { getFunctions } from "firebase/functions";

import firebaseConfig from '../firebase-applet-config.json';


const app = initializeApp(firebaseConfig);


export const db = getFirestore(
  app,
  firebaseConfig.firestoreDatabaseId
);


export const storage = getStorage(app);


export const functions = getFunctions(
  app,
  "us-central1"
);


console.log("Firebase config:", firebaseConfig);
console.log("Storage bucket:", storage.app.options.storageBucket);