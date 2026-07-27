July 27, 2026

Fantastic! That progression makes sense, and it's good to hear the application is now working both locally and on Firebase Hosting.

---

# Development Log — Firebase Storage Integration Fix

## Objective

Connect the Virtual Notebook web application to Firebase Storage so that story cover images stored in Cloud Storage can be retrieved using the Firebase Web SDK.

---

## Initial Symptoms

* Firestore documents loaded correctly.
* Cover image paths existed in Firestore.
* `getDownloadURL()` consistently failed.
* Browser returned:

  * `412 Required service account missing`
  * later `400 Bucket not set up properly`
  * later `403 Forbidden`

Firebase Storage Console initially displayed only the **Get Started** screen despite an existing Google Cloud Storage bucket.

---

## Root Cause

Two different storage buckets existed:

**Original application uploads**

```
gs://crowd-story-uploads
```

This was a normal Google Cloud Storage bucket and was **not linked to Firebase Storage**.

**Firebase bucket**

```
gs://global-notebook.firebasestorage.app
```

This bucket did not initially exist.

The application configuration pointed to

```json
"storageBucket": "global-notebook.firebasestorage.app"
```

while all images existed in

```
crowd-story-uploads
```

Because the bucket was not a Firebase Storage bucket, the Firebase SDK could not generate download URLs.

---

## Resolution Steps

### 1. Enabled Firebase Storage

Initialized Firebase Storage for the project from the Firebase Console.

This created

```
gs://global-notebook.firebasestorage.app
```

---

### 2. Uploaded cover images

Copied all cover images from

```
gs://crowd-story-uploads/covers/
```

to

```
gs://global-notebook.firebasestorage.app/covers/
```

---

### 3. Updated application configuration

`firebase-applet-config.json`

```json
{
  "storageBucket": "global-notebook.firebasestorage.app"
}
```

---

### 4. Verified Storage Rules

Deployed rules:

```javascript
rules_version = '2';

service firebase.storage {
  match /b/{bucket}/o {

    match /covers/{fileName} {
      allow read: if true;
      allow write: if false;
    }

    match /{allPaths=**} {
      allow read, write: if false;
    }

  }
}
```

---

### 5. Added debugging

Additional logging added inside `resolveCoverImage()`:

* Firebase configuration
* bucket name
* requested storage path
* generated download URL
* Firebase error codes
* server response

This isolated each stage of the request.

---

### 6. Verified Hosting

Successfully tested from

* Local Vite development server
* Firebase Hosting deployment

Both now retrieve images correctly.

---

# Final Architecture

```
Firestore
      │
      │ coverImage.path
      ▼
covers/7OuvJci7aFbjxwdjf6DE.png
      │
      ▼
Firebase Storage SDK
      │
      ▼
getDownloadURL()
      │
      ▼
Firebase Storage
(global-notebook.firebasestorage.app)
      │
      ▼
HTTPS download URL
      │
      ▼
React Notebook
```

---

# Files Modified

```
firebase-applet-config.json
src/firebase.ts
src/services/storyService.ts
storage.rules
```

---

# Current Status

✅ Firestore queries working

✅ Firebase Storage initialized

✅ Storage Rules deployed

✅ Cover images loading

✅ Firebase Hosting working

✅ Local development working

No remaining issues with image retrieval.

---

# Master Prompt for New Chat

The following prompt should provide enough context for a new conversation to continue with the next phase of the project.

---

## Master Prompt

I am continuing development of the **Global Notebook** web application.

### Current stack

* React
* TypeScript
* Vite
* Firebase Hosting
* Firebase Firestore
* Firebase Storage
* Google Cloud Functions (2nd Gen)
* Google Cloud Storage
* Gemini API

The application already:

* reads approved stories from Firestore
* displays them inside a notebook interface
* loads cover images from Firebase Storage
* detects the reader's language
* supports multiple languages
* is deployed on Firebase Hosting

Firebase Storage has already been fixed and is working correctly.

Current architecture:

```
Firestore
      │
      ▼
stories collection
      │
      ▼
coverImage.path
      │
      ▼
Firebase Storage
(global-notebook.firebasestorage.app)
      │
      ▼
getDownloadURL()
      │
      ▼
React UI
```

