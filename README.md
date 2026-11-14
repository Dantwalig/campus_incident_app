# Campus Incident Reporting App

A Flutter mobile app where ALU students report campus issues and authorised staff review them and update their status. Built for Individual Assignment 2.

## Features

* Registration, login, logout and password reset with Firebase Authentication
* Email verification, with access limited to ALU emails
* Student and staff roles with role based screens
* Report an incident with category, title, description, location and an optional photo
* Anonymous reporting and a warning when a similar open report exists
* My reports and a campus feed with search, status filter and category filter
* Incident details with a status timeline and activity history
* Edit or delete your own report while it is still Submitted
* Staff dashboard with live counts and status updates with notes

## Tech stack

* Flutter and Provider (ChangeNotifier) for state management
* Firebase Authentication and Cloud Firestore
* Cloudinary for photo storage

## Project structure

```
lib/
  core/              theme, constants, validators, formatters, helpers
  data/models/       AppUser, Incident, IncidentFilter
  data/services/     AuthService, IncidentService, PhotoService
  providers/         AuthProvider, IncidentProvider
  ui/screens/        one file per screen
  ui/widgets/        reusable widgets
```

UI widgets call providers, providers call services, and services talk to Firebase and Cloudinary.

## Data model

users/{uid}

| Field | Type |
| --- | --- |
| name, email, department | string |
| role | student or staff |
| createdAt | timestamp |

incidents/{id}

| Field | Type |
| --- | --- |
| title, description, location | string |
| category | facilities, water, electricity, safety or sanitation |
| status | submitted, in_progress or resolved |
| reporterId, reporterName | string |
| isAnonymous | bool |
| photoUrl, staffNote | string, optional |
| statusHistory | list of status, changedBy, timestamp and note |
| createdAt, updatedAt | timestamp |

## Roles and access control

* Students register with an `@alustudent.com` email. Staff use `@alueducation.com` or `@si.alueducation.com`.
* Everyone who registers starts as a student. The Firestore rules reject any other role at registration.
* Only staff can change a report's status, and the rules enforce this on the server.
* A student can edit or delete only their own report, and only while it is Submitted.

## Run the app

1. Install Flutter 3.27 or newer and start an Android emulator or connect a phone.
2. Run `flutter pub get`.
3. Firebase: the repository already contains `lib/firebase_options.dart` and `android/app/google-services.json`. To use your own project, run `flutterfire configure`. In the Firebase Console enable Email/Password sign in and Cloud Firestore, then publish the contents of `firestore.rules` in the Firestore Rules tab.
4. Cloudinary: create a free account and an unsigned upload preset with the Asset folder set to `campus_incidents`. Put your cloud name and preset name in `lib/core/constants.dart`.
5. Run `flutter run -d <device-id>`.

## Create a staff account

1. Register in the app with a staff email and verify it.
2. In the Firebase Console open Firestore, then the `users` collection, and change the `role` field of that user to `staff`.
3. Sign out and sign in again.

## Tests

Run `flutter test` for the validator, model, filter and widget tests.

## Photo storage

The assignment brief names Firebase Storage. Firebase now requires a paid billing plan for Storage and prepaid cards are not accepted, so the course facilitator approved using another free storage service. Photos are uploaded to Cloudinary and only the image URL is saved in Firestore.

## Limitations

* Deleting a report does not remove its image from Cloudinary, because unsigned uploads cannot delete.
* Staff accounts are promoted manually in the Firestore Console.