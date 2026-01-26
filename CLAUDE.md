# Democracy Action iOS - Development Guide

## Architecture Overview

This SwiftUI app uses SwiftData for persistence and follows clean architecture principles with separated concerns.

### Key Principles

- **Single Responsibility**: Each manager has one clear purpose
- **SwiftUI-Native Patterns**: Use built-in SwiftUI patterns over custom solutions
- **Local-First**: All data bundled in app, no network dependencies
- **Clean Code**: Reduce boilerplate, prefer helpers over duplication

## Data Management Architecture

### Three Independent Managers

**1. DataMigrationManager** (`DataMigrationManager.swift`)
- **Purpose**: One-time Core Data → SwiftData migration
- **Runs**: Once per app lifetime (checks for `.sqlite` file)
- **Key Method**: `checkAndMigrateIfNeeded(modelContext:)`
- **Flag**: `DADefaults.SwiftDataMigrationCompleted`

**2. InitialDataManager** (`InitialDataManager.swift`)
- **Purpose**: Load data for fresh installs
- **Runs**: Once on first launch (when no existing data)
- **Key Method**: `checkAndLoadIfNeeded(modelContext:)`
- **Flag**: `DADefaults.InitialDataLoaded`

**3. DataUpdateManager** (`DataUpdateManager.swift`)
- **Purpose**: Sync updates from bundled Excel
- **Runs**: Every app launch (version check is fast)
- **Key Method**: `checkAndUpdateIfNeeded(modelContext:)`
- **Version Tracking**: `DADefaults.DataVersion`

### Launch Flow

```
SplashScreen.performInitialization()
  ↓
1. DataMigrationManager - Check for .sqlite, migrate if exists
  ↓
2. InitialDataManager - Load from Excel if no data
  ↓
3. DataUpdateManager - Check Excel version, sync if needed
  ↓
Main App
```

See `DATA_FLOW.md` for detailed documentation.

## Image Loading Patterns

### Bundle Resources: Use Synchronous Loading

**Problem**: AsyncImage cancels tasks on view lifecycle changes (e.g., tab switching), causing photos to fail loading.

**Solution**: Use synchronous `UIImage` loading for local bundle files.

```swift
// ✅ Correct - Synchronous loading for bundle files
FileImage(url: person.photo) { image in
    image
        .resizable()
        .aspectRatio(contentMode: .fill)
} placeholder: {
    Rectangle()
        .fill(.gray.opacity(0.2))
        .overlay {
            Image(systemName: "person.fill")
                .foregroundStyle(.gray.opacity(0.5))
        }
}

// ❌ Incorrect - AsyncImage fails on tab switches
AsyncImage(url: person.photo) { ... }
```

**Implementation**: See `Image+URL.swift` for `FileImage` view.

**Why**:
- Bundle files are local and fast (<1ms)
- No task cancellation issues
- More reliable across view lifecycle changes
- AsyncImage is designed for network URLs

## Web Browsing Patterns

### In-App Safari Sheets

All external links (websites, social media, search) open in Safari sheets for better UX.

```swift
struct MyView: View {
    @State private var safariURL: URL?

    var body: some View {
        // ... content
        .sheet(item: $safariURL) { url in
            SafariView(url: url)
                .ignoresSafeArea()
        }
    }

    private func openURL(_ urlString: String) {
        guard !urlString.isEmpty, let url = URL(string: urlString) else { return }
        safariURL = url
    }
}
```

### Deep Link Fallback Pattern

For social media, try native app first, then fall back to Safari sheet.

```swift
private func openWithAppFallback(appURL: URL, webURL: URL) {
    UIApplication.shared.open(appURL) { success in
        if !success {
            self.safariURL = webURL
        }
    }
}

private func openTwitter(account: String) {
    guard !account.isEmpty,
          let appURL = URL(string: "twitter://user?screen_name=\(account)"),
          let webURL = URL(string: "https://twitter.com/\(account)") else { return }
    openWithAppFallback(appURL: appURL, webURL: webURL)
}
```

**Files Using This Pattern**:
- `PersonDetailScreen.swift` - Person website/social media
- `PartyHeaderView.swift` - Party website/social media/search

## SwiftUI Patterns

### Sheet Presentation

**✅ Use `.sheet(item:)` with `Identifiable`**
```swift
@State private var safariURL: URL?

.sheet(item: $safariURL) { url in
    SafariView(url: url)
}
```

**❌ Avoid `.sheet(isPresented:)` with separate boolean**
```swift
// Don't do this - boilerplate
@State private var showSafari = false
@State private var safariURL: URL?

.sheet(isPresented: $showSafari) {
    if let url = safariURL {
        SafariView(url: url)
    }
}
```

**Why**: `URL` conforms to `Identifiable` via extension (`URL+Identifiable.swift`), making `.sheet(item:)` cleaner.

### Helper Functions

Extract repeated logic into helper functions to reduce boilerplate.

**Before** (13 lines per social media):
```swift
private func openTwitter(account: String) {
    guard !account.isEmpty else { return }
    if let url = URL(string: "twitter://user?screen_name=\(account)") {
        UIApplication.shared.open(url) { success in
            if !success {
                if let webURL = URL(string: "https://twitter.com/\(account)") {
                    self.safariURL = webURL
                }
            }
        }
    }
}
```

**After** (4 lines per social media + 6-line helper):
```swift
private func openTwitter(account: String) {
    guard !account.isEmpty,
          let appURL = URL(string: "twitter://user?screen_name=\(account)"),
          let webURL = URL(string: "https://twitter.com/\(account)") else { return }
    openWithAppFallback(appURL: appURL, webURL: webURL)
}

private func openWithAppFallback(appURL: URL, webURL: URL) {
    UIApplication.shared.open(appURL) { success in
        if !success { self.safariURL = webURL }
    }
}
```

