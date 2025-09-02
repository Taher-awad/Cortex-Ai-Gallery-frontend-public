# Cortex-AI Gallery

An intelligent AI-powered photo gallery built with Flutter. This application allows you to browse and manage your photos and videos, with AI-powered features like person recognition.

## Features

*   **View all your media:** Browse all your photos and videos in a beautiful, staggered grid.
*   **Person Recognition:** Automatically identifies and groups photos by person.
*   **View Media by Person:** See all the photos and videos of a specific person.
*   **Rename People:** Easily rename the people identified by the AI.
*   **Efficient Uploads:** Avoids uploading duplicate files by checking with the backend before uploading.
*   **Dark Mode:** Includes a dark mode for comfortable viewing in low-light environments.

## Backend

This project is the frontend for the Cortex-AI Gallery. The backend is a separate project that handles the AI processing, media storage, and API. You can find the backend project here: [Cortex-Ai-Gallery-backend](https://github.com/Taher-awad/Cortex-Ai-Gallery-backend)

## Getting Started

Follow these instructions to get a copy of the project up and running on your local machine for development and testing purposes.

### Prerequisites

*   [Flutter SDK](https://flutter.dev/docs/get-started/install) (version >=3.2.0 <4.0.0)
*   An editor like [VS Code](https://code.visualstudio.com/) or [Android Studio](https://developer.android.com/studio)
*   A running instance of the [Cortex-Ai-Gallery-backend](https://github.com/Taher-awad/Cortex-Ai-Gallery-backend)

### Installation

1.  **Clone the repository:**
    ```bash
    git clone https://github.com/Taher-awade/cortex-ai-gallery-frontend.git
    cd cortex-ai-gallery-frontend
    ```
2.  **Set up the backend URL:**
    Open the `lib/services/api_service.dart` file and replace the `_baseUrl` with the IP address and port of your running backend instance.
    ```dart
    // lib/services/api_service.dart
    static const String _baseUrl = 'http://YOUR_BACKEND_IP:8000';
    ```
3.  **Install dependencies:**
    ```bash
    flutter pub get
    ```
4.  **Run the application:**
    ```bash
    flutter run
    ```

## Project Structure

The project is structured as follows:

```
lib/
├── models/         # Data models for the application
├── providers/      # State management using Provider
├── screens/        # UI screens of the application
├── services/       # Services for API communication, authentication, etc.
├── widgets/        # Reusable UI widgets
└── main.dart       # Entry point of the application
```

## Key Dependencies

*   [**firebase_core**](https://pub.dev/packages/firebase_core) & [**firebase_auth**](https://pub.dev/packages/firebase_auth): For user authentication.
*   [**dio**](https://pub.dev/packages/dio): For making HTTP requests to the backend API.
*   [**provider**](https://pub.dev/packages/provider): For state management.
*   [**flutter_staggered_grid_view**](https://pub.dev/packages/flutter_staggered_grid_view): For the beautiful staggered grid layout.
*   [**cached_network_image**](https://pub.dev/packages/cached_network_image): To cache network images.
*   [**photo_view**](https://pub.dev/packages/photo_view): For a zoomable image view.
*   [**video_player**](https://pub.dev/packages/video_player): For playing videos.
*   [**file_picker**](https://pub.dev/packages/file_picker): For picking files to upload.
*   [**json_serializable**](https://pub.dev/packages/json_serializable): For code generation for JSON serialization.
