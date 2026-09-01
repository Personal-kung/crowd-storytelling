# Virtual Notebook — Handoff & Project Status

## 1. Project Metadata & Stack
- **Name**: Virtual Notebook — Global Crowd Storytelling Platform
- **Repository**: `crowd-storytelling/virtual notebook`
- **Working Directory**: `/home/crowd-storytelling/virtual notebook`
- **Session Date Context**: August / September 2026
- **Technology Stack**:
  - **Frontend**: React 19, TypeScript 5.8, Vite 6, Tailwind CSS v4, Motion (Framer Motion v12)
  - **Backend / Cloud Services**: Firebase Firestore, Cloud Storage, Hosting, Cloud Functions Gen 2 (Node.js)
  - **AI SDK & Model**: `@google/genai` SDK with `gemini-3-flash-preview`

## 2. Completed Features & Architecture Milestones
- **Intro Page & Secure Cloud Translation**:
  - Intro page content fetched from Firestore `stories/Intro`.
  - Secure server-side translation via Gen 2 Cloud Function (`generateIntroTranslation`) utilizing Firebase Secret Manager (`GEMINI_API_KEY`). Client does NOT access Gemini API keys directly.
  - Intro titles and header localization based on user/browser language (`en`, `es`, `ja`, `zh`, `uz` with `en` fallback).
- **Custom URL Routing & Deep Linking**:
  - Route `/story/{storyId}` supported via Firebase Hosting rewrites (`** -> /index.html`).
  - Browser history management (`pushState` / `popstate`) updates URL when opening story reader and resets URL to `/` when closing, supporting native browser Back/Forward navigation.
- **Individual Story Sharing**:
  - Added discrete `<StoryShareButton />` inside the story reader header.
  - Native Web Share API (`navigator.share`) with fallback to clipboard link copy (`navigator.clipboard.writeText`) and temporary visual feedback ("Copied" text with check icon).
- **Dual Navigation Flows & Page Layout**:
  - **Default URL**: Notebook cover -> Intro page -> Index (TOC) -> Story list.
  - **Shared Link URL (`/story/{storyId}`)**: Intended shared story first -> Intro page -> Index (TOC) -> Remaining stories.
  - **Spread Alignment**:
    - **Desktop (`!isMobile`)**: Index 0 Shared Story, Index 1 Blank filler, Index 2 Intro (full spread on even index), Index 3 Index (TOC), Index 4+ Remaining stories.
    - **Mobile (`isMobile`)**: Index 0 Shared Story, Index 1 Intro, Index 2 Index (TOC), Index 3+ Remaining stories.

## 3. Pending Tasks (Roadmap for Next Sessions)
- **Task 3**: Lazy translation behavior (translate story titles and country metadata for new languages at index level; translate complete story text content only when opened).
- **Task 4**: Translation loading animation / UI showing the translation process.
- **Deferred**: Story sorting by timestamp/country (Ignore for now).

---

# next session prompt