## Korean Character Search

Person names are indexed with Korean character decomposition for search.

```swift
person.nameCharacters = name // "홍길동"
person.nameFirstCharacter = "홍"
person.nameFirstCharacters = name.getKoreanChoSeongs(false) // "ㅎㄱㄷ"
```

This enables search by:
- Full name: "홍길동"
- First character: "홍"
- Consonants only: "ㅎㄱㄷ"

Same pattern applies to `area` fields.

## Excel Data Structure

Data is loaded from `direct_democracy.xlsx` with version tracking.

### Version Tracking

```swift
DADefaults.DataVersion = excel.version // e.g., "1.2.0"
```

When bundled Excel version > stored version, updates are synced:
- **Groups**: Update existing, insert new, keep deleted (preserve relationships)
- **Persons**: Update existing, insert new, delete removed (cascade delete relationships)
- **Events**: Update event groups and details

### Korean Character Recomputation

On every person update, Korean search data is recomputed to ensure accuracy.

## File Organization

```
Projects/App/Sources/
├── Screens/
│   ├── SplashScreen.swift          # Coordinates all managers
│   ├── PersonDetailScreen.swift    # Person detail with Safari sheets
│   └── ...
├── Views/
│   ├── PoliticianRow.swift         # Uses FileImage for photos
│   ├── PersonProfileView.swift     # Profile header
│   ├── PartyHeaderView.swift       # Party header with Safari sheets
│   ├── SafariView.swift            # SFSafariViewController wrapper
│   └── Image+URL.swift             # FileImage for bundle resources
├── Managers/
│   ├── DataMigrationManager.swift  # Core Data → SwiftData
│   ├── InitialDataManager.swift    # Fresh install loading
│   ├── DataUpdateManager.swift     # Excel sync updates
│   └── ExcelDataLoader.swift       # Excel → SwiftData conversion
├── Data/
│   └── DADefaults.swift            # UserDefaults wrapper
└── Extensions/
    └── URL+Identifiable.swift      # Makes URL work with .sheet(item:)
```

## Common Patterns

### Data Loading with Progress

```swift
@MainActor
class MyDataManager: ObservableObject {
    @Published var progress: Double = 0.0
    @Published var status: DataStatus = .idle
    @Published var currentStep: String = ""

    func loadData(progressCallback: ((Double, String) async -> Void)?) async {
        await progressCallback?(0.0, "Starting...")
        // ... load step 1
        await progressCallback?(0.5, "Halfway done...")
        // ... load step 2
        await progressCallback?(1.0, "Complete")
    }
}
```

### Phone Number Handling

```swift
// SMS capability based on phone name
let phone = Phone(
    name: excelPhone.name,
    number: excelPhone.number,
    sms: excelPhone.name == "휴대폰"  // Mobile phones are SMS-capable
)

// Clean number for tel: URL
let cleanNumber = number.replacingOccurrences(of: "-", with: "")
let url = URL(string: "tel:\(cleanNumber)")
```

### Error Handling with Retry

```swift
.alert("Initialization Error", isPresented: $showError) {
    Button("Retry") {
        Task {
            await performInitialization()
        }
    }
    Button("Cancel", role: .cancel) {
        // Continue with existing data
        isDone = true
    }
} message: {
    Text(errorMessage)
}
```

## Testing Scenarios

### Data Flow Testing

1. **Fresh Install**
   - Delete app → Install → Launch
   - Expected: Data loads from Excel, version saved

2. **App Update with New Excel**
   - Install v1.0.0 → Update to v1.1.0 → Launch
   - Expected: Update sync runs, version updated

3. **App Update without Excel Change**
   - Install v1.0.0 → Update app (Excel still v1.0.0) → Launch
   - Expected: Version check only (<100ms), no sync

4. **Core Data Migration**
   - Old app (Core Data) → Update to SwiftData app → Launch
   - Expected: Migration runs once, never again

### UI Testing

1. **Photo Loading**
   - Favorite a person → Switch tabs → Return
   - Expected: Photo loads and persists

2. **Safari Sheets**
   - Tap website link → Safari sheet opens in-app
   - Swipe down to dismiss → Returns to app

3. **Deep Links**
   - Tap Twitter (app not installed) → Safari sheet opens
   - Tap Twitter (app installed) → Twitter app opens

## Performance Notes

- **Bundle file loading**: <1ms (synchronous UIImage)
- **Fresh install**: ~3-5 seconds (load all Excel data)
- **Excel update**: ~2-3 seconds (only when needed)
- **Normal launch**: ~200ms (version check only)

## Code Style

Following Paul Hudson / Antoine van der Lee patterns:

- **Clear, descriptive names**: `openWithAppFallback` over `open2`
- **Guard early**: Validate inputs at function start
- **Reduce nesting**: Use guard/early return over nested if
- **SwiftUI native**: Prefer built-in patterns over custom solutions
- **No premature abstraction**: Don't create helpers until pattern repeats 3+ times

## Dependencies

- **SwiftUI**: UI framework
- **SwiftData**: Persistence (iOS 17+)
- **UIKit**: For UIApplication, SFSafariViewController
- **Foundation**: Core utilities

No external dependencies (CocoaPods, SPM packages).

## Important Constraints

- **No Network**: All data bundled, no downloads
- **No Project Regeneration**: Modify existing files only (Tuist constraint)
- **iOS 17+**: SwiftData requirement
- **Bundle Resources**: Photos in `Resources/photos/`, Excel in `Resources/Datas/`
