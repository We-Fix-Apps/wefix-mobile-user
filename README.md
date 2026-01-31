# WeFix User Mobile Application

## Mobile Application

The WeFix User mobile application is a Flutter-based mobile app designed for end users (both B2B and B2C) to create service tickets, manage bookings, subscriptions, and profiles. The app provides different experiences based on user type (B2B business users vs B2C individual users) with role-based features and navigation.

---

## Tools Used

### Development Environment
- **IDE**: VS Code / Android Studio
- **Programming Language**: Dart
- **Framework**: Flutter 2.17.0+

### Core Technologies
- **UI Framework**: Flutter Material Design
- **State Management**: Provider
- **Navigation**: Convex Bottom Bar
- **API Communication**: HTTP, Dio
- **Local Storage**: SharedPreferences
- **Authentication**: JWT, OTP, Google Sign-In
- **Push Notifications**: Firebase Cloud Messaging (FCM)
- **Localization**: Flutter Localizations (Arabic & English)
- **Maps**: Google Maps Flutter

### Key Libraries
- **HTTP Client**: HTTP, Dio
- **State Management**: Provider
- **Navigation**: Convex Bottom Bar
- **Local Storage**: SharedPreferences
- **Image Handling**: Image Picker, Cached Network Image, Flutter Image Compress
- **Maps & Location**: Google Maps Flutter, Geolocator, Geocoding
- **Notifications**: Awesome Notifications, Firebase Messaging
- **UI Components**: Flutter SVG, Shimmer, Bot Toast, Carousel Slider
- **Audio/Video**: Audio Players, Video Player, Flutter Sound, Record
- **File Handling**: File Picker, Open File
- **Authentication**: Google Sign-In, Firebase Auth, Local Auth (Biometric)
- **Real-time Communication**: SignalR NetCore
- **Rating**: Flutter Rating Bar, Flutter Rating Stars
- **Calendar**: Table Calendar
- **Tutorial**: Tutorial Coach Mark
- **WebView**: WebView Flutter
- **Sharing**: Share Plus
- **SMS**: SMS Autofill

---

## Project Structure

```
mobile-user/
├── android/                  # Android platform files
├── ios/                      # iOS platform files
├── assets/                   # Assets
│   ├── image/               # Images
│   ├── icon/                # Icons (SVG)
│   ├── video/                # Videos
│   └── fonts/               # Custom fonts
├── lib/
│   ├── Business/            # Business logic layer
│   │   ├── Address/         # Address APIs
│   │   ├── AppProvider/     # App state provider
│   │   ├── Authantication/  # Authentication APIs
│   │   ├── B2b/             # B2B APIs
│   │   ├── Bookings/        # Booking APIs
│   │   ├── Category/        # Category APIs
│   │   ├── Chat/            # Chat APIs
│   │   ├── Contact/         # Contact APIs
│   │   ├── Contract/        # Contract APIs
│   │   ├── CreateOrder/     # Order creation APIs
│   │   ├── end_points.dart  # API endpoints
│   │   ├── Home/            # Home APIs
│   │   ├── language/        # Language API
│   │   ├── LanguageProvider/# Language provider
│   │   ├── Notification/    # Notification APIs
│   │   ├── orders/          # Order/Profile APIs
│   │   ├── Reviews/         # Review APIs
│   │   ├── Transactions/     # Transaction APIs
│   │   ├── uplade_image.dart
│   │   └── upload_files_list.dart
│   ├── Data/                # Data layer
│   │   ├── Api/             # API helpers
│   │   ├── appText/         # App text constants
│   │   ├── Constant/        # App constants
│   │   │   ├── app_constant.dart
│   │   └── theme/           # Theme definitions
│   │       ├── color_constant.dart
│   │       ├── dark_theme.dart
│   │       └── light_theme.dart
│   │   ├── Functions/       # Utility functions
│   │   ├── Helper/          # Helper classes
│   │   ├── model/           # Data models
│   │   ├── Notification/    # Notification handling
│   │   └── services/        # Data services
│   ├── Presentation/        # UI layer
│   │   ├── Address/         # Address screens
│   │   ├── appointment/     # Appointment screens
│   │   ├── auth/            # Authentication screens
│   │   ├── B2B/             # B2B screens
│   │   │   └── home_b2b.dart
│   │   ├── Checkout/        # Checkout screens
│   │   ├── Components/      # Reusable components
│   │   ├── Home/            # Home screens
│   │   ├── Loading/         # Loading screens
│   │   ├── Profile/         # Profile screens
│   │   ├── SplashScreen/    # Splash screen
│   │   ├── SubCategory/     # Sub-category screens
│   │   ├── Subscriptions/   # Subscription screens
│   │   ├── VersionCheck/    # Version check
│   │   └── wallet/          # Wallet screens
│   ├── l10n/                # Localization files
│   │   ├── app_ar.arb
│   │   ├── app_en.arb
│   │   └── app_localizations.dart
│   ├── firebase_options.dart
│   ├── injection_container.dart
│   ├── layout_screen.dart    # Main layout
│   ├── main_managements.dart
│   └── main.dart            # App entry point
├── pubspec.yaml
└── analysis_options.yaml
```

