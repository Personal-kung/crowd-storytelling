1. Remaining localization/translation tasks

From this session:

Story metadata localization
Batch title transcreation.
Per-story sourceLanguage.
Localized country via ISO code/Intl.DisplayNames, Gemini fallback if necessary.
Store under translations.{language}.
Existing translations remain authoritative.
Failed translations logged and retried on the next request.
Only metadata; no story content yet.
Full story translation
Translate only when the user actually opens the story.
Store transcreated_content.
Do not prematurely translate all stories.
Dedicated diegetic translation/loading state.
User sees the loading state rather than the source-language story while translation is generated.
Translation loading UX
Refine/complete the loading experiences for the relevant translation operations.
2. Story sharing button

After individual-story URL sharing is working:

Add a Share button to each story.

The button should use the story's Firebase document ID to construct the canonical public URL:

/current-global-url/story/{firebaseStoryId}

We haven't designed the exact UI/behavior yet, so that should be a small Q&A when we get there—e.g. native Web Share API vs copy-link fallback, placement, confirmation animation, etc.


# nex session prompt
{
  "handoff": {
    "session_date": "2026-08-15",
    "purpose": "Continue development of Virtual Notebook without repeating previously answered architectural questions.",
    "instruction_to_next_llm": {
      "mode": "implementation-focused",
      "do_not_repeat_questions": true,
      "read_all_decisions_before_asking_any_question": true,
      "ask_only_if_information_is genuinely_missing_or_conflicting": true,
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
        "entrypoint": "src/App.tsx"
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
          "task": "Individual story sharing using Firebase Story document ID",
          "status": "IMPLEMENTED_IN_PREVIOUS_SESSION",
          "note": "Was completed with Antigravity IDE. Verify only if necessary; do not redesign without evidence of a problem."
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
          "task": "Intro page",
          "status": "COMPLETED"
        }
      ],

      "future_task": {
        "id": 6,
        "task": "Add a sharing button to each story",
        "status": "PENDING_FUTURE_SESSION"
      },

      "sorting": {
        "status": "DEFERRED",
        "instruction": "Ignore sorting for now."
      }
    },

    "current_navigation_flow": {
      "required": "cover -> intro -> story index -> story",
      "previous": "cover -> index -> story",
      "sorting": "Ignore for now."
    },

    "intro": {
      "status": "WORKING",
      "source_language": "en",
      "document_path": "stories/Intro",
      "format": "formatted multi-paragraph document",
      "paragraph_count": "variable; preserve exact source structure",
      "important": [
        "Intro is not limited to 3 paragraphs.",
        "The current English Intro contains many paragraphs and a four-item numbered list.",
        "Translation must preserve paragraph structure.",
        "Translation must preserve blank lines.",
        "Translation must preserve numbered sections 1, 2, 3, 4.",
        "Translation must preserve Markdown bold formatting such as **1. Your name**.",
        "Translation must not merge the source into one continuous paragraph.",
        "Translation must not summarize or remove content.",
        "Translation must preserve expressive elements such as XD where appropriate.",
        "Intro translations have no writingMode field."
      ],

      "writing_mode": {
        "intro": "always horizontal-tb",
        "intro_firestore_translation_objects": "do not include writingMode"
      },

      "translation_behavior": {
        "if_language_exists": "return Firestore translation without Gemini",
        "if_language_is_en": "return Intro.en",
        "if_language_missing": "call secure Firebase Cloud Function",
        "cloud_function": "generateIntroTranslation",
        "function_reads": "stories/Intro",
        "function_source": "stories/Intro.en",
        "function_writes": "stories/Intro.{language}",
        "api_key": "Firebase Secret GEMINI_API_KEY only",
        "client_must_never_access_gemini_api_key": true
      },

      "frontend_service": {
        "file": "src/services/introService.ts",
        "responsibility": "Read Intro translations from Firestore and request missing translations through the secure callable function.",
        "important": "No GEMINI_API_KEY is read by introService.ts."
      },

      "ai_content_service": {
        "file": "src/services/aiContentService.ts",
        "intro_callable": "ensureIntroTranslation(language)",
        "callable_function": "generateIntroTranslation"
      }
    },

    "intro_cloud_function": {
      "file": "functions/src/index.ts",
      "function": "generateIntroTranslation",
      "trigger": "Firebase Functions Gen 2 callable",
      "secret": "GEMINI_API_KEY",
      "model": "gemini-3-flash-preview",
      "database": "Firebase Admin Firestore",
      "document": "stories/Intro",
      "behavior": [
        "Validate language.",
        "Read stories/Intro.",
        "Return existing language field if present.",
        "Use Intro.en as canonical source.",
        "Do not call Gemini for English.",
        "Use GEMINI_API_KEY from Firebase Secret Manager.",
        "Generate culturally-aware transcreation.",
        "Preserve exact source document structure.",
        "Save translation to the language field.",
        "Return translation.",
        "Do not save writingMode."
      ]
    },

    "intro_translation_prompt_requirements": {
      "must_preserve": [
        "meaning",
        "emotional nuance",
        "poetic/reflection tone",
        "paragraph structure",
        "blank lines",
        "numbered list structure",
        "four numbered sections",
        "Markdown formatting",
        "expressive elements",
        "all source information"
      ],
      "must_not": [
        "merge paragraphs",
        "summarize",
        "remove information",
        "add information",
        "add commentary",
        "add title",
        "add translator notes",
        "wrap result in quotation marks"
      ],
      "output": "translated text only"
    },

    "story_firestore_model": {
      "collection": "stories",
      "fields": {
        "ISOcode": "string",
        "country": "string",
        "coverImage": {
          "generatedAt": "optional",
          "path": "string"
        },
        "name": "author name",
        "sourceLanguage": "string",
        "status": "approved | pending | potentially useful Gemini failure/log status",
        "text_content": "string",
        "timestamp": "optional",
        "title": "optional",
        "writingMode": "horizontal-tb | vertical-rl",
        "translations": {
          "<languageCode>": {
            "localizedCountry": "localized country name",
            "transcreatedTitle": "localized/culturally-aware title",
            "transcreated_content": "full translated/transcreated story content",
            "writingMode": "horizontal-tb | vertical-rl"
          }
        }
      }
    },

    "story_translation_decisions": {
      "sourceLanguage": {
        "important": "Varies by story.",
        "known_values_so_far": [
          "ja",
          "es",
          "en",
          "zh",
          "uz"
        ],
        "instruction": "Read the story sourceLanguage field and use it to determine the source writing mode / translation context."
      },

      "writingMode": {
        "important": "Writing mode must correspond to the sourceLanguage/content when reading source information.",
        "values": [
          "horizontal-tb",
          "vertical-rl"
        ],
        "east_asian_example": "Japanese/East Asian text can use vertical-rl.",
        "western_example": "Western languages generally use horizontal-tb."
      },

      "ISOcode": {
        "purpose": "Used for country flag emoji/data.",
        "not_translation_field": true,
        "instruction": "Do not translate or replace ISOcode as part of localized translation metadata."
      },

      "localizedCountry": {
        "purpose": "Country name translated/localized into target language.",
        "requirement": "Always ensure localizedCountry exists when generating story metadata translation."
      },

      "title_translation": {
        "requirement": "Use culturally-aware transcreation rather than literal word-for-word translation."
      },

      "api_efficiency": {
        "requirement": "Prefer the implementation that minimizes Gemini API calls.",
        "accepted_behavior": "Batch generation of all currently untranslated story titles/metadata for a target language is preferred over one Gemini request per story when practical.",
        "expected_scale": "Tens of untranslated stories over the next year."
      }
    },

    "story_lazy_translation": {
      "desired_behavior": {
        "new_language_story_index": [
          "Detect user's/browser target language.",
          "Load stories.",
          "For stories missing that language translation, generate only localized title and localized country metadata.",
          "Persist those fields to Firestore.",
          "Do NOT translate full text_content at index-loading time."
        ],
        "story_open": [
          "When user opens an individual story, check whether full transcreated_content exists for target language.",
          "If missing, generate the full story translation at that moment.",
          "Persist it to Firestore.",
          "Then display the story."
        ]
      },
      "important": "Text content and AI cover image generation are not part of the initial title-only batch translation operation."
    },

    "story_sharing": {
      "status": "Implemented previously",
      "architecture": "Use Firebase Firestore story document ID to address/share an individual story.",
      "url": "Project currently has one public global URL only.",
      "subdomains": "None.",
      "authentication": "Not required; public access.",
      "required_behavior": "A shared story URL should resolve directly to that specific Firebase story ID.",
      "error_handling": "It should never normally present a 'story not found' experience for a valid shared story link."
    },

    "cover_image": {
      "status": "Existing functionality",
      "implementation_location": "admin_submission project",
      "frontend_reference": "src/services/storyService.ts / src/services/aiContentService.ts",
      "instruction": "Do not duplicate the admin_submission cover generation function into Virtual Notebook unless explicitly required."
    },

    "existing_admin_submission_functions": {
      "location": "/home/crowd-storytelling/admin_submission/functions/src/index.ts",
      "functions": [
        "processStoryOCR",
        "onStoryPublished",
        "generateTranslation",
        "generateCoverImage",
        "listGeminiModels"
      ],
      "important": "These are existing working functions in a different project directory. Do not confuse them with virtual notebook/functions."
    },

    "virtual_notebook_functions": {
      "location": "/home/crowd-storytelling/virtual notebook/functions/src/index.ts",
      "current_function": "generateIntroTranslation",
      "purpose": "Secure Intro translation using Firebase Secret Manager."
    },

    "firebase_security": {
      "general": "Firestore and Storage security rules exist.",
      "story_access": "Approved stories are intended to be readable.",
      "cover_access": "Public access is restricted to cover-art paths as configured.",
      "instruction": "Do not weaken security rules simply to make a frontend feature work."
    },

    "frontend_components": {
      "Notebook": {
        "file": "src/components/Notebook.tsx",
        "responsibilities": [
          "flip-book",
          "desktop dual-page presentation",
          "mobile single-page presentation",
          "TOC/story index",
          "story reader",
          "intro page",
          "navigation"
        ]
      },
      "JITImage": "Lazy-loading image component using Intersection Observer.",
      "DynamicFlag": "Converts ISO country codes to native flag emojis."
    },

    "other_services": {
      "storyService": "Firestore story querying, Storage cover resolution, missing asset handling.",
      "aiContentService": "Callable Firebase functions for story translation and cover generation plus Intro translation.",
      "transcreationService": "Client-side Gemini-related transcreation functionality; do not expose secrets.",
      "translationStorageService": "Persists generated story translations.",
      "languageService": "Browser language detection and localized content fallback.",
      "HeartbeatService": "Reader interaction telemetry.",
      "countryService": "Country flag/CDN and ISO-to-emoji handling."
    },

    "important_previous_decisions": [
      "No login is required for public notebook access.",
      "There are currently no subdomains.",
      "The public URL is global.",
      "The cover must be followed by the Intro before the story index.",
      "The Intro is a two-page-wide presentation on desktop.",
      "The Intro is not two separate notebook pages on desktop.",
      "Intro content must come from Firestore, not a hardcoded frontend constant.",
      "Intro translations must be stored back into Firestore.",
      "Intro is always horizontal-tb.",
      "Intro does not have a writingMode field.",
      "English is the canonical Intro source language.",
      "Story source languages vary.",
      "ISOcode is for flag handling, not translation.",
      "Localized country name must always be generated/ensured.",
      "Minimize Gemini API calls.",
      "Do not implement sorting yet.",
      "The user expects tens of untranslated stories over the next year.",
      "Do not redo completed functionality unless a bug is demonstrated."
    ],

    "deployment": {
      "frontend": {
        "build": "npm run build",
        "deploy": "firebase deploy --only hosting",
        "hosting_source": "dist"
      },
      "intro_function": {
        "build": "cd functions && npm run build",
        "deploy": "firebase deploy --only functions:generateIntroTranslation"
      },
      "important": "Do not redeploy admin_submission functions from the Virtual Notebook directory."
    },

    "recent_build_fix": {
      "problem": "@google/genai node declarations required @modelcontextprotocol/sdk.",
      "solution": "Installed @modelcontextprotocol/sdk in virtual notebook/functions.",
      "status": "Build now succeeds."
    },

    "next_session_priority": [
      "Finish remaining story translation tasks.",
      "Implement title/country-only translation behavior for new languages.",
      "Implement full story translation only when story is opened.",
      "Add/verify translation loading animation.",
      "Verify individual story sharing using Firebase story ID.",
      "Only after these are stable, consider adding sharing button to each story."
    ],

    "do_not_focus_on_yet": [
      "story sorting by timestamp",
      "sorting by country",
      "sorting by other metadata",
      "subdomains",
      "new authentication",
      "new cover generation architecture"
    ]
  }
}