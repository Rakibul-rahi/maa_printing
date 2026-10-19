# Maa Printing Factory Management

A Flutter-based factory accounting and management app for **Maa Printing**. It lets authorized staff track party accounts, customer accounts, daily production, powder stock and ready goods, and chat with each other, all from one app. Firebase Authentication handles login and Cloud Firestore stores data in real time.

---

## Table of Contents

* [Features](#features)
* [Technology Stack](#technology-stack)
* [Core Modules](#core-modules)
* [User Roles and Access](#user-roles-and-access)
* [Firestore Collections](#firestore-collections)
* [Getting Started](#getting-started)
* [Build APK](#build-apk)
* [Screenshots](#screenshots)
* [Live Demo](#live-demo)
* [Future Improvements](#future-improvements)
* [Developer Notes](#developer-notes)

---

## Features

**Accounts and operations**
* Danar Party account management, with transaction history and deletion
* Customer account management, with transaction history and deletion
* Daily production records
* Powder stock management with faster entry
* Ready goods inventory with a history screen, reset and faster entry
* Real-time dashboard with total payable to parties and total receivable from customers

**Security and access**
* Firebase email/password login with email verification
* Role-based access control (owner, admin, editor)
* Request Access screen for new staff, with owners and admins notified of pending requests
* Admin panel to view users and their roles
* Public signup is disabled

**Communication**
* Built-in staff chat with chat list, chat rooms, unread badges and role badges
* In-app notifications page

**User experience**
* Bangla and English language support, switchable from settings
* Light and dark mode
* Redesigned UI with shared theme and reusable widgets
* Responsive layout: width cap on large screens, text scale clamping and adaptive grids for phones, tablets and web
* Per-product colors across the stock and ready goods screens
* Settings sheet for language and theme
* Firebase initialization error handling
* Logo-based login screen with native splash

---

## Technology Stack

* Flutter and Dart (SDK ^3.8.0)
* Firebase Core, Firebase Authentication and Cloud Firestore
* Riverpod (`flutter_riverpod`) for state management
* `flutter_localizations` and `intl` for Bangla/English
* `shared_preferences` for saving language and theme
* Flutter Native Splash and Flutter Launcher Icons
* Material UI

---

## Core Modules

### Authentication
Email/password login through Firebase Authentication. After login, the app checks the user's email verification and their role in the Firestore `users` collection. Users without an approved role are denied access. New staff can submit an access request from the Request Access screen.

### Dashboard
Shows total due to Danar Parties and total receivable from customers, updated live from Firestore. It also has navigation to every module, chat, notifications and settings.

### Danar Party Hishab
Manage party accounts, record bills and payments, view transaction history, and delete transactions.

### Customer Hishab
Manage customer accounts, record bills and payments, view transaction history, and delete transactions.

### Daily Production
Record and review daily production entries.

### Stock (Powder) Hishab
Track powder stock with quick entry and daily stock records.

### Ready Goods
Track finished-goods inventory per product, with color-coded products, a history screen and a reset option.

### Chat
Staff-only messaging with a room list, per-room conversations, unread counts and role badges.

### Notifications
In-app notifications for access requests and other events, targeted by role.

### Admin Panel
Lists all users and their assigned roles.

---

## User Roles and Access

| Role   | Access                                        |
| ------ | --------------------------------------------- |
| owner  | Full access to the factory management system  |
| admin  | Administrative access                         |
| editor | Data entry and management access              |

Roles are stored in the `users` collection:

```json
{
  "email": "user@example.com",
  "role": "admin"
}
```

---

## Firestore Collections

```text
users
accessRequests
notifications
partyAccounts        (with transactions)
customerAccounts     (with transactions)
production_entries
stock / current_stock / daily_stock_records
readyGoods           (with history)
chats                (with messages)
```

Exact structure may vary by module.

---

## Getting Started

1. Clone the repository
   ```bash
   git clone https://github.com/Rakibul-rahi/maa_printing.git
   cd maa_printing
   ```
2. Install dependencies
   ```bash
   flutter pub get
   ```
3. Add your Firebase configuration (`google-services.json` and `firebase_options.dart`). These files are git-ignored.
4. Run the app
   ```bash
   flutter run
   ```

---

## Build APK

```bash
flutter build apk --release
```

The APK is created at `build/app/outputs/flutter-apk/app-release.apk`.

Notes:
* Android `minSdk` is 23 (required by Firebase Auth) and NDK is `27.0.12077973`.
* If your Pub cache is on a different drive than the project, `kotlin.incremental=false` in `android/gradle.properties` avoids Kotlin cache path errors.

---

## Screenshots

```markdown
![Login](assets/screenshots/login.png)
![Dashboard](assets/screenshots/dashboard.png)
![Stock](assets/screenshots/stock.png)
![Chat](assets/screenshots/chat.png)
```

---

## Live Demo

**Live Project:** https://appetize.io/app/b_qfqxsp6q2p2zzeomu2w5tmsnoi

**APK:**  [Download app-release.apk](https://drive.google.com/file/d/1AEbS-ROdaNqcmPsXkqRh7539ohBIuIrX/view?usp=sharing)

---

## Future Improvements

* PDF and monthly production reports
* Search and filter in account modules
* Backup/export of accounting data
* User management (create, edit and remove roles) in the admin panel
* Push notifications for dues and stock alerts
* Remove the discontinued Firebase Dynamic Links package if unused

---

## Developer Notes

Public signup is disabled. To give a user access, either approve their access request, or create the user in Firebase Authentication and add a matching document at `users/{uid}` with a valid role (`owner`, `admin` or `editor`).

---

## License

This project is developed for Maa Printing Factory internal management use.
