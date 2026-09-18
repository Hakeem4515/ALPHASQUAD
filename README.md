# ☀️ SOLARX — Smart Solar Lighting Platform

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.44.2-02569B?style=for-the-badge&logo=flutter" alt="Flutter">
  <img src="https://img.shields.io/badge/Dart-3.12.2-0175C2?style=for-the-badge&logo=dart" alt="Dart">
  <img src="https://img.shields.io/badge/Firebase-Backend-FFCA28?style=for-the-badge&logo=firebase" alt="Firebase">
  <img src="https://img.shields.io/badge/Android-15-3DDC84?style=for-the-badge&logo=android" alt="Android">
</p>

<p align="center">
  <strong>Smart monitoring for a smarter and more sustainable future.</strong>
</p>

<p align="center">
  SOLARX is a smart solar lighting monitoring platform designed to connect renewable energy, IoT, intelligent monitoring, and mobile technology in one unified solution.
</p>

---

## 🌍 About The Project

**SOLARX** is a smart solar-powered lighting platform developed to improve the monitoring, management, and reliability of solar lighting systems.

The platform combines **Flutter**, **Firebase**, **IoT technologies**, and intelligent monitoring concepts to provide users with a modern mobile interface for monitoring solar-powered lighting infrastructure.

Instead of relying on manual inspection, SOLARX provides a centralized dashboard where users can monitor system status, analyze performance, receive alerts, and manage their profile.

The project was developed as a team project for a technology competition.

---

## ✨ Key Features

### 📊 Smart Dashboard

A centralized dashboard provides an overview of the solar lighting system, including important system information and operational status.

### 🔋 Battery Monitoring

Monitor battery-related information and system health through an intuitive interface.

### 📈 Analytics

Visualize system data and performance through dedicated analytics screens to make monitoring and decision-making easier.

### 🚨 Smart Alerts

Receive alerts when important system conditions or potential problems are detected.

### 👤 User Authentication

Secure user authentication powered by Firebase Authentication.

Supported authentication functionality includes:

* Email & Password
* Google Sign-In
* Persistent user sessions

### ☁️ Firebase Integration

SOLARX uses Firebase as its cloud infrastructure for application services, authentication, and data management.

The architecture includes:

* Firebase Authentication
* Cloud Firestore
* Firebase Cloud Messaging
* Firebase Storage

### 🔔 Push Notifications

Firebase Cloud Messaging (FCM) is used to support real-time notifications and system alerts.

### 🖼️ Profile Management

Users can manage their profile information and profile image, with profile data synchronized across the application.

### 📱 Responsive Interface

The application is designed to provide a consistent experience across different Android screen sizes, including phones and larger displays.

---

# 🧠 System Concept

SOLARX is designed around the idea of connecting the physical solar lighting system with a cloud-connected mobile application.

```text
┌──────────────────────┐
│   Solar Energy       │
│   ☀️ Solar Panel     │
└──────────┬───────────┘
           │
           ▼
┌──────────────────────┐
│ Smart Lighting       │
│ System               │
│ 💡 + Sensors         │
└──────────┬───────────┘
           │
           ▼
┌──────────────────────┐
│ IoT / Communication  │
│ MQTT / Network       │
└──────────┬───────────┘
           │
           ▼
┌──────────────────────┐
│ Firebase Cloud       │
│ ☁️ Firestore         │
│ 🔔 FCM               │
└──────────┬───────────┘
           │
           ▼
┌──────────────────────┐
│ SOLARX Mobile App    │
│ 📱 Flutter           │
└──────────────────────┘
```

---

# 🏗️ Application Architecture

The Flutter application follows a modular architecture designed to separate UI, services, models, and application logic.

A simplified structure:

```text
lib/
│
├── screens/
│   ├── dashboard/
│   ├── analytics/
│   ├── alerts/
│   ├── settings/
│   └── authentication/
│
├── services/
│   ├── authentication/
│   ├── firebase/
│   ├── notifications/
│   └── storage/
│
├── models/
│
├── widgets/
│
├── utils/
│
└── main.dart
```

> The exact structure may vary depending on the current implementation of the project.

---

# 🛠️ Technologies

| Technology                   | Purpose                                     |
| ---------------------------- | ------------------------------------------- |
| **Flutter**                  | Cross-platform mobile application framework |
| **Dart**                     | Application programming language            |
| **Firebase Authentication**  | User authentication                         |
| **Cloud Firestore**          | Cloud database                              |
| **Firebase Storage**         | User/media storage                          |
| **Firebase Cloud Messaging** | Push notifications                          |
| **MQTT**                     | IoT communication                           |
| **ESP32**                    | Embedded/IoT controller                     |
| **MobileNetV2**              | Lightweight deep-learning model concept     |
| **Git & GitHub**             | Version control and collaboration           |

---

# 🎨 Application Screens

The application includes several main interfaces:

### 🏠 Dashboard

Provides a quick overview of the solar lighting system and its current status.

### 📊 Analytics

Displays system performance and monitoring information.

### 🚨 Alerts

Provides users with important notifications and system warnings.

### ⚙️ Settings

Allows users to manage application and account settings.

### 👤 Profile

Provides user profile information and profile image management.

---

# 🔐 Firebase Architecture

