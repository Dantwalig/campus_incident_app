# Campus Incident Reporting App

A Flutter mobile app that I built for Individual Assignment 2. ALU students use it to report campus issues such as broken facilities, water shortages, electricity outages, safety concerns and sanitation problems. Authorised staff review the reports and update their status until the issue is resolved. The app runs on Android and iOS.

## Features

* Registration, login, logout and password reset with Firebase Authentication
* Email verification, with access limited to ALU email addresses
* Student and staff roles, each with its own screens
* Report an incident with a category, title, description, location and an optional photo
* Anonymous reporting, and a warning when a similar open report already exists
* My Reports and a campus feed with search, status filter and category filter
* Incident details with a status timeline and activity history
* Edit or delete my own report while it is still Submitted
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
test/                validator, model, filter, widget and provider tests
docs/                report outline, demo script and submission checklist
```

The UI widgets call the providers, the providers call the services, and the services talk to Firebase and Cloudinary. Screens never access Firebase directly.

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
* Only staff can change a report's status, and the rules enforce this on the server, not only in the UI.
* A student can edit or delete only their own report, and only while it is Submitted.

## Run the app

1. Install Flutter 3.35 or newer and start an Android emulator, an iOS simulator or connect a phone.
2. Run `flutter pub get`.
3. Run `flutter run -d <device-id>`. Use `flutter devices` to list the available devices.

The repository already contains my Firebase configuration (`lib/firebase_options.dart` and `android/app/google-services.json`) and my Cloudinary details (`lib/core/constants.dart`), so the app connects to my backend without any extra setup.

To run it against a different Firebase project, I run `flutterfire configure`, enable Email/Password sign in and Cloud Firestore in the Firebase Console, and publish the contents of `firestore.rules` in the Firestore Rules tab. For different Cloudinary details, I create an unsigned upload preset with the Asset folder set to `campus_incidents` and update the cloud name and preset name in `lib/core/constants.dart`.

## Create a staff account

1. Register in the app with a staff email and verify it.
2. In the Firebase Console open Firestore, then the `users` collection, and change the `role` field of that user to `staff`.
3. Sign out and sign in again.

## Tests

Run `flutter test`. The tests cover:

* the validators (ALU email, password and required fields)
* the Incident model mapping and the search and filter logic
* the StatusBadge widget
* `IncidentProvider`, using an in memory fake service, which covers live updates, submitting normal and anonymous reports, photo upload failures, write failures and staff status updates

I also tested the access rules by hand with two accounts: a student trying to change a report's status is rejected by the Firestore rules, while a staff account succeeds.

## Photo storage

The assignment brief names Firebase Storage. Firebase now requires a paid billing plan for Storage, and I could not set that up because prepaid cards are not accepted. The course facilitator approved using another free storage service, so photos are uploaded to Cloudinary with an unsigned upload preset. Only the image URL is saved in Firestore, in the `photoUrl` field. Images are resized and compressed on delivery to save mobile data.

## Privacy

Anonymous reporting hides my name from staff and from other students in the app. The report document still stores the reporter's user id, which is what lets the rules make sure only the owner can edit or delete it. The name is hidden in the app, but the id is not removed from the database.

## Latest fixes

* Added the `INTERNET` permission to the main Android manifest. It was only declared for debug and profile builds, so a release build had no network access.
* Added the camera and photo library usage descriptions to the iOS `Info.plist`. Without them iOS closes the app when the photo picker opens.
* Corrected the minimum Flutter version in this README to 3.35, because the report form uses `DropdownButtonFormField(initialValue:)`.
* Changed the app name to "Campus Incidents" on Android and iOS.
* Added unit tests for `IncidentProvider`.
* Removed the unused Linux, macOS, Windows and web folders, since the app targets Android and iOS only.
* Documented how anonymous reporting works and what it does not hide.

## Limitations

* Deleting a report does not remove its image from Cloudinary, because unsigned uploads cannot delete.
* There are no push notifications and no offline queue.
* Staff accounts are promoted manually in the Firestore Console.
