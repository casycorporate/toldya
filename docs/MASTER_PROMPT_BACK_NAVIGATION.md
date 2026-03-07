# MASTER PROMPT: Back Button & Bottom Tab Navigation (Flutter)

**Use this document in Cursor Composer or Agent mode.** It provides step-by-step instructions (no direct code blocks) to fix hardware back button and swipe-back behavior, and to implement double-tap-to-exit and safe back navigation.

---

## Context (Already Analyzed)

- **App:** Toldya. **Initial route:** `SplashPage`. After auth, `SplashPage` builds `HomePage()` as its **body** (no `push`/`pushReplacement` to a new route), so the Navigator stack stays `[SplashPage]` and the user sees `HomePage` inside it.
- **HomePage** is the main shell: a `Scaffold` with `body: _getPage(AppState.pageIndex)` and `bottomNavigationBar: BottomMenubar()`. Tabs: **0 = Feed**, **1 = Search**, **2 = Notifications**, **3 = Profile**. Tab state is **AppState.pageIndex** (Provider); there is no separate route per tab.
- **BottomMenubar** reads `AppState.pageIndex` and on tap sets `state.setpageIndex = index`. **AppState** already has `_lastTabBeforeProfile` and updates it in `setpageIndex` when switching to/from Profile (index 3).
- **Pushed routes** (e.g. `FeedPostDetail`, `ProfilePage` via `pushNamed`, `ComposeToldyaPage`, `SettingsAndPrivacyPage`) sit **on top** of the root route. Back on those screens should pop the route; the root route (where `HomePage` is shown) must never pop into a black screen.
- **Reference:** `docs/END_TO_END_USER_FLOW.md`, `lib/page/homePage.dart`, `lib/widgets/bottomMenuBar/bottomMenuBar.dart`, `lib/state/appState.dart`, `lib/helper/routes.dart`.

---

## Requirements (Target Behavior)

1. **Tab navigation (back when not on Feed)**  
   If the user is on tab **1, 2, or 3** (Search, Notifications, Profile) and presses the **hardware back button** (or equivalent swipe-back): the app must **not** close and **not** pop the root route. Instead, **Bottom Navigation must switch to index 0 (Feed)**. Only the tab index changes; no `Navigator.pop`.

2. **Double-tap to exit (when on Feed)**  
   If the user is already on **tab 0 (Feed)** and on the app's root (no overlay route), the first back press must **not** close the app. Show a short message such as **"Press back again to exit"** (or use an existing i18n key). If the user presses back **again within about 2 seconds**, then exit the app (e.g. `SystemNavigator.pop()` or platform exit). If 2 seconds pass without a second back press, reset the "pending exit" state so that the next back press again shows the message.

3. **Black screen protection**  
   **Never** call `Navigator.pop(context)` without first checking `Navigator.canPop(context)`. If the stack has only one route, popping would leave an empty stack (black screen). Any place that performs a pop (AppBar back, `onPopInvoked`, callbacks) must guard with `canPop` or equivalent.

4. **Modern API**  
   Do **not** use deprecated `WillPopScope`. Use **`PopScope`** (Flutter 3.12+) for intercepting back. Prefer migrating existing `WillPopScope` usages to `PopScope` where relevant.

---

## Step-by-Step Instructions

### STEP 1: HomePage – Add PopScope and back handling

**1.1** In **`lib/page/homePage.dart`**, wrap the **entire** `build` return (the `Scaffold`) in a **`PopScope`** widget. The `PopScope` is the top-level widget returned by `build`.

**1.2** Set **`canPop: false`** for this `PopScope`. This ensures that when the user is on the root (seeing `HomePage`), the system does **not** pop the route by default; your logic will handle the back key.

**1.3** Implement **`onPopInvokedWithResult`** (or the equivalent callback for your Flutter version). When invoked with **`didPop == false`** (because `canPop` is false), run the following logic:

- Obtain the current **`AppState`** (e.g. via `Provider.of<AppState>(context, listen: false)`).
- If **`appState.pageIndex != 0`** (user is on Search, Notifications, or Profile tab):  
  Set the bottom tab to Feed by updating AppState: **`appState.setpageIndex = 0`**. Do **not** call `Navigator.pop`. Return.
- If **`appState.pageIndex == 0`** (user is already on Feed):  
  Run the **double-tap-to-exit** logic (see Step 2). Do **not** pop the route on the first tap.

**1.4** Ensure that when there are **pushed routes** (e.g. user is on `FeedPostDetail`), the **top route** is not `HomePage`/`SplashPage`, so that route's own `PopScope`/back handler runs and your HomePage `PopScope` is not the one receiving the back. No change is needed for that; just do not wrap any **other** route's content with this same logic.

---

### STEP 2: Double-tap-to-exit state and UI

