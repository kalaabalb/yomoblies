# YoMobiles Client

Flutter client application for the YoMobiles e-commerce platform.

This repository contains the customer-facing app used for browsing the catalog, managing a cart and favorites, placing orders, reviewing products, and managing profile data.

## Stack

- Flutter
- Provider for state management
- GetX for navigation and lightweight app services
- GetStorage for local session and preference storage
- REST API integration through a shared HTTP service
- `flutter_cart` for cart persistence
- `cached_network_image` for remote media

## Features

- User registration and login
- Session restore from stored JWT access token
- Product catalog browsing
- Category, brand, and sub-category browsing
- Product details and ratings
- Favorites
- Cart management
- Order creation and order history
- Profile editing
- Address storage
- Payment proof upload flow
- Localized UI strings

## Screenshots

Production screenshots are organized under [`docs/screenshots/`](docs/screenshots/README.md):

- `docs/screenshots/authentication/login.jpg`
- `docs/screenshots/core/home.jpg`
- `docs/screenshots/shopping/product_details.jpg`
- `docs/screenshots/shopping/cart.jpg`
- `docs/screenshots/account/profile.jpg`
- `docs/screenshots/orders/order_details.jpg`

Additional screenshots are grouped by feature folder:

- `authentication/`
- `core/`
- `shopping/`
- `orders/`
- `account/`

Keep future screenshots consistent in device size and crop.

## Installation

### Prerequisites

- Flutter SDK 3.0 or newer
- Dart 3
- A connected device, emulator, or desktop target

### Setup

```bash
git clone <repo-url>
cd yomoblies_client
flutter pub get
```

### Run

By default the app uses the hosted backend URL declared in [`lib/utility/constants.dart`](lib/utility/constants.dart).

For local development against a running backend, override the API base URL at launch:

```bash
flutter run --dart-define=MAIN_URL=http://127.0.0.1:3000
```

## Configuration

- API base URL is provided through the `MAIN_URL` compile-time define.
- User sessions are stored in `GetStorage` as `auth_token` and `USER_INFO_BOX`.
- Stored sessions are validated on startup by calling `/users/profile`.
- Invalid or expired sessions are cleared automatically.
- OneSignal initialization remains in `lib/main.dart` and should be configured before shipping.

## Architecture

The client follows a feature-oriented Flutter structure:

- [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md)
- [`docs/FOLDER_STRUCTURE.md`](docs/FOLDER_STRUCTURE.md)
- [`docs/API_REFERENCE.md`](docs/API_REFERENCE.md)

High-level responsibilities:

- `lib/core/data/` owns translations and app-wide data loading
- `lib/models/` contains JSON-backed data models
- `lib/services/` contains the shared HTTP layer
- `lib/screen/` contains feature screens and providers
- `lib/shared/widgets/`, `lib/widget/`, and `lib/utility/` contain reusable UI and helpers

## Backend Repository

The backend lives in the sibling repository [`../yomobiles_backend`](../yomobiles_backend).

It is responsible for auth, data validation, order storage, ratings, and payment verification.

## API Documentation

See [`docs/API_REFERENCE.md`](docs/API_REFERENCE.md) for the current client-side API contract, including auth-protected user routes and order history endpoints.

## Testing

```bash
flutter test
flutter analyze
```

The project currently includes smoke coverage for app startup.

## Release Notes

- [`CHANGELOG.md`](CHANGELOG.md)
- [`docs/RELEASE.md`](docs/RELEASE.md)
- [`docs/RELEASE_NOTES.md`](docs/RELEASE_NOTES.md)

## Contributing

- [`CONTRIBUTING.md`](CONTRIBUTING.md)
- Issue and pull request templates are configured under [`.github/`](.github/)

## Security

- [`SECURITY.md`](SECURITY.md)

Do not commit API keys, tokens, or private backend credentials.

## License

MIT License. See [`LICENSE`](LICENSE).

## Author

Yonas Ambelu
