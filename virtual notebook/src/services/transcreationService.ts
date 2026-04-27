import { GoogleGenAI } from "@google/genai";

export async function transcreateStory(title: string, content: string, targetLanguage: string = "English") {
  const apiKey = process.env.GEMINI_API_KEY;
  if (!apiKey) {
    console.error("GEMINI_API_KEY is not defined");
    return { transcreatedText: content, writingMode: "horizontal-tb", emotionalTone: "original", localizedCountry: null };
  }

  const ai = new GoogleGenAI({ apiKey });
  
  const prompt = `
    Act as a "Transcreator" for an Ancestral Vessel. 
    Transcreate the following story and its metadata into ${targetLanguage}.
    
    CRITICAL INSTRUCTIONS:
    - Maintain the emotional nuance and cultural weight rather than a literal word-for-word translation.
    - If the target language or content is Japanese or Chinese, suggest 'vertical-rl' for writingMode to honor traditional formatting. Otherwise use 'horizontal-tb'.
    - Preserve formatting and poetic rhythm.
    - Also translate the Country Name provided below into the ${targetLanguage} equivalent.
    
    Story Title: ${title}
    Original Content: ${content}

    Return ONLY a JSON response in the following format:
    {
      "transcreatedText": "...",
      "writingMode": "vertical-rl" | "horizontal-tb",
      "emotionalTone": "...",
      "localizedCountry": "Translated Country Name"
    }
  `;

  try {
    const response = await ai.models.generateContent({
      model: "gemini-3-flash-preview",
      contents: prompt,
      config: {
        responseMimeType: "application/json"
      }
    });

    let text = response.text;
    if (!text) throw new Error("Empty response from Gemini");

    return JSON.parse(text);
  } catch (error) {
    console.error("Transcreation failed:", error);
    return { transcreatedText: content, writingMode: "horizontal-tb", emotionalTone: "original", localizedCountry: null };
  }
}
