# Virtual Notebook — Global Crowd Storytelling Platform

![portrait](./media/2026-08-14%2016.20.32%20global-notebook.web.app%208de204cbc2a5.jpg)
![index](./media/2026-08-14%2016.20.42%20global-notebook.web.app%2068a4d29430cc.jpg)

**Virtual Notebook** is an interactive, digital crowd-storytelling application designed to archive, preserve, and transcreate ancestral and contemporary human stories from around the globe. Operating as a living digital ledger of cultural heritage, the platform connects readers and storytellers across linguistic and geographical divides.

---

## 🌟 Core Features & Functionalities

- **📖 Interactive Flip-Book Interface**: Realistic diegetic book reading experience powered by Framer Motion (`motion/react`), complete with paper grain texture, smooth page flips, dual light/dark parchment themes, and silk ribbon bookmark navigation.
- **📱 Adaptive Layout Architecture**: Responsive split-screen desktop dual-page spread and single-page mobile layout with bottom bar navigation and touch-optimized gestures.
- **🌏 AI-Powered Transcreation Engine**: Cultural transcreation using Google's Gemini 3 Flash API (`@google/genai` & Firebase Cloud Functions). Preserves emotional tone, cultural context, localized titles, and translates country names rather than performing literal word-for-word translation.
- **🎌 Vertical & Horizontal Writing Modes**: Supports traditional Japanese/East Asian vertical right-to-left (`vertical-rl`) reading direction alongside standard horizontal left-to-right (`horizontal-tb`) text flows.
- **🖼️ Automated Cover Image Generation & Cloud Storage**: Dynamically generates cover images via AI for approved stories, serving images via Firebase Cloud Storage with JIT lazy-loading blur placeholders (`react-intersection-observer`).
- **💓 Diegetic Engagement Tracking (`HeartbeatService`)**: Built-in engagement telemetry system tracking reader cadences, tactile hovers, page flips, and long-press interactions.
- **🔒 Secure Cloud Infrastructure**: Firebase Firestore database with role-based security rules (public reads restricted to `approved` stories) and Firebase Storage security rules for cover art assets.

---

## 🏗️ Tech Stack

| Layer | Technologies |
| --- | --- |
| **Frontend Framework** | React 19, TypeScript, Vite 6 |
| **Styling & Motion** | Tailwind CSS v4, Motion (Framer Motion v12), Lucide React Icons |
| **AI Integration** | Google GenAI SDK (`@google/genai`), Gemini 3 Flash (`gemini-3-flash-preview`) |
| **Backend & Database** | Firebase Cloud Firestore, Firebase Cloud Storage, Firebase Hosting |
| **Serverless Compute** | Firebase Cloud Functions (2nd Gen, Node.js TypeScript runtime) |
| **Performance & UI** | `react-intersection-observer`, Tailwind Merge, Clsx |

---

## 📁 Repository Structure & Module Breakdown

```
virtual notebook/
├── .devcontainer/           # Containerized development configuration (Vite, TS, Firebase CLI)
├── firebase-applet-config.json # Firebase Web App SDK credentials & bucket settings
├── firebase.json            # Firebase project deployment settings (Hosting, Firestore, Functions)
├── firestore.rules          # Firestore database security rules
├── storage.rules            # Firebase Storage access rules for cover images
├── functions/               # 2nd Gen Cloud Functions source code
│   └── src/index.ts         # Firebase HTTPS callable functions configuration
└── src/
    ├── App.tsx              # Main application entry, story fetching, theme & page state
    ├── main.tsx             # React DOM root render
    ├── index.css            # Global Parchment styling, paper grain, custom scrollbars
    ├── types.ts             # TypeScript interfaces (Story, StoryTranslation, CoverImage, etc.)
    ├── constants.ts         # Initial offline sample stories dataset
    ├── firebase.ts          # Firebase SDK initialization (App, Firestore, Storage, Functions)
    ├── components/
    │   └── Notebook.tsx     # Flip-book UI component, JIT image lazy loader, FullScreenStory reader
    └── services/
        ├── aiContentService.ts          # Cloud function triggers (ensureTranslation, ensureCoverImage)
        ├── countryService.ts            # Country ISO code to emoji conversion & flag URL resolution
        ├── HeartbeatService.ts          # Tactile reader interaction & telemetry logger
        ├── languageService.ts           # Browser language detection & fallback content resolution
        ├── storyService.ts              # Firestore query for approved stories & cover URL resolver
        ├── transcreationService.ts      # Direct Gemini API prompt transcreation service
        └── translationStorageService.ts # Firestore update service for persisting transcreations
```

---

## 🔄 Data Architecture & Processing Flow

```
+-------------------+        1. getApprovedStories()        +---------------------+
|                   |  ---------------------------------->  |  Firebase Firestore |
|   React Notebook  |                                       |  (stories/approved) |
|     Application   |  <----------------------------------  +---------------------+
|                   |        2. Story Documents & Metadata
+---------+---------+
          |
          | 3. ensureStoryAssets() (Trigger missing translation / cover art)
          v
+-------------------+       4. HTTPS Callable               +---------------------+
| Firebase Cloud    |  ---------------------------------->  |  Google Gemini API  |
| Functions 2nd Gen |                                       |  (Transcreate/Img)  |
+---------+---------+  <----------------------------------  +---------------------+
          |                 5. Transcreated Output
          |
          v
+-------------------------------------------------------+
|  Firebase Storage (global-notebook.firebasestorage.app)|
|  covers/{storyId}.png                                 |
+-------------------------------------------------------+
```

---

## 🚀 Development & Deployment

### 1. Prerequisites

- Node.js (v18+)
- npm or yarn
- Firebase CLI (`npm install -g firebase-tools`)

### 2. Running Locally

```bash
# Install dependencies
npm install

# Start local dev server (port 3000)
npm run dev
```

### 3. Deploying to Firebase Hosting & Cloud Functions

```bash
# Build production bundle
npm run build

# Deploy to Firebase Hosting & Functions
firebase deploy
```
