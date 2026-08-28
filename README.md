# YoMobiles Client

Flutter client application for the YoMobiles e-commerce platform.

This repository contains the customer-facing app used to browse products, manage favorites and cart state, place orders, upload payment proof, and maintain the signed-in user profile.

## Who Uses It

- shoppers using the mobile client
- returning users with stored sessions

## Key Features

- user registration and login
- JWT session restore on startup
- product catalog browsing
- category, brand, and sub-category browsing
- product details and ratings
- favorites
- cart management
- order creation and order history
- profile editing
- address storage
- payment proof upload flow
- localized UI strings

## Technology Stack

- Flutter
- Provider for state management
- GetX for navigation, dialogs, and lightweight services
- GetStorage for local session and preference storage
- REST API integration through a shared HTTP service
- `flutter_cart` for cart persistence
- `cached_network_image` for remote media

## Architecture

The app follows a feature-oriented Flutter structure:

- [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md)
- [`docs/FOLDER_STRUCTURE.md`](docs/FOLDER_STRUCTURE.md)
- [`docs/API_REFERENCE.md`](docs/API_REFERENCE.md)

High-level responsibilities:

- `lib/core/data/` owns translations and app-wide data loading
- `lib/models/` contains JSON-backed data models
- `lib/services/` contains the shared HTTP layer
- `lib/screen/` contains feature screens and providers
- `lib/shared/widgets/`, `lib/widget/`, and `lib/utility/` contain reusable UI and helpers

## Authentication and Security Model

- The client stores the JWT access token and user payload in `GetStorage`.
- Stored sessions are validated on startup by calling `/users/profile`.
- Invalid or expired sessions are cleared automatically.
- API requests use the `Authorization: Bearer <token>` header for protected routes.
- Do not commit API keys, backend tokens, or private credentials.

## API and Integration Model

- The API base URL is supplied through the `MAIN_URL` compile-time define.
- The default hosted backend URL is defined in [`lib/utility/constants.dart`](lib/utility/constants.dart).
- Local development can target a running backend with `--dart-define=MAIN_URL=http://127.0.0.1:3000`.
- Shared API details are documented in [`docs/API_REFERENCE.md`](docs/API_REFERENCE.md).
- The backend lives in the sibling repository [YoMobiles Backend](https://github.com/kalaabalb/ecommerce-backend-api).
- Admin workflows live in the sibling repository [YoMobiles Admin](https://github.com/kalaabalb/yomobliesctl).

## Screenshots and Demo Evidence

Production screenshots are organized under [`docs/screenshots/`](docs/screenshots/README.md).

Representative captures currently checked in:

- `docs/screenshots/authentication/login.jpg`
- `docs/screenshots/authentication/register.jpg`
- `docs/screenshots/authentication/forgot_password.jpg`
- `docs/screenshots/core/home.jpg`
- `docs/screenshots/core/language_selection.jpg`
- `docs/screenshots/core/navigation_drawer.jpg`
- `docs/screenshots/shopping/product_details.jpg`
- `docs/screenshots/shopping/category_products.jpg`
- `docs/screenshots/shopping/cart.jpg`
- `docs/screenshots/shopping/favorites.jpg`
- `docs/screenshots/orders/order_form.jpg`
- `docs/screenshots/orders/order_confirmation_dialog.jpg`
- `docs/screenshots/orders/orders.jpg`
- `docs/screenshots/orders/order_details.jpg`
- `docs/screenshots/orders/payment_upload_form.jpg`
- `docs/screenshots/account/profile.jpg`
- `docs/screenshots/account/addresses.jpg`

## Local Setup

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

```bash
flutter run --dart-define=MAIN_URL=http://127.0.0.1:3000
```

## Configuration

- API base URL is provided through the `MAIN_URL` compile-time define.
- User sessions are stored in `GetStorage` as `auth_token` and `USER_INFO_BOX`.
- OneSignal initialization remains in `lib/main.dart` and should be configured before shipping.
- The app expects the backend endpoints documented in [`docs/API_REFERENCE.md`](docs/API_REFERENCE.md).

## Testing

```bash
flutter test
flutter analyze
flutter build apk --release
flutter build linux --release
```

The repository currently includes smoke coverage for app startup.

## Deployment / Current Status

- Android release signing is configured through local, gitignored signing files documented in [`android/RELEASE_SIGNING.md`](android/RELEASE_SIGNING.md).
- Linux release builds currently pass locally.
- GitHub Actions runs format, analyze, and test on pushes and pull requests.

## Known Limitations

- The app still depends on the backend being reachable at the configured API base URL.
- OneSignal and release signing require local environment setup before a production build.
- The screenshot set is representative rather than exhaustive.

## Future Improvements

- Expand GitHub Actions with device/emulator coverage when the test matrix needs it.
- Capture additional screenshots as the UI stabilizes.
- Expand integration tests around order and payment flows.

## Release Notes

- [`CHANGELOG.md`](CHANGELOG.md)
- [`docs/RELEASE.md`](docs/RELEASE.md)
- [`docs/RELEASE_NOTES.md`](docs/RELEASE_NOTES.md)

## Contributing

- [`CONTRIBUTING.md`](CONTRIBUTING.md)
- Keep the feature folders, screenshots, and API docs aligned with any behavior change.
- GitHub Actions, issue templates, and a pull request template are configured under [`.github/`](.github/).

## Security

- [`SECURITY.md`](SECURITY.md)

Do not commit API keys, tokens, or private backend credentials.

## License

MIT License. See [`LICENSE`](LICENSE).

## Author

Yonas Ambelu