{
  "handoff": {
    "session_date": "2026-09-02",
    "purpose": "Continue development of Virtual Notebook without repeating previously answered architectural questions.",
    "instruction_to_next_llm": {
      "mode": "implementation-focused",
      "do_not_repeat_questions": true,
      "read_all_decisions_before_asking_any_question": true,
      "ask_only_if_information_is_genuinely_missing_or_conflicting": true,
      "preserve_existing_working_behavior": true,
      "avoid_reimplementing_existing_functions": true
    },

    "project": {
      "name": "Virtual Notebook — Global Crowd Storytelling Platform",
      "repository": "crowd-storytelling/virtual notebook",
      "working_directory": "/home/crowd-storytelling/virtual notebook",
      "stack": {
        "frontend": "React 19",
        "language": "TypeScript 5.8",
        "bundler": "Vite 6",
        "css": "Tailwind CSS v4",
        "animation": "Motion / Framer Motion v12",
        "ai": "@google/genai SDK",
        "ai_model": "gemini-3-flash-preview",
        "database": "Firebase Cloud Firestore",
        "storage": "Firebase Cloud Storage",
        "hosting": "Firebase Hosting",
        "functions": "Firebase Cloud Functions Gen 2",
        "functions_runtime": "Node.js"
      }
    },

    "important_architecture": {
      "frontend": {
        "location": "virtual notebook/src",
        "entrypoint": "src/App.tsx",
        "notebook_component": "src/components/Notebook.tsx"
      },

      "firebase_functions": {
        "location": "virtual notebook/functions",
        "important_note": "This is separate from /home/crowd-storytelling/admin_submission/functions.",
        "virtual_notebook_functions_currently": [
          "generateIntroTranslation"
        ],
        "admin_submission_functions_existing_elsewhere": [
          "generateTranslation",
          "generateCoverImage",
          "processStoryOCR",
          "onStoryPublished",
          "listGeminiModels"
        ],
        "do_not_duplicate_admin_submission_functions": true
      },

      "firebase_config": {
        "hosting_public_directory": "dist",
        "hosting_rewrite": "** -> /index.html",
        "functions_source": "functions",
        "functions_codebase": "default",
        "firestore_database": "(default)",
        "firestore_location": "nam5"
      }
    },

    "current_user_requirements": {
      "priority": "Continue remaining project tasks without repeating prior discovery questions.",

      "initial_tasks": [
        {
          "id": 1,
          "task": "Intro page and Intro translation",
          "status": "COMPLETED"
        },
        {
          "id": 2,
          "task": "Custom URL per story (/story/{storyId}) & deep linking",
          "status": "COMPLETED"
        },
        {
          "id": 3,
          "task": "Lazy translation behavior: translate story titles/country metadata for new languages at index level; translate complete story only when story is opened",
          "status": "PENDING"
        },
        {
          "id": 4,
          "task": "Translation loading animation / UI showing translation process",
          "status": "PENDING"
        },
        {
          "id": 5,
          "task": "Intro page and header title localization",
          "status": "COMPLETED"
        },
        {
          "id": 6,
          "task": "Individual story share button with Web Share API and clipboard fallback",
          "status": "COMPLETED"
        }
      ],

      "sorting": {
        "status": "DEFERRED",
        "instruction": "Ignore sorting for now."
      }
    },

    "current_navigation_flow": {
      "default_url": "Notebook cover -> Intro page -> Index (TOC) -> Story list",
      "shared_link_url": "Intended shared story -> Intro page -> Index (TOC) -> Remaining stories",
      "desktop_spread": "Index 0: Shared Story, Index 1: Blank, Index 2: Intro, Index 3: TOC, Index 4+: Remaining stories",
      "mobile_spread": "Index 0: Shared Story, Index 1: Intro, Index 2: TOC, Index 3+: Remaining stories"
    },

    "intro": {
      "status": "WORKING",
      "source_language": "en",
      "document_path": "stories/Intro",
      "header_localization": "Intro titles ('Preface & Purpose' / 'The Scribe's Archive') localized via INTRO_TITLES for en, es, ja, zh, uz.",
      "writing_mode": {
        "intro": "always horizontal-tb",
        "intro_firestore_translation_objects": "do not include writingMode"
      },
      "translation_behavior": {
        "if_language_exists": "return Firestore translation without Gemini",
        "if_language_is_en": "return Intro.en",
        "if_language_missing": "call secure Firebase Cloud Function generateIntroTranslation"
      }
    },

    "story_sharing_and_routing": {
      "status": "COMPLETED",
      "url_structure": "/story/{storyId}",
      "browser_history": "pushState on story select, reset to '/' on close, listener on popstate",
      "share_button": "StoryShareButton component in FullScreenStory header with Web Share API and clipboard fallback",
      "firebase_hosting": "** -> /index.html rewrite"
    },

    "next_session_priority": [
      "Task 3: Implement lazy translation behavior (title/country metadata at index level, full story text on open).",
      "Task 4: Implement translation loading animation / UI showing translation process."
    ],

    "do_not_focus_on_yet": [
      "story sorting by timestamp or country",
      "subdomains",
      "new authentication",
      "new cover generation architecture"
    ]
  }
}
