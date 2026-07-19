export function getUserLanguage(): string {
    const browserLanguage = navigator.language || navigator.languages?.[0] || "en";
    return browserLanguage.split("-")[0].toLowerCase();
}


export function getStoryContent(story: any, language: string) {
    const translation = story.translations?.[language];
    if (translation) {
        return {
            title: translation.transcreatedTitle || story.title,
            content: translation.transcreated_content || story.text_content,
            writingMode: translation.writingMode || "horizontal-tb",
            localizedCountry: translation.localizedCountry || story.country,
            translated: true
        };
    }
    return {
        title: story.title,
        content: story.text_content,
        writingMode: "horizontal-tb",
        localizedCountry: story.country,
        translated: false
    };
}

