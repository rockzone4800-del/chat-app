# Flutter Firebase WhatsApp-Style Chat App

A simple WhatsApp-like chat app built with **Flutter + Firebase**.

## Features

- Phone number login with OTP (Firebase Authentication)
- Real-time one-to-one messaging (Cloud Firestore)
- Send and receive text messages
- Online / offline status with last seen
- Message timestamps
- Chat list with recent conversations
- Individual chat screen with modern WhatsApp-inspired UI

## Full Project Folder Structure

```text
chat-app/
├── android/
│   └── app/
│       └── (google-services.json goes here)
├── lib/
│   ├── models/
│   │   └── chat_message.dart
│   ├── screens/
│   │   ├── auth_gate.dart
│   │   ├── chat_list_screen.dart
│   │   ├── chat_screen.dart
│   │   └── login_screen.dart
│   ├── services/
│   │   ├── auth_service.dart
│   │   ├── chat_service.dart
│   │   ├── presence_service.dart
│   │   └── user_service.dart
│   ├── widgets/
│   │   └── presence_badge.dart
│   ├── firebase_options.dart
│   └── main.dart
├── firestore.indexes.json
├── firestore.rules
├── pubspec.yaml
├── analysis_options.yaml
└── README.md
```

## Step-by-Step Setup Instructions

### 1) Prerequisites

- Flutter SDK installed
- Android Studio installed
- Firebase project access
- Real Android device for OTP testing (recommended)

### 2) Install Flutter dependencies

```bash
flutter pub get
```

### 3) Create Firebase project

1. Open [Firebase Console](https://console.firebase.google.com/)
2. Create a new project
3. Add an **Android app** to Firebase:
   - Android package name (must match your Flutter app package)
4. Download `google-services.json`
5. Place it in `android/app/google-services.json`

### 4) Enable Firebase Authentication (Phone)

1. Go to **Firebase Console → Authentication → Sign-in method**
2. Enable **Phone** provider
3. (Optional) Add test phone numbers + OTP codes for development

### 5) Enable Cloud Firestore

1. Go to **Firebase Console → Firestore Database**
2. Create database in production or test mode
3. Deploy the included rules and indexes:

```bash
firebase deploy --only firestore:rules
firebase deploy --only firestore:indexes
```

### 6) Configure FlutterFire

Install tools (if needed):

```bash
dart pub global activate flutterfire_cli
```

Run:

```bash
flutterfire configure
```

This generates platform-specific Firebase config values. Replace placeholder values in `lib/firebase_options.dart` with generated values (or regenerate the file automatically).

### 7) Android native setup

Make sure your Android Gradle setup includes Google Services plugin (standard FlutterFire setup):

- Project-level Gradle includes Google services classpath
- App-level Gradle applies plugin: `com.google.gms.google-services`

(If you run `flutterfire configure` on a standard Flutter app, this is typically handled automatically.)

## Firebase Data Model

### `users/{uid}`

```json
{
  "uid": "userUid",
  "phone": "+15551234567",
  "online": true,
  "lastSeen": "timestamp"
}
```

### `chats/{chatId}`

```json
{
  "participants": ["uidA", "uidB"],
  "participantPhones": {
    "uidA": "+15550000001",
    "uidB": "+15550000002"
  },
  "lastMessage": "hello",
  "lastMessageAt": "timestamp"
}
```

### `chats/{chatId}/messages/{messageId}`

```json
{
  "senderId": "uidA",
  "text": "Hello!",
  "createdAt": "timestamp"
}
```

## How to Run in Android Studio

1. Open Android Studio
2. Click **Open** and select this project folder (`chat-app`)
3. Let Android Studio sync Gradle and Flutter packages
4. Start an Android emulator (or connect a real Android device)
5. In terminal:

```bash
flutter pub get
flutter run
```

or click **Run ▶** from Android Studio.

## Usage Flow

1. Login with phone number
2. Enter OTP received via Firebase phone auth
3. On the chat list screen, enter another registered phone number and open a chat
4. Send messages in real-time
5. Observe online/offline + last seen on chat header

## Notes

- OTP on emulator can be unreliable; use Firebase test numbers or a physical device.
- For production, tighten Firestore rules and validate chat participant membership strictly.
- UI intentionally simple and modern; customize colors/spacing as needed.
