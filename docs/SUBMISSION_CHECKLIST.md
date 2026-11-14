# Submission Checklist and Rubric Map

## Deliverables (all required, incomplete submissions are not graded)
* [ ] Technical report as a PDF (not a Google Doc link), IEEE or APA references
* [ ] GitHub repository link inside the report
* [ ] Demo video link (7 to 10 minutes) inside the report
* [ ] File named StudentName_Assignment2.pdf
* [ ] App runs on an Android or iOS emulator or a real phone

## Rubric map: what to show or say

| Criterion | Where it lives in the app | Show in the demo |
| --- | --- | --- |
| UI/UX (6) | ui/screens, ui/widgets, core/theme.dart | Home, report form, details timeline, empty and loading states, explain design choices |
| Authentication (6) | AuthService, AuthProvider, AuthGate, VerifyEmailScreen | Register, verification email, ALU only validation, Firebase Console users list, logout and relogin |
| Firestore CRUD (6) | IncidentService | Create, live read, edit, delete, status update, then the incidents documents in the Console |
| State management (8) | AuthProvider, IncidentProvider | Student and staff screens update from one Firestore stream, explain ChangeNotifier |
| Features (7) | report_form_screen, filter bar, details screen | Category, validation, photo upload, search, status and category filters, loading and error messages |
| Technical explanation (7) | Whole codebase | Walk through folders, one provider, one service, firestore.rules |
| Code quality (5) | Three layers, reusable widgets | Point at widgets reused across screens and the service layer |
| Report (5) | docs/REPORT_OUTLINE.md | Diagrams, screenshots, rules snippets, tests, limitations, references |
| Product thinking (5) | Anonymous mode, duplicate warning, role rules | Explain privacy, misuse prevention and why students can delete only Submitted reports |

## Before recording
* [ ] Cloudinary cloud name and unsigned preset set in lib/core/constants.dart
* [ ] Firestore rules published
* [ ] One student account and one staff account verified and ready
* [ ] A few sample reports with different categories and statuses
* [ ] Firebase Console and Cloudinary Media Library open in browser tabs
* [ ] Phone on Do Not Disturb, battery charged, screen recording tested

## Known limitations to state honestly in the report
* Deleting a report does not delete its image from Cloudinary (unsigned uploads cannot delete)
* No push notifications or offline queue
* Staff accounts are promoted manually in the Firestore Console
