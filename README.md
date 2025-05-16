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
