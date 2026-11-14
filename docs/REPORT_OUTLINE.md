# Technical Report Outline (export to PDF, IEEE or APA references)

Name the final file: YourName_Assignment2.pdf

## Cover page
* Title, your name, course, date
* GitHub repository link
* Demo video link (7 to 10 minutes)

## 1. Introduction
* Problem: students have no central channel to report campus issues
* Goals and scope of the app

## 2. Architecture
* Three layers: data (models, services), providers (state), ui (screens, widgets)
* Insert an architecture diagram: UI to Provider to Service to Firebase
* Folder structure screenshot
* Justify each major decision (Provider, streams, service classes)

## 3. Firebase data structure
* Collections: users, incidents (fields table from README)
* Photos are stored on Cloudinary (unsigned upload preset), the URL is saved in photoUrl
* Explain why Cloudinary was used instead of Firebase Storage: Blaze billing needs a card that is not available, and the facilitator approved an alternative
* Include a screenshot of the facilitator's approval message as evidence
* Mention server side image transformations (thumbnail and detail sizes)
* Insert a data model diagram and Firebase Console and Cloudinary screenshots

## 4. State management
* Why Provider with ChangeNotifier
* AuthProvider (session, profile, role) and IncidentProvider (live list, actions)
* How one Firestore stream updates every screen at once

## 5. User roles and access control
* Roles: student and staff, stored in users/{uid}.role
* Client side: staff UI is only built for staff
* Server side: firestore.rules (paste key snippets)
* Email verification and ALU domain restriction

## 6. UI and UX decisions
* Screenshots: login, register, verify email, home, report form, my reports,
  details with timeline, staff dashboard
* Reasons: category chips, status badges, timeline, empty and loading states

## 7. Testing strategy
* Unit tests: validators, model mapping, filters (test folder)
* Widget test: StatusBadge
* Manual test table: workflow, expected result, actual result
* Security rule tests with two accounts (student cannot update status)

## 8. Challenges and lessons learned
* Examples: token refresh after email verification, array fields and
  server timestamps, composite index avoidance, rules for partial updates

## 9. Limitations and future work
* Push notifications, offline mode, multi photo upload, admin tools

## 10. Privacy and misuse considerations
* Anonymous reporting, duplicate warning, delete only while submitted
* Limitation: Cloudinary images are not removed when a report is deleted

## References
* Flutter, Firebase and Provider documentation (cite with access dates)
