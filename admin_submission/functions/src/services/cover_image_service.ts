import {VertexAI} from "@google-cloud/vertexai";
import * as admin from "firebase-admin";

const vertexAI = new VertexAI({
  project: "global-notebook",
  location: "us-central1",
});

const gemini = vertexAI.getGenerativeModel({
  model: "gemini-2.5-flash",
});

const imagen = vertexAI.preview.getGenerativeModel({
  model: "imagen-4.0-fast-generate-001",
});


/**
 * Generates a cover image for a story.
 */
export class CoverImageService {
  /**
   * Creates an image prompt and stores generated image.
   *
   * @param {string} storyId Firestore story id.
   * @param {string} title Story title.
   * @param {string} body Story body.
   * @param {string} countryName Story country.
   * @return {Promise<string>} Storage path.
   */
  async generateCover(
    storyId: string,
    title: string,
    body: string,
    countryName: string,
  ): Promise<string> {
    const promptResult = await gemini.generateContent({
      contents: [
        {
          role: "user",
          parts: [
            {
              text:
                `Act as an artistic director. Create a high-quality, cinematic, 
                and evocative cover image for a story titled "${title}". 
      Context: "${body}"
      Style: A beautiful, traditional painting or cinematic scene reflecting 
      the culture of ${countryName}. 
      Composition: Centered, rich textures, deep emotional resonance. 
      Avoid any text, letters, or logos in the image.`,
            },
          ],
        },
      ],
    });

    const imagePrompt =
      promptResult.response.candidates?.[0]
        ?.content.parts[0]
        ?.text ?? "A meaningful human story illustration";


    const imageResult = await imagen.generateContent({
      contents: [
        {
          role: "user",
          parts: [
            {
              text: imagePrompt,
            },
          ],
        },
      ],
    });


    const imageData =
      imageResult.response.candidates?.[0]
        ?.content.parts[0];


    if (!imageData) {
      throw new Error("Imagen returned no image");
    }


    const bucket = admin.storage()
      .bucket("crowd-story-uploads");


    const filePath =
      `covers/${storyId}.png`;


    await bucket.file(filePath).save(
      Buffer.from(
        imageData.inlineData?.data ?? "",
        "base64",
      ),
      {
        metadata: {
          contentType: "image/png",
        },
      },
    );


    return filePath;
  }
}
