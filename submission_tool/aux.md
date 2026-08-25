
```json
{
  "schema_version": "1.0",
  "generated_at": "2026-08-23T13:39:00Z",
  "project": {
    "name": "subssion_tool",
    "root": "/home/ubuntu/Desktop/crowd-storytelling/submission_tool",
    "description": "The Submission Tool is the user-facing entry point for the Crowd Storytelling project. It captures stories and digitizes them.",
    "languages": [
      "Dart"
    ],
    "frameworks": [
      "Flutter"
    ],
    "runtime": [
      "Flutter Engine"
    ],
    "package_managers": [
      "pub"
    ],
    "entrypoints": [
      "lib/main.dart"
    ],
    "architecture": {
      "client": "Flutter application",
      "backend": "Firebase Firestore and Storage",
      "external_apis": [
        "Google Vision API"
      ]
    }
  },
  "scope": {
    "directory_only": true,
    "allowed_root": "/home/ubuntu/Desktop/crowd-storytelling/submission_tool",
    "parent_directories_allowed": false,
    "external_repositories_allowed": false,
    "unknown_information_policy": "Treat as unknown rather than inventing."
  },
  "repository": {
    "tree": [
      "lib/",
      "lib/main.dart",
      "lib/firebase_options.dart",
      "pubspec.yaml",
      "README.md",
      "firebase.json",
      "analysis_options.yaml",
      "android/",
      "ios/",
      "web/",
      "macos/",
      "linux/",
      "windows/"
    ],
    "files": [
      "lib/main.dart",
      "lib/firebase_options.dart",
      "pubspec.yaml",
      "README.md",
      "firebase.json",
      "analysis_options.yaml"
    ],
    "configuration": [
      "pubspec.yaml",
      "firebase.json",
      "analysis_options.yaml"
    ],
    "dependencies": [
      {
        "name": "flutter",
        "version": "sdk",
        "purpose": "UI Framework",
        "runtime": true,
        "development": false,
        "llm_relevant": true
      },
      {
        "name": "signature",
        "version": "^5.5.0",
        "purpose": "Handwriting capture",
        "runtime": true,
        "development": false,
        "llm_relevant": false
      },
      {
        "name": "image_picker",
        "version": "^1.0.7",
        "purpose": "Photo uploads",
        "runtime": true,
        "development": false,
        "llm_relevant": false
      },
      {
        "name": "file_picker",
        "version": "^8.0.0",
        "purpose": "Font sample uploads",
        "runtime": true,
        "development": false,
        "llm_relevant": false
      },
      {
        "name": "google_fonts",
        "version": "^6.2.1",
        "purpose": "Text preview formatting",
        "runtime": true,
        "development": false,
        "llm_relevant": false
      },
      {
        "name": "firebase_core",
        "version": "^3.0.0",
        "purpose": "Firebase core SDK",
        "runtime": true,
        "development": false,
        "llm_relevant": true
      },
      {
        "name": "cloud_firestore",
        "version": "^5.0.0",
        "purpose": "Database for storing stories",
        "runtime": true,
        "development": false,
        "llm_relevant": true
      },
      {
        "name": "firebase_storage",
        "version": "^12.0.0",
        "purpose": "Asset storage",
        "runtime": true,
        "development": false,
        "llm_relevant": true
      },
      {
        "name": "http",
        "version": "^1.1.0",
        "purpose": "Network requests for Google Vision API",
        "runtime": true,
        "development": false,
        "llm_relevant": true
      },
      {
        "name": "flutter_dotenv",
        "version": "^5.1.0",
        "purpose": "Environment variable loading",
        "runtime": true,
        "development": false,
        "llm_relevant": true
      }
    ],
    "scripts": []
  },
  "runtime": {
    "start_commands": [
      "flutter run"
    ],
    "build_commands": [
      "flutter build"
    ],
    "test_commands": [
      "flutter test"
    ],
    "development_commands": [
      "flutter pub get"
    ],
    "environment_variables": [
      {
        "name": "GOOGLE_VISION_API_KEY",
        "required": true,
        "referenced_in": "lib/main.dart",
        "controls": "OCR processing capability via Google Vision API"
      }
    ]
  },
  "capabilities": {
    "filesystem": {},
    "network": {
      "outbound_connections": [
        "vision.googleapis.com",
        "firebaseapp.com",
        "firebasestorage.app"
      ]
    },
    "database": {
      "writes": [
        "Firestore 'stories' collection"
      ]
    },
    "process_execution": {},
    "git": {},
    "llm": {}
  },
  "tools": [],
  "functions": [
    {
      "name": "_submitStory",
      "fully_qualified_name": "_SubmissionPlatformState._submitStory",
      "source": "lib/main.dart",
      "exported": false,
      "parameters": [],
      "return_type": "Future<void>",
      "description": "Reads user input, calls Google Vision API for OCR on images, and writes the resulting story document to Firestore.",
      "side_effects": [
        "Network request to Vision API",
        "Database write to Firestore 'stories' collection",
        "UI navigation and dialogs"
      ],
      "calls": [
        "http.post",
        "FirebaseFirestore.instance.collection('stories').doc().set"
      ],
      "called_by": [
        "Stepper.onStepContinue"
      ],
      "llm_exposable": false,
      "reason": "It relies heavily on UI state (_storyController, _nameController, _pickedImage) and BuildContext, and is not designed as a standalone headless function."
    }
  ],
  "commands": [
    {
      "name": "Install Dependencies",
      "command": "flutter pub get",
      "source": "README.md",
      "purpose": "Installs the Dart/Flutter packages specified in pubspec.yaml.",
      "platform": [
        "All"
      ],
      "side_effects": [
        "Downloads files to local package cache",
        "Modifies pubspec.lock"
      ],
      "destructive": false,
      "requires_confirmation": false
    },
    {
      "name": "Run Application",
      "command": "flutter run",
      "source": "README.md",
      "purpose": "Compiles and starts the Flutter application on an available device/emulator.",
      "platform": [
        "All"
      ],
      "side_effects": [
        "Builds artifacts",
        "Executes application process"
      ],
      "destructive": false,
      "requires_confirmation": false
    }
  ],
  "schemas": {
    "tool_call": {
      "$schema": "https://json-schema.org/draft/2020-12/schema",
      "title": "LLM Tool Call",
      "type": "object",
      "required": [
        "tool",
        "arguments"
      ],
      "properties": {
        "tool": {
          "type": "string"
        },
        "arguments": {
          "type": "object"
        }
      },
      "additionalProperties": false
    },
    "tool_result": {
      "$schema": "https://json-schema.org/draft/2020-12/schema",
      "title": "LLM Tool Result",
      "type": "object",
      "properties": {
        "success": {
          "type": "boolean"
        },
        "result": {
          "type": "object"
        },
        "error": {
          "type": "string"
        },
        "metadata": {
          "type": "object"
        }
      },
      "required": [
        "success"
      ]
    },
    "error": {}
  },
  "security": {
    "secrets": {
      "GOOGLE_VISION_API_KEY": "Expected to be located in a local .env file. Do not expose.",
      "FIREBASE_API_KEYS": "Present in lib/firebase_options.dart. Treat as credentials and do not output."
    },
    "dangerous_operations": [
      "Firestore document creation via lib/main.dart",
      "External API calls to vision.googleapis.com"
    ],
    "confirmation_required": [],
    "sandbox_requirements": []
  },
  "llm_instructions": {
    "system_context": "You are assisting with a Flutter Dart application named 'subssion_tool'. The app integrates with Firebase and Google Vision API.",
    "operating_rules": [
      "operate only within the declared project root",
      "never assume unavailable capabilities",
      "never invent tool names",
      "never invent function parameters",
      "validate tool arguments against schemas",
      "prefer read-only operations when possible",
      "request confirmation before destructive operations",
      "never expose secrets",
      "never modify files unless the requested operation requires it",
      "never access files outside the project root"
    ],
    "tool_selection_rules": [
      "use the most specific available tool",
      "avoid unnecessary tool calls"
    ],
    "reasoning_rules": [
      "inspect relevant project files before making architectural claims",
      "distinguish repository facts from assumptions",
      "treat unknown information as unknown",
      "preserve existing project conventions"
    ],
    "error_handling": [
      "report tool errors faithfully",
      "follow existing validation and error-handling mechanisms"
    ],
    "unknown_information_policy": [
      "If something cannot be verified from the current directory, mark it as unknown rather than inventing it."
    ],
    "security_rules": [
      "Never output API keys, passwords, tokens, private keys, cookies, credentials, secrets, or personal authentication material."
    ]
  },
  "examples": [],
  "limitations": [
    "The project currently has no backend headless commands or LLM-callable functions. Functionality is tightly coupled to Flutter UI elements."
  ],
  "evidence": [
    {
      "file": "pubspec.yaml",
      "symbol": "name",
      "evidence_type": "configuration",
      "details": "Project name is declared as 'subssion_tool'."
    },
    {
      "file": "lib/main.dart",
      "symbol": "_submitStory",
      "evidence_type": "implementation",
      "details": "Function directly accesses HTTP client to call vision.googleapis.com and uses cloud_firestore to mutate 'stories' collection."
    },
    {
      "file": "lib/firebase_options.dart",
      "symbol": "DefaultFirebaseOptions",
      "evidence_type": "implementation",
      "details": "Defines project ID 'global-notebook' and contains configuration for Android, iOS, Web, MacOS, and Windows."
    }
  ]
}
```
