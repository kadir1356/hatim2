# Firebase Setup Guide

## 1. Firebase Project Setup

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Create a new project or select an existing one
3. Enable **Authentication**:
   - Go to Authentication > Sign-in method
   - Enable **Google Sign-In**
   - Enable **Anonymous** authentication

4. Enable **Firestore Database**:
   - Go to Firestore Database
   - Create database in **test mode** (for development)
   - Set security rules:
   ```javascript
   rules_version = '2';
   service cloud.firestore {
     match /databases/{database}/documents {
       match /users/{userId}/{document=**} {
         allow read, write: if request.auth != null && request.auth.uid == userId;
       }
     }
   }
   ```

## 2. Android Configuration

1. In Firebase Console, go to Project Settings
2. Under "Your apps", click "Add app" > Android
3. Register your app:
   - Package name: `com.hatimtracker.hatim_tracker`
   - Download `google-services.json`
   - Place it in `android/app/google-services.json`

4. Update `android/build.gradle`:
   ```gradle
   buildscript {
       dependencies {
           classpath 'com.google.gms:google-services:4.4.0'
       }
   }
   ```

5. Update `android/app/build.gradle`:
   ```gradle
   apply plugin: 'com.google.gms.google-services'
   ```

## 3. iOS Configuration (if needed)

1. In Firebase Console, add iOS app
2. Download `GoogleService-Info.plist`
3. Place it in `ios/Runner/GoogleService-Info.plist`
4. Update `ios/Runner/Info.plist` with Firebase configuration

## 4. Web Configuration (for Chrome testing)

1. In Firebase Console, add Web app
2. Copy the Firebase configuration object
3. Create `lib/firebase_options.dart` (or use environment variables)

## 5. Testing

After setup, the app will:
- Allow Google Sign-In
- Allow Anonymous Sign-In
- Sync Hatim progress to Firestore
- Work offline with local Hive storage

## Notes

- For production, update Firestore security rules
- Add SHA-1 fingerprint for Android (if using Google Sign-In)
- Configure OAuth consent screen in Google Cloud Console
