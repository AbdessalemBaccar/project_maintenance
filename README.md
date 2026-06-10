# 🚗 CarTrack — Personal Car Maintenance Tracker

A production-ready Flutter 3.x mobile application for tracking vehicle maintenance history, built with Firebase, Riverpod, and GoRouter.

---

## 📁 Project Structure

```
lib/
├── main.dart                    # App entry point, Firebase init
├── app_theme.dart               # Material 3 dark theme & design tokens
├── firebase_options.dart        # Firebase platform config (replace with yours)
├── router.dart                  # GoRouter config + bottom nav shell
│
├── models/
│   ├── maintenance_entry.dart   # Maintenance log model + ServiceType enum
│   └── car_profile.dart         # Vehicle profile model + ServiceStatus enum
│
├── services/
│   ├── auth_service.dart        # Firebase Auth wrapper with error mapping
│   └── firestore_service.dart   # Firestore CRUD + real-time streams
│
├── providers/
│   └── app_providers.dart       # All Riverpod providers + state notifiers
│
├── screens/
│   ├── splash_screen.dart       # Initial loading screen
│   ├── auth_screen.dart         # Login / Sign-up toggle
│   ├── dashboard_screen.dart    # Home: car summary, stats, recent activity
│   ├── history_screen.dart      # Full log with search + filter + swipe-delete
│   ├── add_entry_screen.dart    # Form to log new maintenance
│   └── car_profile_screen.dart  # Vehicle setup / edit screen
│
└── widgets/
    ├── stat_card.dart           # Small metric card (dashboard)
    ├── service_status_badge.dart # Good / Soon / Overdue status chip
    └── entry_list_tile.dart     # Single maintenance entry card
```

---

## 🚀 Setup Instructions

### 1. Prerequisites

- Flutter SDK ≥ 3.0.0 (`flutter --version`)
- Dart SDK ≥ 3.0.0 (included with Flutter)
- A Firebase project (free Spark plan works)
- FlutterFire CLI: `dart pub global activate flutterfire_cli`

### 2. Clone & Install

```bash
git clone <your-repo-url>
cd car_maintenance_tracker
flutter pub get
```

### 3. Firebase Setup

```bash
# Login to Firebase
firebase login

# Configure FlutterFire (auto-generates firebase_options.dart)
flutterfire configure --project=YOUR_FIREBASE_PROJECT_ID
```

This overwrites the placeholder `firebase_options.dart` with your real credentials.

#### Firestore Rules (paste in Firebase Console → Firestore → Rules)

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

#### Enable Authentication
Firebase Console → Authentication → Sign-in method → Enable **Email/Password**.

### 4. Run the App

```bash
# iOS
flutter run -d ios

# Android
flutter run -d android

# Both (if both simulators running)
flutter run
```

---

## 🏗️ Architecture Overview

| Layer | Technology | Purpose |
|---|---|---|
| UI | Flutter + Material 3 | Screens & widgets |
| Navigation | GoRouter 13 | Declarative routing with auth guard |
| State | Riverpod 2 | Providers, StateNotifiers, Streams |
| Backend | Firebase Auth | Email/password authentication |
| Database | Cloud Firestore | Real-time maintenance log + car profile |

### Data Model

**Firestore Structure:**
```
users/
  {uid}/
    profile/
      car          ← CarProfile document
    maintenance_entries/
      {entryId}    ← MaintenanceEntry documents
```

### Auth Flow

```
App Launch
    ↓
Firebase.initializeApp()
    ↓
authStateProvider (StreamProvider<User?>)
    ↓
GoRouter redirect
  ├── No user  → /auth  (AuthScreen)
  └── Has user → /dashboard (MainShell)
```

---

## ✨ Features

| Feature | Details |
|---|---|
| **Auth** | Email/Password login & sign-up, password toggle, detailed error messages |
| **Dashboard** | Car summary hero card, 3 stat cards, recent activity, service status badge |
| **Service History** | Real-time Firestore stream, search, filter by service type, swipe-to-delete |
| **Add Entry** | Dropdown for service type, date picker, mileage & cost with thousands formatting, notes |
| **Car Profile** | Make/Model/Year, license plate, VIN, current mileage, next service milestone |
| **Routing** | GoRouter with auth guard, animated transitions, bottom nav shell |
| **Theme** | Material 3, dark-only, teal accent, DM Sans typography |

---

## 🔧 Key Dependencies

```yaml
firebase_core: ^2.24.2
firebase_auth: ^4.16.0
cloud_firestore: ^4.14.0
go_router: ^13.2.0
flutter_riverpod: ^2.4.10
google_fonts: ^6.1.0
intl: ^0.19.0
```

---

## 📱 Screens Preview

```
AuthScreen          DashboardScreen       HistoryScreen
┌─────────────┐    ┌─────────────┐       ┌─────────────┐
│ 🚗 CarTrack │    │ Good evening│       │ Service Log │
│             │    │  John       │       │ 🔍 Search   │
│ Welcome     │    │ ┌─────────┐ │       │             │
│ back.       │    │ │2021 Toyota│       │ 🛢️ Oil Change│
│             │    │ │Camry    │ │       │ Mar 5 · $45 │
│ [Email]     │    │ │All Good ✓│ │       │             │
│ [Password]  │    │ └─────────┘ │       │ 🔄 Tires    │
│             │    │ $1,240 | 8  │       │ Jan 12 · $80│
│ [Sign In]   │    │ Recent:     │       │             │
│             │    │ 🛢️ Oil Change│       │ [+ FAB]     │
│ Sign Up     │    │ [+ FAB]     │       └─────────────┘
└─────────────┘    └─────────────┘
```

---

## 🛠️ Development Notes

- **Sound null safety** is enforced throughout.
- All Firestore calls use `.handleError()` on streams and `try/catch` on writes.
- `AuthService._mapFirebaseError()` converts Firebase error codes to human-readable messages.
- `GoRouter` redirect prevents unauthenticated access to protected routes.
- `addEntryProvider` uses `autoDispose` to reset form state on pop.
- The `ServiceType` enum drives both the dropdown and emoji avatars, making it trivial to add new service types.

---

## 📄 License

MIT — free to use, modify, and distribute.