**2.1** In **`_HomePageState`** (or wherever HomePage's state lives), add **private state** to track "pending exit":

- A **boolean** (e.g. `_pendingExit`) or a **timestamp** (e.g. `_lastBackPressTime`). Purpose: remember that the user has already pressed back once on Feed and we showed "Press back again to exit".

**2.2** When **`onPopInvokedWithResult`** runs and **`pageIndex == 0`**:

- If **not** in "pending exit" state:  
  - Set "pending exit" to true (or store current time).  
  - Show a **SnackBar** (or similar) with the message "Press back again to exit" (prefer an i18n key, e.g. from `AppLocalizations` if it exists).  
  - Schedule a **reset** of "pending exit" after **2 seconds** (e.g. `Future.delayed(Duration(seconds: 2), () { setState(() => _pendingExit = false; })` or clear the timestamp). Use `mounted` check before calling `setState` if the widget might be disposed.
- If **already** in "pending exit" state (second back within 2 seconds):  
  - **Exit the app** using the platform API (e.g. `import 'package:flutter/services.dart';` and `SystemNavigator.pop()`). Do **not** call `Navigator.pop(context)` here.

**2.3** Ensure the 2-second timer **cancels or resets** the pending state so that after 2 seconds the next back press is again treated as "first press" and shows the message again.

---

### STEP 3: BottomNavigationBar index and AppState

**3.1** The bottom bar index is already driven by **`AppState.pageIndex`** in **`BottomMenubar`** (`lib/widgets/bottomMenuBar/bottomMenuBar.dart`). When you set **`appState.setpageIndex = 0`** in Step 1.3, the UI will automatically switch to the Feed tab because `_body()` uses `Provider.of<AppState>(context).pageIndex` and `_getPage(index)`.

**3.2** No change is required inside **BottomMenubar** for the back button; the only requirement is that when back is pressed on tab 1/2/3, **AppState.pageIndex** is set to **0** from the **HomePage PopScope** callback (Step 1.3). Use **`setState`** only if you keep double-tap state in `_HomePageState`; tab index itself is updated via **AppState** and **Provider** (no need for local `setState` for the index).

---

### STEP 4: Black screen protection (project-wide)

**4.1** Search the codebase for **`Navigator.pop(context)`** and **`Navigator.of(context).pop()`** (and similar). Before **every** pop, add a guard: **only pop if `Navigator.canPop(context)` is true**. If `canPop` is false, do not call `pop` (and optionally show a SnackBar or do nothing, depending on the screen).

**4.2** Pay special attention to:

- **ProfilePage** (both tab and pushed): back handler and any explicit `pop` after `profilePageClosing`.
- **FeedPostDetail**: back handler and any `removeLastToldyaDetail` + `pop`.
- **Other screens** that call `pop` in AppBar leading or in a callback.

**4.3** Do **not** remove necessary pops (e.g. after closing a pushed screen); only add the **guard** so that pop is never called when the stack would become empty.

---

### STEP 5: Migrate WillPopScope to PopScope (optional but recommended)

**5.1** Find all usages of **`WillPopScope`** (e.g. in **ProfilePage**, **FeedPostDetail**, **ChatScreenPage**, **NewMessagePage**). Replace each with **`PopScope`**.

**5.2** Mapping:

- **`onWillPop`** returning `Future<bool>`:  
  - If you want to **prevent** the default pop and run custom logic: use **`canPop: false`** and in **`onPopInvokedWithResult`** (when **`didPop == false`**) run your cleanup (e.g. `profilePageClosing`, `removeLastToldyaDetail`), then call **`Navigator.pop(context)`** only if **`Navigator.canPop(context)`** is true.  
  - If you only want to run logic **before** pop but still allow the system to pop: use **`canPop: true`** and in **`onPopInvokedWithResult`** when **`didPop == true`** run your cleanup (if the logic is "after pop"); or when **`didPop == false`** run cleanup then call **`Navigator.pop(context)`** once (with `canPop` check).

**5.3** Ensure that **ProfilePage** when used as **tab content** (`isTabContent: true`) does **not** pop the route; it should only change **AppState.pageIndex** (e.g. to `lastTabBeforeProfile`). That behavior should remain as already implemented; the new HomePage PopScope will handle "back from tab" by setting index to 0 (or you can keep "back from Profile tab → previous tab" by setting `appState.setpageIndex = appState.lastTabBeforeProfile` in HomePage when `pageIndex == 3`). Choose one: back from Profile tab goes to **Feed (0)** or to **last tab**; the requirements above say "go to index 0", so in Step 1.3 when `pageIndex != 0` use `setpageIndex = 0`.

---

### STEP 6: Verify flow and edge cases

**6.1** After implementation:

- From **tab 1, 2, or 3**: press back → tab switches to **0 (Feed)**, app does not close, no black screen.
- From **tab 0**: first back → SnackBar "Press back again to exit"; second back within 2 sec → app exits.
- From **tab 0**: first back → SnackBar; wait >2 sec; second back → SnackBar again (no exit).
- With a **pushed route** (e.g. FeedPostDetail) open: back → that route pops; only when the root is visible again should HomePage's PopScope handle back (tab or double-tap).

**6.2** Ensure **i18n**: if you add a new string for "Press back again to exit", add it to the ARB files and use **`AppLocalizations`** in the SnackBar (or existing key if present).

---

## Summary Checklist

- [ ] HomePage wraps its `Scaffold` in **PopScope** with **canPop: false**.
- [ ] **onPopInvokedWithResult**: if **pageIndex != 0** → **setpageIndex = 0**; if **pageIndex == 0** → double-tap-to-exit logic.
- [ ] Double-tap state (e.g. `_pendingExit` or timestamp) in **HomePage** state; SnackBar on first back; 2-second reset; **SystemNavigator.pop()** on second back within 2 sec.
- [ ] All **Navigator.pop** calls guarded with **Navigator.canPop(context)**.
- [ ] **WillPopScope** replaced with **PopScope** where applicable.
- [ ] No pop when stack would be empty (black screen protection).

Use this as the single source of instructions for implementing and verifying back and tab behavior in Cursor Composer or Agent mode.
