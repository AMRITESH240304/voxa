# Voxa - Voice Identity Authentication App

Voxa is a multi-platform Flutter application that provides secure voice-based identity verification.

## Overview

This application allows users to authenticate using their voice through a user-friendly interface with animated visualizations. The app captures voice samples, processes them for verification, and provides real-time feedback through interactive UI elements.

## Features

- **Voice Sample Recording**: High-quality audio recording with proper permissions handling
- **Animated UI**: Engaging bubble animations during the voice collection process
- **Real-time Feedback**: Visual waveform display during recording
- **Cross-platform Support**: Works on iOS, Android, Web, macOS, Windows and Linux
- **Microphone Permission Handling**: Seamless permission requests on all platforms

## Technology Stack

- **Frontend**: Flutter (Dart)
- **Audio Processing**: `record` package for cross-platform recording capability
- **Animations**: Custom animations and Lottie for enhanced visual experience
- **Permission Management**: Using `permission_handler` for microphone access
- **Storage**: Local path management with `path_provider`

## Project Structure

The project is divided into two main parts: `frontend` (Flutter application) and `backend` (Python FastAPI server).

### Frontend (`/frontend`)

The frontend is a Flutter application responsible for the user interface, voice recording, and interaction with the backend.

**Key Features & Logic:**

*   **Voice Sample Collection (`BubblePage`):**
    *   Users record 5 voice samples.
    *   Engaging UI with custom bubble animations that react to the recording process. Bubbles fill "storage cans" visually representing collected samples.
    *   A pulsing animation on the microphone icon indicates readiness.
    *   The microphone icon changes to a GIF during recording.
    *   If a voice sample is rejected by the backend (e.g., too dissimilar from previous ones), a "burst" animation is shown.
    *   Displays instructional text for each voice sample.
*   **Real-time Feedback:**
    *   Visual waveform display during audio recording using the `audio_waveforms` package.
*   **Success Indication (`SuccessPage`):**
    *   Shown after successful creation of the voice identity and DID.
    *   Displays a Lottie animation for success.
    *   Shows the user's newly created DID.
    *   Provides an option to navigate to the voice verification page.
*   **Voice Verification (`VerifyPage`):**
    *   Allows users to verify their voice against their stored voiceprint.
*   **Loading States:**
    *   Uses Lottie animations for loading indicators during backend communication (e.g., while creating DID).
*   **State Management:**
    *   Utilizes `ChangeNotifier` and `ViewModel` pattern (`BubblePageViewModel`) for managing UI state and business logic related to voice recording, animation control, and backend communication.
*   **Backend Communication (`VoiceService`):**
    *   Handles HTTP requests to the backend API endpoints for collecting voice samples, creating keys, creating DIDs, and verifying voice.
*   **Error Handling:**
    *   Displays dialogs for errors encountered during API calls or other processes.

**Technology Stack (Frontend):**

*   **Framework:** Flutter (Dart)
*   **Audio Recording:** `record` package
*   **Waveform Visualization:** `audio_waveforms` package
*   **Animations:**
    *   Custom Flutter animations (bubbles, lids, transitions)
    *   Lottie (`lottie` package) for complex vector animations (loading, success)
*   **HTTP Client:** `http` package
*   **Permissions:** `permission_handler` (for microphone access)
*   **Local Storage:** `path_provider` (for temporary storage of audio files)
*   **UUID Generation:** `uuid` package

### Backend (`/backend`)

The backend is a Python application built with FastAPI, responsible for processing voice data, managing user embeddings, and interacting with the cheqd network for DID creation.

**Key Endpoints & Logic:**

*   **`/collectVoice` (POST):**
    *   Receives an audio file and a `user_id`.
    *   Uses `resemblyzer` to generate a voice embedding from the audio.
    *   Compares the current embedding's similarity with the previous one for the same user (if any) using `scipy.spatial.distance.cosine`.
    *   A similarity score of >= 0.85 is required for the sample to be accepted.
    *   Voice embeddings are temporarily stored in a Redis cache (`CacheHandler`).
    *   After 5 successful and similar voice samples are collected, the batch of embeddings is persisted to MongoDB.
*   **`/keyCreate` (POST):**
    *   Receives a `userId`.
    *   Calls the `cheqd.net` API (`https://studio-api.cheqd.net/key/create`) to generate a new cryptographic key pair (Ed25519).
    *   Stores the returned `kid` (Key ID) and `publicKeyHex` in MongoDB, associated with the `userId`.
*   **`/didCreate/{user_id}/{public_key_hex}` (POST):**
    *   Receives `user_id` and `public_key_hex`.
    *   Calls the `cheqd.net` API (`https://studio-api.cheqd.net/did/create`) to create a new Decentralized Identifier (DID) on the testnet.
    *   Uses the provided `public_key_hex` for the DID's verification method.
    *   Stores the resulting DID document in MongoDB, associated with the `user_id`.
*   **`/verify` (POST):**
    *   Receives an audio file and a `user_id`.
    *   Generates a voice embedding from the audio.
    *   Retrieves the stored voice embeddings for that `user_id` from MongoDB.
    *   Compares the new embedding against the stored ones (typically the first or an average).
    *   A similarity score of >= 0.82 is required for successful verification.
*   **`/hello` (GET):** A simple test endpoint.
*   **`/getEmbedding` (GET):** Placeholder/utility endpoint.
*   **`/attachCheqdDid` (POST):** Placeholder endpoint, not yet implemented.

**Technology Stack (Backend):**

*   **Framework:** FastAPI
*   **Voice Processing:**
    *   `resemblyzer`: For creating voice embeddings.
    *   `scipy`: For calculating cosine similarity between embeddings.
*   **Database:** MongoDB (`pymongo` driver) for persistent storage of user voice embeddings, DIDs, and key information.
*   **Caching:** Redis (`redis` library) for temporary storage of voice embeddings during the collection process.
*   **HTTP Client:** `httpx` for making asynchronous requests to external APIs (e.g., cheqd.net).
*   **Web Server:** Uvicorn
*   **Configuration:** `pydantic-settings` for managing application settings.

## Setup and Run

(Instructions for setting up and running both frontend and backend would go here - currently not detailed in the provided files beyond standard Flutter/Python practices)
