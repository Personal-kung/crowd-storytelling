import { doc, getDoc } from "firebase/firestore";
import { db } from "../firebase";
import { ensureIntroTranslation } from "./aiContentService";

/**
 * Requests a missing Intro translation from the secure
 * Firebase Cloud Function.
 *
 * The Gemini API key is NOT accessed from the client.
 * The Cloud Function is responsible for accessing the
 * GEMINI_API_KEY Firebase Secret.
 */
export async function translateAndSaveIntro(
  targetLanguage: string
): Promise<string> {
  const langCode = (targetLanguage || "en").toLowerCase().trim();

  if (!langCode) {
    throw new Error("Target language is required");
  }

  return await ensureIntroTranslation(langCode);
}

/**
 * Gets the Intro content for the requested language.
 *
 * Firestore is the source of truth.
 *
 * Flow:
 * 1. Read stories/Intro from Firestore.
 * 2. If the requested translation exists, return it.
 * 3. If English is requested, return Intro.en.
 * 4. If the requested language is missing, call the
 *    secure Firebase Cloud Function.
 *
 * The frontend never accesses the Gemini API key.
 */
export async function getIntro(
  targetLanguage: string = "en"
): Promise<string> {
  const langCode = (targetLanguage || "en").toLowerCase().trim();

  if (!langCode) {
    throw new Error("Target language is required");
  }

  const introRef = doc(db, "stories", "Intro");

  try {
    const snapshot = await getDoc(introRef);

    if (!snapshot.exists()) {
      throw new Error(
        "Intro document does not exist in Firestore"
      );
    }

    const docData =
      snapshot.data() as Record<string, unknown>;

    /*
     * Existing translation in Firestore.
     *
     * Example:
     * Intro.ja
     * Intro.es
     * Intro.zh
     */
    const existingTranslation = docData[langCode];

    if (
      typeof existingTranslation === "string" &&
      existingTranslation.trim()
    ) {
      return existingTranslation;
    }

    /*
     * English is the canonical source language.
     */
    if (langCode === "en") {
      const englishIntro = docData["en"];

      if (
        typeof englishIntro !== "string" ||
        !englishIntro.trim()
      ) {
        throw new Error(
          "Intro.en is missing from Firestore"
        );
      }

      return englishIntro;
    }

    /*
     * Requested language does not exist.
     *
     * Ask the secure Firebase Cloud Function to:
     * - read Intro.en
     * - access GEMINI_API_KEY from Firebase Secrets
     * - call Gemini
     * - save Intro.{langCode} to Firestore
     * - return the translation
     */
    return await translateAndSaveIntro(langCode);
  } catch (error) {
    console.error(
      "Error loading Intro:",
      error
    );

    throw error;
  }
}