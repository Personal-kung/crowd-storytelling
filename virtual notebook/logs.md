# Development Logs

| Date | File | Actions |
| --- | --- | --- |
| 2026-07-19 | `.devcontainer/devcontainer.json` | Configured standardized containerized development environment for Vite, TypeScript, and Firebase CLI. |
| 2026-07-27 | `firebase-applet-config.json` | Updated Firebase Storage bucket configuration to point to `global-notebook.firebasestorage.app`. |
| 2026-07-27 | `storage.rules` | Created and deployed Firebase Storage security rules for public cover image access. |
| 2026-07-27 | `src/firebase.ts` | Configured Firebase SDK initialization for Firestore and Cloud Storage. |
| 2026-07-27 | `src/services/storyService.ts` | Implemented `resolveCoverImage` logic with Firebase Storage URL resolution and error handling. |
| 2026-07-29 | `src/services/aiContentService.ts` | Created Cloud Function trigger handlers (`ensureTranslation`, `ensureCoverImage`) for Gemini API assets. |
| 2026-07-29 | `src/services/languageService.ts` | Added browser language detection (`getUserLanguage`) and story content fallback handler (`getStoryContent`). |
| 2026-07-29 | `src/services/transcreationService.ts` | Implemented Gemini AI transcreation prompt and response parser for localized titles, content, and writing modes. |
| 2026-07-29 | `src/services/translationStorageService.ts` | Added Firestore update handler to save transcreated content under story language maps. |
| 2026-07-29 | `src/services/HeartbeatService.ts` | Built diegetic engagement tracking service for reader scroll, page flips, and tactile interactions. |
| 2026-07-29 | `src/components/Notebook.tsx` | Refactored notebook language toggles, fixed `userLanguage` state scope, and optimized flip-book rendering. |
| 2026-07-29 | `src/App.tsx` | Connected story fetching lifecycle, global page structure calculation, and parchment dark/light mode toggles. |
| 2026-08-14 | `README.md` | Rewrote project README into a concise, easy-to-understand 3-paragraph summary. |
| 2026-08-14 | `logs.md` | Created development activity log in table format tracking dates, files, and actions. |
| 2026-08-15 | `firestore.rules` | Restricted Intro rules to public read only (`allow read: if true; allow write: if false;`) on `/intro/{docId}` and `/Intro/{docId}`. |
| 2026-08-15 | `admin_submission/functions/src/index.ts` | Added `generateIntroTranslation` Cloud Function trigger for secure server-side Intro transcreation and Admin SDK Firestore persistence. |
| 2026-08-15 | `src/services/aiContentService.ts` | Added `ensureIntroTranslation` helper to trigger backend Cloud Function. |
| 2026-08-15 | `src/services/introService.ts` | Configured `getIntro` for narrow public Firestore reads and backend Cloud Function writes for missing translations. |
| 2026-08-15 | `src/App.tsx` | Simplified `globalPages` to single `{ type: 'intro' }` page entry. |
| 2026-08-15 | `src/services/storyService.ts` | Added `getApprovedStoryById` function to fetch individual approved stories directly from Firestore by document ID. |
| 2026-08-15 | `src/App.tsx` | Implemented `/story/{firebaseStoryId}` URL detection and `sharedStory` state loading. |
| 2026-08-15 | `src/components/Notebook.tsx` | Configured `Notebook` to bypass Stories Index for valid shared stories (Cover → Intro → Story) while falling back gracefully to Stories Index for invalid IDs. |
| 2026-08-15 | `src/services/introService.ts` | Modified to translated intro to match readers browser language |
