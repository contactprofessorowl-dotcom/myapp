# Project Blueprint

## Overview

This application is designed to help users prepare for entrance exams by providing general knowledge and awareness questions tailored to their age and location. The app will feature a user-friendly, flashcard-based interface for an engaging learning experience.

## Style, Design, and Features

### Initial Version

*   **UI/UX:**
    *   Modern, intuitive, and accessible design based on Material Design 3.
    *   Responsive layout for mobile and web.
    *   Visually balanced with clean spacing and polished styles.
    *   Uses the `google_fonts` package for custom typography.
    *   Features a bottom tab bar for navigation between Home, Settings, and Account screens.
    *   Accessibility compliant to support a wide range of users.
*   **Core Functionality:**
    *   Asks for the user's age and location (country/city).
    *   Presents multiple-choice questions (MCQs) on flashcards.
    *   Hints are available on the back of each flashcard.
    *   Swipe gestures for navigating between questions.
*   **State Management:**
    *   Uses the `provider` package for state management.
*   **Navigation:**
    *   Uses the `go_router` package for declarative routing.

## Current Plan

### Step 1: Initial Project Setup

*   Create a `blueprint.md` file to document the project.
*   Add `provider`, `google_fonts`, and `go_router` to `pubspec.yaml`.
*   Set up the basic app structure in `lib/main.dart`.
*   Create placeholder screens for Home, Settings, and Account.
*   Implement a basic theme using `ThemeData`, `ColorScheme.fromSeed`, and `google_fonts`.
