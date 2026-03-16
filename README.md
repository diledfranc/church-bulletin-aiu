# AIU Church Program Bulletin

A Flutter mobile application for the AIU Church, featuring a digital program bulletin and announcements.

## Features

- **Weekly Program Bulletin**: View the order of service, hymns, scripture readings, and sermon details.
- **Announcements**: Stay updated with upcoming church events and notifications.
- **Offline Access**: The content is bundled with the app (currently using placeholder data).

## Getting Started

To run this project, ensure you have Flutter installed and set up.

1.  **Clone the repository**:
    `ash
    git clone https://github.com/diledfranc/church-bulletin-aiu.git
    cd church-bulletin-aiu
    `

2.  **Install dependencies**:
    `ash
    flutter pub get
    `

3.  **Run the app**:
    `ash
    flutter run
    `

## Project Structure

- lib/models: Data models for Bulletin Items and Announcements.
- lib/screens: UI screens for the Bulletin, Announcements, and Home.
- lib/data: Dummy data used to populate the app (replace with API or local database in the future).
- lib/widgets: Reusable UI components.

## Future Improvements

- Add a backend to manage bulletin and announcements dynamically.
- Integration with calendar for events.
- Push notifications for important updates.
- Theme customization.
