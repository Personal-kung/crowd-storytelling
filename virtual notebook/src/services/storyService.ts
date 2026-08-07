import {
  collection,
  query,
  where,
  getDocs
} from "firebase/firestore";

import {
  ref,
  getDownloadURL
} from "firebase/storage";
import { db, storage } from "../firebase";
import { Story } from "../types";
import {
  ensureStoryAssets
} from "./aiContentService";
import {getUserLanguage} from "./languageService";

async function resolveCoverImage(
  coverImage: Story["coverImage"]
): Promise<string | undefined> {

  console.group("resolveCoverImage");

  if (!coverImage) {
    console.log("No cover image");
    console.groupEnd();
    return undefined;
  }

  if (typeof coverImage === "string") {
    console.log("Already URL");
    console.groupEnd();
    return coverImage;
  }

  if (!coverImage.path) {
    console.log("No path");
    console.groupEnd();
    return undefined;
  }

  try {
    const imageRef = ref(storage, coverImage.path);
    console.log("fullPath =", imageRef.fullPath);
    const url = await getDownloadURL(imageRef);
    console.log("downloadURL =", url);
    console.groupEnd();
    return url;

  } catch (error: any) {

    console.error("===== STORAGE ERROR =====");
    console.error("code:", error.code);
    console.error("message:", error.message);
    console.error("customData:", error.customData);
    console.error("serverResponse:", error.serverResponse);
    console.error("full error:", error);

    return undefined;
  }

}



export async function getApprovedStories(): Promise<Story[]> {


  const storiesQuery = query(
    collection(db, "stories"),
    where(
      "status",
      "==",
      "approved"
    )
  );


  let snapshot =
    await getDocs(storiesQuery);


  const language =
    getUserLanguage();


  let needsReload = false;


  for (const document of snapshot.docs) {

    const story =
      document.data() as Story;


    const changed =
      await ensureStoryAssets(
        {
          id: document.id,
          ...story
        },
        language
      );


    if (changed) {
      needsReload = true;
    }
    if (needsReload) {
      console.log(
        "Reloading stories after AI generation"
      );

      snapshot =
        await getDocs(storiesQuery);
    }
  }


  const stories =
    await Promise.all(

      snapshot.docs.map(
        async document => {


          const data =
            document.data() as Story;



          const coverUrl =
            await resolveCoverImage(
              data.coverImage
            );



          return {

            id:
              document.id,


            ...data,


            coverImage:
              coverUrl

          } as Story;

        }
      )

    );


  return stories;
}
