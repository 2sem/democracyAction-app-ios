# Making Renovate Work with Tuist: Detecting Swift Package Dependencies Across Multiple Project Files

When you adopt Tuist to manage your iOS project's modular architecture, you gain powerful project generation capabilities. But there's a hidden challenge: automated dependency management tools like Renovate don't know how to read Tuist's `Project.swift` files out of the box. After spending several hours debugging why Renovate detected only 1 out of 12 Swift package dependencies in my project, I discovered the key insights that made everything work. Here's what I learned.

## The Problem: Invisible Dependencies

My iOS project uses Tuist to organize code into three modules, each with its own `Project.swift` file:

- `Projects/App/Project.swift` - Main app target with 1 dependency
- `Projects/ThirdParty/Project.swift` - Static framework with 10 dependencies
- `Projects/DynamicThirdParty/Project.swift` - Dynamic framework with 2 dependencies

When I first configured Renovate, it only detected `CoreOffice.CoreXLSX`. The other 11 packages were completely invisible. This was frustrating because I knew the dependencies were there, declared clearly in the Swift files.

The root cause? Tuist uses two different syntaxes for declaring Swift packages:

**Dot notation** (Swift Package Registry format):
```swift
.package(id: "CoreOffice.CoreXLSX", exact: "0.14.1")
.package(id: "krzyzanowskim.CryptoSwift", from: "1.8.3")
.package(id: "firebase.firebase-ios-sdk", from: "11.8.1")
```

**Remote URL format** (GitHub repositories):
```swift
.remote(url: "https://github.com/kakao/kakao-ios-sdk",
        requirement: .upToNextMajor(from: "2.22.2"))

.remote(url: "https://github.com/2sem/GADManager",
        requirement: .upToNextMajor(from: "1.3.8"))
```

Renovate's built-in Swift package manager doesn't understand these formats. We need custom regex patterns to extract the dependency information.

## The Investigation: Why Was Only One Working?

I started by examining what made `CoreOffice.CoreXLSX` special. Looking at Renovate's logs, I noticed it was successfully looking up `CoreOffice/CoreXLSX` on GitHub. The dot in the package ID had been transformed into a slash.

That's when it clicked: **Swift Package Registry uses dot notation (like Java package names), but GitHub uses slash notation for repositories**. The package ID `CoreOffice.CoreXLSX` corresponds to the GitHub repository `CoreOffice/CoreXLSX`.

For packages using `.remote()` with full GitHub URLs, this wasn't an issue. The repository path was already explicit:
```swift
.remote(url: "https://github.com/kakao/kakao-ios-sdk", ...)
// → Renovate knows to look up kakao/kakao-ios-sdk
```

But for packages using `.package(id:)`, Renovate needed help transforming the dot notation:
```swift
.package(id: "krzyzanowskim.CryptoSwift", from: "1.8.3")
// → Needs to become krzyzanowskim/CryptoSwift
```

The second problem was multiline declarations. Swift developers often format package declarations across multiple lines for readability:

```swift
.remote(
    url: "https://github.com/2sem/GADManager",
    requirement: .upToNextMajor(from: "1.3.8")
)
```

My initial regex patterns used `.+?` which doesn't match newlines by default. These multiline declarations were invisible to Renovate.

## The Solution: Three Key Configuration Elements

The complete solution required three interconnected fixes in `renovate.json`:

### 1. Multiline-Aware Regex Patterns

Replace simple character matching with patterns that handle flexible whitespace and line breaks:

```json
{
  "matchStrings": [
    "\\.package\\(id:\\s*\"(?<depName>[\\w\\-.]+?)\"[\\s\\S]*?(?:from|exact):\\s*\"(?<currentValue>[^\"]+)\"\\)"
  ]
}
```

The critical changes:
- `\\s*` - Matches zero or more whitespace characters (spaces, tabs, newlines)
- `[\\s\\S]*?` - Matches any character including newlines (non-greedy)
- This pattern now works whether the declaration is on one line or split across multiple lines

For remote URL declarations:
```json
{
  "matchStrings": [
    "\\.remote\\(url:\\s*\"(?:https?:\\/\\/)?github\\.com\\/(?<depName>[\\w\\-_]+\\/[\\w\\-_.]+?)(?:\\.git)?\"[\\s\\S]*?requirement:\\s*\\.(?:upToNextMajor|upToNextMinor)\\(from:\\s*\"(?<currentValue>[^\"]+)\"\\)"
  ]
}
```

This handles:
- Optional `https://` or `http://` prefix
- Optional `.git` suffix
- Various requirement types (`.upToNextMajor`, `.upToNextMinor`, `.exact`)
- Multiline formatting with any amount of whitespace

### 2. Package Name Transformation

