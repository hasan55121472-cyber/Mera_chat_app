# WhatsApp Clone (Flutter + Firebase)

A production-ready WhatsApp-style chat app built with Flutter and Firebase.

## Features
- Login: Email/Password, Google Sign-In, Phone OTP (+92 Pakistan)
- Real-time chat list with instant search filtering
- Text + voice messages (record, waveform, slide-to-cancel, playback)
- Delete for Me / Delete for Everyone with Anti-Delete Mode
- Privacy settings: Last Seen, Profile Photo, Freeze Last Seen
- Profile editing (photo, name, about)
- Status (stories) that disappear after 24h
- Calls tab (UI placeholder)
- WhatsApp-style top tabs: Chats, Status, Calls

## Firebase Setup

### 1. Create a Firebase project
Go to <https://console.firebase.google.com> and create a project.

### 2. Enable services
- **Authentication**: enable Email/Password and Phone providers.
- **Firestore**: create database in production mode (rules below).
- **Storage**: enable (rules below).

### 3. Add Android app
- Register your Android app (package `com.example.whatsapp_clone`).
- Download `google-services.json` and place it at:
  ```
  whatsapp_clone/android/app/google-services.json
  ```
  (A placeholder file exists there now — replace it with your real one.)
- Add the SHA-1 / SHA-256 of your signing key in Firebase console
  (required for Google Sign-In and Phone Auth). Run:
  ```
  cd android && ./gradlew signingReport
  ```

### 4. Firestore Security Rules
```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.auth.uid == userId;
    }
    match /chats/{chatId} {
      allow read, write: if request.auth != null;
      match /messages/{messageId} {
        allow read, write: if request.auth != null;
      }
    }
    match /statuses/{statusId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.auth.uid == resource.data.uid;
    }
  }
}
```

### 5. Storage Rules
```
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /profile_images/{userId}/{fileName} {
      allow read: if true;
      allow write: if request.auth != null && request.auth.uid == userId;
    }
    match /voice_notes/{chatId}/{fileName} {
      allow read: if request.auth != null;
      allow write: if request.auth != null;
    }
    match /statuses/{userId}/{fileName} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

## Run
```
flutter pub get
flutter run
```

## Project Structure
```
lib/
  main.dart
  models/        (user, message, status)
  services/      (auth, firestore, storage)
  utils/         (theme, helpers)
  screens/       (login, profile setup, home, chat, settings, privacy, profile, status, calls)
  widgets/       (chat bubble, chat list tile)
```
