# AIU Church Program Bulletin

A Flutter + Firebase app for managing and viewing AIU Church service information.

This project includes a role-based content management flow for church staff and a clean viewing experience for members and guests.

## Current Feature Set

### Core modules
- Program Bulletin (service flow / order of worship)
- Announcements
- Events Calendar
- Contacts
- Duty Roster

### Role-based permissions
- `admin` and `clerk` can create, edit, and delete records in managed modules.
- `user` and guests are read-only for protected content.

### Sabbath archive system
- Content is organized by Sabbath archives in `services/{serviceId}`.
- Admin/clerk users can browse archives and manage active Sabbath.
- Users/guests only see the active Sabbath archive.
- Supports creating/opening next Sabbath for planning.

### Live current program control
- "Now it is" card shows current program step.
- Admin/clerk can move the sequence forward/backward.
- Current program state is tracked per service archive.

### Personal notes
- Logged-in users can open notes directly from the current program.
- Notes are private per user and scoped by Sabbath + program item.
- Auto-save with manual save option.
- Includes per-Sabbath note history view.

### Additional screens
- About screen (mission + contact info)
- App header with account dialog and sign in/out controls

## Role Matrix

| Feature | Admin | Clerk | User | Guest |
|---|---|---|---|---|
| View active Sabbath content | Yes | Yes | Yes | Yes |
| Browse previous archives | Yes | Yes | No | No |
| CRUD: Bulletin | Yes | Yes | No | No |
| CRUD: Announcements | Yes | Yes | No | No |
| CRUD: Events | Yes | Yes | No | No |
| CRUD: Contacts | Yes | Yes | No | No |
| CRUD: Duty Roster | Yes | Yes | No | No |
| Personal notes | Yes | Yes | Yes | No |

## Tech Stack

- Flutter
- Provider (state management)
- Firebase Auth
- Cloud Firestore

## Firestore Structure (current)

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

## Getting Started

### 1. Prerequisites
- Flutter SDK installed
- A Firebase project configured for your target platform(s)

### 2. Install dependencies

```bash
flutter pub get
```

### 3. Run the app

```bash
flutter run
```

## Firebase Setup Notes

- Ensure Firebase config files are present for your platform(s):
    - `android/app/google-services.json`
    - iOS/macOS equivalents when needed
- Verify `lib/firebase_options.dart` matches your Firebase project.

## Seed Sample Data (Optional)

The app includes an archive-aware seeder in `lib/services/seeder_service.dart`.

What it can seed:
- Multiple Sabbath archives (past + future)
- Program items and announcements per archive
- Active Sabbath and current program pointers
- Events and contacts

To run seeding once from startup:

1. Add import in `lib/main.dart`:

```dart
import 'services/seeder_service.dart';
```

2. Call one of the seeder methods after Firebase initialization:

```dart
await SeederService().seedFirestore();
// or
await SeederService().seedSabbathArchives(
    pastWeeks: 6,
    futureWeeks: 3,
    overwriteExisting: false,
);
```

3. Remove/comment it again after seeding to avoid reseeding on every launch.

## Project Map

For a full folder map and detailed feature inventory, see:
- `PROJECT_SF.md`
