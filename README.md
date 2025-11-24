# 🩺 AayuTrack – Smart Health Monitoring & Wellness Application

**Developed by:** CodeXwarriors
**Institution:** Dr. D.Y. Patil Pratishthan’s College of Engineering, Salokhenagar, Kolhapur

**GitHub Repository:** [https://github.com/codeXwarrior4/AayuTrack](https://github.com/codeXwarrior4/AayuTrack)

---

## 📌 Project Overview

AayuTrack is a smart health monitoring and wellness mobile application designed to assist users in tracking vital health metrics, managing medication reminders, analyzing health progress, and promoting healthy lifestyle habits. This project is currently developed as a functional prototype representing approximately **60–70% of the complete system**, focusing on core health tracking and reminder functionalities.

The application aims to bridge the gap between daily health monitoring and intelligent health insights with an intuitive, user-friendly interface.

---

## 🎯 Objective

To create a scalable, intelligent healthcare assistant that empowers individuals to:

* Monitor daily vitals
* Maintain medication schedules
* Improve health discipline
* Access basic AI-based insights
* Track long-term wellness progress

---

## 🚀 Key Features (Implemented in Prototype)

### ✅ Core Functionalities

* Real-time Dashboard for Health Overview
* Daily Wellness Tracking
* Medication Reminder System with Alarm-style popups
* Voice-based Health Reminders (Text-to-Speech)
* Local Data Persistence using Hive
* Manual Entry for Blood Pressure & SpO2
* Health Streak Tracking (Steps, Hydration, Medication)
* Report Generation (PDF Summary)
* Multi-language Support
* Dark Mode & Light Mode Support
* Smart Navigation & Clean UI

### 🩺 Health Monitoring

* Steps Tracking
* Heart Rate Display
* Blood Pressure Logging (Systolic/Diastolic)
* Oxygen Saturation (SpO2)
* Hydration Monitoring

### 🔔 Reminder System

* Scheduled reminders
* Daily recurring reminders
* Alarm-style UI popups
* Persistent reminders even after app restart

---

## 🛠️ Technical Stack

### ✅ Current Prototype Technologies

* **Framework:** Flutter 3.35.7 (Stable Channel)
* **Language:** Dart 3.9.2
* **Local Database:** Hive (NoSQL)
* **Notifications:** flutter_local_notifications
* **State Management:** setState + InheritedWidget
* **PDF Generation:** Custom Flutter PDF Services
* **Platform Target:** Android

### ✅ Development Environment

* Flutter SDK: 3.19.0
* Dart SDK: 3.3.0
* Android SDK: API Level 24+
* IDE Used: Visual Studio Code
* Build Mode: Debug & Release Supported

---

## 🧠 Architecture Overview

```
UI Layer (Flutter Widgets)
        ↓
Service Layer (Notification, Health, Storage)
        ↓
Data Layer (Hive Database)
```

The prototype follows a modular architecture separation for future scalability and maintainability.

---

## 📂 Project Structure Highlights

lib/
├── services/
│   ├── notification_service.dart
│   ├── data_storage_service.dart
│   └── health_service.dart
├── models/
├── screens/
├── widgets/
└── main.dart

---

## 🔮 Future Scope & Upgrades

Currently, AayuTrack uses Hive for lightweight local storage suitable for prototyping. In future production versions, the application will be upgraded with more powerful and scalable technologies including:

### 🔧 Planned Enhancements

* ✅ Migration from Hive to Cloud-Based Databases (Firebase / MongoDB / PostgreSQL)
* ✅ Real-time synchronization across devices
* ✅ Advanced AI-powered health predictions
* ✅ Doctor-Patient Telemedicine System
* ✅ Secure user authentication (OAuth, JWT)
* ✅ Health API Integration (Google Fit / Apple Health)
* ✅ Predictive Analytics Dashboard
* ✅ Smart Wearable Device Connectivity
* ✅ Remote Health Monitoring System
* ✅ Role-based user management

These upgrades will dramatically enhance performance, data security, scalability, and intelligence of the system.

---

## 🧪 Prototype Status

✅ Functional UI and core features completed
🟡 Advanced AI features under development
🟡 Cloud integration planned
🔴 Full production deployment pending

---

## 📈 Innovation Focus

AayuTrack integrates modern healthcare concepts with emerging mobile technologies to deliver a preventive healthcare ecosystem focused on:

* Lifestyle improvement
* Health accountability
* Continuous monitoring
* Intelligent reminders

---

## 👨‍💻 Development Team

**Team Name:** CodeXwarriors

From: Dr. D.Y. Patil Pratishthan’s College of Engineering, Kolhapur

---

## 📜 License

This project is developed as an academic prototype and is intended for demonstration and educational purposes only. Commercial deployment is reserved for future development phases.

---

## 📧 Contact

For academic collaboration or technical queries, please contact the CodeXwarriors development team through GitHub repository issues.

---

✅ This README reflects current prototype status and outlines the roadmap for a production-ready healthcare application ecosystem.

---

## 📸 Screenshots

> *Hackathon Prototype Visuals*
> The following screenshots showcase the current user interface and core functionality implemented during the hackathon phase:

* **Dashboard Overview** – Real-time vitals monitoring UI
* **AI Health Checkup Screen** – Symptom input and AI-based guidance
* **Smart Reminders Interface** – Alarm-style health reminders
* **Reports & PDF Export Screen** – Auto-generated health summaries
* **Breathing Exercise Module** – Guided wellness animations

*(Add actual screenshots here by embedding images using GitHub markdown syntax)*

```md
![Dashboard](screenshots/dashboard.png)
![AI Checkup](screenshots/ai_checkup.png)
![Reminders](screenshots/reminders.png)
![Reports](screenshots/reports.png)
```

> ℹ️ Create a `/screenshots` folder in your repository and place all UI images there for proper rendering on GitHub.
