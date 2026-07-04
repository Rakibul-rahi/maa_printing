# Maa Printing Factory Management

Maa Printing Factory Management is a Flutter-based factory accounting and management application designed for managing daily business records of Maa Printing. The system helps authorized users track party accounts, customer accounts, daily production records, stock information, and overall financial summaries from a single dashboard.

The application uses Firebase Authentication for secure login and Cloud Firestore for real-time data storage and updates.

---

## Table of Contents

* [Project Description](#project-description)
* [Features](#features)
* [Technology Stack](#technology-stack)
* [Core Modules](#core-modules)
* [User Roles](#user-roles)
* [Firebase Services Used](#firebase-services-used)
* [Firestore Collections](#firestore-collections)
* [Build APK](#build-apk)
* [Screenshots](#screenshots)
* [Future Improvements](#future-improvements)

---

## Project Description

Maa Printing Factory Management is a private factory management system built to simplify and digitize factory-related accounting tasks. Instead of maintaining manual records, the system allows authorized users to manage important factory data such as customer dues, party payments, daily production, and stock records.

The app is designed for internal use by the factory owner, admin, or editor. Public signup is not available. User access is controlled through Firebase Authentication and Firestore-based role verification.

---

## Features

* Secure login using Firebase Authentication
* Role-based access control
* Admin, editor, and owner access support
* Real-time dashboard using Cloud Firestore
* Total due calculation for Danar Parties
* Total receivable calculation from customers
* Customer account management
* Danar Party account management
* Daily production record management
* Stock record management
* Firebase initialization error handling
* Logout system
* Factory logo-based login interface
* Android APK build support for testing and showcase

---

## Technology Stack

* Flutter
* Dart
* Firebase Core
* Firebase Authentication
* Cloud Firestore
* Firebase Dynamic Links
* Flutter Native Splash
* Flutter Dotenv
* Material UI

---

## Core Modules

### Authentication Module

The app uses Firebase Authentication for secure email and password login. After successful authentication, the system checks the user's role from the Firestore `users` collection.

Only users with approved roles can access the dashboard.

Allowed roles:

```text
admin
editor
owner
```

If a user does not have a valid role, the app signs them out and shows an access denied message.

---

### Dashboard Module

The dashboard provides a quick overview of the factory’s current financial status.

It shows:

* Total due to Danar Parties
* Total receivable from customers
* Navigation buttons for all main accounting modules

The dashboard data updates in real time using Firestore streams.

---

### Danar Party Hishab

This module is used to manage Danar Party account records. It helps track total bills, paid amounts, and remaining due amounts for party accounts.

---

### Customer Hishab

This module is used to manage customer account records. It helps track customer bills, payments, and receivable amounts.

---

### Daily Production Hishab

This module is used to record and manage daily production information of the factory.

---

### Stock Hishab

This module is used to manage stock-related records and inventory information.

---

## User Roles

The app supports role-based access control.

| Role   | Access                                       |
| ------ | -------------------------------------------- |
| owner  | Full access to the factory management system |
| admin  | Administrative access                        |
| editor | Data entry and management access             |

User roles are stored in Cloud Firestore inside the `users` collection.

Example user document:

```json
{
  "role": "admin"
}
```

---

## Firebase Services Used

### Firebase Authentication

Used for secure email/password login.

### Cloud Firestore

Used for storing and retrieving factory data in real time.

### Firebase Core

Used to initialize Firebase in the Flutter application.

### Firebase Dynamic Links

Currently included in the project dependencies. This package is discontinued, so it can be removed if the app does not use dynamic link features.

---

## Firestore Collections

Based on the current project structure, the app uses these Firestore collections:

```text
users
partyAccounts
customerAccounts
```

Possible module-based collections:

```text
stock records
daily production records
```

The exact collection names may depend on the implementation inside each module file.

---

## Build APK

To build a debug APK:

```bash
flutter clean
flutter pub get
flutter build apk --debug
```

The APK will be generated here:

```text
build/app/outputs/flutter-apk/app-debug.apk
```

This APK can be uploaded to Appetize.io for live Android app preview.

To build a release APK:

```bash
flutter build apk --release
```

The release APK will be generated here:

```text
build/app/outputs/flutter-apk/app-release.apk
```

---

## Screenshots

Add screenshots of the application here.

```text
assets/screenshots/login.png
assets/screenshots/dashboard.png
assets/screenshots/stock.png
assets/screenshots/customer.png
```

Example:

```markdown
![Login Screen](assets/screenshots/login.png)
![Dashboard](assets/screenshots/dashboard.png)
```

---

## Current Status

The project currently supports:

* Firebase initialization
* Secure login
* Role-based dashboard access
* Real-time dashboard summary
* Factory accounting module navigation
* APK build for Android testing

---

## Future Improvements

* Add notification system for due reminders and stock alerts
* Add password visibility toggle in login screen
* Add better loading states during login
* Add user management panel for owner/admin
* Add PDF report generation
* Add monthly production report
* Add search and filter options in account modules
* Add backup/export option for accounting data
* Improve responsive UI for web and tablet screens
* Remove Firebase Dynamic Links if unused

---

## Developer Notes

Public signup is disabled. All users should be created and managed by the administrator through Firebase Authentication and Firestore user role documents.

To give a user access, create the user in Firebase Authentication and add a matching document in Firestore:

```text
users/{uid}
```

Example:

```json
{
  "role": "admin"
}
```

Valid roles are:

```text
admin
editor
owner
```

---

## License

This project is developed for Maa Printing Factory internal management use.