There are already deployed Google Cloud Functions that should be reused rather than recreated.

They include functions for:

* translation / transcreation using Gemini
* AI cover image generation
* possibly other AI services

The goal is to connect the existing web application to those already-deployed Cloud Functions.

Important constraints:

* Reuse existing Cloud Functions whenever possible.
* Do not create duplicate functions unless absolutely necessary.
* Inspect the existing `functions/` directory before making architectural decisions.
* Prefer callable HTTPS functions if they already exist.
* Keep Firestore as the source of truth.
* Continue using Firebase Storage for generated cover images.
* Follow the existing project architecture and coding style.
* Make changes incrementally with clear explanations.

The first task is to inspect the current `functions/` directory, identify all deployed Cloud Functions, explain what each one does, and determine how the React application should call them. Then implement the client-side integration one function at a time, testing each connection before moving to the next.

-------------------

# Master Prompt — Global Notebook AI Generation Optimization Phase

I am continuing development of the **Global Notebook** web application.

## Current stack

* React
* TypeScript
* Vite
* Firebase Hosting
* Firebase Firestore
* Firebase Storage
* Google Cloud Functions 2nd Gen
* Gemini API

## Current production state

The application is deployed successfully.

Current working architecture:

```
Browser
   |
   ▼
React Virtual Notebook
   |
   ▼
Firebase callable functions
   |
   ├── generateTranslation
   |
   └── generateCoverImage
          |
          ▼
      Gemini API
          |
          ▼
      Firestore + Storage
```

The existing deployed functions are located in:

```
admin_submission/functions
```

and must be reused.

Do not create duplicate functions.

---

## Current working functions

### generateTranslation

Callable function:

```
generateTranslation
```

Responsibilities:

* receives:

```json
{
 "storyId":"",
 "language":""
}
```

* checks Firestore story
* generates Gemini transcreation
* stores:

```
stories/{storyId}
   translations:
      language
```

---

### generateCoverImage

Callable function:

```
generateCoverImage
```

Responsibilities:

* receives:

```json
{
 "storyId":""
}
```

* generates Gemini image
* stores:

```
Firebase Storage:

covers/{storyId}.png
```

* updates Firestore:

```json
coverImage:{
 path:"covers/{storyId}.png"
}
```

---

# Current reader flow

The notebook currently:

1. Detects browser language:

```
navigator.language
```

2. Checks missing assets.

3. Calls:

```
ensureTranslation()
```

and:

```
ensureCoverImage()
```

through Firebase callable functions.

This works.

---

# Next objective

Optimize AI generation calls.

Goals:

## 1. Prevent duplicate generation

A story should only generate:

```
storyId + language translation
```

once.

A story should only generate:

```
cover image
```

once.

Implement protection against:

* multiple readers opening simultaneously
* repeated callable requests
* accidental duplicate Gemini calls

---

## 2. Add generation locking

Before Gemini execution:

Check Firestore state.

Example:

```
aiGeneration:
{
 translation:
   ja:"processing",

 coverImage:"processing"
}
```

Possible states:

```
missing
processing
completed
failed
```

Only one request should transition:

```
missing → processing
```

---

## 3. Improve callable function safety

Consider:

* Firebase App Check
* request validation
* rate protection

Do not require user authentication because the notebook is public.

---

## 4. Maintain failure behavior

Important:

If Gemini fails:

* do not write incomplete Firestore data
* do not store broken Storage references
* leave the story available for future retry

---

## 5. Preserve current architecture

Do not move Gemini logic into React.

React should only call:

```
httpsCallable()
```

Firestore remains the source of truth.

---

## First task

Inspect:

```
admin_submission/functions/src/index.ts
admin_submission/functions/src/services/translation_service.ts
admin_submission/functions/src/services/cover_image_service.ts
virtual notebook/src/services/aiContentService.ts
```

Then propose the smallest safe change to guarantee:

```
one translation generation per story/language
one cover generation per story
```

before modifying code.

---

End of master prompt.

---

After deployment, the next phase will be much safer because we will be optimizing a known-good production baseline rather than debugging multiple moving parts.
