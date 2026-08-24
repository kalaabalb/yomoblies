# Configuration

## Runtime Values

The client reads its API base URL from the `MAIN_URL` compile-time define.

- Default: `https://yonasmarketplace-backend.onrender.com`
- Local development override: `--dart-define=MAIN_URL=http://127.0.0.1:3000`

Other runtime values are sourced from the app or platform state:

- OneSignal initialization in `lib/main.dart`
- local image rewrites in helper widgets

## Sessions and Local Storage

The app uses `GetStorage` to persist:

- `auth_token` for the signed JWT access token
- `USER_INFO_BOX` for the current user profile payload

On startup, the app validates the stored session with `GET /users/profile`.

If the session is invalid or expired, the app clears the stored auth data and falls back to the login screen.

## Secrets

Do not commit:

- API keys
- push notification credentials
- Stripe secrets
- backend tokens
- private staging URLs

Use environment variables, compile-time defines, or platform-specific configuration files instead.

## Local Development

- Install Flutter and fetch dependencies with `flutter pub get`
- Start the backend before launching the app
- Override `MAIN_URL` when testing against a local backend
- Configure OneSignal before production release

## Backend Contract

The app expects the backend to expose the routes documented in [`docs/API_REFERENCE.md`](API_REFERENCE.md).

The current client flow depends on:

- JWT-based user authentication
- `/users/profile` for session restore and profile reads
- `/users/profile` for profile updates
- `/orders/orderByUserId/:userId` for order history

## Storage

`GetStorage` and `flutter_cart` are used for local state.

Keep sensitive data out of local storage unless there is an explicit retention policy.
