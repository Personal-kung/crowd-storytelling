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
You are correcting OCR output extracted from handwritten stories.

Your task is ONLY to improve OCR accuracy.

Rules:
- Correct obvious OCR recognition mistakes.
- Correct spelling mistakes.
- Correct punctuation only when clearly needed.
- Correct grammar only when the intended meaning is obvious.
- Preserve the author's wording, tone and voice.
- Preserve paragraph breaks.
- Never summarize.
- Never rewrite sentences for style.
- Never make the text more literary.
- Never invent missing words.
- If uncertain, leave the original wording unchanged.

Return ONLY the corrected text.

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
