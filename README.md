<p align="center">
  <img src="assets/TT_Logo.png" alt="Travel Trust Logo" width="120"/>
</p>

<h1 align="center">🌍 Travel Trust</h1>

<p align="center">
  <strong>Unified Agency Management System for Travel Agents, Hoteliers & Cab Drivers</strong>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.10+-02569B?logo=flutter" alt="Flutter"/>
  <img src="https://img.shields.io/badge/Dart-3.10+-0175C2?logo=dart" alt="Dart"/>
  <img src="https://img.shields.io/badge/Firebase-Backend-FFCA28?logo=firebase" alt="Firebase"/>
  <img src="https://img.shields.io/badge/License-MIT-green" alt="License"/>
  <img src="https://img.shields.io/badge/Platform-Android%20%7C%20Web-blue" alt="Platform"/>
</p>

---

## 📖 Overview

**Travel Trust** is a multi-platform solution built with **Flutter** and **Firebase** that streamlines booking verifications between Travel Agents, Hoteliers, and Cab Drivers. The system features an Android management app for agents and specialized web portals for customers and the public.

Travel Agents generate unique verification tokens that link a Hotel and a Cab provider to a single booking. Each provider independently approves or rejects their part of the booking. Once both approve, the agent can send a confirmation email with a secure verification link to the customer.

---

## ✨ Features

### 🔐 Authentication & User Management

- **Passwordless OTP Login** — Users authenticate via a 4-digit numeric OTP sent to their registered email (SMTP via Gmail).
- **Email Verification on Registration** — New users must verify their email with an OTP before their account is created.
- **Role-Based Registration** — Users register as one of three roles: **Travel Agent**, **Hotelier**, or **Cab Driver**.
- **Business Profile** — Each user has a profile with Name, Business Name, Email, Phone, and Role.

### 🎫 Token-Based Booking System

- **Unified Token Creation** — Travel Agents select one Hotelier and one Cab Driver, then generate a single booking token that links all three parties.
- **Room & Cab Specifications** — Tokens include Room Type & Room Count for hotels and Cab Type & Seats for cab providers.
- **Date Range Selection** — Each token has a Booking Date and Expiry Date set via a date range picker.
- **Dual-Approval Workflow** — Both the Hotelier and Cab Driver must independently approve the token. If either rejects, the overall status is set to "Rejected". Only when both approve does the overall status become "Approved".
- **Three-Tier Status Tracking** — Every token tracks `hotelStatus`, `cabStatus`, and `overallStatus` independently (Pending → Approved / Rejected).
- **Server-Side Timestamps** — Tokens are timestamped using Firestore's `FieldValue.serverTimestamp()` for accurate chronological ordering.

### 👤 Role-Specific Dashboards

#### Travel Agent Dashboard
- **Provider Directory** — Browse all registered Hoteliers and Cab Drivers in a real-time, filterable list.
- **Sort & Filter** — Filter providers by role: All, Hotels only, or Cabs only using interactive filter chips.
- **Select & Deselect** — Select one Hotelier and one Cab Driver for a booking, with visual indicators (green highlight) and validation.
- **One-Click Token Generation** — Create a unified booking token via a dialog with room type, cab type, and date range inputs.
- **Send Confirmation Email** — For fully approved tokens, open the device mail app with a pre-filled booking confirmation email containing a customer verification link.

#### Hotelier Dashboard
- **Incoming Requests Feed** — View all pending booking requests from Travel Agents in real time.
- **Approve / Reject Actions** — One-tap approve or reject buttons for each incoming request.
- **Agent Contact Info** — See the requesting agent's business name and phone number for each token.
- **Hotel Requirement Details** — View the specific room type and count requirements for each booking.

#### Cab Driver Dashboard
- **Incoming Requests Feed** — View all pending booking requests from Travel Agents in real time.
- **Approve / Reject Actions** — One-tap approve or reject buttons for each incoming request.
- **Agent Contact Info** — See the requesting agent's business name and phone number for each token.
- **Cab Requirement Details** — View the specific cab type and seat requirements for each booking.

