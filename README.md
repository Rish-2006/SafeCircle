# SafeCircle — Disposable, Journey-Based Safety & Live Tracking

> Silent, journey-based live location sharing with trusted contacts, shake-to-panic gesture, web tracking links, auto inactivity detection, client push notifications, and discreet fake incoming call exit system.

---

## Problem Statement

Traditional safety and location-sharing mobile applications suffer from two critical adoption flaws:

1. **Always-On Privacy Intrusiveness:** Apps like Life360 enforce continuous, permanent 24/7 location tracking. Users often feel uncomfortable being monitored constantly when they only need protection during specific, vulnerable moments (e.g. walking home late at night, taking a solo taxi ride, or traveling through an unfamiliar area).
2. **App Installation Friction:** Almost every safety platform requires both parties—the traveler and their contact—to download, install, and create accounts on the same app. In practice, this friction kills real-world usage when a user needs to quickly notify a friend, spouse, or colleague.

**SafeCircle solves both problems:**
- **Journey-Based Disposable Safety:** Location sharing is explicitly active *only* for the duration of a single journey. Tapping "I'm Safe" instantly ends the session and closes tracking.
- **Zero-Friction Web Live Link:** Trusted contacts do not need to install SafeCircle. Starting a journey generates a secure, expiring web tracking link viewable directly in any web browser.

---

## Live Demo & Hosted Web Tracker

**🚀 Live Web Application:**
[https://rish-2006.github.io/SafeCircle/](https://rish-2006.github.io/SafeCircle/)

**📌 Demo Web Tracking Link:**
[https://rish-2006.github.io/SafeCircle/#/track/demo-journey-id](https://rish-2006.github.io/SafeCircle/#/track/demo-journey-id)

> *Trusted contacts can view a live journey without installing the app. Open the link above to test the interactive live web tracking preview directly in any browser! Includes live OpenStreetMap path polyline rendering, traveler pin updates, emergency SOS toggle, and safe arrival simulation.*

---

## Key Differentiating Features

- 🚀 **Onboarding & Profile Setup:** First-time onboarding carousel explaining core safety features and personal safety profile setup saved directly to Firestore.
- 📱 **Shake-to-Panic Gesture:** Shaking the device firmly (tuned accelerometer threshold $\ge 27.0\text{ m/s}^2$ with a 1.5s debounce window to prevent accidental triggers while walking) instantly starts an emergency journey and alerts trusted contacts without unlocking the screen.
- 🌐 **Web-Based Live Tracking Link:** Lightweight Flutter Web target deployed automatically on GitHub Pages via CI/CD that displays real-time map updates for an active journey with OpenStreetMap rendering. Links automatically expire once the journey ends.
- 🔔 **Client Push Notifications:** Native Firebase Cloud Messaging (FCM) integration subscribing users to `contact_{contactId}` topics for foreground alert banners during panic and inactivity triggers.
- ⚡ **One-Tap Quick Ping:** Instant location snapshot written to Firestore `quickPings` subcollections and dispatched to trusted contact FCM topics.
- 🛡️ **Firestore Security Rules:** Granular rule definitions (`firestore.rules`) providing public single-doc `get` access for web tracking links while blocking unauthorized list queries and protecting user profile data.
- 🔋 **Battery-Critical Auto-Alert:** Automatic client-side listener that flags active journeys and dispatches emergency alerts if the phone battery drops below 15%.
- 🏁 **Safe Arrival Confirmation:** Tapping "I'm Safe" ends the journey with a warm arrival animation and dispatches a final "arrived safely" alert to trusted contacts.
- 📞 **Discreet Fake Incoming Call:** Native overlay UI with realistic incoming call screen, ringtone audio loop via `audioplayers`, and custom vibration pattern for a natural exit from uncomfortable situations.
- 👥 **In-App Contact Tracking Screen:** Dedicated native Flutter screen (`/contact-track/:journeyId`) for trusted contacts with the app installed to monitor real-time map streams.

---

## Tech Stack

- **Framework:** Flutter (Latest Stable), Dart 3
- **State Management:** `flutter_riverpod` (v2.6+)
- **Routing:** `go_router` (v14.0+) with Auth & Profile Guard + Web Route Parameters
- **Backend & Cloud Services:**
  - Firebase Authentication (Google Sign-In & Email/Demo Auth)
  - Cloud Firestore (Real-time subcollections for location updates & security rules)
  - Firebase Cloud Functions (Scheduled Node.js 18 cron for inactivity detection)
  - Firebase Cloud Messaging (FCM push alerts & topic subscriptions)
  - GitHub Actions CI/CD (Automated web build & deployment to GitHub Pages)
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
                  │ (Firestore / Auth / User)
                  └───────────┬────────────┘
                              │ streams
                              ▼
                  ┌────────────────────────┐
                  │ Firebase & Device APIs │
                  └────────────────────────┘
```

- **Core Layer (`lib/core/`):** Contains central theme tokens (`AppColors`, `AppTheme`), router configuration (`app_router.dart`), and device services (`LocationService`, `BackgroundTrackingService`, `SensorService`, `BatteryService`, `AudioVibrationService`, `NotificationService`).
- **Data Layer (`lib/data/`):** Houses data models (`UserModel`, `ContactModel`, `JourneyModel`, `LocationPoint`) and repositories (`AuthRepository`, `UserRepository`, `ContactRepository`, `JourneyRepository`). UI components never access Firebase directly.
- **Presentation Layer (`lib/presentation/`):** Feature screens (`SplashScreen`, `OnboardingScreen`, `ProfileSetupScreen`, `LoginScreen`, `JourneyScreen`, `TrustedContactsScreen`, `ContactLiveTrackingScreen`, `WebLiveTrackingScreen`, `HistoryScreen`) and Riverpod controllers.
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
│       ├── notification_service.dart
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
│       ├── journey_repository.dart
│       └── user_repository.dart
├── presentation/
│   ├── auth/
│   │   ├── providers/auth_provider.dart
│   │   └── screens/
│   │       ├── login_screen.dart
│   │       ├── onboarding_screen.dart
│   │       ├── profile_setup_screen.dart
│   │       └── splash_screen.dart
│   ├── contacts/
│   │   ├── providers/contact_provider.dart
│   │   └── screens/
│   │       ├── contact_live_tracking_screen.dart
│   │       └── trusted_contacts_screen.dart
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
   - **Web Target:**
     ```bash
     flutter run -d chrome
     ```

---

## CI/CD Deployment

The repository includes a GitHub Actions pipeline (`.github/workflows/deploy-web.yml`) that automatically builds the Flutter Web application with `--base-href /SafeCircle/` and deploys to the `gh-pages` branch on every push to `main`.

