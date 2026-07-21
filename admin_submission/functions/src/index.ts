import {
  HttpsError,
  onCall,
} from "firebase-functions/v2/https";
import { logger } from "firebase-functions";
import { GeminiService } from "./services/gemini_service";
import { VisionService } from "./services/vision_service";
import { onDocumentCreated } from "firebase-functions/v2/firestore";
import { TranslationService } from "./services/translation_service";
import { CoverImageService } from "./services/cover_image_service";
import { initializeApp } from "firebase-admin/app";
import { getFirestore, FieldValue } from "firebase-admin/firestore";

initializeApp();
const coverImageService = new CoverImageService();
const visionService = new VisionService();
const geminiService = new GeminiService();
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
  onDocumentCreated(
    {
      document: "stories/{storyId}",
      secrets: ["GEMINI_API_KEY"],
    },
    async (event) => {
      const snap =
        event.data;

      if (!snap) {
        return;
      }

      const story =
        snap.data();


      if (story.status !== "approved") {
        return;
      }


      const translationService =
        new TranslationService();

      const translation =
        await translationService.translateStory(
          story.title ?? "",
          story.body ?? "",
          story.countryName ?? "",
          "en",
        );


      await snap.ref.update({
        translations: {
          en: translation,
        },
      });


      logger.info(
        "Story translated",
        {
          id: snap.id,
        },
      );
      try {

        await coverImageService.generateCover(
          snap.id,
          story.title ?? "",
          story.body ?? "",
          story.countryName ?? "",
        );

        await snap.ref.update({
          coverImage: {
            generatedAt:
              FieldValue.serverTimestamp(),
          },
        });

      } catch (error) {

        logger.error(
          "Cover generation failed",
          error,
        );

      }
    },
  );

export const generateCoverImage = onCall(
  async (request) => {
    const { storyId } = request.data;

    if (!storyId) {
      throw new Error("Missing storyId");
    }


    const storyRef =
      getFirestore()
        .collection("stories")
        .doc(storyId);


    const story =
      await storyRef.get();


    if (!story.exists) {
      throw new Error("Story not found");
    }


    const data = story.data()!;


    const path =
      await coverImageService.generateCover(
        storyId,
        data.title ?? "",
        data.body ?? "",
        data.countryName ?? "",
      );


    await storyRef.update({
      coverImage: {
        path,
        generatedAt:
          FieldValue.serverTimestamp(),
      },
    });


    return {
      success: true,
      path,
    };
  },
);
