# 🌍 Travel Trust - Unified Agency Management System

**Travel Trust** is a robust, multi-platform solution designed for Travel Agents to streamline booking verifications between Hoteliers and Cab Drivers. Built with **Flutter** and **Firebase**, it features a management app for agents and specialized web portals for customers and the public.

---

## 🚀 Key Features

* **Role-Based Access Control**: Specialized visibility for Travel Agents, Hoteliers, and Cab Drivers.
* **Secure Token System**: Agents generate unique verification tokens sent directly via email.
* **Multi-Site Hosting**: Unified project hosting a Public Website, a Customer Verification Portal, and an Android Management App.
* **Real-time Analytics**: Activity heatmaps and token tracking via Cloud Firestore.
* **Privacy First**: Automated filtering ensures providers only see relevant booking details.

---

## 📱 Platforms & Portals

| Component | Platform | Purpose |
| :--- | :--- | :--- |
| **Management App** | Android (APK/AAB) | Core tools for Agents to create/manage tokens. |
| **Customer Portal** | Firebase Hosting | Secure web interface for travelers to Accept/Reject bookings. |
| **Public Site** | Firebase Hosting | Informational site with Agent search and profile heatmaps. |

---

## 🛠️ Tech Stack

* **Frontend**: Flutter (Dart)
* **Backend**: Firebase (Auth, Firestore, Hosting)
* **Security**: Role-based Firestore Rules & Multi-step Verification
* **State Management**: StreamBuilder for real-time data sync

---

## ⚙️ Installation & Setup

### Prerequisites
* Flutter SDK (Latest Stable)
* Android Studio / VS Code
* Firebase Project Setup

### Steps

1. **Clone the repository**
   ```bash
   git clone [https://github.com/atulsg88/TravelTribe.git](https://github.com/atulsg88/TravelTribe.git)
   cd TravelTribe
1. Install Dependencies

Bash

flutter pub get

2. Firebase Configuration

Place your google-services.json in android/app/.

Update firebase_options.dart with your project credentials.

3. Run the Management App

Bash

flutter run -t lib/app/main.dart


📦 Deployment


1. Android (APK)


To generate a release APK for testing:

Bash

flutter build apk --release -t lib/app/main.dart

2. Web (Firebase Hosting)

This project uses multisite hosting. Deploy each site individually:

Bash

# Public Website

flutter build web -t lib/public_site/main_public_web.dart --output=build/web_public

firebase deploy --only hosting:public

# Customer Portal

flutter build web -t lib/customer_site/main_customer.dart --output=build/web_customer

firebase deploy --only hosting:customer


📂 Project Structure

Plaintext

lib/

├── app/             # Main Management App (Android)

├── customer_site/   # Customer Verification Web Portal

├── public_site/     # Informational Public Website

└── core/            # Shared logic and Firebase options


📄 License

Distributed under the MIT License.

👥 Contact

Atul S. - GitHub Profile

Project Link: https://github.com/atulsg88/TravelTribe


---

### Next Step:
Once you save this file, you can upload it to GitHub using:

```bash
git add README.md
git commit -m "Add professional README"
git push origin main
