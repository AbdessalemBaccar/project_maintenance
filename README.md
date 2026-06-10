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
##  Features

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






