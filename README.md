# 🔐 Voxa - Voice Identity Authentication App

**Voxa** is a multi-platform Flutter application that provides secure **voice-based identity verification** through an engaging and interactive user experience.

---

## 🧭 Overview

Voxa enables users to authenticate using their **voice**, featuring:

- 🎙️ High-quality voice capture  
- 🎨 Animated visualizations during recording  
- 🔄 Real-time feedback with waveform displays  
- 📱 Cross-platform support (iOS, Android, Web, macOS, Windows, Linux)

---

## ✨ Features

- 🎤 **Voice Sample Recording**: High-fidelity recording with microphone permission handling  
- 💬 **Animated UI**: Bubble animations visualizing the voice sample collection  
- 📊 **Real-time Feedback**: Visual waveform during recording using `audio_waveforms`  
- 🖥️ **Cross-platform**: Works seamlessly across all major platforms  
- 🔐 **Microphone Permissions**: Smooth access handling via `permission_handler`

---

## 🛠️ Technology Stack

### 🧩 Frontend (Flutter - Dart)
- **Audio Recording**: `record`  
- **Waveform Visualization**: `audio_waveforms`  
- **Animations**: Custom Flutter animations & Lottie (`lottie` package)  
- **Permissions**: `permission_handler`  
- **Local Storage**: `path_provider`  
- **UUID Generation**: `uuid`  
- **Networking**: `http` package

### ⚙️ Backend (Python - FastAPI)
- **Framework**: FastAPI  
- **Voice Embedding**: `resemblyzer`  
- **Similarity Check**: `scipy.spatial.distance.cosine`  
- **Database**: MongoDB (`pymongo`)  
- **Caching**: Redis (`redis`)  
- **External API Integration**: `httpx` (for `cheqd.net`)  
- **Configuration**: `pydantic-settings`  
- **Web Server**: Uvicorn

---

## 📁 Project Structure

### 🖼️ Frontend (`/frontend`)

#### 🔄 BubblePage (Voice Sample Collection)
- Users record **5 voice samples**
- Animated **bubbles fill "storage cans"** with each successful recording
- **Microphone icon pulses** to show readiness & turns into a **GIF while recording**
- Rejected samples show a **"burst" animation**
- Step-by-step instructional UI for the user

#### 🔊 Real-time Waveform
- Displayed during recording using `audio_waveforms`

#### ✅ SuccessPage
- Shows **success Lottie animation** after voice identity creation
- Displays the **generated DID**
- Option to continue to **voice verification**

#### 🔐 VerifyPage
- Records new voice input and verifies against stored voiceprint

#### 🔃 Loading States
- **Lottie animations** indicate loading during backend interactions

#### 📦 State Management
- `ChangeNotifier` + `ViewModel` (`BubblePageViewModel`) for clean UI logic separation

#### 🌐 Backend Communication (`VoiceService`)
- Handles all **API calls**: voice sample submission, key creation, DID creation, and verification

#### ⚠️ Error Handling
- Proper **error dialogs** for API and logic failures

---

### 🧠 Backend (`/backend`)

#### 📥 `/collectVoice` (POST)
- Accepts audio + `user_id`
- Embeds voice using `resemblyzer`
- Ensures similarity (≥ 0.85) between samples before accepting
- Stores in **Redis** temporarily, then persists to **MongoDB** after 5 valid samples

#### 🔑 `/keyCreate` (POST)
- Creates a new **Ed25519 key pair** using `cheqd.net` API
- Saves `kid` and `publicKeyHex` to MongoDB

#### 🆔 `/didCreate/{user_id}/{public_key_hex}` (POST)
- Registers a new **DID** on `cheqd.net` using the provided public key
- Stores the DID document in MongoDB

#### 🔍 `/verify` (POST)
- Accepts new voice + `user_id`
- Generates new embedding, compares to stored ones
- Successful if similarity ≥ 0.82

#### 🔧 Utility Endpoints
- `/hello` - test endpoint  
- `/getEmbedding` - placeholder  
- `/attachCheqdDid` - not implemented

---

## 🚀 Setup & Run Instructions

> ℹ️ Setup steps are based on standard Flutter and Python project practices. Please refer to the `README.md` files inside the `/frontend` and `/backend` directories.

---

## 📬 Contact & Contributions

Want to contribute or have suggestions? We'd love to hear from you!

Feel free to open issues or submit pull requests 🤝

---

**Voxa** - *Your Voice. Your Identity.* 🔐🗣️
