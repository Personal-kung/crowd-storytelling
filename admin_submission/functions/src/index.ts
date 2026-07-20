import {
  HttpsError,
  onCall,
} from "firebase-functions/v2/https";
import {logger} from "firebase-functions";
import {GeminiService} from "./services/gemini_service";
import {VisionService} from "./services/vision_service";

const visionService =
  new VisionService();


const geminiService =
  new GeminiService();

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