### 📊 Analytics & History

- **Activity Heatmap** — GitHub-style contribution heatmap visualizing token creation activity over time, powered by `flutter_heatmap_calendar`.
- **Heatmap Time Filters** — Toggle between 6-month and 1-year views with filter chips.
- **Scrollable Heatmap** — Horizontally scrollable heatmap with visible scrollbar for easy navigation.
- **Token History List** — Complete chronological list of all tokens with detailed status, timestamps, and contact information.
- **Role-Aware History** — Token details adapt based on the logged-in user's role (agents see both providers; providers see only the agent).

### 👤 Profile & Statistics

- **User Profile View** — Displays Name, Business Name, Role, Email, and Phone.
- **Token Statistics Cards** — Visual summary cards showing counts of Approved, Pending, and Rejected tokens.
- **Total Token Counter** — Aggregate count of all tokens associated with the user.
- **Auto-Refresh** — Statistics automatically refresh when navigating to the Profile tab.

### 📧 Customer Communication

- **Email Verification Links** — Agents can send booking confirmation emails to customers with a secure web link.
- **Deep Link to Customer Portal** — Emails contain a URL pointing to the Firebase-hosted Customer Portal where customers can verify booking details.
- **Mail App Integration** — Uses `url_launcher` to open the default mail app with pre-filled subject, body, and recipient.

### 🌐 Multi-Site Firebase Hosting

- **Customer Verification Portal** — A dedicated web app hosted on Firebase where travelers can view and verify their booking details via the token link.
- **Public Website** — An informational website with agent search and profile heatmaps, hosted on a separate Firebase Hosting site.
- **Android Management App** — The core mobile application for agents and providers to manage tokens.

### 🎨 UI / UX

- **Dark Theme** — Sleek dark mode UI with Material 3 design, using a blueGrey color scheme.
- **Custom Color Palette** — Dark backgrounds (`#121212`, `#1E1E2C`, `#2A2A3C`) with contrasting accent colors.
- **Rounded Input Fields** — Custom `InputDecorationTheme` with 12px border radius and subtle borders.
- **Responsive Navigation** — Bottom Navigation Bar with three tabs: Requests, History, and Profile.
- **Real-time Data Sync** — `StreamBuilder` widgets for live updates from Firestore without manual refresh.
- **Loading States** — `CircularProgressIndicator` shown during OTP sending, login, data loading, and profile fetching.
- **Snackbar Notifications** — User feedback via themed snackbars for success/error messages.
- **Custom App Icon** — Branded launcher icon generated with `flutter_launcher_icons`.

---

## 🏗️ Architecture

The project follows the **MVVM (Model-View-ViewModel)** pattern with a clean separation of concerns:

```
lib/
├── app/                    # App entry point & MaterialApp configuration
│   └── main.dart           # Theme, routes, Firebase initialization
├── core/                   # Shared infrastructure
│   └── firebase_options.dart
├── models/                 # Data models
│   ├── token_model.dart    # Booking token with tri-party status tracking
│   └── user_model.dart     # User profile with role-based fields
├── services/               # Business logic & external APIs
│   ├── auth_service.dart   # OTP send/verify via SMTP (email_otp)
│   └── firestore_service.dart  # All Firestore CRUD operations
├── viewmodels/             # State management (ChangeNotifier + Provider)
│   ├── agent_viewmodel.dart      # Provider selection & token creation
│   ├── dashboard_viewmodel.dart  # Profile loading & token count stats
│   ├── login_viewmodel.dart      # OTP login flow state
│   ├── provider_viewmodel.dart   # Approve/reject token logic
│   ├── register_viewmodel.dart   # Registration flow state
│   └── token_list_viewmodel.dart # Heatmap data & token history
└── views/                  # UI layer
    ├── screens/
    │   ├── login_screen.dart       # OTP-based login
    │   ├── register_screen.dart    # Role-based registration
    │   └── dashboard_screen.dart   # Main dashboard with tab navigation
    └── tabs/
        ├── agent_tabs.dart    # Provider directory & token creation
        ├── provider_tabs.dart # Incoming request approval/rejection
        └── token_list.dart    # Heatmap + token history
```

