# Color Generator App 🎨

A beautiful SwiftUI app that generates random colors, saves them to your collection, and syncs them across devices using Firebase Firestore.

## Features ✨
- Generate random colors with elegant animations
- Save colors to your personal collection
- Cloud sync via Firebase
- Works offline with automatic sync when connection returns
- Gorgeous glass-morphism UI

## Requirements 📋
- Xcode 15+
- iOS 17+
- Swift 5.9+
- Firebase account

## Installation 🛠️

### 1. Clone the repository
```bash
git clone https://github.com/your-username/Color-Generator.git
cd Color-Generator
```

### 2. Install dependencies
The project uses Swift Package Manager for dependencies. Xcode will automatically resolve these when you open the project.

### 3. Firebase Setup
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Create a new project
3. Add an iOS app to your project:
   - Bundle ID: Use your app's bundle identifier
   - Download the `GoogleService-Info.plist` file
4. Place the `GoogleService-Info.plist` file in the `Color_Generator` directory (same level as `ContentView.swift`)

### 4. Configure Firestore
1. In Firebase Console, go to Firestore Database
2. Create database in test mode
3. Set security rules:
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /userColors/{color} {
      allow read, write: if request.auth != null; // For production use
      // For testing use: allow read, write: if true;
    }
  }
}
```

## Running the App ▶️
1. Open `Color_Generator.xcodeproj` in Xcode
2. Select your development team in:
   - Project Navigator → Signing & Capabilities
3. Choose a simulator or connect a device
4. Build and run (⌘R)

## Project Structure 📂
```
Color_Generator/
├── Color_GeneratorApp.swift        - Main app entry
├── ContentView.swift               - Primary view
├── Models/
│   ├── Item.swift                  - Color data model
├── Utilities/
│   ├── NetworkMonitor.swift        - Network status tracking
│   ├── FirebaseService.swift       - Firestore operations  
│   ├── SyncManager.swift           - Sync coordination
├── Extensions/
│   ├── Color+Hex.swift             - Color extension
```

## Dependencies 📦
- FirebaseFirestore (via SPM)
- FirebaseCore (via SPM)
- SwiftData (native iOS 17+)

## Configuration ⚙️
To customize the app:
1. Change app name in `Info.plist`
2. Adjust color generation parameters in `generateAppleStyleColor()`
3. Modify sync behavior in `SyncManager.swift`

## Troubleshooting 🛠
**Firebase connection issues:**
- Verify `GoogleService-Info.plist` is correctly placed
- Check bundle identifier matches Firebase config
- Ensure Firestore rules allow access

**Sync problems:**
- Check network connection indicator
- Verify Firestore database is created
- Monitor Xcode console for sync logs
