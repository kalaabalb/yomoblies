# API Reference

This client talks to the YoMobiles backend through a shared REST API.

- Default hosted base URL: `https://yonasmarketplace-backend.onrender.com`
- Local override: `MAIN_URL` compile-time define
- HTTP wrapper: [`lib/services/http_services.dart`](../lib/services/http_services.dart)

## Response Envelope

The backend uses a consistent response shape:

- `success`
- `message`
- `data`

## Authentication

All authenticated requests include `Authorization: Bearer <token>`.

The client persists the token in `GetStorage` and restores the session on startup.

| Method | Endpoint | Purpose |
| --- | --- | --- |
| `POST` | `/users/login` | Authenticate a user and receive a JWT plus public user data |
| `POST` | `/users/register` | Register a new user account |
| `GET` | `/users/profile` | Read the currently authenticated user profile |
| `PUT` | `/users/profile` | Update the currently authenticated user profile |
| `GET` | `/users/:id` | Read the signed-in user profile by id |

## Catalog

| Method | Endpoint | Purpose |
| --- | --- | --- |
| `GET` | `/products` | Load the product list |
| `GET` | `/categories` | Load product categories |
| `GET` | `/subCategories` | Load sub-categories |
| `GET` | `/brands` | Load brands |
| `GET` | `/posters` | Load promotional posters |

## Orders

| Method | Endpoint | Purpose |
| --- | --- | --- |
| `POST` | `/orders` | Create a new order for the authenticated user |
| `GET` | `/orders/orderByUserId/:userId` | Load the authenticated user order history |
| `GET` | `/orders/:id` | Load a single order owned by the authenticated user |
| `POST` | `/payment/upload-proof` | Upload a payment proof image |
| `POST` | `/payment/upload-proof-base64` | Upload a payment proof image from a base64 payload |

## Ratings

| Method | Endpoint | Purpose |
| --- | --- | --- |
| `GET` | `/ratings/product/:productId` | Load paginated ratings for a product |
| `GET` | `/ratings/product/:productId/stats` | Load rating statistics for a product |
| `GET` | `/ratings/product/:productId/user/:userId` | Load the authenticated user rating for a product |
| `POST` | `/ratings` | Create or update the authenticated user rating |
| `PUT` | `/ratings/:ratingId` | Update the authenticated user rating |
| `DELETE` | `/ratings/:ratingId` | Delete the authenticated user rating |

## Notes

- The client does not rely on unauthenticated access for private data.
- `GET /orders` is available to admin users in the backend, but the client uses the user-scoped order-history endpoint.
- If the backend contract changes, update the corresponding models and session handling together.
