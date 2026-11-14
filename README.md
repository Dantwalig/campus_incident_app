# Campus Incident Reporting App

A Flutter mobile app where students report campus issues (facilities, water,
electricity, safety, sanitation) and authorised staff review them and update
their status. Built for ALU Individual Assignment 2.

## Features

* Registration, login, logout, password reset
* Email verification and ALU only access: students use alustudent.com, staff use
  alueducation.com or si.alueducation.com
* Roles: student and staff, enforced in the UI and in Firebase security rules
* Submit reports with category, title, description, location and optional photo
* Anonymous reporting and a duplicate report warning
* My reports and a campus feed, with search plus status and category filters
* Incident details with a status timeline and activity history
* Edit or delete your own report while it is still Submitted
* Staff dashboard with live counts and status updates with notes
* Realtime updates from Cloud Firestore

## Tech stack

* Flutter and Dart
* State management: Provider (ChangeNotifier)
* Firebase Authentication and Cloud Firestore
* Cloudinary (free plan) for incident photos

## Photo storage decision

The assignment brief names Firebase Storage for photos. Firebase now requires a
paid billing plan (Blaze) to enable Storage, and prepaid cards are not accepted.
The course facilitator approved using another free storage service, so photos are
uploaded to Cloudinary (free tier, no card needed). Firebase Authentication and
Cloud Firestore are used as required. Only the image URL is stored in Firestore.

Cloudinary also resizes and compresses images on delivery (small thumbnails in
lists, larger images on the details screen), which keeps the app fast on mobile data.

## Architecture

```
lib/
  main.dart                    app entry, providers
  core/                        theme, constants, validators, helpers
  data/models/                 AppUser, Incident, IncidentFilter
  data/services/               AuthService, IncidentService, PhotoService
  providers/                   AuthProvider, IncidentProvider
  ui/screens/                  login, register, verify email, home, report form,
                               my reports, details, staff dashboard, profile
  ui/widgets/                  reusable widgets (cards, chips, badges, timeline)
```

Flow: UI widgets call Providers, Providers call Services, Services talk to
Firebase. Screens never import Firebase directly (except models for timestamps).

## Firestore data model

users/{uid}

| Field | Type | Notes |
| --- | --- | --- |
| name | string | |
| email | string | ALU email |
| role | string | student or staff |
| department | string | optional |
| createdAt | timestamp | |

incidents/{id}

| Field | Type | Notes |
| --- | --- | --- |
| title, description, location | string | |
| category | string | facilities, water, electricity, safety, sanitation |
| status | string | submitted, in_progress, resolved |
| reporterId, reporterName | string | reporterName is Anonymous when hidden |
| isAnonymous | bool | |
| photoUrl | string | Cloudinary image URL, optional |
| staffNote | string | latest staff note, optional |
| statusHistory | array of maps | status, changedBy, timestamp, note |
| createdAt, updatedAt | timestamp | |

Photos are uploaded to Cloudinary (folder campus_incidents/{uid}). Only the image URL is stored in Firestore.

## Setup

1. Install Flutter (3.27 or newer) and the Firebase CLI, then run
   `dart pub global activate flutterfire_cli`.
2. Generate the native Android and iOS folders inside this project:
   `flutter create . --org com.yourname --project-name campus_incident_app`
3. Create a Firebase project. Enable Authentication (Email/Password) and
   Cloud Firestore. Firebase Storage is not used.
4. Run `flutterfire configure` and choose your project. It overwrites
   `lib/firebase_options.dart`.
5. Android only: in `android/app/build.gradle` (or `build.gradle.kts`) make sure
   `minSdk` is at least 23.
6. Deploy the security rules: copy `firestore.rules` into the Rules tab of
   Firestore in the Firebase Console and publish.
7. Set up Cloudinary (see the next section).
8. Run `flutter pub get`, then `flutter run`.

If a package version fails to resolve, run `flutter pub upgrade --major-versions`.

## Cloudinary setup (photo uploads)

1. Create a free account at cloudinary.com and copy your Cloud name from the dashboard.
2. Go to Settings, Upload, Upload presets, and click Add upload preset.
3. Set Signing mode to Unsigned, set a name, and save.
4. Open `lib/core/constants.dart` and replace `n4xbtdw9` and
   `YOUR_UNSIGNED_PRESET` with your values.
5. Android release builds need `<uses-permission android:name="android.permission.INTERNET"/>`
   in `android/app/src/main/AndroidManifest.xml` (debug builds already have it).

Note: unsigned presets cannot delete images from the app, so deleting a report
removes the Firestore record but the image stays in Cloudinary. This is listed as
a limitation in the report.

## Creating a staff account

1. Register a normal account in the app with an ALU email and verify it.
2. In Firebase Console open Firestore, collection users, the document with that
   user's UID, and change the field `role` from `student` to `staff`.
3. Sign out and sign in again. The staff dashboard appears.

Self registration can only ever create students, because the security rules
reject a users document with any other role.

## Pushing to GitHub

Commit `lib/firebase_options.dart`, `android/app/google-services.json` and
`pubspec.lock`. They contain client configuration, not secrets, and graders need
them to build the app. Data is protected by the Firestore rules, not by hiding
these files. The Cloudinary cloud name and the unsigned preset are public by design.

## Tests

`flutter test` runs the validator, model, filter and widget tests.

## Suggested commit history

```
chore: initial Flutter project setup
feat(core): add theme, constants and validators
feat(auth): add registration, login and email verification
feat(incidents): add models, services and provider
feat(ui): add student home, report form and report lists
feat(staff): add dashboard and status updates
feat(security): add Firestore security rules
test: add unit and widget tests
docs: add README, report outline and demo script
```
