# 📌 Context-Aware To-Do App (Flutter, Android)

A **context-driven, intelligent to-do application** built with Flutter, designed to go beyond basic task management. This app leverages **location awareness, scheduling intelligence, and adaptive notifications** to surface the *right task at the right time*.

---

## 🚧 Project Status

> In active development — focused on building a **mature personal productivity system**, not just a CRUD to-do app.

---

## 🎯 Core Philosophy

Most to-do apps fail because they:

* Show static lists
* Ignore user context
* Overload decision-making

This app focuses on:

> **Context + Timing + Relevance = Actionable Tasks**

---

## ✨ Features

### 1. 📍 Geofencing-Based Task Visibility

* Detects when the user enters a predefined location (e.g., office)
* Dynamically filters and surfaces **location-relevant tasks**

---

### 2. 🔔 Smart Notifications (FCM)

* Deadline-based reminders using Firebase Cloud Messaging
* Designed to evolve into:

  * Adaptive reminders
  * Escalation logic for ignored tasks

---

### 3. ☁️ Cloud Storage (Firebase DataConnect)

* Tasks are persisted in Firebase
* Structured for scalability and future analytics

---

### 4. ⏱ Task Lifecycle Management

Each task follows a defined lifecycle:

```
planned → active → snoozed → completed → archived
```

---

### 5. 😴 Snooze & Deferral System

* Temporarily defer tasks
* Enables real-world usability (not rigid reminders)

---

### 6. 🔄 Offline-First Architecture (Planned / In Progress)

* Local database for fast access
* Sync layer with Firebase
* Conflict resolution strategy

---

## 🧠 Planned Intelligent Features

### Smart Scheduling Engine

* Effort estimation (e.g., 30 min, 2 hrs)
* Soft vs Hard deadlines
* Auto task suggestions based on available time

---

### Context Engine (Extended)

* Location (Geofencing)
* Time (morning / evening)
* Device state (WiFi, activity)

---

### Priority Scoring Model

Instead of static priorities:

```
priorityScore = urgency + contextMatch + manualWeight
```

---

### 📊 Analytics Layer

* Track completion rates
* Identify delay patterns
* Suggest optimal productivity windows

---

### 🔁 Recurring Task Engine

* Support for:

  * Daily / Weekly patterns
  * Custom recurrence rules
  * Exception handling

---

### ⚡ Energy-Based Task Tagging

* Low effort / deep work classification
* Helps in selecting tasks based on mental state

---

## 🏗 Architecture

This project follows a **clean, scalable architecture**:

```
lib/
│
├── presentation/     # UI (Flutter widgets, state management)
├── domain/           # Business logic (entities, use-cases)
├── data/             # Repositories, Firebase, local DB
└── core/             # Utilities, constants, helpers
```

### Key Principles:

* Separation of concerns
* Testable domain logic
* Minimal logic in UI layer

---

## 🛠 Tech Stack

* **Frontend:** Flutter (Android-focused)
* **Backend:** Firebase DataConnect
* **Notifications:** Firebase Cloud Messaging (FCM)
* **Location Services:** Geofencing APIs
* **(Planned)** Local DB: Isar / Hive / Drift

---

## 📱 Platform Support

| Platform | Status                   |
| -------- | ------------------------ |
| Android  | ✅ Primary                |
| iOS      | ⏳ Not targeted currently |

---

## 🚀 Getting Started

### Prerequisites

* Flutter SDK
* Android Studio / VS Code
* Firebase project configured

---

### Installation

```bash
git clone <your-repo-url>
cd <project-folder>
flutter pub get
```

---

### Run the App

```bash
flutter run
```

---

## 🔐 Firebase Setup

1. Create a Firebase project
2. Enable:

   * Firestore / DataConnect
   * Cloud Messaging (FCM)
3. Add `google-services.json` to:

```
android/app/
```

---

## ⚠️ Known Challenges

* Reliable geofencing in background (Android restrictions)
* Notification delivery consistency (battery optimizations)
* Sync conflicts in offline-first mode

---

## 📌 Roadmap

