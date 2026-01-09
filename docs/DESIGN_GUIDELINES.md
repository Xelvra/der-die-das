# Der Die Das - UI/UX Standards & Layout Rules

This document defines critical rules for maintaining the stability, responsiveness, and visual consistency of the user interface. Any future UI modifications must respect these principles to prevent regression.

## 1. General Responsiveness Principles
*   **Overflow Protection:**
    *   Critical texts and rows (e.g., keys in `HelpScreen`) must be wrapped in `FittedBox(fit: BoxFit.scaleDown)` to ensure they scale down rather than wrap or overflow on small screens.
*   **Extreme Window Sizes (Anti-Torture):**
    *   If the window width or height drops below a critical threshold (typically **50px**), the app should stop rendering complex content (return `SizedBox.shrink()`) to prevent rendering engine errors (GTK/Pixman warnings).
    *   The `AppBar` in HelpScreen is hidden if height < **250px**.
    *   Bottom controls in HomeScreen are hidden if height < **140-150px**.
*   **Safe Area:**
    *   Always respect `MediaQuery.of(context).padding.bottom` for elements fixed to the bottom of the screen (especially in `HelpScreen` and `AppDrawer`).

## 2. HomeScreen (Game Area)
*   **Layout:**
    *   Use `Column`, not `Stack`, for the main layout structure.
    *   **Card Deck:** Must be placed within an `Expanded` widget to occupy all available space *above* the controls. Use `LayoutBuilder` inside for aspect ratio calculations.
    *   **Controls:** Fixed height of **92px**.
*   **Centering:**
    *   The card is centered within the `Expanded` space, not the entire screen. This visually lifts the card above the controls and eliminates the awkward gap below the AppBar.
*   **Autoplay:**
    *   When the game mode changes (listener on `gameMode`), the app must **agresively reset** all states (`_isAutoplaying`, `_isProcessingAnswer`, `Timer`) to prevent logic deadlocks or "stuck" cards.

## 3. AboutDialogCard
*   **Consistency:**
    *   Must exactly replicate the `HomeScreen` layout structure.
    *   Structure: `Column` -> `Expanded (Card)` -> `SizedBox(height: 92)`.
    *   This ensures zero visual shifting when toggling between the Game and the About card.

## 4. AppDrawer (Menu)
*   **Structure:**
    *   Use **`CustomScrollView`**, not `ListView` or `Column`.
    *   **Main Content:** Use `SliverToBoxAdapter` for the top section.
    *   **Sticky Footer:** Use `SliverFillRemaining(hasScrollBody: false)` for the bottom section (Donate/Coffee).
    *   This ensures the footer sits at the bottom when there is space, but becomes scrollable when space is tight.
*   **Header:**
    *   The "Der Die Das" text must be wrapped in `FittedBox` to accommodate narrow drawer widths.

## 5. HelpScreen
*   **Content:**
    *   The main content container must have a bottom margin of `24 + MediaQuery.of(context).padding.bottom` to prevent the content border from being cut off by the system navigation bar/home indicator.
*   **Keyboard Shortcuts:**
    *   Rows containing visual key representations (Arrows, WASD) must be wrapped in `FittedBox`.

## 6. Testing
*   Before any UI commit, it is **mandatory** to run:

    ```bash
    flutter test
    ```
*   This verifies **Golden Tests** (pixel-perfect matching).
*   If a test fails, it means the visual appearance has changed. Check the failure images.
*   If the change is intentional, update the goldens:

    ```bash
    flutter test --update-goldens
    ```