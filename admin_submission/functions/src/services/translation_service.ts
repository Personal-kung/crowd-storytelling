import {GoogleGenAI} from "@google/genai";

/**
 * Service responsible for translating stories.
 */
export class TranslationService {
  /**
   * Translate story content.
   *
   * @param {string} title Original title.
   * @param {string} content Original story content.
   * @param {string} country Country name.
   * @param {string} sourceLanguage Original language.
   * @param {string} targetLanguage Target language.
   * @return {Promise<object>} Translation result.
   */
  async translateStory(
    title: string,
    content: string,
    country: string,
    sourceLanguage: string,
    targetLanguage: string,
  ): Promise<object> {
    const apiKey =
      process.env.GEMINI_API_KEY;

    if (!apiKey) {
      throw new Error(
        "Missing GEMINI_API_KEY",
      );
    }

    const ai =
      new GoogleGenAI({
        apiKey,
        apiVersion: "v1beta",
      });

    const prompt = `
Act as a "Transcreator" for an Ancestral Vessel. 

Transcreate the following story from ${sourceLanguage} and its metadata 
into ${targetLanguage}.

CRITICAL INSTRUCTIONS:
- Maintain the emotional nuance and cultural weight 
rather than a literal word-for-word translation.
- If the target language or content is Japanese or Chinese, 
suggest 'vertical-rl' for writingMode to honor 
traditional formatting. Otherwise use 'horizontal-tb'.
- Preserve formatting and poetic rhythm.
- Also translate the Country Name provided 
below into the ${targetLanguage} equivalent.

Return exactly this schema:

{
  "localizedCountry": "",
  "translatedTitle": "",
  "translatedContent": "",
  "writingMode": "vertical-rl" | "horizontal-tb",
}

Country:
${country}

Story Title:
${title}

Original Content:
${content}
`;

    let response;

    try {
      response =
        await ai.models.generateContent({
          model: "gemini-3-flash-preview",
          contents: [
            {
              role: "user",
              parts: [
                {
                  text: prompt,
                },
              ],
            },
          ],
        });
    } catch (error) {
      console.error(
        "Gemini translation request failed",
        {
          name:
            error instanceof Error ? error.name: "unknown",
          message:
            error instanceof Error ? error.message: String(error),
          error,
        },
      );

      throw error;
    }

    const text =
      response.text
        ?.trim()
        .replace(
          /^```json\s*/i,
          "",
        )
        .replace(
          /\s*```$/,
          "",
        );

    if (!text) {
      throw new Error(
        "Gemini returned empty translation",
      );
    }

    try {
      return JSON.parse(text);
    } catch (error) {
      console.error(
        "Gemini returned invalid JSON",
        {
          text,
          error,
        },
      );

      throw new Error(
        "Translation JSON parsing failed",
      );
    }
  }
}