---

## Features

### Authentication
- **OTP-based Login**: Phone number authentication with OTP
- **Google Sign-In**: Google authentication support
- **Biometric Authentication**: Local auth support (fingerprint/face ID)
- **Token Management**: Secure JWT token storage and refresh
- **Auto-login**: Remember user sessions

### Home Screen
- **Service Categories**: Browse service categories
- **Search Services**: Search for services
- **Quick Actions**: Quick access to common services
- **B2B Dashboard**: Specialized dashboard for B2B users
  - Company information
  - Last tickets section
  - Statistics
  - Quick actions
- **B2C Home**: Standard home for individual users
  - Service categories
  - Popular services
  - Promotions

### Ticket/Order Management
- **Create Tickets**: Create new service tickets
- **View Tickets**: View ticket history and status
- **Ticket Details**: Detailed ticket information
- **Update Tickets**: Update ticket information
- **B2B Tickets**: Specialized ticket management for B2B users
- **B2C Bookings**: Booking management for individual users

### Subscriptions
- **Subscription Plans**: View available subscription plans
- **Subscribe**: Subscribe to service plans
- **Manage Subscription**: Manage active subscriptions
- **Subscription Status**: Check subscription status

### Profile Management
- **User Profile**: View and edit profile
- **Address Management**: Manage delivery addresses
- **Settings**: App settings and preferences
- **Language Selection**: Switch between Arabic and English
- **Theme Selection**: Light/Dark theme (if supported)
- **Notifications**: Manage notification preferences
- **Logout**: Secure logout

### B2B Features
- **Company Profile**: Company information and settings
- **Ticket Management**: Advanced ticket management
- **Contract Management**: View and manage contracts
- **Team Management**: Manage team members (for admins)
- **Reports**: View company reports

### B2C Features
- **Service Booking**: Book services
- **Order History**: View order history
- **Reviews & Ratings**: Rate and review services
- **Wallet**: Manage wallet and payments
- **Transactions**: View transaction history

### Additional Features
- **Real-time Chat**: SignalR-based chat with support
- **Push Notifications**: Firebase Cloud Messaging
- **Location Services**: Google Maps integration
- **Image Upload**: Upload images from gallery or camera
- **File Attachments**: Attach files to tickets
- **Audio/Video Recording**: Record audio and video
- **QR Code**: QR code functionality (if implemented)
- **Calendar**: Calendar view for appointments
- **Tutorial**: Onboarding tutorial
- **Version Check**: Automatic version checking

---

## Getting Started

### Prerequisites

