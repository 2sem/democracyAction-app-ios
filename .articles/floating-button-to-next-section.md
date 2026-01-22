# Migrating a Floating Next-Section Button from UIKit to SwiftUI

I've been migrating a Korean politician directory app from UIKit to SwiftUI.

One of the interesting challenges was converting a floating button that navigates to the next section.

## What is the Floating Next-Section Button?

In Korean apps, this pattern is common.

The button shows the next chosung (초성, first consonant) character like "ㄱ" → "ㄴ" → "ㄷ" for quick navigation.

When you tap the button, it scrolls to the next section automatically.

## The UIKit Implementation

In the original UIKit implementation (`DAInfoTableViewController`), the button logic was spread across several methods.

### Button Setup

If UIKit uses UIButton,
```swift
self.nextButton = UIButton()
self.view.addSubview(self.nextButton)
self.nextButton.backgroundColor = "#78909c".toUIColor()
self.nextButton.setImage(UIImage(named: "icon_down.png"), for: .normal)
self.nextButton.setTitle("ㄱ", for: .normal)
self.nextButton.widthAnchor.constraint(equalToConstant: 44 * 2).isActive = true
self.nextButton.heightAnchor.constraint(equalToConstant: 44).isActive = true
self.nextButton.layer.cornerRadius = 5.0
self.nextButton.addTarget(self, action: #selector(self.onGoNextSection(_:)), for: .touchUpInside)
```

it can be configured with manual frame calculations and constraints.

### Updating Button State During Scroll

The button updates its title and visibility during scroll.
```swift
func updateNextButton() {
    let maxSection = self.tableView.numberOfSections - 1

    self.nextButton.isHidden = (false || self.isDragging) && !self.isScrollingToUp

    guard let lastIndexPath = self.tableView.indexPathsForVisibleRows?.last else {
        self.nextButton.isHidden = true
        return
    }

    guard maxSection > lastIndexPath.section else {
        self.nextButton.isHidden = true
        return
    }

    let nextSection = lastIndexPath.section.advanced(by: 1)
    guard let group = self.groups[safe: nextSection] else {
        return
    }

    self.nextButton.setTitle(group.name, for: .normal)

    switch self.groupingType {
    case .byName:
        self.nextButton.frame.size.width = 44 + 8
    case .byGroup, .byArea:
        self.nextButton.sizeToFit()
        self.nextButton.frame.size.width += 8
        self.nextButton.frame.size.height = 44
    }
}
```

UIKit provides `indexPathsForVisibleRows` to get the last visible section.

### Navigation Logic

When tapped, it scrolls to the next section.
```swift
@IBAction func onGoNextSection(_ button: UIButton) {
    let section = self.tableView(self.tableView, sectionForSectionIndexTitle: button.title(for: .normal) ?? "", at: 0)
    let indexPath = IndexPath(row: 0, section: section)
    self.tableView.scrollToRow(at: indexPath, at: .top, animated: false)
}
```

## The SwiftUI Challenge

SwiftUI's declarative nature required a completely different approach.

The main challenges were:

1. **No `indexPathsForVisibleRows` equivalent** - SwiftUI doesn't expose visible rows
2. **Programmatic scrolling detection** - `onScrollPhaseChange` doesn't fire for `scrollTo()`
3. **State synchronization** - Button must update after both manual and programmatic scrolling

## The SwiftUI Solution

Let's implement the same feature in SwiftUI.

### Step 1: Track Visible Sections

If UIKit uses `indexPathsForVisibleRows`,

SwiftUI can use `.onScrollTargetVisibilityChange`.

```swift
@State var visibleGroupIds: Set<String> = []
@State var lastVisibleGroupID: String?

ScrollView {
    LazyVStack() {
        ForEach(viewModel.groups) { group in
            Section(header: Text(group.title)) {
                ForEach(group.persons, id: \.no) { person in
                    PoliticianRow(person: person)
                }
            }
            .id(group.id)
        }
    }
    .scrollTargetLayout()
}
.onScrollTargetVisibilityChange(idType: String.self) { visibleGroupIds in
    self.visibleGroupIds = Set(visibleGroupIds)
    updateLastVisibleGroupID()
}
```

