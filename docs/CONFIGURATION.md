# Configuration

## Runtime Values

The repository still has a few hardcoded runtime values that should be treated as configuration:

- backend base URL in `lib/utility/constants.dart`
- OneSignal app id in `lib/main.dart`
- local-development image URL rewrites in image helpers

## Secrets

Do not commit:

- API keys
- Push notification credentials
- Stripe secrets
- backend tokens
- private URLs for staging environments

Use environment variables or platform-specific configuration files instead.

## Local Development

- Install Flutter and fetch dependencies with `flutter pub get`
- Start a local or remote backend before running the app
- Replace placeholder notification configuration before production use

## Backend Contract

The app expects the backend to continue exposing the endpoints documented in [`docs/API_REFERENCE.md`](API_REFERENCE.md).

## Storage

The app uses `GetStorage` and `flutter_cart` for local state. This is convenient, but it means the app should be careful about what it stores locally. Sensitive data should not be added without an explicit storage policy.
