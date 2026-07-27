import { httpsCallable } from "firebase/functions";
import { functions } from "../firebase";
import { Story } from "../types";

export async function ensureTranslation(
    storyId: string,
    language: string
) {

    const generateTranslation =
        httpsCallable(
            functions,
            "generateTranslation"
        );


    const result =
        await generateTranslation({
            storyId,
            language
        });


    return result.data;
}



export async function ensureCoverImage(
    storyId: string
) {

    const generateCoverImage =
        httpsCallable(
            functions,
            "generateCoverImage"
        );


    const result =
        await generateCoverImage({
            storyId
        });


    return result.data;
}

export async function ensureStoryAssets(
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
        (
            typeof story.coverImage !== "string" &&
            !story.coverImage.path
        )
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