### Step 2: Calculate Last Visible Section

We need to find the bottom-most visible section.

```swift
func updateLastVisibleGroupID() {
    self.lastVisibleGroupID = visibleGroupIds.sorted(by: <).last
}
```

### Step 3: Get Next Section from ViewModel

The ViewModel calculates which section comes after the current one.

```swift
// In ViewModel
func nextGroup(ofGroupWithId groupId: String) -> PersonGroup? {
    let sections = groups

    guard !sections.isEmpty else { return nil }
    guard let currentIndex = sections.firstIndex(where: { $0.id == groupId }) else {
        return sections.first
    }

    let nextIndex = currentIndex + 1
    guard nextIndex < sections.count else {
        return nil // At the end
    }

    return sections[nextIndex]
}
```

### Step 4: Render Button with Conditional Visibility

The button uses `ScrollViewReader` for reliable navigation.

```swift
ScrollViewReader { scrollProxy in
    ZStack(alignment: .bottomTrailing) {
        // ScrollView here...

        if let lastVisibleGroupID,
           let nextGroup = viewModel.nextGroup(ofGroupWithId: lastVisibleGroupID) {
            Button {
                withAnimation {
                    scrollProxy.scrollTo(nextGroup.id, anchor: .top)
                }
            } label: {
                HStack(spacing: 4) {
                    Image(systemName: "chevron.down")
                        .font(.system(size: 12, weight: .semibold))
                    Text(nextGroup.title)
                        .font(.system(size: viewModel.groupingType == .byName ? 20 : 14, weight: .bold))
                        .lineLimit(1)
                }
                .padding(.init(top: 8, leading: 16, bottom: 8, trailing: 16))
                .foregroundColor(.white)
                .background(Color(red: 0.47, green: 0.56, blue: 0.61))
                .cornerRadius(5)
                .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 2)
            }
            .padding(.trailing, 16)
            .padding(.bottom, 16)
        }
    }
}
```

## Key Differences

| Aspect | UIKit | SwiftUI |
|--------|-------|---------|
| Scroll tracking | `indexPathsForVisibleRows` | `.onScrollTargetVisibilityChange(idType:)` |
| Button positioning | Manual frame calculation | ZStack + alignment |
| Visibility logic | Imperative hiding/showing | Conditional rendering with `if let` |
| Scroll detection | `scrollViewDidScroll()` | Reactive state updates |
| Navigation | `scrollToRow(at:)` | `ScrollViewReader` with `scrollTo(id:anchor:)` |

## Lessons Learned

### SwiftUI Scroll APIs Are Still Evolving

I tried several approaches:

**`onScrollPhaseChange`** - doesn't fire for programmatic scrolling

**`onScrollVisibilityChange`** - doesn't fire for system gestures like status bar tap

**`.onScrollTargetVisibilityChange(idType:)`** - ✅ This worked!

The key insight: Track section visibility, not row visibility.

### State Management is Key

UIKit queries state when needed: `tableView.indexPathsForVisibleRows`

SwiftUI maintains state proactively: `visibleGroupIds` set

### Conditional Rendering > Manual Visibility

UIKit uses `button.isHidden = true`

SwiftUI uses `if let nextGroup` to render the button only when needed.

### Grouping by Chosung Requires Careful String Handling
```swift
// Original UIKit used full character
let grouped = Dictionary(grouping: persons) { person in
    person.nameFirstCharacter // "홍", "김", etc.
}

// SwiftUI uses chosung only
let grouped = Dictionary(grouping: persons) { person in
    String(person.nameFirstCharacters.prefix(1)) // "ㅎ", "ㄱ", etc.
}
```

## Performance Considerations

