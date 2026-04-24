# curation_dashboard

The **Curation Dashboard** is the administrative heart of the Crowd Storytelling project. It serves as the "Digital-to-Analog Bridge," allowing editors to manage digital submissions before they are physically transcribed by the robotic pen plotter.

## Core Features

*   **Status-Based Queue:** Manage stories through *Pending*, *Approved*, and *Inscribed* states.
*   **Interactive Editor:** Refine user-submitted text and correct typos before the permanent inscription phase.
*   **Layout Previewer:** A virtual "Notebook View" to visualize text placement and margins relative to the physical book's dimensions.
*   **Real-time Synchronization:** Powered by Firebase to push approved tasks to the robotic scribe (AxiDraw) in real-time.

## Technical Stack

*   **Framework:** [Flutter](https://flutter.dev) (Web & Android)
*   **Backend:** Firebase Realtime Database / Firestore
*   **Integrations:** 
    *   **Grammar:** OpenAI / LanguageTool API.
    *   **Hardware:** Raspberry Pi + AxiDraw V3 Pen Plotter.

## Getting Started

### Prerequisites
*   Flutter SDK (Latest stable version).
*   Firebase project credentials (`google-services.json` for Android or Web configuration).

### Installation
1.  Clone the repository.
2.  Install dependencies:
    ```bash
    flutter pub get
    ```
3.  Run the application:
    ```bash
    flutter run -d chrome
    ```