Here's the critical discovery - the `packageNameTemplate` configuration:

```json
{
  "packageNameTemplate": "{{{replace '\\.' '/' depName}}}"
}
```

This template uses Handlebars syntax to transform the captured `depName`:
- Input: `krzyzanowskim.CryptoSwift`
- Output: `krzyzanowskim/CryptoSwift`

Without this transformation, Renovate would try to look up a repository named `krzyzanowskim.CryptoSwift` (with a literal dot), which doesn't exist on GitHub. The slash notation matches GitHub's repository structure.

Note the triple braces `{{{ }}}` instead of double `{{ }}`. This is important because it prevents Handlebars from HTML-escaping the result, which would turn the slash into `&#x2F;`.

### 3. Multiple Custom Managers for Different Patterns

Instead of trying to create one complex regex to handle all cases, I created separate custom managers for each declaration pattern:

```json
{
  "customManagers": [
    {
      "customType": "regex",
      "managerFilePatterns": ["/(^|/)Project\\.swift$/"],
      "matchStrings": [
        "\\.package\\(id:\\s*\"(?<depName>[\\w\\-.]+?)\"[\\s\\S]*?(?:from|exact):\\s*\"(?<currentValue>[^\"]+)\"\\)"
      ],
      "packageNameTemplate": "{{{replace '\\.' '/' depName}}}",
      "datasourceTemplate": "github-releases"
    },
    {
      "customType": "regex",
      "managerFilePatterns": ["/(^|/)Project\\.swift$/"],
      "matchStrings": [
        "\\.remote\\(url:\\s*\"(?:https?:\\/\\/)?github\\.com\\/(?<depName>[\\w\\-_]+\\/[\\w\\-_.]+?)(?:\\.git)?\"[\\s\\S]*?requirement:\\s*\\.(?:upToNextMajor|upToNextMinor)\\(from:\\s*\"(?<currentValue>[^\"]+)\"\\)"
      ],
      "datasourceTemplate": "github-releases"
    },
    {
      "customType": "regex",
      "managerFilePatterns": ["/(^|/)Project\\.swift$/"],
      "matchStrings": [
        "\\.remote\\(url:\\s*\"(?:https?:\\/\\/)?github\\.com\\/(?<depName>[\\w\\-_]+\\/[\\w\\-_.]+?)(?:\\.git)?\"[\\s\\S]*?requirement:\\s*\\.exact\\(\"(?<currentValue>[^\"]+)\"\\)"
      ],
      "datasourceTemplate": "github-releases"
    }
  ]
}
```

Each manager handles a specific pattern:
- **Manager 1**: `.package(id:)` with dot notation (needs transformation)
- **Manager 2**: `.remote()` with version ranges (`.upToNextMajor`, `.upToNextMinor`)
- **Manager 3**: `.remote()` with exact versions (`.exact()`)

I also created duplicates using `"datasourceTemplate": "github-tags"` as fallback for packages that don't publish GitHub releases.

### 4. Performance Optimization

One final optimization that dramatically improved Renovate's performance:

```json
{
  "extends": ["config:recommended"],
  "enabledManagers": ["custom.regex"]
}
```

By explicitly setting `enabledManagers`, we tell Renovate to only use our custom regex managers and skip all the built-in package managers (npm, Maven, Gradle, etc.). This prevents Renovate from unnecessarily scanning `Project.swift` files looking for JavaScript packages or Java dependencies.

The `config:recommended` preset provides sensible defaults for security updates, PR limits, and scheduling. Building on top of it keeps the configuration maintainable.

## The Complete Configuration

Here's the full `renovate.json` that successfully detects all 12 dependencies:

```json
{
  "$schema": "https://docs.renovatebot.com/renovate-schema.json",
  "extends": ["config:recommended"],
  "enabledManagers": ["custom.regex"],
  "labels": ["dependencies", "renovate"],
  "prConcurrentLimit": 3,
  "prHourlyLimit": 2,
  "schedule": ["before 3am on monday"],
  "customManagers": [
    {
      "customType": "regex",
      "managerFilePatterns": ["/(^|/)Project\\.swift$/"],
      "matchStrings": [
        "\\.package\\(id:\\s*\"(?<depName>[\\w\\-.]+?)\"[\\s\\S]*?(?:from|exact):\\s*\"(?<currentValue>[^\"]+)\"\\)"
      ],
      "packageNameTemplate": "{{{replace '\\.' '/' depName}}}",
      "datasourceTemplate": "github-releases"
    },
    {
      "customType": "regex",
      "managerFilePatterns": ["/(^|/)Project\\.swift$/"],
      "matchStrings": [
        "\\.remote\\(url:\\s*\"(?:https?:\\/\\/)?github\\.com\\/(?<depName>[\\w\\-_]+\\/[\\w\\-_.]+?)(?:\\.git)?\"[\\s\\S]*?requirement:\\s*\\.(?:upToNextMajor|upToNextMinor)\\(from:\\s*\"(?<currentValue>[^\"]+)\"\\)"
      ],
      "datasourceTemplate": "github-releases"
    },
    {
      "customType": "regex",
      "managerFilePatterns": ["/(^|/)Project\\.swift$/"],
      "matchStrings": [
        "\\.remote\\(url:\\s*\"(?:https?:\\/\\/)?github\\.com\\/(?<depName>[\\w\\-_]+\\/[\\w\\-_.]+?)(?:\\.git)?\"[\\s\\S]*?requirement:\\s*\\.(?:upToNextMajor|upToNextMinor)\\(from:\\s*\"(?<currentValue>[^\"]+)\"\\)"
      ],
      "datasourceTemplate": "github-tags"
    },
    {
      "customType": "regex",
      "managerFilePatterns": ["/(^|/)Project\\.swift$/"],
      "matchStrings": [
        "\\.remote\\(url:\\s*\"(?:https?:\\/\\/)?github\\.com\\/(?<depName>[\\w\\-_]+\\/[\\w\\-_.]+?)(?:\\.git)?\"[\\s\\S]*?requirement:\\s*\\.exact\\(\"(?<currentValue>[^\"]+)\"\\)"
      ],
      "datasourceTemplate": "github-releases"
    },
    {
      "customType": "regex",
      "managerFilePatterns": ["/(^|/)Project\\.swift$/"],
      "matchStrings": [
        "\\.remote\\(url:\\s*\"(?:https?:\\/\\/)?github\\.com\\/(?<depName>[\\w\\-_]+\\/[\\w\\-_.]+?)(?:\\.git)?\"[\\s\\S]*?requirement:\\s*\\.exact\\(\"(?<currentValue>[^\"]+)\"\\)"
      ],
      "datasourceTemplate": "github-tags"
    }
  ],
  "packageRules": [
    {
      "matchDatasources": ["github-releases"],
      "matchManagers": ["custom.regex"],
      "groupName": "Swift/Tuist Dependencies",
      "automerge": false
    },
    {
      "matchUpdateTypes": ["patch"],
      "automerge": true,
      "automergeType": "branch",
      "groupName": "Patch Updates"
    },
    {
      "matchUpdateTypes": ["minor"],
      "automerge": false,
      "groupName": "Minor Updates"
    },
    {
      "matchUpdateTypes": ["major"],
      "automerge": false,
      "groupName": "Major Updates (Manual Review)"
    }
  ]
}
```

The `packageRules` section adds additional behavior:
- Groups all Swift/Tuist dependencies into a single PR
- Auto-merges patch updates (1.2.3 → 1.2.4) directly to the branch
- Requires manual review for minor and major updates
- Groups updates by semantic versioning level

## Results: From 1 to 12 Dependencies

After applying this configuration, Renovate now successfully detects and monitors all dependencies:

**Projects/App/Project.swift:**
- `2sem/GADManager` (1.3.8)

**Projects/ThirdParty/Project.swift:**
- `kakao/kakao-ios-sdk` (2.22.2)
- `jdg/MBProgressHUD` (1.2.0)
- `2sem/LSExtensions` (0.1.22)
- `CosmicMind/Material` (3.1.8)
- `2sem/LProgressWebViewController` (3.1.0)
- `krzyzanowskim/CryptoSwift` (1.8.3)
- `CoreOffice/CoreXLSX` (0.14.1)
- `facebook/facebook-ios-sdk` (14.1.0)
- `SwipeCellKit/SwipeCellKit` (2.7.1)

**Projects/DynamicThirdParty/Project.swift:**
- `SDWebImage/SDWebImage` (5.21.0)
- `firebase/firebase-ios-sdk` (11.8.1)

That's 12 out of 12 dependencies detected across three different `Project.swift` files. Renovate now automatically creates PRs when any of these packages releases a new version.

## Lessons Learned

### 1. Package Naming Conventions Matter

Understanding the relationship between Swift Package Registry IDs and GitHub repository paths is crucial. The dot-to-slash transformation might seem obvious in hindsight, but it's not documented anywhere in Renovate's Swift package manager guides. This is because Renovate's official Swift support assumes you're using `Package.swift` files, not Tuist's `Project.swift` format.

### 2. Test Regex Patterns with Real Data

Don't assume your regex works until you test it against actual multiline declarations. I initially tested with single-line examples and thought everything was working. The multiline cases failed silently because Renovate simply didn't match them.

