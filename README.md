# SafeCircle — Disposable, Journey-Based Safety & Live Tracking

> Silent, journey-based live location sharing with trusted contacts, shake-to-panic gesture, web tracking links, auto inactivity detection, and discreet fake incoming call exit system.

---

## Problem Statement

Traditional safety and location-sharing mobile applications suffer from two critical adoption flaws:

1. **Always-On Privacy Intrusiveness:** Apps like Life360 enforce continuous, permanent 24/7 location tracking. Users often feel uncomfortable being monitored constantly when they only need protection during specific, vulnerable moments (e.g. walking home late at night, taking a solo taxi ride, or traveling through an unfamiliar area).
2. **App Installation Friction:** Almost every safety platform requires both parties—the traveler and their contact—to download, install, and create accounts on the same app. In practice, this friction kills real-world usage when a user needs to quickly notify a friend, spouse, or colleague.

**SafeCircle solves both problems:**
- **Journey-Based Disposable Safety:** Location sharing is explicitly active *only* for the duration of a single journey. Tapping "I'm Safe" instantly ends the session and closes tracking.
- **Zero-Friction Web Live Link:** Trusted contacts do not need to install SafeCircle. Starting a journey generates a secure, expiring web tracking link viewable directly in any web browser.

---

## Live Demo & Web Target Deployment

### Testing the Web Tracking Page Locally
The lightweight read-only web tracking page shell can be previewed locally at any time:
```bash
flutter build web
# Serve locally using any local web server, e.g.:
npx serve build/web
```
Or run directly in Chrome with hot reload:
```bash
flutter run -d chrome
```
Navigate to `http://localhost:<port>/#/track/demo-journey-id` to view the read-only live tracking map shell.

### Deploying to Your Live Firebase Hosting Project
To deploy the public web live-tracking link to your live Firebase project domain:
```bash
# 1. Build the production Flutter Web target
flutter build web

# 2. Login to your Firebase Console account
npx firebase-tools login

# 3. Deploy to Firebase Hosting
npx firebase-tools deploy --only hosting --project YOUR_FIREBASE_PROJECT_ID
```
> *Once deployed, trusted contacts can view any active journey live without installing the app by opening `https://<YOUR-PROJECT-ID>.web.app/#/track/<JOURNEY-ID>`.*

---

## Key Differentiating Features

- 📱 **Shake-to-Panic Gesture:** Shaking the device firmly (tuned accelerometer threshold $\ge 27.0\text{ m/s}^2$ with a 1.5s debounce window to prevent accidental triggers while walking) instantly starts an emergency journey and alerts trusted contacts without unlocking the screen.
- 🌐 **Web-Based Live Tracking Link:** Lightweight Flutter Web target deployed on Firebase Hosting that displays real-time map updates for an active journey. Links automatically expire once the journey ends.
- ⚡ **One-Tap Quick Ping:** A quick single-tap action from the home screen to send a one-time location snapshot without starting continuous background tracking.
- 🔋 **Battery-Critical Auto-Alert:** Automatic client-side listener that flags active journeys and dispatches emergency push notifications if the phone battery drops below 15%.
- 🏁 **Safe Arrival Confirmation:** Tapping "I'm Safe" ends the journey with a warm arrival animation and dispatches a final "arrived safely" push alert to trusted contacts.
- 📞 **Discreet Fake Incoming Call:** Native overlay UI with realistic incoming call screen, ringtone audio loop via `audioplayers`, and custom vibration pattern for a natural exit from uncomfortable situations.

---

## Tech Stack

- **Framework:** Flutter (Latest Stable), Dart 3
- **State Management:** `flutter_riverpod` (v2.5+)
- **Routing:** `go_router` (v14.0+) with Auth Guard & Web Route Parameters
- **Backend & Cloud Services:**
  - Firebase Authentication (Google Sign-In & Email/Demo Auth)
  - Cloud Firestore (Real-time subcollections for location updates)
  - Firebase Cloud Functions (Scheduled Node.js 18 cron for inactivity detection)
  - Firebase Hosting (Web tracking target deployment)
  - Firebase Cloud Messaging (FCM push alerts)
- **Location & Sensors:**
  - `geolocator` & `permission_handler`
  - `flutter_background_service` & `flutter_local_notifications` (Android Foreground Service with persistent notification)
  - `sensors_plus` (User Accelerometer shake detection)
  - `battery_plus` (Battery state & level listener)
  - `audioplayers` & `vibration` (Fake call ringtone and haptics)
- **Map Rendering:** `flutter_map` & `latlong2` (OpenStreetMap tile renderer without paid API key requirements)

---

## MVVM Architecture

SafeCircle follows strict Model-View-ViewModel (MVVM) architecture with full decoupling between UI, business state, and data repositories:

```
                  ┌────────────────────────┐
                  │       UI Screens       │
                  │ (Presentation Layer)   │
                  └───────────┬────────────┘
                              │ reads / calls
                              ▼
                  ┌────────────────────────┐
                  │   Riverpod Providers   │
                  │   (Controller / VM)    │
                  └───────────┬────────────┘
                              │ invokes
                              ▼
                  ┌────────────────────────┐
                  │   Data Repositories    │
                  │  (Firestore / Auth)    │
                  └───────────┬────────────┘
                              │ streams
                              ▼
                  ┌────────────────────────┐
                  │ Firebase & Device APIs │
                  └────────────────────────┘
```

- **Core Layer (`lib/core/`):** Contains central theme tokens (`AppColors`, `AppTheme`), router configuration (`app_router.dart`), and device services (`LocationService`, `BackgroundTrackingService`, `SensorService`, `BatteryService`, `AudioVibrationService`).
- **Data Layer (`lib/data/`):** Houses pure data classes (`UserModel`, `ContactModel`, `JourneyModel`, `LocationPoint`) with `toMap`/`fromMap` serialization, and repository classes (`AuthRepository`, `ContactRepository`, `JourneyRepository`) encapsulating all Firebase calls. UI components never access Firebase directly.
- **Presentation Layer (`lib/presentation/`):** Contains feature screens and Riverpod state controllers (`auth_provider`, `contact_provider`, `journey_provider`, `fake_call_provider`).
- **Shared Layer (`lib/shared/`):** Reusable UI components (`CustomButton`, `TrustedContactCard`, `JourneyStatusCard`, `BottomNavBar`, `PulseIndicator`).

---

## Project Folder Structure

```
lib/
├── core/
│   ├── constants/
│   │   ├── app_colors.dart
│   │   ├── app_strings.dart
│   │   └── app_theme.dart
│   ├── router/
│   │   └── app_router.dart
│   └── services/
│       ├── audio_vibration_service.dart
│       ├── background_service.dart
│       ├── battery_service.dart
│       ├── location_service.dart
│       └── sensor_service.dart
├── data/
│   ├── models/
│   │   ├── contact_model.dart
│   │   ├── journey_model.dart
│   │   ├── location_point.dart
│   │   └── user_model.dart
│   └── repositories/
│       ├── auth_repository.dart
│       ├── contact_repository.dart
│       └── journey_repository.dart
├── presentation/
│   ├── auth/
│   │   ├── providers/auth_provider.dart
│   │   └── screens/login_screen.dart
│   ├── contacts/
│   │   ├── providers/contact_provider.dart
│   │   └── screens/trusted_contacts_screen.dart
│   ├── fake_call/
│   │   └── screens/fake_call_screen.dart
│   ├── journey/
│   │   ├── providers/journey_provider.dart
│   │   └── screens/
│   │       ├── history_screen.dart
│   │       └── journey_screen.dart
│   └── web/
│       └── screens/web_live_tracking_screen.dart
├── shared/
│   └── widgets/
│       ├── bottom_nav_bar.dart
│       ├── custom_button.dart
│       ├── journey_status_card.dart
│       ├── pulse_indicator.dart
│       └── trusted_contact_card.dart
├── firebase_options.dart
└── main.dart
```

---

## Local Setup & Installation

### Prerequisites
- Flutter SDK 3.22.0+ (Stable Channel)
- Dart SDK 3.4.0+
- Git & Node.js 18+ (for Cloud Functions)

### Steps
1. **Clone the repository:**
   ```bash
   git clone https://github.com/Rish-2006/SafeCircle.git
   cd SafeCircle
   ```

2. **Install Flutter dependencies:**
   ```bash
   flutter pub get
   ```

3. **Run Flutter Analyze & Test Suite:**
   ```bash
   flutter analyze
   flutter test
   ```

4. **Run Locally:**
   - **Mobile (Android/iOS):**
     ```bash
     flutter run
     ```
   - **Web (Public Live Tracking Target):**
     ```bash
     flutter run -d chrome
     ```

---

## Screenshots & Demo Flow

| Journey Dashboard | Active Tracking & Map | Trusted Contacts | Fake Call Overlay |
| :---: | :---: | :---: | :---: |
| *(Placeholder: Active journey card, panic gesture status, quick ping)* | *(Placeholder: Real-time map, pulse indicator, live web link generator)* | *(Placeholder: Up to 5 contact cards, relation badges, quick add)* | *(Placeholder: Incoming call overlay, caller name, accept/decline)* |

---

## Important Platform & Policy Engineering Notes

### Foreground Service & Android Background Location Policy
To guarantee reliable location updates when the user's screen is locked or the app is minimized, SafeCircle utilizes `flutter_background_service` configured as an **Android Foreground Service** with an explicit, persistent status bar notification ("SafeCircle Live Protection").

- Silent background location tracking without a visible notification violates Android background execution limits and Google Play Store Developer Policies.
- The persistent notification explicitly informs the user that location tracking is currently active and provides clear visual feedback.
- When the user taps "I'm Safe" or ends the journey, the foreground service terminates immediately and dismisses the notification.

### Data Safety & Privacy Disclosure
SafeCircle collects precise location data exclusively during active, user-initiated journeys and shares it solely with user-designated trusted contacts. Location tracking is immediately halted upon journey completion.
