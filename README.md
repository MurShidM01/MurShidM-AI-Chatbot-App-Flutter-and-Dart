# MurShidM AI Assistant

A sophisticated Flutter-based AI chat assistant leveraging Google's Gemini Pro API, featuring a modern Material Design 3 interface and comprehensive chat functionality.

## ✨ Key Features

- 🤖 Powered by Google's Gemini Pro AI for intelligent conversations
- 🎨 Modern Material Design 3 UI with custom animations
- 💾 Persistent chat history with SQLite database
- ⭐ Message favoriting and management
- 📊 User interaction statistics
- 🌙 Custom app theme with Material 3 design
- 🔄 Real-time typing indicators
- 📱 Responsive drawer navigation
- 🌐 Robust error handling and offline support

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (^3.6.0)
- Dart SDK (^3.0.0)
- Android Studio / VS Code
- Google Gemini API key

### Installation

1. Clone the repository:
```bash
git clone [your-repository-url]
```

2. Navigate to the project directory:
```bash
cd firstapp
```

3. Create a .env file in the root directory and add your Gemini API key:
```
GEMINI_API_KEY=your_api_key_here
```

4. Install dependencies:
```bash
flutter pub get
```

5. Run the app:
```bash
flutter run
```

## 📂 Project Structure

```
lib/
├── screens/
│   ├── chat_screen.dart      # Main chat interface
│   └── splash_screen.dart    # App loading screen
├── widgets/
│   ├── chat_drawer.dart      # Navigation drawer
│   ├── message_bubble.dart   # Chat message UI
│   ├── points_indicator.dart # Loading animations
│   └── typing_indicator.dart # Typing status
├── providers/
│   └── chat_provider.dart    # State management
└── main.dart                 # App entry point
```

## 🛠️ Technical Stack

### Core Dependencies

- `google_generative_ai: ^0.2.0`: Gemini AI integration
- `provider: ^6.1.1`: State management
- `google_fonts: ^6.1.0`: Custom typography
- `animated_text_kit: ^4.2.2`: Text animations
- `loading_animation_widget: ^1.2.0+4`: Loading states
- `flutter_dotenv: ^5.1.0`: Environment configuration
- `shared_preferences: ^2.2.2`: Local storage
- `sqflite: ^2.3.2`: SQLite database
- `lottie: ^3.0.0`: Advanced animations

### Features Implementation

- **Chat Interface**: Modern, responsive chat UI with typing indicators
- **State Management**: Provider pattern for efficient state handling
- **Local Storage**: SQLite + SharedPreferences for data persistence
- **UI/UX**: Material 3 design with custom animations and transitions
- **Error Handling**: Comprehensive error states and offline support

## 🔒 Security Features

- Secure API key storage using .env
- Local data encryption with SQLite
- Network security best practices
- No sensitive data stored in app memory

## 📱 Building & Deployment

### Release Build

Generate a release APK:
```bash
flutter build apk --release
```

Generate a release Bundle:
```bash
flutter build appbundle
```

### Platform Support

- ✅ Android
- ✅ iOS
- ✅ Web
- ✅ Windows
- ✅ Linux
- ✅ macOS

## 📝 License

This project is licensed under the MIT Licens

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.
