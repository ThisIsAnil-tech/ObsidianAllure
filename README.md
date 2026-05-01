<div align="center">
  <h1>🌟 Obsidian Allure</h1>
  <p><b>Your Offline, Gamified Career & Goal Tracker</b></p>

  <p>
    <img alt="Platform" src="https://img.shields.io/badge/Platform-Android%20%7C%20iOS-blue?style=flat-square">
    <img alt="Framework" src="https://img.shields.io/badge/Framework-Flutter-02569B?style=flat-square&logo=flutter&logoColor=white">
    <img alt="Database" src="https://img.shields.io/badge/Database-Hive-orange?style=flat-square">
    <img alt="Offline First" src="https://img.shields.io/badge/Offline-100%25-success?style=flat-square">
  </p>
</div>

---

**Obsidian Allure** is a powerful, fully offline, hierarchical to-do list and progression tracker. Built with Flutter, it helps you organize complex goals systematically while keeping you highly motivated through interactive gamification and advanced productivity tools.

## ✨ Key Features

- 🗂️ **Infinite Hierarchies:** Organize your long-term goals logically into `Domains` → `Subtopics` → `Topics` → `Tasks`. Go as deep as you need!
- 🏆 **Gamification Engine:** Stay motivated by earning XP, leveling up, maintaining daily streaks, and filling out your activity heatmap.
- 🍅 **Focus Mode (Pomodoro):** Launch a built-in 25-minute Pomodoro timer directly from any task. Completing a focus session rewards you with massive XP bonuses!
- ❤️ **Favorites System:** "Like" any task to instantly save it to your Favorites Page, accessible straight from the bottom navigation bar.
- ↩️ **Safe Deletions:** Accidental tap? No problem. Enjoy a 4-second **Undo** safety net whenever you delete a task or folder.
- 📋 **Template Duplication:** Easily duplicate entire root folders and their deeply nested contents to create reusable syllabus or project templates.
- 📊 **Enhanced Analytics:** Track your overall progress dynamically with top-level category breakdowns and task completion percentages.
- 🎨 **Dynamic Theming:** Switch between "Boys" (Brown/Earthy) and "Girls" (Pink/Vibrant) aesthetic variants, alongside full Light/Dark mode support.
- 📦 **Deep JSON Import & Export:** Back up your entire curriculum offline or share it using a clean, deeply nested JSON format.

## 🚀 Getting Started

### Prerequisites
- [Flutter SDK](https://flutter.dev/docs/get-started/install) (`>=3.3.0 <4.0.0`)
- Android Studio / VS Code (for emulation/building)

### Installation

1. **Clone this repository:**
   ```bash
   git clone https://github.com/ThisIsAnil-tech/ObsidianAllure.git
   ```
2. **Navigate to the project directory:**
   ```bash
   cd obsidian-allure
   ```
3. **Install dependencies:**
   ```bash
   flutter pub get
   ```
4. **Run the app:**
   ```bash
   flutter run
   ```

## 🛠️ Building the APK
To build a release APK for Android deployment, run:
```bash
flutter build apk --release
```
*The output file will be generated at `build/app/outputs/flutter-apk/app-release.apk`.*

## 📂 JSON Import/Export Format

Obsidian Allure supports importing and exporting massive goal trees instantly. 

**Example format:**
```json
{
  "Data Science": {
    "Machine Learning": {
      "Supervised Learning": [
        "Linear Regression",
        "Logistic Regression"
      ]
    },
    "Deep Learning": [
      "Understand Neural Networks"
    ]
  }
}
```

## 🏗️ Architecture Stack

- **[Flutter](https://flutter.dev/)** - UI Toolkit
- **[Hive](https://docs.hivedb.dev/)** - Fast, lightweight NoSQL local database
- **[Riverpod](https://riverpod.dev/)** - Robust State Management
- **[Shared Preferences](https://pub.dev/packages/shared_preferences)** - Local storage for aesthetic toggles and likes

---
<div align="center">
  <p><i>“Your career journey, beautifully organized.”</i></p>
</div>
