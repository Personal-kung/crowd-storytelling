import {setGlobalOptions, logger} from "firebase-functions";
import {HttpsError, onCall} from "firebase-functions/v2/https";
import {initializeApp} from "firebase-admin/app";
import {getFirestore} from "firebase-admin/firestore";
import {GoogleGenAI} from "@google/genai";

initializeApp();

setGlobalOptions({maxInstances: 10});

/**
 * Generates and stores a missing Intro translation.
 *
 * Firestore source:
 *   stories/Intro
 *
 * Expected document structure:
 *   Intro.en = canonical English source
 *   Intro.ja = Japanese translation
 *   Intro.es = Spanish translation
 *   etc.
 *
 * Intro translations intentionally do not contain a writingMode field.
 */
export const generateIntroTranslation = onCall(
  {
    secrets: ["GEMINI_API_KEY"],
  },
  async (request) => {
    const language = request.data?.language;

    if (
      typeof language !== "string" ||
      !language.trim()
    ) {
      throw new HttpsError(
        "invalid-argument",
        "language is required",
      );
    }

    const langCode = language.toLowerCase().trim();

    const firestore = getFirestore();

    const introRef = firestore
      .collection("stories")
      .doc("Intro");

    const snapshot = await introRef.get();

    if (!snapshot.exists) {
      throw new HttpsError(
        "not-found",
        "Intro document not found",
      );
    }

    const introData = snapshot.data();

    if (!introData) {
      throw new HttpsError(
        "internal",
        "Intro document contains no data",
      );
    }

    /*
     * If the requested translation already exists,
     * return it without calling Gemini.
     */
    const existingTranslation =
      introData[langCode];

    if (
      typeof existingTranslation === "string" &&
      existingTranslation.trim()
    ) {
      logger.info(
        "Intro translation already exists",
        {
          language: langCode,
        },
      );

      return {
        success: true,
        language: langCode,
        translation: existingTranslation,
        generated: false,
      };
    }

    /*
     * English is the canonical source language.
     */
    const englishSource = introData["en"];

    if (
      typeof englishSource !== "string" ||
      !englishSource.trim()
    ) {
      throw new HttpsError(
        "failed-precondition",
        "Intro.en is missing from Firestore",
      );
    }

    /*
     * English requires no Gemini request.
     */
    if (langCode === "en") {
      return {
        success: true,
        language: "en",
        translation: englishSource,
        generated: false,
      };
    }

    /*
     * GEMINI_API_KEY is supplied by Firebase Secret Manager.
     *
     * It is NEVER exposed to the frontend.
     */
    const apiKey =
      process.env.GEMINI_API_KEY;

    if (!apiKey) {
      logger.error(
        "GEMINI_API_KEY is not configured",
      );

      throw new HttpsError(
        "internal",
        "Gemini API key is not configured",
      );
    }

    const ai = new GoogleGenAI({
      apiKey,
      apiVersion: "v1beta",
    });

    const prompt = `
Act as a culturally-aware literary transcreator.

Transcreate the following English introduction into ${langCode}.

The translated result will be displayed directly inside a digital notebook.
Therefore, STRUCTURAL FIDELITY IS CRITICAL.

TRANSLATION REQUIREMENTS:
- Preserve the meaning, emotional nuance, warmth, and reflective tone.
- Produce natural, fluent ${langCode}.
- Do not translate mechanically word-for-word 
when a culturally natural expression is more appropriate.
- Preserve the author's personal voice.

FORMATTING REQUIREMENTS:
- Preserve the EXACT paragraph structure of the source.
- Every paragraph in the source must remain a 
separate paragraph in the translation.
- Preserve every blank line between paragraphs.
- NEVER merge two or more source paragraphs into one paragraph.
- NEVER split one source paragraph into multiple paragraphs 
unless absolutely required by the target language's writing conventions.
- Preserve the numbered list structure exactly.
- The source contains four numbered sections: 1, 2, 3, and 4. 
The translation MUST contain exactly four numbered sections.
- Preserve the numbering exactly as 1., 2., 3., and 4.
- Preserve Markdown formatting such as **bold** 
exactly where it is used in the source.
- Preserve paragraph breaks inside each numbered section.
- Preserve intentional expressive elements such as "XD".
- Do not convert the content into a summary, essay, or continuous prose.
- Do not remove any information.
- Do not add any information.
- Do not add an introduction, explanation, 
translator's note, commentary, title, or quotation marks.

OUTPUT REQUIREMENTS:
- Return ONLY the translated text.
- The output must follow the same structural layout as the source.
- Before returning the answer, internally verify that all source paragraphs and 
all four numbered sections are represented.

SOURCE TEXT:

${englishSource}
`;

    try {
      logger.info(
        "Generating Intro translation",
        {
          language: langCode,
        },
      );

      const response =
        await ai.models.generateContent({
          model: "gemini-3-flash-preview",
          contents: prompt,
        });

      const translatedIntro =
        response.text?.trim();

      if (!translatedIntro) {
        throw new Error(
          "Gemini returned an empty translation",
        );
      }

      /*
       * Store only the language field.
       *
       * No writingMode is stored for Intro.
       */
      await introRef.set(
        {
          [langCode]: translatedIntro,
        },
        {
          merge: true,
        },
      );

      logger.info(
        "Intro translation generated and stored",
        {
          language: langCode,
        },
      );

      return {
        success: true,
        language: langCode,
        translation: translatedIntro,
        generated: true,
      };
    } catch (error) {
      logger.error(
        "Intro translation generation failed",
        {
          language: langCode,
          error,
        },
      );

      throw new HttpsError(
        "internal",
        "Intro translation generation failed",
      );
    }
  },
);
