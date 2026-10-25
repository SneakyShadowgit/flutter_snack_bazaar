# Snack Bazaar

Snack Bazaar is a Flutter marketplace prototype targeting an Android closed beta. Firebase is used for Authentication and Cloud Firestore. Buyer checkout currently supports cash on delivery.

## Current implementation

- Email/password buyer registration and sign-in.
- User profile lookup routes approved sellers, admins, and buyers to their respective portals.
- New public registrations can only create buyer profiles.
- Seller product create, update, and delete operations include the signed-in seller ID; seller inventory reads are limited to that seller.
- Buyer checkout captures a phone number and delivery address, then saves a pending cash-on-delivery order to Firestore.
- Buyer order history reads the signed-in buyer's saved orders from Firestore.
- Seller order queues read orders containing that seller's products and persist fulfillment status changes.
- Buyers can submit a seller application; admins can review it and approve seller access.
- Firestore rules are in `firestore.rules` and are configured in `firebase.json`.

Online payment, product image uploads, persistent seller listings, and admin analytics are not implemented yet. Legacy product documents without `sellerId` remain unassigned and will not appear in a seller's order queue.

## Firebase setup for local use

1. In Firebase Console, open project `snack-bazaar` and enable **Authentication → Email/Password**.
2. Create the Cloud Firestore database in the intended region.
3. In Firestore, create a `users/{your-auth-uid}` document for the first administrator with at least `role: "admin"`. Do this from the Firebase Console using the Auth user's UID; client app rules intentionally prevent users from granting themselves admin or seller roles.
4. Deploy the checked-in Firestore rules from the project root with `firebase deploy --only firestore:rules` after installing/logging into the Firebase CLI and selecting the intended project.
5. Register a buyer account in the app to confirm the Authentication and profile-creation setup.
6. Publish the updated `firestore.rules` after rule changes; the latest version covers seller applications and seller-owned order fulfillment.

Firebase project configuration currently exists for Android and web. The initial closed beta target is Android. iOS and desktop Firebase configurations are not present.

## Beta milestones

1. Authentication, role routing, and initial Firestore ownership rules.
2. Seller applications, admin approval, and seller-owned COD order fulfillment.
3. Order price/stock validation, persistent seller management, and admin analytics.
4. Device checks, error handling, privacy/support information, Android package identity, and release signing.
