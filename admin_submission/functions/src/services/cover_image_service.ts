import {GoogleGenAI} from "@google/genai";
import * as admin from "firebase-admin";

/**
 * Service responsible for generating story cover images.
 */
export class CoverImageService {
  /**
   * Generate and store a story cover image.
   *
   * @param {string} storyId Firestore story id.
   * @return {Promise<string>} Storage path.
   */
  async generateCover(
    storyId: string,
  ): Promise<string> {
    const apiKey =
      process.env.GEMINI_API_KEY;

    if (!apiKey) {
      throw new Error(
        "Missing GEMINI_API_KEY",
      );
    }


    const firestore =
      admin.firestore();


    const storyRef =
      firestore
        .collection("stories")
        .doc(storyId);


    const snap =
      await storyRef.get();


    if (!snap.exists) {
      throw new Error(
        "Story not found",
      );
    }


    const story =
      snap.data();


    if (!story) {
      throw new Error(
        "Story data missing",
      );
    }


    const title =
      story.title ?? "";


    const content =
      story.text_content ?? "";


    const country =
      story.country ?? "";


    const prompt = `
Act as an artistic director.

Create a high-quality cinematic cover image
for a historical story.

Story title:
${title}

Story context:
${content.substring(0, 1000)}

Country:
${country}


Style:

- Traditional painting style.
- Cinematic atmosphere.
- Symbolic storytelling.
- Focus on landscapes, architecture,
  objects and cultural elements.
- Avoid identifiable people.
- Respect local culture.
- Rich textures.
- Emotional.
- Vertical book cover composition.
- No text.
- No letters.
- No logos.
- No watermark.
`;


    const ai =
      new GoogleGenAI({
        apiKey,
      });


    const response =
      await ai.models.generateContent({
        model:
          "gemini-2.5-flash-image",
        contents:
          prompt,
        config: {
          imageConfig: {
            aspectRatio:
              "9:16",
          },
        },
      });


    const parts =
      response
        .candidates?.[0]
        ?.content
        ?.parts;


    const imagePart =
      parts?.find(
        (part) =>
          part.inlineData,
      );


    if (
      !imagePart ||
      !imagePart.inlineData?.data
    ) {
      throw new Error(
        "No image returned from Gemini",
      );
    }


    const bucket =
      admin.storage().bucket();


    const filePath =
      `covers/${storyId}.png`;


    await bucket
      .file(filePath)
      .save(
        Buffer.from(
          imagePart.inlineData.data,
          "base64",
        ),
        {
          metadata: {
            contentType:
              "image/png",
            cacheControl:
              "public,max-age=31536000",
          },
        },
      );


    await storyRef.update({
      coverImage: {
        path: filePath,
        generatedAt:
          admin.firestore
            .FieldValue
            .serverTimestamp(),
      },
    });


    return filePath;
  }
}