- Flutter SDK 2.17.0 or higher
- Dart SDK 2.17.0 or higher
- Android Studio / VS Code with Flutter extensions
- Android SDK (for Android development)
- Xcode (for iOS development, macOS only)
- Firebase project (for push notifications)
- Google Maps API key (for location features)

### Installation

1. Clone the repository:

```bash
$ git clone <repository-url>
$ cd mobile-user
```

2. Install dependencies:

```bash
flutter pub get
```

3. Configure Google Maps:

Add your Google Maps API key:
- Android: `android/app/src/main/AndroidManifest.xml`
- iOS: `ios/Runner/AppDelegate.swift`

4. Configure Firebase:

- Add `google-services.json` to `android/app/`
- Add `GoogleService-Info.plist` to `ios/Runner/`

5. Configure API endpoints:

Update API endpoints in `lib/Business/end_points.dart`

6. Run the application:

```bash
# For development
flutter run

# For specific platform
flutter run -d android
flutter run -d ios
```

---

## Available Scripts

### Development
- `flutter pub get` - Install dependencies
- `flutter run` - Run the app in debug mode
- `flutter run --release` - Run the app in release mode
- `flutter build apk` - Build Android APK
- `flutter build ios` - Build iOS app
- `flutter build appbundle` - Build Android App Bundle

### Testing
- `flutter test` - Run unit tests
- `flutter test --coverage` - Run tests with coverage

### Code Quality
- `flutter analyze` - Analyze code for issues
- `flutter format .` - Format code

---

## Build Configuration

### Android

1. Update `android/app/build.gradle`:
   - Set `minSdkVersion` (minimum 21)
   - Set `targetSdkVersion`
   - Configure signing configs

2. Update `android/app/src/main/AndroidManifest.xml`:
   - Add Google Maps API key
   - Add required permissions
   - Configure app metadata

### iOS

1. Update `ios/Runner/Info.plist`:
   - Add Google Maps API key
   - Add required permissions
   - Configure app metadata

2. Update `ios/Podfile`:
   - Set minimum iOS version (12.0+)

---

## User Types & Roles

### B2B Users
- **Role IDs**: Admin (18), Team Leader (20), Super User (26)
- **Features**:
  - B2B home dashboard
  - Ticket management screen
  - Company profile
  - Contract management
  - Team management (for admins)
- **Navigation**: Home, Tickets, Subscriptions, Profile, Contact Us

### B2C Users
- **Role IDs**: Individual customers
- **Features**:
  - Standard home screen
  - Service booking
  - Order history
  - Reviews and ratings
  - Wallet management
- **Navigation**: Home, Bookings, Subscriptions, Profile, Contact Us

---

## API Integration

### Authentication
- **OTP Request**: Request OTP via phone number
- **OTP Verify**: Verify OTP and receive JWT token
- **Google Sign-In**: Google authentication
- **Token Refresh**: Automatic token refresh

### Home & Services
- **Get Categories**: Fetch service categories
- **Get Services**: Fetch available services
- **Search Services**: Search for services
- **B2B Home Data**: Fetch B2B dashboard data

### Tickets/Orders
- **Create Ticket**: Create new service ticket
- **Get Tickets**: Fetch user tickets
- **Update Ticket**: Update ticket information
- **Ticket Details**: Get ticket details

### Subscriptions
- **Get Plans**: Fetch subscription plans
- **Subscribe**: Subscribe to a plan
- **Get Subscription**: Get user subscription status

### Profile
- **Get Profile**: Fetch user profile
- **Update Profile**: Update user information
- **Manage Addresses**: CRUD operations for addresses

### Additional APIs
- **Chat**: Real-time chat APIs
- **Notifications**: Notification APIs
- **Reviews**: Review and rating APIs
- **Transactions**: Transaction history APIs
- **Contracts**: Contract management (B2B)

---

## Localization

The app supports two languages:
- **English** (`app_en.arb`)
- **Arabic** (`app_ar.arb`)

Language can be switched from profile/settings screen.