SOLARX uses Firebase services to provide cloud-based application functionality.

### Authentication

Firebase Authentication manages user accounts and authentication.

### Firestore

Cloud Firestore stores application and user-related data.

Example conceptual user document:

```text
users/{uid}
│
├── uid
├── email
├── displayName
├── photoUrl
├── role
├── fcmToken
├── provider
├── createdAt
└── lastLoginAt
```

### Storage

Firebase Storage can be used for user profile images and other application media.

### Cloud Messaging

Firebase Cloud Messaging provides push notification functionality.

---

# 🚀 Getting Started

## Prerequisites

Before running the project, make sure you have installed:

* Flutter SDK
* Dart SDK
* Android Studio
* Android SDK
* Git
* A Firebase project

Verify Flutter installation:

```bash
flutter doctor
```

---

## 📥 Installation

Clone the repository:

```bash
git clone https://github.com/YOUR_GITHUB_USERNAME/SOLARX.git
```

Navigate to the project:

```bash
cd SOLARX
```

Install dependencies:

```bash
flutter pub get
```

Run the application:

```bash
flutter run
```

---

# 🔥 Firebase Configuration

For security reasons, Firebase configuration files and credentials should be handled carefully.

Before running the project, configure your own Firebase project and add the required Firebase configuration files.

For Android:

```text
android/app/google-services.json
```

Do not commit private credentials, signing keys, or sensitive configuration files to a public repository.

---

# 🏭 Build Release APK

To generate a release APK:

```bash
flutter build apk --release
```

The generated APK can be found at:

```text
build/app/outputs/flutter-apk/app-release.apk
```

For an optimized and obfuscated release:

```bash
flutter build apk --release --obfuscate --split-debug-info=debug-info
```

---

# 🧪 Testing

Before creating a production release, verify:

* User registration
* Email login
* Google Sign-In
* Firebase authentication persistence
* Dashboard functionality
* Analytics
* Alerts
* Profile image loading
* Profile image synchronization
* Firebase data access
* Push notifications
* Application behavior after restart

---

# 🔒 Security

Never commit sensitive information such as:

```text
*.jks
*.keystore
key.properties
private API credentials
service account credentials
```

Firebase security rules should also be configured appropriately before deploying the application to production.

---

# 🤝 Team Collaboration

SOLARX was developed as a collaborative project.

We use **Git and GitHub** for version control and team collaboration.

Recommended workflow:

```text
main
 │
 ├── develop
 │
 ├── feature/dashboard
 │
 ├── feature/analytics
 │
 ├── feature/authentication
 │
 └── feature/profile
```

Example commit messages:

```text
feat: add Google authentication
feat: add analytics dashboard
fix: resolve profile avatar synchronization
fix: improve Firebase authentication flow
refactor: improve dashboard architecture
docs: update project documentation
```

---

# 📸 Screenshots

> Add your application screenshots here.

Example:

```text
docs/
└── screenshots/
    ├── login.png
    ├── dashboard.png
    ├── analytics.png
    ├── alerts.png
    └── settings.png
```

Then display them in the README:

```markdown
<p align="center">
  <img src="docs/screenshots/dashboard.png" width="250">
  <img src="docs/screenshots/analytics.png" width="250">
  <img src="docs/screenshots/alerts.png" width="250">
</p>
```

---

# 🎯 Project Goals

SOLARX aims to contribute toward smarter and more sustainable solar lighting infrastructure by combining:

* ☀️ Renewable Energy
* 💡 Smart Lighting
* 📡 IoT Connectivity
* 🤖 Intelligent Monitoring
* ☁️ Cloud Technology
* 📱 Mobile Applications
* 🌱 Sustainable Infrastructure

The long-term vision is to create a connected monitoring ecosystem that helps organizations manage solar-powered lighting systems more efficiently and make better operational decisions.

---

# 🚧 Future Improvements

Potential future development includes:

* Real-time IoT device integration
* Advanced AI-based fault detection
* Predictive maintenance
* Real-time device location tracking
* Advanced energy consumption analytics
* Multi-device management
* Admin dashboard
* Automated system diagnostics
* Expanded notification and alert rules
* iOS support
* Cloud-based reporting

---

# 📄 License

This project is currently intended for educational, competition, and portfolio purposes.

If you plan to distribute or commercially use the project, add an appropriate open-source license such as MIT, Apache-2.0, or another license that matches the team's requirements.

---

# 👥 Team

### AlphaSquad

**Project:** SOLARX — Smart Solar Lighting Platform

Developed by:

* **Abdul Hakeem Haider**
* **[Teammate Name]**

GitHub:

* [@YOUR_GITHUB_USERNAME](https://github.com/YOUR_GITHUB_USERNAME)
* [@FRIEND_GITHUB_USERNAME](https://github.com/FRIEND_GITHUB_USERNAME)

---

# 🌟 Acknowledgments

Special thanks to the technologies and open-source communities that made this project possible:

* Flutter
* Dart
* Firebase
* Android
* ESP32
* MQTT
* TensorFlow / MobileNetV2
* GitHub

---

<p align="center">
  <strong>☀️ SOLARX</strong><br>
  <em>Smarter Monitoring. Sustainable Energy. Better Future.</em>
</p>
