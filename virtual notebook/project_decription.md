{
  "project": {
    "name": "Virtual Notebook — Global Crowd Storytelling Platform",
    "repository": "crowd-storytelling/virtual notebook",
    "stack": {
      "frontend": "React 19, TypeScript 5.8, Vite 6, Tailwind CSS v4, Motion (Framer Motion v12)",
      "ai_engine": "@google/genai SDK (Gemini 3 Flash / gemini-3-flash-preview)",
      "database": "Firebase Cloud Firestore",
      "storage": "Firebase Cloud Storage (global-notebook.firebasestorage.app)",
      "hosting": "Firebase Hosting",
      "serverless_compute": "Firebase Cloud Functions (2nd Gen, Node.js TypeScript runtime)"
    }
  },
  "core_functionalities": [
    {
      "feature": "Diegetic Interactive Flip-Book UI",
      "description": "Realistic book flip animation using Framer Motion with natural paper grain textures, parchment light/dark theme toggling, and silk ribbon bookmark navigation.",
      "file": "src/components/Notebook.tsx"
    },
    {
      "feature": "Adaptive Responsive Viewports",
      "description": "Dual-page spread layout for desktop browsers and single-page touch-optimized card layout with bottom bar navigation for mobile devices.",
      "file": "src/components/Notebook.tsx"
    },
    {
      "feature": "Culturally-Aware AI Transcreation",
      "description": "Translates stories and metadata using Gemini 3 Flash to preserve emotional nuance, localized titles, and translated country names over literal word-for-word translation.",
      "files": ["src/services/transcreationService.ts", "src/services/aiContentService.ts"]
    },
    {
      "feature": "Multilingual Layouts (Vertical & Horizontal)",
      "description": "Dynamically adjusts typography layout: Japanese/East Asian text renders in vertical right-to-left ('vertical-rl') reading direction while Western text uses horizontal left-to-right ('horizontal-tb').",
      "file": "src/components/Notebook.tsx"
    },
    {
      "feature": "AI Cover Image Generation & JIT Lazy Loading",
      "description": "Triggers cloud generation of missing story cover images and delivers assets using Firebase Storage with JIT blur placeholders via react-intersection-observer.",
      "files": ["src/services/storyService.ts", "src/services/aiContentService.ts"]
    },
    {
      "feature": "Diegetic Engagement Telemetry (HeartbeatService)",
      "description": "Singleton service tracking tactile interactions, reading cadences, hover durations, page flips, and long-press actions for developer analytics.",
      "file": "src/services/HeartbeatService.ts"
    },
    {
      "feature": "Firestore & Cloud Storage Security Controls",
      "description": "Enforces security rules ensuring read access is restricted to approved stories and public access is restricted to cover art paths.",
      "files": ["firestore.rules", "storage.rules"]
    }
  ],
  "module_registry": {
    "entrypoint": "src/App.tsx",
    "components": {
      "Notebook": "Main flip-book component handling page flipping, mobile layout adaptation, TOC modal, and full-screen story reader.",
      "JITImage": "Lazy-loading image component using Intersection Observer with watercolor blur placeholders.",
      "DynamicFlag": "Converts 2-character country ISO codes to native flag emojis."
    },
    "services": {
      "storyService": "Queries Firestore for approved stories, resolves Cloud Storage URLs, and triggers missing AI assets.",
      "aiContentService": "Firebase HTTPS callable function triggers (generateTranslation, generateCoverImage).",
      "transcreationService": "Client-side Gemini API runner for story transcreation, writing mode detection, and title localization.",
      "translationStorageService": "Persists generated transcreations into Firestore story documents.",
      "languageService": "Detects browser language and resolves localized story titles, content, and fallback content.",
      "HeartbeatService": "Diegetic analytics logger tracking reader interactions.",
      "countryService": "Resolves flag CDN URLs and converts country codes to Unicode flag emojis."
    }
  },
  "data_models": {
    "Story": {
      "id": "string",
      "title": "string",
      "name": "string",
      "country": "string",
      "ISOcode": "string?",
      "text_content": "string",
      "status": "approved | pending",
      "coverImage": "string | CoverImage",
      "translations": "Record<languageCode, StoryTranslation>"
    },
    "StoryTranslation": {
      "localizedCountry": "string?",
      "transcreatedTitle": "string?",
      "transcreated_content": "string?",
      "translatedTitle": "string?",
      "translatedContent": "string?",
      "writingMode": "'horizontal-tb' | 'vertical-rl'"
    }
  }
}