* [ ] Basic task CRUD
* [ ] Geofencing integration
* [ ] FCM reminders
* [ ] Snooze system
* [ ] Local database integration
* [ ] Sync engine
* [ ] Smart scheduling
* [ ] Analytics dashboard

---

## 🤝 Contribution

This is currently a **personal project**, but suggestions and architectural discussions are welcome.

---

## 🧭 Long-Term Vision

To evolve from:

> A simple to-do list

Into:

> A **personal productivity engine** that adapts to user behavior and context.

---

# 📌 Context-Aware To-Do App — Build Log (Weekend Scope)

> **Purpose of this build:** Not a startup MVP. This is a **skills-proof project** to close 5 specific
> interview gaps: SQLite, background notifications, Crashlytics, permission handling, and Play Store deployment.
> Everything below is scoped to what's realistically shippable in 3 days (Fri–Sun).
> Anything fancier (geofencing, sync engines, analytics, recurring tasks) is moved to a **"Later / Not This Weekend"** list at the bottom — build it only after you have interviews lined up.

---

## ⚠️ Scope Correction

Your original README describes Firebase DataConnect, geofencing, priority-scoring models, and an analytics layer.
Your `pubspec.yaml` currently has **none of the packages needed for that** (no `firebase_core`, no `geolocator`,
no `workmanager`). Building what's in this doc first — in order — is what actually gets you interview-ready by Sunday night.

---

## ✅ Step-by-Step Build Checklist

Test each step on your physical device (USB or wireless debugging) before moving to the next. Don't batch untested code.

### Step 1 — SQLite (Core Data Layer)
- [ ] Add `sqflite` + `path` (already in pubspec ✅)
- [ ] Create `todo.db` with a single `todos` table: `id, title, description, location, isDone, createdAt`
- [ ] Write CRUD functions: `insertTodo`, `getTodos`, `updateTodo`, `deleteTodo`
- [ ] Wire CRUD to UI: add a todo, see it in the list, mark done, delete
- [ ] **On-device test:** kill the app fully, reopen, confirm todos persist
- [ ] **Interview note to write after:** "Why SQLite here and not shared_preferences?" → because todos are structured, queryable records, not a single key-value setting

### Step 2 — shared_preferences (Contrast Case)
- [ ] Use `shared_preferences` (already in pubspec ✅) for exactly one thing: a simple app setting (e.g. dark mode toggle, or "has seen onboarding" flag)
- [ ] **On-device test:** toggle it, kill app, reopen, confirm it persisted
- [ ] **Interview note:** now you have a real example of both, side by side, in the same app

### Step 3 — Permissions (Do the Denial Path Too)
- [ ] Add `permission_handler`
- [ ] Request **notification permission** (required explicitly on Android 13+/API 33)
- [ ] Request **location permission** (for "in-office" todos)
- [ ] Test the **happy path**: grant → feature works
- [ ] Test the **denial path**: deny → app doesn't crash, shows a fallback message
- [ ] Test **"don't ask again"** → app directs user to `openAppSettings()`
- [ ] **Interview note:** this denial-path testing is the part almost nobody does — it's what separates "used a package" from "understands permissions"

### Step 4 — Background Notifications
- [ ] Add `firebase_core`, `firebase_messaging` (not yet in your pubspec — add them)
- [ ] Add `workmanager`
- [ ] Set up Firebase project, add `google-services.json` to `android/app/`
- [ ] Schedule a periodic background task with WorkManager
- [ ] Trigger a local notification via `awesome_notifications` (already in pubspec ✅) from the background callback
- [ ] **On-device test:** fully close the app, wait for the scheduled window, confirm notification fires
- [ ] **Interview note:** write down what happened when you tested this on a real device with battery optimization on — that anecdote is worth more than the textbook definition of Doze mode

