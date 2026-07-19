import { doc, updateDoc } from "firebase/firestore";
import { db } from "../firebase";

export async function saveTranslation(
    storyId: string,
    language: string,
    translation: any
) {
    const storyRef = doc(db, "stories", storyId);
    await updateDoc(
        storyRef,
        {
            [`translations.${language}`]: {
                localizedCountry: translation.localizedCountry,
                transcreatedTitle: translation.transcreatedTitle,
                transcreated_content: translation.transcreatedText,
                writingMode: translation.writingMode
            }
        }
    );
}