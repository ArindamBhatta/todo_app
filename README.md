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

## 📄 License

MIT License (or your preferred license)

---

## 👨‍💻 Author

Built as a personal system to explore:

* Context-aware computing
* Scalable Flutter architecture
* Intelligent task management systems

---