---

## State Management

The app uses **Provider** for state management:
- `AppProvider`: Main app state and user data
- `LanguageProvider`: Language and localization
- Various screen-specific providers

---

## Local Storage

### SharedPreferences
- User data
- App settings
- User preferences
- Authentication tokens

---

## Push Notifications

### Firebase Cloud Messaging (FCM)
- Background notifications
- Foreground notifications
- Notification handling

### Awesome Notifications
- Local notifications
- Custom notification UI

---

## Version Management

The app includes automatic version checking:
- Compares app version with server
- Prompts for update if needed
- Handles forced updates

---

## Security Features

- **JWT Authentication**: Secure token-based authentication
- **Biometric Auth**: Local authentication support
- **Secure Storage**: Sensitive data stored securely
- **Token Refresh**: Automatic token refresh mechanism
- **HTTPS**: All API calls over HTTPS

---

## B2B vs B2C Differences

### Navigation
- **B2B**: Home → Tickets → Subscriptions → Profile → Contact Us
- **B2C**: Home → Bookings → Subscriptions → Profile → Contact Us

### Home Screen
- **B2B**: Dashboard with company info, last tickets, statistics
- **B2C**: Service categories, popular services, promotions

### API Calls
- **B2B**: Uses new GraphQL/RESTful APIs (backend-oms)
- **B2C**: Uses legacy ASP.NET APIs (for some features)

### Features
- **B2B**: Company management, contracts, team features
- **B2C**: Service booking, reviews, wallet

---

## Troubleshooting

### Build Issues

1. **Clean build**:
```bash
flutter clean
flutter pub get
```

2. **iOS Pod issues**:
```bash
cd ios
pod deintegrate
pod install
cd ..
```

3. **Android Gradle issues**:
```bash
cd android
./gradlew clean
cd ..
```

### Runtime Issues

- **Network errors**: Check API URLs in `end_points.dart`
- **Firebase errors**: Verify Firebase configuration files
- **Google Maps errors**: Verify Google Maps API key
- **Permission errors**: Check permission requests in code
- **Token expiration**: Check token refresh mechanism

---

## Recent Updates

### Version 1.1.23+1

- **Release Title**: Application initialization
- **Release Description**: Flutter user app with B2B and B2C support, ticket management, subscriptions, and comprehensive features
- **Release Date**: Initial release

---

## Change Log

### 1.1.23+1
- Initial release
- Authentication with OTP and Google Sign-In
- B2B and B2C user support
- Ticket/Order management
- Subscription management
- Real-time chat
- Push notifications
- Multi-language support
- Google Maps integration
- Profile management

---

## Platform Support

- **Android**: Minimum SDK 21 (Android 5.0)
- **iOS**: Minimum iOS 12.0

---

## Dependencies

Key dependencies (see `pubspec.yaml` for complete list):
- `flutter`: SDK
- `provider`: State management
- `convex_bottom_bar`: Navigation
- `http`: HTTP client
- `shared_preferences`: Local storage
- `firebase_messaging`: Push notifications
- `google_maps_flutter`: Maps integration
- `image_picker`: Image selection
- `signalr_netcore`: Real-time communication
- `google_sign_in`: Google authentication
- `table_calendar`: Calendar widget

---

## Authors

**Jehad Abu Awwad**  
Email: jadabuawwad@outlook.com

---

## License

ISC

---

## Additional Notes

### Environment Setup

Ensure you have:
- Firebase configuration files
- Google Maps API key configured
- Proper API endpoints in `end_points.dart`
- Required permissions in AndroidManifest.xml and Info.plist

### B2B API Integration

B2B users use the new backend-oms APIs:
- GraphQL endpoint for queries
- RESTful endpoints for operations
- No legacy ASP.NET API calls

### B2C API Integration

B2C users may use:
- New backend-oms APIs (for new features)
- Legacy ASP.NET APIs (for backward compatibility)

---