### Step 5 — Location-Aware Todos
- [ ] Add `geolocator`
- [ ] Get current location, store it with the todo (e.g. "in-office" tag)
- [ ] Filter/highlight todos when current location matches a saved todo's location
- [ ] Keep this simple — a distance check (e.g. within 200m), **not** true geofencing (Android's geofencing API is a rabbit hole, skip it this weekend)

### Step 6 — Weather Check (Your Rain Feature)
- [ ] Call a free weather API (OpenWeatherMap has a free tier) using `http` (not in pubspec — add it)
- [ ] If rain is detected in the forecast, fire a notification: "Rain expected — check your in-office todos"
- [ ] This can piggyback on the same WorkManager periodic task from Step 4

### Step 7 — Offline Handling
- [ ] Add `connectivity_plus`
- [ ] Confirm the app works fully with no internet (SQLite is already local, so this should mostly work already)
- [ ] Show a small "offline" indicator when there's no connection
- [ ] Skip building a full sync queue — that's a "later" feature, not this weekend

### Step 8 — Crashlytics
- [ ] Add `firebase_crashlytics`
- [ ] Initialize it in `main.dart`
- [ ] Deliberately throw a test exception, confirm it shows up in the Firebase console
- [ ] **Interview note:** "I set up Crashlytics and verified it by triggering a test crash" is a complete answer

### Step 9 — App Lifecycle Handling
- [ ] Add a `WidgetsBindingObserver` to the main widget
- [ ] Log lifecycle changes: `resumed`, `inactive`, `paused`, `detached`
- [ ] Save any in-progress state (e.g. draft todo text) when the app pauses
- [ ] Only takes ~30 minutes — don't skip it, it directly answers a common gap question

### Step 10 — Release Build + Play Store
- [ ] Generate a release keystore: `keytool -genkey -v -keystore release-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload`
- [ ] Configure `key.properties` + signing config in `android/app/build.gradle`
- [ ] Build the release bundle: `flutter build appbundle --release`
- [ ] Create a Play Console account (₹1999 one-time registration)
- [ ] Create an app listing, upload the AAB to the **internal testing track** (doesn't need to go public)
- [ ] **This step alone answers "how do you deploy to Play Store" with real, first-hand experience**

---

## 🧠 Gap → Feature Mapping (For Your Own Reference)

| Interview Question That Tripped You Up | Step That Fixes It |
|---|---|
| What is Crashlytics? | Step 8 |
| How do you deploy to Play Store? | Step 10 |
| How do you implement background workers? | Step 4 |
| Why SQLite over shared_preferences? | Steps 1 + 2 |
| Why shared_preferences at all? | Steps 1 + 2 |
| (Bonus) App lifecycle / permission handling | Steps 3 + 9 |

---

## 🎨 UI Reference (You're Not a Designer — Use These)

Don't design from scratch. Duplicate a free kit and reskin it with your own colors/fonts (you already have `flutter_colorpicker` and `google_fonts` in your pubspec, which suggests you were already planning to customize a base theme).

- **Figma's own free Mobile UI Kit** — general-purpose components (lists, cards, nav bars), good base to reskin: https://www.figma.com/templates/mobile-ui-kit/
- **Figma Community — Mobile UI templates (browse many free options)**: https://www.figma.com/community/mobile-apps/ui
- **Figma Community — UI Kits directory** (search "to-do" or "task manager" once inside): https://www.figma.com/community/ui-kits

Pick one, duplicate it into your own Figma account (free), swap colors/type, and build your screens against it. Don't spend more than an hour choosing — any clean list-based kit works for a todo app.

---

## 🚫 Not This Weekend (Move to "Later")

These are in your original README's ambition but will turn this into a 3-week project if you touch them now:

- True Android Geofencing API (background-restricted, genuinely hard to get reliable)
- Firebase DataConnect / full sync engine with conflict resolution
- Priority scoring model (`urgency + contextMatch + manualWeight`)
- Recurring task engine with exception handling
- Analytics dashboard / completion-rate tracking
- Energy-based task tagging

Build these **after** you have interviews scheduled or an offer — not before.

---

## 📦 Updated Dependencies Needed (Add to pubspec.yaml)

```yaml
firebase_core: ^3.0.0
firebase_messaging: ^15.0.0
firebase_crashlytics: ^4.0.0
workmanager: ^0.5.2
geolocator: ^12.0.0
connectivity_plus: ^6.0.0
permission_handler: ^11.3.0
http: ^1.2.0
```

(Keep everything already in your current pubspec — `sqflite`, `shared_preferences`, `awesome_notifications`, `riverpod`, `go_router`, etc. are all correctly chosen for this scope.)
