### Obsidian Allure

A powerful, fully offline, hierarchical to-do list and career progression tracker built with Flutter. Obsidian Allure helps you organize your goals, domains, and tasks systematically while tracking your progress with engaging gamification mechanics.

## ✨ Features

- **Offline First**: All data is stored locally on your device using Hive. No internet connection required.
- **Hierarchical Structure**: Organize your long-term goals logically into `Domains` → `Subtopics` → `Topics/Tasks`.
- **Gamification**: Stay motivated with XP, streaks, and an interactive activity heatmap.
- **Deep JSON Import & Export**: Easily backup or share your complete curriculum and tasks using a deeply nested JSON format.
- **Beautiful UI**: A sleek, dark-themed interface built for focus and productivity.
- **Cross-Platform**: Neatly designed for optimal experience across mobile phones and tablets.

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (`>=3.3.0 <4.0.0`)
- Android Studio / Xcode (for emulation/building)

### Installation

1. Clone this repository:
   ```bash
   git clone https://github.com/your-username/obsidian-allure.git
   ```
2. Navigate to the project directory:
   ```bash
   cd obsidian-allure
   ```
3. Install dependencies:
   ```bash
   flutter pub get
   ```
4. Run the app:
   ```bash
   flutter run
   ```

### Building the APK
To build a release APK for Android, run:
```bash
flutter build apk --release
```
The output file will be generated at `build/app/outputs/flutter-apk/app-release.apk`.

## 📂 JSON Import/Export Format

Obsidian Allure seamlessly supports importing and exporting your goals via a nested JSON structure. 

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
      "Understand Neural Networks",
      "Learn Backpropagation"
    ]
  }
}
```

## 🛠️ Built With

- **[Flutter](https://flutter.dev/)** - UI Toolkit
- **[Hive](https://docs.hivedb.dev/)** - Fast, lightweight NoSQL local database
- **[Riverpod](https://riverpod.dev/)** - Robust State Management

---

*“Your career journey, beautifully organized.”*
