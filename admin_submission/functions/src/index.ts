import {
  HttpsError,
  onCall,
} from "firebase-functions/v2/https";
import { logger } from "firebase-functions";
import { GeminiService } from "./services/gemini_service";
import { VisionService } from "./services/vision_service";
import { onDocumentUpdated } from "firebase-functions/v2/firestore";
import { TranslationService } from "./services/translation_service";
import { CoverImageService } from "./services/cover_image_service";
import { initializeApp } from "firebase-admin/app";
import { getFirestore } from "firebase-admin/firestore";

initializeApp();
const coverImageService = new CoverImageService();
const visionService = new VisionService();
const geminiService = new GeminiService();
/**
 * Ensures that a translation exists for the requested language.
 *
 * If the translation already exists and force is false,
 * the existing translation is returned.
 *
 * @param {string} storyId Firestore story id.
 * @param {string} language Target language.
 * @param {boolean} force Regenerate even if already present.
 * @return {Promise<object>} Translation object.
 */
async function ensureTranslation(
  storyId: string,
  language: string,
  force = false,
) {
  if (!language || typeof language !== "string") {
    throw new HttpsError(
      "invalid-argument",
      "language is required",
    );
  }
  const storyRef =
    getFirestore()
      .collection("stories")
      .doc(storyId);

  const snap =
    await storyRef.get();

  if (!snap.exists) {
    throw new HttpsError(
      "not-found",
      "Story not found",
    );
  }

  const story =
    snap.data()!;
  if (!story) {
    throw new HttpsError(
      "internal",
      "Story data missing",
    );
  }

  const existing =
    story.translations?.[language];

  if (existing && !force) {
    logger.info(
      "Translation already exists",
      {
        storyId,
        language,
      },
    );

    return existing;
  }

  logger.info(
    "Generating translation",
    {
      storyId,
      language,
    },
  );

  const translationService =
    new TranslationService();

  const translation =
    await translationService.translateStory(
      story.title ?? "",
      story.text_content ?? "",
      story.country ?? "",
      story.sourceLanguage ?? "unknown",
      language,
    );

  await storyRef.set(
    {
      translations: {
        [language]: translation,
      },
    },
    {
      merge: true,
    },
  );

  logger.info(
    "Translation stored",
    {
      storyId,
      language,
    },
  );

  return translation;
}
/**
 * Processes story images with OCR and correction.
 */
export const processStoryOCR = onCall(
  {
    secrets: ["GEMINI_API_KEY"],
  },
  async (request) => {
    const start =
      Date.now();

    const images =
      request.data.images;

    if (
      !images ||
      !Array.isArray(images)
    ) {
      throw new HttpsError(
        "invalid-argument",
        "Images array is required",
      );
    }

    const pageTexts: string[] = [];

    for (const image of images) {
      logger.info(
        "Processing image",
        {
          size: image.length,
        },
      );


      const buffer =
        Buffer.from(
          image,
          "base64",
        );

      const text =
        await visionService.extractText(
          buffer,
        );
      logger.info(
        "OCR result",
        {
          chars: text.length,
          preview: text.substring(0, 100),
        },
      );

      pageTexts.push(text);
    }

    const rawText =
      pageTexts.join("\n\n");
    logger.info(
      "Combined OCR",
      {
        chars: rawText.length,
      },
    );


    let correctedText = rawText;

    try {
      correctedText =
        await geminiService.correctText(
          rawText,
        );
    } catch (error) {
      logger.error(
        "Gemini correction failed",
        error,
      );
    }
    logger.info(
      "Gemini correction complete",
    );

    return {
      success: true,
      rawText,
      correctedText,
      pages: pageTexts.map(
        (text, index) => ({
          pageNumber: index + 1,
          text,
        }),
      ),
      processingTimeMs:
        Date.now() - start,
    };
  },
);

export const onStoryPublished =
  onDocumentUpdated(
    {
      document: "stories/{storyId}",
      secrets: ["GEMINI_API_KEY"],
    },
    async (event) => {
      const eventData =
        event.data;

      if (!eventData) {
        return;
      }

      const before =
        eventData.before.data();

      const after =
        eventData.after.data();

      if (!before || !after) {
        return;
      }

      const snap =
        eventData.after;

      try {
        await ensureTranslation(
          snap.id,
          "en",
        );

        logger.info(
          "English translation generated",
          {
            storyId: snap.id,
            language: "en",
          },
        );
      } catch (error) {
        logger.error(
          "Translation failed",
          error,
        );
      }
      try {
        await coverImageService.generateCover(snap.id,);
        logger.info(
          "Cover image generated",
          {
            storyId: snap.id,
          },
        );
      } catch (error) {
        logger.error(
          "Cover generation failed",
          error,
        );
      }
    },
  );