Tools like [regex101.com](https://regex101.com) are invaluable. Paste your actual Swift code and test the pattern with the JavaScript flavor (since Renovate uses JavaScript regex internally).

### 3. Multiple Managers Beat Complex Patterns

My first instinct was to create one massive regex pattern that handled all cases. This resulted in an unmaintainable mess with tons of optional groups. Breaking it into separate managers made each pattern simpler and easier to debug.

It also makes the configuration more extensible. If Tuist adds a new dependency declaration format in the future, I can add another custom manager without modifying the existing ones.

### 4. Datasource Fallbacks Are Worth It

Some packages publish GitHub releases while others only use Git tags. By creating duplicate managers with different `datasourceTemplate` values, we ensure Renovate can find updates regardless of how maintainers version their packages.

This is particularly important for smaller or personal repositories that might not follow GitHub's release conventions.

### 5. Performance Optimization Is Not Premature

Setting `enabledManagers: ["custom.regex"]` reduced Renovate's scan time from several minutes to seconds. Without this, Renovate was trying to parse `Project.swift` files as npm packages, Maven POMs, and dozens of other formats.

In a large monorepo with multiple Tuist projects, this optimization becomes critical.

## What About Branch Dependencies?

You might notice this line in `ThirdParty/Project.swift`:

```swift
.remote(url: "https://github.com/2sem/DownPicker",
        requirement: .branch("spm"))
```

This package depends on a specific Git branch rather than a version tag. Renovate can't automatically update these because branches are mutable references without semantic versioning.

I intentionally disabled these in the configuration:

```json
{
  "matchDatasources": ["git-refs"],
  "matchManagers": ["custom.regex"],
  "groupName": "Branch Dependencies (No Auto-update)",
  "enabled": false
}
```

Branch dependencies should be upgraded manually when you know the branch has received important updates. This is a deliberate choice to prevent Renovate from creating noisy PRs every time someone pushes to the branch.

## Adapting This for Your Project

To use this configuration in your own Tuist project:

1. **Copy the `customManagers` array** into your `renovate.json`
2. **Verify the patterns match your usage**. If you use different requirement types like `.range()`, you'll need to add patterns for those
3. **Test with a local Renovate run** using `renovate --dry-run` to see what dependencies it detects
4. **Adjust the `packageRules`** to match your team's merge strategy (auto-merge patches, manual review for majors, etc.)

If your team uses SPM's official `Package.swift` instead of Tuist, you'll need different patterns. The principles remain the same: multiline matching, package name transformation, and multiple managers for different patterns.

## Conclusion

Getting Renovate to work with Tuist's `Project.swift` files required understanding three things:

1. **Swift Package Registry's dot notation must be transformed into GitHub's slash notation**
2. **Regex patterns must handle multiline declarations with flexible whitespace**
3. **Multiple focused custom managers are clearer than one complex pattern**

The result is automated dependency management that actually works. Instead of manually checking 12 packages for updates, Renovate now monitors them all and creates PRs when new versions are available. This frees up time to focus on building features rather than chasing dependency updates.

If you're using Tuist and struggling with Renovate, I hope this guide saves you the debugging time I spent. The complete configuration is battle-tested across three different module types and handles all the common Swift package declaration patterns.

Have you encountered other challenges with Renovate and Tuist? Let me know what patterns you've discovered.

---

## Further Reading

- [Renovate Documentation - Custom Managers](https://docs.renovatebot.com/modules/manager/custom/regex/)
- [Tuist Documentation - Dependencies](https://docs.tuist.io/guides/develop/projects/dependencies)
- [Swift Package Registry Service Specification](https://github.com/apple/swift-package-manager/blob/main/Documentation/Registry.md)
- [Handlebars Template Syntax](https://handlebarsjs.com/guide/expressions.html)

## Example Project

The complete working example from this article is available in the [democracyAction-app-ios](https://github.com/2sem/democracyaction/tree/master/src/democracyAction-app-ios) repository, specifically:
- [`renovate.json`](https://github.com/2sem/democracyaction/blob/master/src/democracyAction-app-ios/renovate.json) - Complete Renovate configuration
- [`Projects/App/Project.swift`](https://github.com/2sem/democracyaction/blob/master/src/democracyAction-app-ios/Projects/App/Project.swift) - App module with GADManager dependency
- [`Projects/ThirdParty/Project.swift`](https://github.com/2sem/democracyaction/blob/master/src/democracyAction-app-ios/Projects/ThirdParty/Project.swift) - Third-party dependencies module
- [`Projects/DynamicThirdParty/Project.swift`](https://github.com/2sem/democracyaction/blob/master/src/democracyAction-app-ios/Projects/DynamicThirdParty/Project.swift) - Dynamic framework dependencies
