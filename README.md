# Yomoblies

![Flutter](https://img.shields.io/badge/Flutter-3.0%2B-02569B?logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-3.0%2B-0175C2?logo=dart&logoColor=white)
![CI](https://img.shields.io/badge/CI-GitHub%20Actions-2088FF?logo=githubactions&logoColor=white)
![License](https://img.shields.io/badge/License-MIT-yellow.svg)
![Architecture](https://img.shields.io/badge/Architecture-Feature%20Oriented-6A5ACD)

Flutter e-commerce frontend built with Provider, GetX, GetStorage, and a REST backend.

## Overview

This repository contains the Flutter client for an e-commerce application. The codebase includes authentication, catalog browsing, product details, ratings, cart and favorites, profile management, order creation, and order tracking.

The app is structured as a feature-oriented Flutter project and is ready to run on the standard Flutter platforms supported by the generated runners in this repository.

## Features

- Authentication flow
- Product catalog browsing
- Category, brand, and sub-category browsing
- Product details with customer ratings
- Favorites
- Cart management
- Order creation
- Order tracking
- Profile editing
- Address storage
- Light and dark theme support
- Multi-language UI strings
- In-app tracking screen using a web view

## Screenshots

No production screenshots are committed in this repository snapshot.

Add captures in [`docs/screenshots/`](docs/screenshots/README.md) with these filenames:

| Screen | Suggested file |
| --- | --- |
| Home | `docs/screenshots/home.png` |
| Product details | `docs/screenshots/product-details.png` |
| Cart | `docs/screenshots/cart.png` |
| Profile | `docs/screenshots/profile.png` |

If you add screenshots later, keep them consistent in size and device framing.

## Installation

### Prerequisites

- Flutter SDK 3.0 or newer
- Dart 3
- A device or emulator

### Setup

```bash
git clone <repo-url>
cd yomoblies
flutter pub get
```

### Configuration

- Backend base URL is defined in [`lib/utility/constants.dart`](lib/utility/constants.dart)
- OneSignal initialization is still configured in [`lib/main.dart`](lib/main.dart)
- Review [`docs/CONFIGURATION.md`](docs/CONFIGURATION.md) before shipping to production

### Run

```bash
flutter run
```

### Verify

```bash
dart format --set-exit-if-changed .
flutter analyze
flutter test
```

## Architecture

The application follows a feature-oriented layout:

- [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md) explains the app layers and data flow
- [`docs/FOLDER_STRUCTURE.md`](docs/FOLDER_STRUCTURE.md) documents the repository folders
- [`docs/API_REFERENCE.md`](docs/API_REFERENCE.md) documents the HTTP endpoints used by the app

In short:

- `lib/core/data/` owns translation strings and app-wide data loading
- `lib/models/` contains JSON-backed model classes
- `lib/services/` contains the shared HTTP layer
- `lib/screen/` contains feature screens and their providers
- `lib/shared/widgets/`, `lib/widget/`, and `lib/utility/` hold reusable UI and helpers

## API Documentation

The app talks to a REST backend using a shared `HttpService`.

- Base URL: `https://yonasmarketplace-backend.onrender.com`
- Common response shape: `success`, `message`, and `data`
- Endpoint reference: [`docs/API_REFERENCE.md`](docs/API_REFERENCE.md)

## Backend Repository

The backend source repository is not included in this checkout.

If you maintain the backend separately, link it here once it is confirmed and public.

## Repository Topics

Suggested GitHub topics:

`flutter`, `dart`, `ecommerce`, `provider`, `getx`, `mobile`, `rest-api`, `cross-platform`, `opensource`, `state-management`

## Release Notes

- Current notes: [`CHANGELOG.md`](CHANGELOG.md)
- Release process: [`docs/RELEASE.md`](docs/RELEASE.md)
- Public release notes summary: [`docs/RELEASE_NOTES.md`](docs/RELEASE_NOTES.md)

## Testing

The repository includes a smoke test that verifies app boot. Feature-level tests are still limited.

## Contributing

- [`CONTRIBUTING.md`](CONTRIBUTING.md)
- Issue templates and pull request templates are configured in `.github/`

## Security

- [`SECURITY.md`](SECURITY.md)

## License

MIT License. See [`LICENSE`](LICENSE).

## Author

Yonas Ambelu
