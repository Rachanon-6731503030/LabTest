# Smart Class Check-in & Learning Reflection App

## Project Description

This Flutter application allows students to check in to classes using GPS location and QR code scanning, along with pre and post-class reflections to ensure active participation.

## Setup Instructions

1. Ensure Flutter is installed: `flutter --version`
2. Clone or download the project
3. Run `flutter pub get` to install dependencies
4. For Android/iOS, ensure permissions are set (already configured)
5. Run `flutter run` to start the app

## How to Run the App

- Open in Android Studio or VS Code with Flutter extension
- Select device/emulator
- Run `flutter run`

## Firebase Configuration Notes

- Create a Firebase project at https://console.firebase.google.com/
- Enable Firestore Database
- Run `flutterfire configure` to generate firebase_options.dart
- Add Firebase initialization in main.dart if needed

## Features

- GPS location recording
- QR code scanning
- Pre-class reflection (previous topic, expected topic, mood)
- Post-class reflection (learned today, feedback)
- Local SQLite storage

## Deployment

- Build web: `flutter build web`
- Deploy to Firebase Hosting: `firebase deploy`
