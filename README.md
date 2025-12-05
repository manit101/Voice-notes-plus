# Voice Notes Plus

Voice Notes Plus is a Flutter application designed to make note-taking effortless using speech-to-text technology. Users can record their thoughts, which are automatically transcribed into text, and manage their notes with ease.

## Features

- **Voice to Text**: Instantly transcribe your voice into text notes using the device's microphone.
- **Local Storage**: All notes are stored securely on your device using a local SQLite database.
- **Search**: Quickly find notes by searching for keywords in the title.
- **Pin Notes**: Pin important notes to the top of your list for quick access.
- **Edit & Delete**: Modify the content of your notes or remove them when they are no longer needed.
- **Dark/Light Mode**: Toggle between dark and light themes for a comfortable viewing experience.
- **Offline Capable**: Works entirely offline without needing an internet connection for basic functionality.

## Screenshots

*(Add screenshots here)*

## Getting Started

### Prerequisites

- [Flutter SDK](https://flutter.dev/docs/get-started/install) installed on your machine.
- An Android or iOS device/emulator.

### Installation

1.  **Clone the repository:**
    ```bash
    git clone https://github.com/yourusername/voice_notes_plus.git
    cd voice_notes_plus
    ```

2.  **Install dependencies:**
    ```bash
    flutter pub get
    ```

3.  **Run the app:**
    ```bash
    flutter run
    ```

## Project Structure

The project follows a clean MVC (Model-View-Controller) architecture:

-   **`lib/models/`**: Contains data models (e.g., `Note`).
-   **`lib/views/`**: Contains the UI screens (`HomeScreen`, `AddNoteScreen`, `NoteDetailScreen`).
-   **`lib/controllers/`**: Handles data logic and database interactions (`DatabaseHelper`).
-   **`lib/main.dart`**: The entry point of the application.

## Dependencies

-   [speech_to_text](https://pub.dev/packages/speech_to_text): For converting speech to text.
-   [sqflite](https://pub.dev/packages/sqflite): For local database storage.
-   [path](https://pub.dev/packages/path): For handling file paths.
-   [permission_handler](https://pub.dev/packages/permission_handler): For managing app permissions (microphone).
-   [intl](https://pub.dev/packages/intl): For date formatting.

## Usage

1.  **Grant Permissions**: Upon first launch, grant microphone permissions to allow recording.
2.  **Create a Note**: Tap the `+` button, then tap the microphone icon to start recording. Tap again to stop.
3.  **Save**: Review the transcribed text and tap "Save".
4.  **Search**: Use the search bar on the Home Screen to filter notes.
5.  **Pin**: Tap the star icon on a note to pin it to the top.
6.  **Edit**: Tap the pencil icon or open a note and tap the edit button to make changes.

## Contributing

Contributions are welcome! Please fork the repository and submit a pull request.

## License

This project is licensed under the MIT License.
