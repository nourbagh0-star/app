# FadeApp - Barber Booking Platform

FadeApp is a comprehensive, multi-vendor booking platform tailored for the barbering industry. It connects clients looking for a fresh cut with professional barbers and barber shops. 

The project is structured as a monorepo containing two distinct Flutter applications and a shared UI library.

## 📱 Apps Included

1. **Customer App (`customer_app`)**: 
   - Allows users to discover nearby barber shops and individual specialists.
   - View shop portfolios, ratings, and reviews.
   - Seamlessly book, reschedule, or cancel appointments.
   - Favorite preferred shops.

2. **Barber App (`barber_app`)**:
   - Designed for shop owners and individual barbers to manage their business.
   - Manage daily schedules, view upcoming appointments, and handle walk-ins.
   - Configure shop details, upload portfolio images, and manage services and pricing.
   - Add and manage staff members.

3. **Shared Library (`shared_ui`)**:
   - A dedicated package containing shared design tokens (colors, typography), reusable UI components (buttons, scaffolds, premium images), and core logic (repositories, BLoCs) used by both applications.

## 🛠 Tech Stack

- **Framework**: [Flutter](https://flutter.dev/) (Dart)
- **State Management**: `flutter_bloc` (Cubit pattern)
- **Routing**: `go_router`
- **Backend & Database**: Firebase (Authentication, Cloud Firestore)
- **File Storage**: Supabase (Used for handling shop and portfolio image uploads)
- **Dependency Injection**: `get_it`
- **UI & Layout**: `flutter_screenutil` (responsive sizing), `google_fonts`
- **Calendar & Scheduling**: `table_calendar`

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (>= 3.10.0)
- Dart SDK
- A Firebase project with Firestore and Authentication enabled.
- A Supabase project with a storage bucket configured for image uploads.

### Setup
1. Clone the repository.
2. Ensure you have the `firebase.json` and `.firebaserc` files configured for your environment.
3. Run `flutter pub get` in all three main directories (`shared_ui`, `customer_app`, `barber_app`).
4. To run the Customer App:
   ```bash
   cd customer_app
   flutter run
   ```
5. To run the Barber App:
   ```bash
   cd barber_app
   flutter run
   ```

## 📦 Deployment
The Android version is optimized for Edge-to-Edge displays (Android 15+) and is configured to be built as an App Bundle (`.aab`) for distribution on platforms like RuStore and Google Play Store.

To build a release bundle:
```bash
flutter build appbundle --release
```
