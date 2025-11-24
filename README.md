# Aayu Track – Smart Health Monitoring & Reminder System (Prototype)

## 👨‍💻 Developed By

**codeXwarriors**
Dr. D.Y. Patil Pratishthan’s College of Engineering, Salokhenagar, Kolhapur

GitHub Repository: [https://github.com/codeXwarrior4/AayuTrack](https://github.com/codeXwarrior4/AayuTrack)

---

## 📌 Project Overview

**AayuTrack** is a Flutter-based intelligent health monitoring and reminder system designed as an assistive digital healthcare prototype. The application integrates real-time health data tracking, smart medication reminders, and wellness guidance to improve adherence, awareness, and daily health management.

This prototype focuses on combining preventive healthcare principles with mobile automation, providing users with actionable insights and scheduled interventions.

---

## 🧠 System Architecture

The application follows a modular layered architecture:

* **UI Layer:** Flutter Widgets + Material Design
* **Logic Layer:** Services for health data processing & reminders
* **Storage Layer:** Hive (local NoSQL database)
* **Notification Engine:** flutter_local_notifications + Timezone scheduling
* **External Integration:** Health APIs (Steps, Heart Rate)

```
User Interface
      ↓
State Management
      ↓
Services Layer
      ↓
Local Database (Hive)
      ↓
Notification & Alarm Engine
```

---

## ⚙️ Technologies Used

* Flutter (Dart)
* Hive Database
* flutter_local_notifications
* Google Health API / Device Sensors
* PDF Generator Service
* Timezone Scheduling
* Android Native Exact Alarm Handling

---

## ✅ Core Functional Modules

### 1. Health Vital Monitoring

* Steps Tracking
* Heart Rate Monitoring
* Hydration Logging
* Blood Pressure (Manual + Auto)
* SpO2 Monitoring

### 2. Medication Reminder System

* One-time reminders
* Daily recurring alarms
* High-priority alarm notifications
* Voice-based reminder alerts
* Pop-up alarm interface

### 3. Wellness Assistant

* Guided Breathing Exercises
* Motivational Health Tips
* Daily Habit Encouragement Engine

### 4. Reporting Engine

* Automated PDF Health Report
* Time-stamped vitals history
* Doctor consultation-ready summary

---

## 🔔 Notification Engine Specifications

* Uses Android Exact Alarm Permission
* Full-screen alarm popup
* Auto-reschedule on app restart
* Alarm channel prioritization
* Persistent scheduling via Hive

Supported modes:

* Instant Alerts
* Delayed One-time Alarms
* Daily Fixed-Time Alarms

---

## 📂 Directory Structure (Simplified)

```
lib/
 ├── services/
 │     ├── notification_service.dart
 │     ├── health_service.dart
 │     ├── pdf_service.dart
 ├── models/
 │     ├── vitals_model.dart
 ├── screens/
 │     ├── dashboard_screen.dart
 │     ├── breathing_exercise_screen.dart
 ├── widgets/
 │     ├── stat_card.dart
 └── main.dart
```

---

## 🚀 Application Workflow

1. User opens Dashboard
2. Real-time vitals displayed
3. Reminder scheduling engine active
4. Health alerts trigger
5. Reports generated on demand
6. Data stored securely offline

---

## 🔐 Security & Privacy

* All data stored locally on device
* No cloud sync in prototype phase
* Encrypted Hive storage planned for next version

---

## 📈 Current Development Status

✅ UI Framework Complete
✅ Reminder Engine Stable
✅ Health Tracking Integrated
✅ PDF Reports Functional
⏳ AI Recommendations (Planned)

Completion Level: **60%**

---

## 🎯 Target Users

* Elderly Patients
* Chronic Disease Patients
* Fitness Enthusiasts
* Medical Students for Self Monitoring

---

## 📌 Future Enhancements

* AI Health Prediction
* Cloud Backup & Sync
* Doctor Portal Integration
* Emergency SOS Alerts
* Multilingual Support

---

## 🧪 Prototype Purpose

This application is developed as an academic and functional prototype showcasing modern digital healthcare automation and reminder-based intervention systems for improving patient health adherence.

---

## 📞 Contact

codeXwarriors Team
Dr. D.Y. Patil Pratishthan’s College of Engineering
Kolhapur, Maharashtra

---

⭐ If you like this prototype, consider starring the repository!