The SwiftUI implementation is more reactive.

UIKit updates button in `scrollViewDidScroll()` (potentially every frame).

SwiftUI updates only when section visibility changes (less frequent).

However, SwiftUI requires more state tracking:

`visibleGroupIds: Set<String>`

`lastVisibleGroupID: String?`

The trade-off is worth it.

Section-level tracking is more efficient than row-level tracking.

## Implementation Challenges

The final solution looks clean.

But getting there required working through several issues.

### Issue 1: ScrollPosition Anchor Not Working

I initially tried using `ScrollPosition` for navigation.

```swift
@State private var scrollPosition = ScrollPosition()

Button {
    withAnimation {
        scrollPosition.scrollTo(id: nextGroup.id, anchor: .top)
    }
}
```

The problem: The `anchor` parameter didn't work.

The target section wouldn't position at the top of the screen.

Solution: Roll back to `ScrollViewReader`.

```swift
ScrollViewReader { scrollProxy in
    Button {
        withAnimation {
            scrollProxy.scrollTo(nextGroup.id, anchor: .top)
        }
    }
}
```

`ScrollViewReader` reliably respects the anchor parameter.

### Issue 2: Button Not Updating When Tapping Status Bar

iOS has a system gesture.

Tap the status bar to scroll to top.

The button wasn't updating after this gesture.

Why? I was tracking individual row visibility.

```swift
// This approach doesn't work
ForEach(group.persons, id: \.no) { person in
    PoliticianRow(person: person)
        .onScrollVisibilityChange(threshold: 0.5) { isVisible in
            // Fires for manual scrolling
            // Does NOT fire for status bar tap
        }
}
```

Row visibility events don't fire during the system scroll-to-top.

Solution: Track section-level visibility instead.

```swift
ScrollView {
    LazyVStack() {
        ForEach(viewModel.groups) { group in
            Section(header: Text(group.title)) {
                ForEach(group.persons, id: \.no) { person in
                    PoliticianRow(person: person)
                }
            }
            .id(group.id)
        }
    }
    .scrollTargetLayout()
}
.onScrollTargetVisibilityChange(idType: String.self) { visibleGroupIds in
    self.visibleGroupIds = Set(visibleGroupIds)
    updateLastVisibleGroupID()
}
```

`.onScrollTargetVisibilityChange(idType:)` fires for all scroll events.

Including system gestures like status bar tap.

### Issue 3: Sections Being Marked Invisible Too Early

Sections were marked invisible while partially visible.

Some rows were still on screen.

First attempt: Track individual person visibility.

```swift
// Overly complex approach
@State var visiblePersonIds: [String: Set<Int16>] = [:]

PoliticianRow(person: person)
    .onScrollVisibilityChange(threshold: 0.5) { isVisible in
        if isVisible {
            visiblePersonIds[groupId, default: []].insert(person.no)
        } else {
            visiblePersonIds[groupId]?.remove(person.no)

            // If no persons visible, mark section invisible
            if visiblePersonIds[groupId]?.isEmpty == true {
                visiblePersonIds.removeValue(forKey: groupId)
            }
        }
    }
```

This was complex and still had the status bar issue.

Final solution: Trust `.onScrollTargetVisibilityChange`.

It handles section visibility at the right granularity.

No need to manually aggregate person-level visibility.

### Issue 4: Visibility Tracking Includes Sections from Previous Grouping Type

The app has three grouping types.

Users switch between them using a segmented picker in the toolbar.

**byName** (이름) - groups by chosung like "ㄱ", "ㄴ", "ㄷ"

**byGroup** (소속) - groups by political party

**byArea** (지역) - groups by constituency area

When the user switches grouping types, the problem appeared.

`.onScrollTargetVisibilityChange(idType: String.self)` still reported section IDs from the PREVIOUS grouping type.

Example flow:

