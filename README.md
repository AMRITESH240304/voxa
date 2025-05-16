# 🎙️ Voxa - Voice Identity Authentication App

Voxa is a multi-platform Flutter application that provides **secure voice-based identity verification** with animated visual feedback.

[![Watch Demo](https://img.shields.io/badge/🎥%20Watch%20Demo-YouTube-red)](https://youtu.be/ffwbOwZaceM)

---

## 📋 Overview

Voxa allows users to authenticate using their **voice**, offering a seamless experience through a user-friendly interface and real-time animated feedback.

---

## ✨ Features

- 🎤 **Voice Sample Recording** — High-quality audio capture with permission handling  
- 🌐 **Cross-platform Support** — Works on iOS, Android, Web, macOS, Windows, and Linux  
- 💫 **Animated UI** — Bubble animations during voice collection  
- 📈 **Real-time Feedback** — Visual waveform display while recording  
- 🔐 **Secure Identity** — Voice-based DID creation and authentication  
- 📲 **Interactive UX** — Visual cues, feedback animations, and instructional guidance

---

## 🛠️ Technology Stack

### 🚀 Frontend

- **Framework**: Flutter (Dart)  
- **Audio Recording**: [`record`](https://pub.dev/packages/record)  
- **Waveform Visualization**: [`audio_waveforms`](https://pub.dev/packages/audio_waveforms)  
- **Animations**: Custom Flutter animations + Lottie (`lottie` package)  
- **HTTP Client**: `http`  
- **Permissions**: `permission_handler`  
- **Local Storage**: `path_provider`  
- **UUID Generation**: `uuid`

### 🔧 Backend

- **Framework**: FastAPI (Python)  
- **Voice Processing**:
  - `resemblyzer`: Voice embedding generation  
  - `scipy`: Cosine similarity comparison  
- **Database**: MongoDB (`pymongo`)  
- **Cache**: Redis (`redis`)  
- **API Requests**: `httpx`  
- **Server**: Uvicorn  
- **Configuration**: `pydantic-settings`

---

## 📁 Project Structure

### 📱 Frontend (`/frontend`)

Handles UI, audio recording, and API communication.

- 🎛️ **BubblePage**  
  - Record 5 voice samples  
  - Bubble animations represent each sample  
  - Mic icon pulses and switches to GIF during recording  
  - "Burst" animation for rejected samples  
  - Instructional prompts shown per sample  

- 📡 **Real-time Feedback**  
  - Waveform displayed using `audio_waveforms` during recording  

- ✅ **SuccessPage**  
  - Lottie animation upon successful DID creation  
  - Displays user’s DID  
  - Option to verify voice  

- 🧪 **VerifyPage**  
  - Allows voice authentication against stored voiceprint  

- 🔄 **State Management**  
  - `ChangeNotifier` and ViewModel pattern (`BubblePageViewModel`)  

- 🌐 **API Communication**  
  - `VoiceService` handles backend interaction  
  - Error dialogs for failed API calls

---

### 🔙 Backend (`/backend`)

Handles voice processing, key generation, DID creation, and verification.

#### 🔊 `/collectVoice` (POST)

- Receives audio + `user_id`
- Generates embedding with `resemblyzer`
- Compares similarity with previous samples
- Requires ≥ 0.85 similarity to accept
- Temporarily stores embeddings in Redis
- Stores in MongoDB after 5 valid samples

#### 🔐 `/keyCreate` (POST)

- Receives `userId`
- Creates Ed25519 key via `cheqd.net`
- Stores `kid` and `publicKeyHex` in MongoDB

#### 🆔 `/didCreate/{user_id}/{public_key_hex}` (POST)

- Calls `cheqd.net` API to create a DID  
- Stores DID in MongoDB

#### 🧾 `/verify` (POST)

- Receives audio + `user_id`
- Compares new embedding with stored ones
- Requires ≥ 0.82 similarity to verify

#### 🛠️ Utility Endpoints

- `/hello`: Test endpoint  
- `/getEmbedding`: Utility  
- `/attachCheqdDid`: Not yet implemented

---

## ▶️ Demo

🎥 **Watch the demo here**: [https://youtu.be/ffwbOwZaceM](https://youtu.be/ffwbOwZaceM)

---

## ⚙️ Setup & Run

Instructions for setup and run (Flutter & FastAPI) will go here.  
Make sure to install all dependencies and handle permissions correctly.

---

Made with ❤️ by the Voxa team.