---

## 🛠️ Tech Stack

| Layer | Technology | Purpose |
| :--- | :--- | :--- |
| **Framework** | Flutter 3.10+ (Dart) | Cross-platform UI |
| **Backend** | Firebase (Firestore, Hosting) | Database, web hosting |
| **Auth** | Email OTP (`email_otp`) | Passwordless authentication |
| **State Management** | Provider + ChangeNotifier | Reactive state management (MVVM) |
| **Real-time Sync** | StreamBuilder + Firestore Snapshots | Live data updates |
| **Email** | SMTP via `mailer` / `email_otp` | OTP delivery |
| **Analytics** | `flutter_heatmap_calendar` | GitHub-style activity heatmap |
| **Deep Linking** | `url_launcher` | Open mail app with pre-filled emails |
| **Hosting** | Firebase Multi-site Hosting | Customer portal + public site |

---

## 📱 Platforms & Portals

| Component | Platform | Purpose |
| :--- | :--- | :--- |
| **Management App** | Android (APK/AAB) | Core tools for Agents & Providers to create/manage tokens |
| **Customer Portal** | Firebase Hosting (`traveltribe-7ddea`) | Web interface for travelers to verify bookings via token link |
| **Public Website** | Firebase Hosting (`traveltrust-public`) | Informational site with agent search and activity heatmaps |

---

## ⚙️ Installation & Setup

### Prerequisites

- Flutter SDK `^3.10.0` (Latest Stable)
- Android Studio / VS Code
- A Firebase project with Firestore enabled

### Steps

1. **Clone the repository**

   ```bash
   git clone https://github.com/atulsg88/TravelTribe.git
   cd TravelTribe
   ```

2. **Install dependencies**

   ```bash
   flutter pub get
   ```

3. **Configure Firebase**

   - Place your `google-services.json` in `android/app/`.
   - Update `lib/core/firebase_options.dart` with your Firebase project credentials.

4. **Run the Management App**

   ```bash
   flutter run -t lib/app/main.dart
   ```

---

## 📦 Deployment

### Android (APK)

Generate a release APK for distribution:

```bash
flutter build apk --release -t lib/app/main.dart
```

### Web (Firebase Multi-site Hosting)

This project uses multi-site hosting. Deploy each site individually:

```bash
# Public Website
flutter build web -t lib/public_site/main_public_web.dart --output=build/web_public
firebase deploy --only hosting:public

# Customer Portal
flutter build web -t lib/customer_site/main_customer.dart --output=build/web_customer
firebase deploy --only hosting:customer
```

---

## 🔄 Booking Workflow

```
┌─────────────────┐     ┌──────────────┐     ┌──────────────┐
│  Travel Agent    │     │   Hotelier    │     │  Cab Driver   │
│                  │     │              │     │              │
│  1. Browse       │     │              │     │              │
│     providers    │     │              │     │              │
│  2. Select Hotel │────▶│ 3. Receives  │     │              │
│     + Cab        │     │    request   │     │              │
│  3. Create Token │────▶│              │────▶│ 4. Receives  │
│                  │     │ 5. Approve / │     │    request   │
│                  │     │    Reject    │     │ 6. Approve / │
│                  │     │              │     │    Reject    │
│  7. Both approved│◀────│              │◀────│              │
│     → Send email │     │              │     │              │
│     to customer  │     │              │     │              │
└─────────────────┘     └──────────────┘     └──────────────┘
```

---

## 📄 License

Distributed under the **MIT License**.

---

## 👥 Contact

**Atul S.** — [GitHub Profile](https://github.com/atulsg88)

**Project Link:** [https://github.com/atulsg88/TravelTribe](https://github.com/atulsg88/TravelTribe)
