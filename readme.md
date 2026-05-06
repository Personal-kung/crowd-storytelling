# Crowd Storytelling

This is a beautiful blend of the digital and the tactile. You’re essentially building a "Digital-to-Analog Bridge" that preserves the intimacy of handwriting while solving the logistical nightmare of shipping a single physical book around the world.

Here is a blueprint for the hardware and software stack required to bring this global notebook to life.

---

## Project Structure

This repository contains the following main components:

- **`subssion_tool/`**: The Submission Platform (Flutter). Where users write or submit their stories.
- **`curation_dashboard/`**: The Curation Dashboard (Flutter). A control center to manage the queue of submitted stories.
- **`virtual notebook/`**: A Virtual Notebook (React/Vite). A digital way to view the crowd-sourced stories online.
- **`hardware/`**: Contains information or scripts related to the mechanical scribe (AxiDraw/Plotter).

---

## 1. The Submission Platform (`subssion_tool`)

To capture handwriting digitally, you need a web interface that prioritizes **SVG (Scalable Vector Graphics)** data rather than just flat images.

- **Frontend:** A **Flutter** application.
- **The "Ink" Engine:** Uses libraries like `signature` to allow users to write on their touchscreens (tablets/phones) and saves the coordinates of their pen strokes.
- **Handwriting Capture:**
  - _Digital Native:_ Users write directly on the screen.
  - _Analog Upload:_ Users write on paper, take a photo (`image_picker`), and you use **Handwriting Recognition (OCR)** to convert it or use the image for tracing.

## 2. The Curation Dashboard (`curation_dashboard`)

You need a control center to manage the queue.

- **Platform:** A private web dashboard and mobile app built in **Flutter**, powered by **Firebase** for real-time updates.
- **Features:**
  - **The Queue:** A list of "Pending," "Approved," and "Inscribed" (already written) stories.
  - **Edit Mode:** A simple text editor to fix typos before the "robotic" phase begins.
  - **Layout Preview:** A virtual "Notebook View" that shows you exactly how the text will fit on the physical page based on the dimensions of your current book.

## 3. The Virtual Notebook (`virtual notebook`)

A digital counterpart to the physical book.

- **Tech Stack:** React, Vite, TailwindCSS, Motion, Firebase, and Gemini API.
- **Purpose:** Allows users from around the world to view the collection of stories in a beautiful, interactive digital format.

## 4. The Hardware (The Mechanical Scribe)

This is the most critical piece: a machine that holds a real pen and writes on real paper.

### The Machine: The AxiDraw (or DIY Pen Plotter)

The industry standard for this is a **Pen Plotter**.

- **Recommendation:** The **AxiDraw V3**. It is a high-precision robotic arm that can hold any fountain pen, ballpoint, or marker.
- **Flexibility:** It is "open-frame," meaning you can place it over a notebook, a whiteboard, or a piece of wood. It doesn't care about the thickness of the surface.

### The Software: Inkscape + Hershey Text

To turn a user's story into a pen movement, you need:

1. **Vector Conversion:** A script that takes the approved story and converts it into G-code (the language of CNC machines).
2. **Handwriting Replication:**
    - If the user wrote on a screen, the machine simply replays their stroke coordinates.
    - If the user typed their story, you can use **"Single Line Fonts" (Hershey Fonts)** which look like real handwriting rather than computer-generated "bubble" letters.
3. **Custom Font Generation:** You can use a service like **Calligraphr** to turn your own handwriting (or a user's) into a font file that the plotter can use.

---

### Technical Workflow Summary

|**Step**|**Action**|**Tool**|
|---|---|---|
|**1**|User writes/types story|`subssion_tool` (Flutter)|
|**2**|System checks grammar/transcribes|OpenAI API / Google Vision|
|**3**|You review and click "Approve"|`curation_dashboard` (Flutter)|
|**4**|Story is sent to the plotter|Raspberry Pi (connected to AxiDraw)|
|**5**|The Machine writes in the book|AxiDraw + Lamy Fountain Pen|
|**6**|View digital collection|`virtual notebook` (React)|
