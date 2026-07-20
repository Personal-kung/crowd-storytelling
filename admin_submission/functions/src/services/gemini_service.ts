import {GoogleGenerativeAI} from "@google/generative-ai";

/**
 * Service responsible for text correction.
 */
export class GeminiService {
  /**
   * Corrects OCR text conservatively.
   *
   * @param {string} text Raw OCR text.
   * @return {Promise<string>} Corrected text.
   */
  async correctText(text: string): Promise<string> {
    const apiKey =
      process.env.GEMINI_API_KEY;

    if (!apiKey) {
      throw new Error(
        "Missing GEMINI_API_KEY",
      );
    }

    const genAI =
      new GoogleGenerativeAI(apiKey);

    const model =
      genAI.getGenerativeModel({
        model: "gemini-2.0-flash",
      });

    const prompt = `
You are correcting OCR output from handwritten stories.

Rules:
- Fix spelling mistakes.
- Fix grammar mistakes.
- Fix obvious OCR errors.
- Preserve the author's writing style.
- Do not rewrite.
- Do not add new information.

Return only the corrected text.

OCR TEXT:

${text}
`;

    const result =
      await model.generateContent(
        prompt,
      );

    return result.response
      .text()
      .trim();
  }
}
