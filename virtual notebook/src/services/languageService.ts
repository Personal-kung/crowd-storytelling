export function getUserLanguage(): string {

    const browserLanguage =
        navigator.language ||
        navigator.languages?.[0] ||
        "en";


    return browserLanguage
        .split("-")[0]
        .toLowerCase();
}

/**
 * Returns authoritative writing mode for original story:
 * 1. story.writingMode if explicitly set ("horizontal-tb" or "vertical-rl")
 * 2. Fallback based on story.sourceLanguage, story.country, or language detection
 */
export function getOriginalWritingMode(story: any): "horizontal-tb" | "vertical-rl" {
    if (story?.writingMode === "vertical-rl" || story?.writingMode === "horizontal-tb") {
        return story.writingMode;
    }
    const srcLang = (story?.sourceLanguage || "").toLowerCase();
    const country = (story?.country || "").toLowerCase();
    if (
        srcLang === "ja" || srcLang === "japanese" ||
        srcLang === "zh" || srcLang === "chinese" ||
        country === "japan" || country === "china"
    ) {
        return "vertical-rl";
    }
    return "horizontal-tb";
}

/**
 * Returns authoritative writing mode for localized story in target language:
 * 1. translation.writingMode if explicitly set ("horizontal-tb" or "vertical-rl")
 * 2. Fallback based on target language rules ("ja" / "zh" -> "vertical-rl", else "horizontal-tb")
 */
export function getLocalizedWritingMode(translation: any, targetLanguage: string): "horizontal-tb" | "vertical-rl" {
    if (translation?.writingMode === "vertical-rl" || translation?.writingMode === "horizontal-tb") {
        return translation.writingMode;
    }
    const lang = (targetLanguage || "").toLowerCase();
    if (lang === "ja" || lang === "japanese" || lang === "zh" || lang === "chinese") {
        return "vertical-rl";
    }
    return "horizontal-tb";
}

//if translation is found, load only the original and translated
export function getStoryContent(
    story: any,
    language: string
) {
    const translation = story?.translations?.[language];
    if (translation) {
        return {
            title: translation.transcreatedTitle ?? translation.translatedTitle ?? story.title,
            content: translation.transcreated_content ?? translation.translatedContent ?? story.text_content,
            writingMode: getLocalizedWritingMode(translation, language),
            localizedCountry: translation.localizedCountry ?? story.country,
            translated: true
        };
    }
    return {
        title: story?.title ?? "",
        content: story?.text_content ?? "",
        writingMode: getOriginalWritingMode(story),
        localizedCountry: story?.country,
        translated: false
    };

}