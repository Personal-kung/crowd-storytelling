import {GoogleGenerativeAI} from "@google/generative-ai";

/**
 * Service responsible for translating approved story submissions.
 */
export class TranslationService {
  /**
   * Translates a story into English.
   *
   * @param {string} title Original story title.
   * @param {string} body Original story content.
   * @param {string} countryName Original country name.
   * @param {string} targetLanguage Original language story
   * @return {Promise<object>} Structured translated story content.
   */
  async translateStory(
    title: string,
    body: string,
    countryName: string,
    targetLanguage: string,
  ) {
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
        model: "gemini-2.5-flash-lite",
      });

    const prompt = `
Translate this story submission into natural English.

Return ONLY valid JSON.

Schema:

{
  "localizedCountry": "",
  "translatedTitle": "",
  "translatedContent": ""
}


Country:
${countryName}

Title:
${title}

Content:
${body}
`;

    const result =
      await model.generateContent(prompt);

    const response =
      result.response.text();

    return JSON.parse(response);
  }
}
