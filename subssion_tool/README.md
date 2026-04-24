# subssion_tool

The **Submission Tool** is the user-facing entry point for the Crowd Storytelling project. Known as "The Gateway," it captures stories from around the world and digitizes them for the physical book.

## Core Features

*   **Digital Ink Engine:** A responsive canvas for capturing handwriting strokes as vector data (SVG), preserving personal style for the plotter.
*   **OCR Scanning:** Camera integration to convert physical handwriting into digital text using Google Vision AI.
*   **AI Refinement:** Built-in translation and grammar checking via OpenAI and Google Cloud APIs.
*   **Hybrid Input:** Supports both digital-native stylus input and traditional typing (converted to single-line fonts).

## Technical Stack

*   **Framework:** [Flutter](https://flutter.dev) (Web, Android, & Linux)
*   **Data Capture:** Signature Pad / Custom Vector Canvas
*   **Backend:** Firebase (Realtime Database & Storage)
*   **APIs:** 
    *   Google Vision AI (OCR)
    *   Google Cloud Translation
    *   OpenAI (Grammar & Stylizing)

## Getting Started

### Prerequisites
*   Flutter SDK.
*   Active API keys for Google Cloud and OpenAI (configured in `.env` or Firebase Remote Config).

### Installation
1.  Clone the repository.
2.  Install dependencies:
    ```bash
    flutter pub get
    ```
3.  Run the application:
    ```bash
    flutter run
    ```
