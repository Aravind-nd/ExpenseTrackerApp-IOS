# ExpenseTrackerApp-iOS (SwiftUI + Core Data + MVC-style Controllers)

**ExpenseTrackerApp-iOS** is a personal finance app built with **SwiftUI** and **Core Data** to help users record expenses, browse history, and view basic analytics.  
The codebase is organized using an **MVC-inspired structure** (`Views` + `Controllers` + `Services`) to keep UI, logic, and persistence cleanly separated.

---

## Table of Contents
- [Features](#features)
- [Tech Stack](#tech-stack)
- [Project Architecture](#project-architecture)
  - [Overall flow](#overall-flow)
  - [Why Controllers in SwiftUI?](#why-controllers-in-swiftui)
  - [Persistence layer](#persistence-layer)
- [Folder Structure](#folder-structure)
- [Key Modules / Files](#key-modules--files)
- [Core Data Model](#core-data-model)
- [Getting Started](#getting-started)
- [Build & Run](#build--run)
- [Notes](#notes)
- [Roadmap / Improvements](#roadmap--improvements)
- [License](#license)

---

## Features
- **Onboarding** experience for first-time usage
- **Dashboard** view for a quick snapshot of spending
- **Add Expense**
  - Amount, category, payment method, notes
  - Optional SF Symbol/icon selection (stored as a symbol name)
- **Edit Expense** for updating an existing record
- **Expense List**
  - Browse expenses
  - Item detail / item row screen component
- **Analytics**
  - Spending insights and summaries (based on stored expenses)
- **Offline-first storage** using **Core Data**
- **Preview sample data** configured for SwiftUI previews (via `PersistenceController.preview`)

---

## Tech Stack
- **Language:** Swift
- **UI Framework:** SwiftUI
- **Persistence:** Core Data (`NSPersistentContainer`)
- **Architecture style:** MVC-inspired separation of concerns

---

## Project Architecture

### Overall flow
This app follows an MVC-style separation adapted for SwiftUI:

- **Views (`Views/`)**  
  SwiftUI screens responsible for layout, rendering, and user interactions.

- **Controllers (`Controllers/`)**  
  Feature-specific logic and orchestration (validation, computation, coordinating persistence operations).  
  Controllers act like the “C” layer in MVC and keep business logic out of SwiftUI views.

- **Services (`Services/`)**  
  Shared components used across features—most importantly Core Data setup (`PersistenceController`).

- **Core Data Model (`ExpenseTracker_MVC.xcdatamodeld/`)**  
  The schema that defines your `Expense` entity (and any others).

### Why Controllers in SwiftUI?
SwiftUI encourages lightweight views, but apps still need:
- validation
- transformations and aggregation
- persistence coordination
- feature workflows (add/edit/list/analytics)

Controllers make it easier to:
- keep Views focused on UI
- test logic more easily later
- reduce duplication across screens

### Persistence layer
Core Data setup is centralized in:

- `Services/Persistence.swift`

It provides:
- `PersistenceController.shared` for the running app
- `PersistenceController.preview` for SwiftUI preview/sample data
- An `NSPersistentContainer` named **`ExpenseTracker_MVC`**
- The main managed object context exposed via:
  - `persistenceController.container.viewContext`

---

## Folder Structure

```text
.
├── ExpenseTracker_MVCApp.swift
├── Assets.xcassets/
├── ExpenseTracker_MVC.xcdatamodeld/
├── Services/
│   └── Persistence.swift
├── Controllers/
│   ├── AddExpenseController.swift
│   ├── AnalyticsController.swift
│   ├── DashboardController.swift
│   ├── ExpenseEditController.swift
│   ├── ExpenseListController.swift
│   ├── ExpenseListItemController.swift
│   └── OnboardingController.swift
└── Views/
    ├── ContentView.swift
    ├── OnboardingViewScreen.swift
    ├── DashboardScreen.swift
    ├── ExpenseListScreen.swift
    ├── ExpenseListItemScreen.swift
    ├── AddExpenseScreen.swift
    ├── EditExpenseScreen.swift
    └── AnalyticsScreen.swift
```

---

## Key Modules / Files

### App entry point
- **`ExpenseTracker_MVCApp.swift`**
  - Creates the shared persistence controller
  - Injects Core Data context into SwiftUI environment:
    - `.environment(\.managedObjectContext, persistenceController.container.viewContext)`

### Services
- **`Services/Persistence.swift`**
  - Initializes Core Data stack
  - Supports in-memory store for previews
  - Seeds preview expenses (useful for UI development)

### Views + Controllers (by feature)
- **Onboarding**
  - `Views/OnboardingViewScreen.swift`
  - `Controllers/OnboardingController.swift`

- **Dashboard**
  - `Views/DashboardScreen.swift`
  - `Controllers/DashboardController.swift`

- **Expenses**
  - List: `Views/ExpenseListScreen.swift` + `Controllers/ExpenseListController.swift`
  - List item: `Views/ExpenseListItemScreen.swift` + `Controllers/ExpenseListItemController.swift`
  - Add: `Views/AddExpenseScreen.swift` + `Controllers/AddExpenseController.swift`
  - Edit: `Views/EditExpenseScreen.swift` + `Controllers/ExpenseEditController.swift`

- **Analytics**
  - `Views/AnalyticsScreen.swift`
  - `Controllers/AnalyticsController.swift`

---

## Core Data Model
The Core Data model is stored in:

- `ExpenseTracker_MVC.xcdatamodeld`

From the persistence preview seeding, the app stores an `Expense` object with fields such as:
- `amount` (Double)
- `category` (String)
- `date` (Date)
- `paymentMethod` (String)
- `note` (String)
- `symbolName` (String) — SF Symbol name for displaying an icon in the UI

> If you want, I can tailor this section *exactly* to your model (entity names + attributes + relationships) if you share a screenshot of the Core Data model editor or export the model as XML.

---

## Getting Started

### Prerequisites
- macOS with **Xcode** installed
- An iOS Simulator or physical iPhone

### Clone
```bash
git clone https://github.com/Aravind-nd/ExpenseTrackerApp-IOS.git
cd ExpenseTrackerApp-IOS
```

---

## Build & Run
1. Open the project in Xcode.
2. Select a target simulator/device.
3. Run:
   - **Cmd + R**

For SwiftUI previews, the project includes a pre-configured preview store via `PersistenceController.preview`.

---

## Notes
- This repo follows an MVC-inspired structure even though SwiftUI doesn’t strictly require it.
- Core Data context is injected via the SwiftUI environment at app start.
- Sample data is created only for previews to make UI development easier.

---

## Roadmap / Improvements
- Add unit tests around controller logic (validation, aggregations)
- Add filtering/sorting (category, date range, payment method)
- Export expenses (CSV)
- Add budgets and alerts
- Add recurring expenses
- Improve analytics visualizations (category pie, monthly trend, etc.)
- Optional: iCloud sync via CloudKit

