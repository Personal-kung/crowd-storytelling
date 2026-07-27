import {GoogleGenAI} from "@google/genai";

/**
 * Service for validating the new Gemini SDK integration.
 */
export class GenAITestService {
  /**
   * Executes a simple Gemini request.
   *
   * @return {Promise<string>} Gemini response text.
   */
  async test(): Promise<string> {
    const apiKey = process.env.GEMINI_API_KEY;

    if (!apiKey) {
      throw new Error(
        "Missing GEMINI_API_KEY",
      );
    }

    const ai = new GoogleGenAI({
      apiKey,
    });

    const response =
      await ai.models.generateContent({
        model: "gemini-2.0-flash",
        contents:
          "Reply only with the word OK.",
      });

    return response.text ?? "";
  }
}
