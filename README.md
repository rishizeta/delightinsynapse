# delightinsynapse

A mobile-first Flutter app to preview all your Rive (.riv) files. Works on Android, iOS, and Web.

## Features

- Lists all Rive files in `assets/rive/` with name and file size
- Tap to preview animation on a new page
- Mobile-first UI, centered on web
- Easy to add new Rive files (just update the manifest)

---

## 🚀 Running in GitHub Codespaces (Step-by-Step)

You can run this Flutter app entirely in the cloud using [GitHub Codespaces](https://github.com/features/codespaces), with no local setup required. Here’s how:

### 1. **Open the Project in Codespaces**

- On your GitHub repo page, click the green **Code** button, then **Open with Codespaces** → **New codespace**.
- Wait for the Codespace to start (it opens a browser-based VS Code editor).

### 2. **Install Flutter in Codespaces**

- Open a new terminal in Codespaces (Terminal → New Terminal).
- Run the following commands:
  ```sh
  # Download Flutter
  git clone https://github.com/flutter/flutter.git -b stable
  # Add Flutter to PATH for this session
  export PATH="$PATH:$(pwd)/flutter/bin"
  # (Optional) Add to ~/.bashrc or ~/.zshrc for persistence
  flutter --version
  ```
- You should see Flutter’s version info printed.

### 3. **Install Project Dependencies**

```sh
flutter pub get
```

### 4. **Add Your Rive Files**

- Upload your `.riv` files to the `assets/rive/` folder (use the VS Code file explorer or drag-and-drop).

### 5. **Generate the Manifest**

```sh
dart assets/rive/generate_manifest.dart
```

- This creates/updates `assets/rive/manifest.json` with your files and sizes.

### 6. **Run the App**

#### **A. Preview on Web (Easiest, works in browser)**

```sh
flutter run -d web-server
```

- The terminal will show a local URL (e.g., `http://127.0.0.1:8000`).
- Click the **Ports** tab in Codespaces, find the port (e.g., 8000), and click the globe icon to open the app in your browser.

#### **B. Run on Android Emulator**

- Codespaces does **not** support running Android emulators directly in the cloud.
- To run on a real Android device, you must clone the repo and run locally on your machine with Flutter installed.

#### **C. Run on iOS Simulator**

- Codespaces does **not** support iOS simulators.
- To run on iOS, you must use a Mac with Flutter and Xcode installed.

**Summary:**

- **Web preview works great in Codespaces.**
- **For Android/iOS, use your own machine.**

---

## Getting Started (Locally)

1. **Clone or copy this project**
2. **Add your `.riv` files** to `assets/rive/`
3. **Update `assets/rive/manifest.json`**
   - Run the provided script (`generate_manifest.dart`) to auto-generate the manifest with file names and sizes
4. **Run the app:**
   ```sh
   flutter pub get
   flutter run
   ```

## Adding New Rive Files

1. Place your new `.riv` file in `assets/rive/`
2. Run the manifest generator:
   ```sh
   dart assets/rive/generate_manifest.dart
   ```
3. Your new file will appear in the app list automatically!

## Project Structure

- `assets/rive/` — Place all your `.riv` files here
- `assets/rive/manifest.json` — List of all Rive files and their sizes (auto-generated)
- `lib/` — Flutter app source code

## Dependencies

- [rive](https://pub.dev/packages/rive)
- [path](https://pub.dev/packages/path)

## Notes

- Flutter cannot list bundled asset directories at runtime, so we use a manifest file.
- File sizes are calculated at build time by the script.

---

Enjoy previewing your Rive animations!
