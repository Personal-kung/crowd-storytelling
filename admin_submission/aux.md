Copy the following into the first message of the new chat. It contains the project context, architecture, decisions already made, and the current state so we can continue without repeating the debugging process.

---

# Crowd Storytelling Project — Master Continuation Prompt

You are continuing development of the **Crowd Storytelling** application.

Act as a senior Firebase + TypeScript + Google AI engineer. Preserve existing architecture decisions and avoid unnecessary rewrites. Before changing code, always review the current implementation and explain:

1. File path being modified.
2. Current code section.
3. Replacement code.
4. Reason for the change.
5. Testing procedure.

The project prioritizes:

* maintainability
* Firebase-native architecture
* secure secret handling
* minimal duplication
* server-side AI processing
* scalable public usage

---

# Project Overview

Crowd Storytelling is a platform where users submit stories from around the world.

Workflow:

1. User submits handwritten story images.
2. Firebase Functions perform OCR.
3. Gemini corrects OCR output.
4. Admin reviews and approves final draft.
5. Approval triggers:

   * translation generation
   * cover image generation
6. Public users can request stories in their preferred language.
7. Translations are stored in Firestore for reuse.

The sole admin currently approves stories.

---

# Main Stack

## Frontend

* Flutter
* Firebase SDK

## Backend

Firebase Cloud Functions Gen 2

Runtime:

```
Node.js 22
TypeScript
```

Configuration:

`functions/tsconfig.json`

```json
{
  "compilerOptions": {
    "module": "NodeNext",
    "esModuleInterop": true,
    "moduleResolution": "nodenext",
    "strict": true,
    "target": "es2017",
    "noUnusedLocals": true,
    "noImplicitReturns": true
  }
}
```

---

# Firebase Services

Used services:

## Firebase Functions

Location:

```
functions/src/index.ts
```

Functions currently:

### OCR

```ts
processStoryOCR
```

Purpose:

* receives uploaded images
* extracts text
* corrects OCR output with Gemini

---

### Translation

```ts
generateTranslation
```

Callable function.

Input:

```json
{
 "storyId": "...",
 "language": "ja"
}
```

Uses:

```
ensureTranslation()
```

Logic:

* check Firestore
* if translation exists return it
* otherwise generate
* save under:

```
stories/{storyId}

translations:
 {
   ja:{
      localizedCountry:"",
      translatedTitle:"",
      translatedContent:""
   }
 }
```

---

### Cover Image

```ts
generateCoverImage
```

Callable function.

Input:

```json
{
 "storyId":"..."
}
```

The service retrieves all story data internally.

---

### Approval Trigger

Current trigger:

```ts
onDocumentUpdated
```

Listening:

```
stories/{storyId}
```

Logic:

Only execute when:

before.status != approved

AND

after.status == approved

Then:

1. generate English translation
2. generate cover image

---

# Google AI Libraries

## Current Gemini SDK

IMPORTANT:

Old SDK:

```
@google/generative-ai
```

was removed.

Do NOT use:

```ts
GoogleGenerativeAI
```

Use:

```ts
@google/genai
```

Example:

```ts
import {GoogleGenAI} from "@google/genai";

const ai =
 new GoogleGenAI({
   apiKey
 });
```

---

# Gemini Models

Current working models:

Text:

```
gemini-3-flash-preview
```

Reason:

* available with current API key
* previous models returned 404

Image:

```
gemini-2.5-flash-image
```

Reason:

* replaces deprecated Imagen model usage

Do NOT use:

```
imagen-4.0-fast-generate-001
```

It returned:

```
404 model no longer available to new users
```

---

# Secret Handling

IMPORTANT:

All Gemini API calls must use Firebase secrets.

Never hardcode keys.

Functions declaration:

```ts
{
 secrets:[
   "GEMINI_API_KEY"
 ]
}
```

Access:

```ts
process.env.GEMINI_API_KEY
```

---

# Current Services

## Translation Service

Location:

```
src/services/translation_service.ts
```

Current responsibilities:

* receive story data
* call Gemini
* return JSON translation

Expected schema:

```json
{
 "localizedCountry":"",
 "translatedTitle":"",
 "translatedContent":""
}
```

Requirements:

* preserve meaning
* preserve emotional tone
* no summarization
* no additional information
* valid JSON only

---

## Cover Image Service

Location:

```
src/services/cover_image_service.ts
```

Current design:

The service only requires:

```ts
generateCover(
 storyId:string
)
```

It internally:

1. Reads:

```
stories/{storyId}
```

2. Extracts:

```
title
text_content
country
```

3. Creates cinematic prompt.

4. Calls:

```ts
gemini-2.5-flash-image
```

with:

```ts
config:{
 imageConfig:{
   aspectRatio:"9:16"
 }
}
```

5. Stores:

Firebase Storage:

```
covers/{storyId}.png
```

Bucket:

```
crowd-story-uploads
```

6. Updates Firestore:

```json
coverImage:{
 path:"",
 generatedAt:"timestamp"
}
```

---

# Current Firestore Structure

Collection:

```
stories
```

Example:

```
stories/{storyId}

{
 title:"",
 text_content:"",
 country:"",
 sourceLanguage:"",
 status:"approved",

 translations:{
   en:{
     localizedCountry:"",
     translatedTitle:"",
     translatedContent:""
   },
   ja:{
     ...
   }
 },

 coverImage:{
   path:"",
   generatedAt:"timestamp"
 }
}
```

---

# Important Lessons From Debugging

## Gemini 404 errors

Usually caused by unavailable models.

Check available models using:

Gemini API models endpoint.

Current valid models returned:

```
gemini-2.5-flash
gemini-3-flash-preview
gemini-2.5-flash-image
```

---

## Callable Function Testing

Correct Firebase callable format:

```bash
curl \
-X POST \
-H "Content-Type: application/json" \
-d '
{
 "data":{
   "storyId":"YOUR_ID"
 }
}
' \
FUNCTION_URL
```

Do not send:

```json
{
 "storyId":"..."
}
```

because callable functions require:

```json
{
 "data":{}
}
```

---

# Coding Preferences

When editing:

* keep TypeScript strict compatibility
* satisfy ESLint rules:

  * valid-jsdoc
  * require-jsdoc
  * no non-null assertions where possible
* avoid duplicate Firestore writes
* services should own their complete workflows
* index.ts should orchestrate only

---

# Current Successful State

Completed successfully:

✅ Translation architecture
✅ Firebase secret usage
✅ Gemini SDK migration
✅ Gemini model update
✅ Cover image migration away from Vertex Imagen
✅ Cover generation requiring only storyId
✅ Cover image generation tested successfully

---

# Next Development Goals

Continue from this state.

Potential next tasks:

1. Improve translation caching logic.
2. Add user language preference handling.
3. Generate translations automatically when public users request unavailable languages.
4. Add translation status tracking:

Example:

```json
translationStatus:{
 ja:"completed",
 fr:"pending"
}
```

5. Improve cover prompt quality.
6. Add retry/error handling for AI services.
7. Add automated tests for:

   * translation function
   * cover generation function
   * approval trigger.

---

Start by reviewing the existing files before making any changes.
