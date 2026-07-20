import {TranslationServiceClient} from "@google-cloud/translate";

const client = new TranslationServiceClient();

/**
 * Detects the language of extracted OCR text.
 */
export class LanguageService {
  /**
   * Detects language from text.
   *
   * @param {string} text OCR extracted text.
   * @return {Promise<string>} Detected language code.
   */
  async detectLanguage(text: string): Promise<string> {
    const projectId =
      process.env.GCLOUD_PROJECT;

    if (!projectId) {
      throw new Error(
        "Missing Google Cloud project id",
      );
    }

    const [response] =
      await client.detectLanguage({
        parent:
          `projects/${projectId}/locations/global`,
        content: text,
      });

    const languages =
      response.languages ?? [];

    if (languages.length === 0) {
      return "unknown";
    }

    return (
      languages[0].languageCode ?? "unknown"
    );
  }
}