export const generateCoverImage = onCall(
  {
    secrets: ["GEMINI_API_KEY"],
  },
  async (request) => {
    const { storyId } =
      request.data;

    if (!storyId) {
      throw new HttpsError(
        "invalid-argument",
        "storyId is required",
      );
    }

    const storyRef =
      getFirestore()
        .collection("stories")
        .doc(storyId);

    const snap =
      await storyRef.get();

    if (!snap.exists) {
      throw new HttpsError(
        "not-found",
        "Story not found",
      );
    }

    const story = snap.data();

    if (!story) {
      throw new HttpsError(
        "internal",
        "Story data missing",
      );
    }

    const path =
      await coverImageService.generateCover(
        storyId,
      );

    return {
      success: true,
      path,
    };
  },
);

export const generateTranslation = onCall(
  {
    secrets: ["GEMINI_API_KEY"],
  },
  async (request) => {
    const {
      storyId,
      language = "en",
    } = request.data;

    if (!storyId) {
      throw new HttpsError(
        "invalid-argument",
        "storyId is required",
      );
    }
    try {
      await ensureTranslation(
        storyId,
        language,
      );

      return {
        success: true,
        language,
      };
    } catch (error) {
      logger.error(
        "generateTranslation failed",
        {
          error,
          storyId,
          language,
        },
      );

      throw new HttpsError(
        "internal",
        "Translation generation failed",
      );
    }
  },
);
export const listGeminiModels =
  onCall(
    {
      secrets: ["GEMINI_API_KEY"],
    },
    async () => {
      const { GoogleGenAI } =
        await import("@google/genai");

      const ai =
        new GoogleGenAI({
          apiKey:
            process.env.GEMINI_API_KEY,
        });

      const models: string[] = [];

      for await (const model of await ai.models.list()) {
        models.push(
          model.name ?? "unknown",
        );
      }

      return {
        models,
      };
    },
  );

export const generateIntroTranslation = onCall(
  {
    secrets: ["GEMINI_API_KEY"],
  },
  async (request) => {
    const { language = "en" } = request.data || {};
    const langCode = String(language).toLowerCase().trim();

    if (!langCode) {
      throw new HttpsError(
        "invalid-argument",
        "language is required",
      );
    }

    const introRef = getFirestore()
      .collection("stories")
      .doc("Intro");

    const snap = await introRef.get();

    if (!snap.exists) {
      throw new HttpsError(
        "not-found",
        "Intro document not found",
      );
    }

    const docData = snap.data();

    if (!docData) {
      throw new HttpsError(
        "internal",
        "Intro document contains no data",
      );
    }

    // Existing translation → return immediately.
    if (typeof docData[langCode] === "string" &&
      docData[langCode].trim()) {
      logger.info(
        "Intro translation already exists",
        { language: langCode },
      );

      return {
        translation: docData[langCode],
      };
    }

    // English is the canonical source language.
    const englishSource = docData["en"];

    if (
      typeof englishSource !== "string" ||
      !englishSource.trim()
    ) {
      throw new HttpsError(
        "failed-precondition",
        "Intro.en is missing from Firestore",
      );
    }

    // English requires no Gemini call.
    if (langCode === "en") {
      return {
        translation: englishSource,
      };
    }

    const apiKey = process.env.GEMINI_API_KEY;

    if (!apiKey) {
      throw new HttpsError(
        "internal",
        "GEMINI_API_KEY is not configured",
      );
    }

    const { GoogleGenAI } = await import("@google/genai");

    const ai = new GoogleGenAI({
      apiKey,
      apiVersion: "v1beta",
    });

    const prompt = `
Act as a "Transcreator" for an Ancestral Vessel.

Transcreate the following introduction from English into ${langCode}.

CRITICAL INSTRUCTIONS:
- Preserve the poetic, reflective, and dignified tone.
- Preserve exactly 3 paragraphs.
- Preserve the meaning and emotional nuance.
- Do not add preamble, commentary, titles, or quotation marks.
- Return ONLY the transcreated text.
- Separate the three paragraphs with double newlines.

Original Intro:

${englishSource}
`;

    try {
      const response = await ai.models.generateContent({
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

      // Intro translations are horizontal-tb by design.
      // No writingMode field is stored.
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
        translation: translatedIntro,
      };
    } catch (error) {
      logger.error(
        "Intro translation failed",
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