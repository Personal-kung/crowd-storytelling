import { httpsCallable } from "firebase/functions";
import { functions } from "../firebase";


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