1. User views "byName" grouping - sees sections "ㄱ", "ㄴ", "ㄷ"
2. User switches to "byGroup" - should see sections "더불어민주당", "국민의힘", etc.
3. But `onScrollTargetVisibilityChange` still reports "ㄱ", "ㄴ", "ㄷ" from the old grouping
4. The floating button shows incorrect next section

Root cause: SwiftUI didn't recognize that the content structure had completely changed.

#### First Attempt: Add Identity to ScrollView

Give the scroll container a unique identity based on the grouping type.

```swift
ScrollView {
    LazyVStack() {
        ForEach(viewModel.groups) { group in
            Section(header: Text(group.title)) {
                ForEach(group.persons, id: \.no) { person in
                    PoliticianRow(person: person)
                }
            }
            .id(group.id)
        }
    }
    .scrollTargetLayout()
}
.id(viewModel.groupingType) // Forces view refresh when grouping changes
.onScrollTargetVisibilityChange(idType: String.self) { visibleGroupIds in
    self.visibleGroupIds = Set(visibleGroupIds)
    updateLastVisibleGroupID()
}
```

By adding `.id(viewModel.groupingType)` to the ScrollView, SwiftUI treats it as a completely new view.

This helped, but didn't fully solve the problem.

`visibleGroupIds` still sometimes contained stale IDs from the previous grouping during the transition.

#### Complete Solution: Filter Visible IDs

The visibility callback can fire with old section IDs while they're being removed.

We need to filter incoming IDs against the current grouping.

First, give each row a unique ID that includes the group:

```swift
ForEach(viewModel.groups) { group in
    Section(header: Text(group.title)) {
        ForEach(group.persons, id: \.no) { person in
            PoliticianRow(person: person)
                .id("\(group.id)-\(person.no)") // Unique ID per row
        }
    }
    .id(group.id)
}
```

Then filter the visible IDs to only include groups that exist in the current grouping:

```swift
.onScrollTargetVisibilityChange(idType: String.self) { visibleGroupIds in
    // Filter to only include groups that exist in current grouping
    let currentGroupIds = Set(viewModel.groups.map { $0.id })
    self.visibleGroupIds = Set(visibleGroupIds).intersection(currentGroupIds)

    updateLastVisibleGroupID()
}
```

Why both steps were needed:

Adding `.id(viewModel.groupingType)` tells SwiftUI to recreate the view.

But during the transition, the visibility callback can still fire with IDs being removed.

By filtering against `viewModel.groups`, we ensure we only track sections that actually exist.

Key insight: When content structure changes, use `.id()` to force view recreation AND filter tracked state to match the current data model.

## Conclusion

Migrating this floating button from UIKit to SwiftUI required rethinking the entire approach.

Instead of imperatively querying the table view's state, I built a reactive system that tracks visibility changes and updates declaratively.

The result is cleaner separation of concerns:

**View**: Renders button conditionally with `ScrollViewReader`

**ViewModel**: Calculates next section

**State**: Tracks visible sections

While SwiftUI's scroll APIs are still maturing, `.onScrollTargetVisibilityChange(idType:)` proved to be the right tool for this use case.

The key lessons:

Track section visibility, not row visibility.

Use `ScrollViewReader` for reliable anchored scrolling.

Trust the framework's section-level tracking instead of building your own.

Please leave a comment if you find any wrong information or have feedback.

Happy SwiftUI-ing! 🎉

---

If you found this post helpful, please give it a round of applause and [buy me a coffee ☕](https://buymeacoffee.com/toyboy2). Explore more iOS, SwiftUI related content in my other posts.

For additional insights and updates, check out my [LinkedIn profile](https://www.linkedin.com/in/toyboy2/). Thank you for your support!

---

**Full implementation**: See [`PoliticianListScreen.swift`](Projects/App/Sources/Screens/PoliticianListScreen.swift) and [`PoliticianListViewModel.swift`](Projects/App/Sources/ViewModels/PoliticianListViewModel.swift) in the democracyaction project.
