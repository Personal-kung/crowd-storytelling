import vision from "@google-cloud/vision";

/**
 * Service responsible for OCR extraction.
 */
export class VisionService {
  private readonly client =
    new vision.ImageAnnotatorClient();

  /**
   * Extracts text from image.
   *
   * @param {Buffer} imageBuffer Image buffer.
   * @return {Promise<string>} OCR text.
   */
  async extractText(
    imageBuffer: Buffer,
  ): Promise<string> {
    const [result] =
      await this.client.documentTextDetection({
        image: {
          content: imageBuffer,
        },
      });

    return (
      result.fullTextAnnotation?.text ??
      ""
    );
  }
}
