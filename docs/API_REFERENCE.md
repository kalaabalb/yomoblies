# API Reference

This app uses a REST backend hosted at:

- `https://yonasmarketplace-backend.onrender.com`

The shared HTTP layer is implemented in [`lib/services/http_services.dart`](../lib/services/http_services.dart).

## Request Format

The app uses `GET`, `POST`, `PUT`, and `DELETE` requests through a common service helper.

Typical response envelope:

- `success`
- `message`
- `data`

## Public Endpoints Used by the App

### Catalog Data

| Method | Endpoint | Purpose |
| --- | --- | --- |
| `GET` | `/products` | Load the product list |
| `GET` | `/categories` | Load product categories |
| `GET` | `/subCategories` | Load sub-categories |
| `GET` | `/brands` | Load brands |
| `GET` | `/posters` | Load promotional posters |
| `GET` | `/orders` | Load order data |

### Authentication and Profile

| Method | Endpoint | Purpose |
| --- | --- | --- |
| `POST` | `/users/login` | Log a user in |
| `POST` | `/users/register` | Register a new user |
| `PUT` | `/users/:id` | Update a user profile |

### Cart and Orders

| Method | Endpoint | Purpose |
| --- | --- | --- |
| `POST` | `/orders` | Create a new order |
| `POST` | `/payment/upload-proof-base64` | Upload payment proof from the checkout flow |

### Ratings

| Method | Endpoint | Purpose |
| --- | --- | --- |
| `GET` | `/ratings/product/:productId?page=:page&limit=:limit` | Load paginated ratings for a product |
| `GET` | `/ratings/product/:productId/stats` | Load rating statistics for a product |
| `GET` | `/ratings/product/:productId/user/:userId` | Load a specific user rating for a product |
| `POST` | `/ratings` | Create a rating |
| `PUT` | `/ratings/:ratingId` | Update a rating |
| `DELETE` | `/ratings/:ratingId` | Delete a rating |

## Notes

- The app currently expects backend responses to match the existing model classes and `ApiResponse` parsing logic.
- No API contract tests are included in this repository snapshot.
- If the backend changes, update both the model classes and this reference together.

