export function getUserLanguage(): string {

    const browserLanguage =
        navigator.language ||
        navigator.languages?.[0] ||
        "en";


    return browserLanguage
        .split("-")[0]
        .toLowerCase();
}
async function ensureStoryAssets(
    story: Story,
    language: string
) {

    let changed = false;


    if (!story.translations?.[language]) {

        console.log(
            "Generating translation",
            story.id,
            language
        );

        await ensureTranslation(
            story.id,
            language
        );

        changed = true;
    }


    if (
        !story.coverImage ||
        typeof story.coverImage !== "string" &&
        !story.coverImage.path
    ) {

        console.log(
            "Generating cover",
            story.id
        );

        await ensureCoverImage(
            story.id
        );

        changed = true;
    }


    return changed;
}


export function getStoryContent(
    story: any,
    language: string
) {

    const translation =
        story.translations?.[language];


    if (translation) {

        return {

            title:
                translation.transcreatedTitle ??
                translation.translatedTitle ??
                story.title,


            content:
                translation.transcreated_content ??
                translation.translatedContent ??
                story.text_content,


            writingMode:
                translation.writingMode ??
                "horizontal-tb",


            localizedCountry:
                translation.localizedCountry ??
                story.country,


            translated: true
        };

    }


    return {

        title:
            story.title,


        content:
            story.text_content,


        writingMode:
            "horizontal-tb",


        localizedCountry:
            story.country,


        translated:false
    };
}