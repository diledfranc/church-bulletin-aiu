# AIU Church Program Bulletin

## Project Structure

```text
aiu_church_program_bulletin/
├── android/
├── ios/
├── linux/
├── macos/
├── web/
├── windows/
├── assets/
│   └── images/
│       └── church-logo-white.png
├── lib/
│   ├── main.dart
│   ├── firebase_options.dart
│   ├── data/
│   │   └── dummy_data.dart
│   ├── models/
│   │   ├── announcement.dart
│   │   ├── bulletin_item.dart
│   │   ├── contact.dart
│   │   ├── duty_roster_item.dart
│   │   ├── event.dart
│   │   ├── sabbath_service.dart
│   │   ├── user.dart
│   │   └── user_note.dart
│   ├── providers/
│   │   └── auth_provider.dart
│   ├── screens/
│   │   ├── home_screen.dart
│   │   ├── bulletin_screen.dart
│   │   ├── announcements_screen.dart
│   │   ├── events_calendar_screen.dart
│   │   ├── contacts_screen.dart
│   │   ├── duty_roster_screen.dart
│   │   ├── sermon_notes_screen.dart
│   │   ├── about_screen.dart
│   │   ├── edit_bulletin_item_screen.dart
│   │   ├── edit_announcement_screen.dart
│   │   ├── edit_event_screen.dart
│   │   ├── edit_contact_screen.dart
│   │   └── edit_duty_roster_screen.dart
│   ├── services/
│   │   ├── bulletin_service.dart
│   │   ├── announcement_service.dart
│   │   ├── event_service.dart
│   │   ├── contact_service.dart
│   │   ├── duty_roster_service.dart
│   │   ├── notes_service.dart
│   │   ├── sabbath_archive_service.dart
│   │   └── seeder_service.dart
│   └── widgets/
│       ├── app_header.dart
│       ├── archive_selector_card.dart
│       ├── current_program_card.dart
│       ├── login_dialog.dart
│       └── sabbath_info_card.dart
├── test/
├── pubspec.yaml
└── README.md
```

## App Features

### 1. Authentication and Roles
- Firebase Authentication with email/password sign in and registration.
- Role-based access control via `UserRole`: `admin`, `clerk`, `user`.
- Admin and clerk users can create/update/delete content.
- Users and guests are view-only for protected modules.

### 2. Header and About
- App header with church logo and profile/login control.
- Tap logo to open About page.
- About page includes mission statement, contact details, and app version.

### 3. Program Bulletin Module
- View weekly Sabbath program flow.
- Admin/clerk CRUD for program items.
- "Now it is" live program section.
- Admin/clerk controls to move program sequence (`previous` / `next`).
- "Open Notes" action to write notes for the current program item.

### 4. Announcements Module
- List announcements with dates.
- Admin/clerk CRUD for announcements.

### 5. Events Calendar Module
- Upcoming events list with date badge and event time/location.
- Admin/clerk CRUD for calendar events.

### 6. Contacts Module
- Contact directory with role, phone, and email.
- Admin/clerk CRUD for contacts.
- Overflow-safe rendering for long phone/email values.

### 7. Duty Roster Module
- Duty assignment list by role, name, and date.
- Admin/clerk CRUD for duty assignments.

### 8. Sabbath Archive System
- Sabbath archives stored under `services` collection.
- Archive selector available to admin/clerk users.
- Guests/users only see active Sabbath data.
- "Create/Open Next Sabbath" support for planning upcoming services.
- Active Sabbath pointer stored in `settings/program_status`.

### 9. Notes Module (User Personal Notes)
- Private notes stored per user in `users/{uid}/notes`.
- Notes linked to Sabbath service and program item.
- Auto-save while typing plus manual save.
- "This Sabbath" note history tab.

### 10. Seeder Support
- Seeder service can populate:
- Multiple Sabbath archives (past and future weeks).
- Program items and announcements per archive.
- Active Sabbath and current program pointers.
- Supplemental events and contacts.

## Firestore Data Layout (Current)

```text
users/{uid}
users/{uid}/notes/{noteId}

settings/program_status

services/{serviceId}
services/{serviceId}/program_items/{itemId}
services/{serviceId}/announcements/{announcementId}

events/{eventId}
contacts/{contactId}
duty_roster/{dutyId}
```

## Home Navigation Tabs
- Program
- Announce
- Calendar
- Contacts
- Roster

## Notes
- This file is intended as a quick project map for developers and maintainers.
- Update this document whenever new major features, screens, or services are added.
