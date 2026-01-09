# Localization Guide

Welcome to the **Der-Die-Das Localization Guide**. This project uses a **fully dynamic localization system**, meaning you can add support for new languages without modifying the core application code.

## Important: Data & Licensing

The source vocabulary files located in `raw_data/` (including `vocabulary.csv`) are **proprietary** and subject to the **LICENSE** of this project. 

For this reason, these files are **not included** in the public Git repository. If you are a contributor and wish to add a new language or correct existing translations, please **contact the developers** to request access to the source data.

---

## Quick Start (For Developers)

Adding a new language is a professional process involving AI-assisted translation with full linguistic context.

**Example: Adding Japanese (ja)**

1.  **Translate Vocabulary (AI-Powered)**
    Use the Gemini AI tool to translate words. This tool is **context-aware**—it uses the word's article and category to ensure the correct meaning (e.g., distinguishing between "Bank" as a financial institution vs. "Bank" as a bench).
    
    ```bash
    # Set your Gemini API Key
    export GEMINI_API_KEY="your_api_key_here"
    
    # Run the translator
    dart tool/translate_with_gemini.dart raw_data/vocabulary.csv ja
    ```

### Alternative: Legacy Fallback (No API Key)
If you don't have access to Gemini API, you can use the legacy tool which uses the free MyMemory API. 
**Note:** This method is not context-aware and provides much lower quality translations. Manual review is mandatory.
```bash
dart tool/translate_csv.dart raw_data/vocabulary.csv ja
```

2.  **Register the Language (Generate ARB)**
    This script ensures the app recognizes the new language code by creating a corresponding `.arb` file in `lib/l10n/`.
    ```bash
    dart tool/generate_arb_from_csv.dart
    ```

3.  **Build the Database**
    Compile the CSV into the SQLite database used by the app.
    ```bash
    dart run tool/build_database.dart
    ```

**That's it!** Run the app. "Japanese" (or "JA") will now appear in the settings menu.

---

## For Translators (Non-Programmers)

If you are a linguist who wants to help with translations:

1.  **Request the Source File**
    Contact the maintainers to receive the `vocabulary.csv` file.
2.  **Edit in Spreadsheet Software**
    Open the file in Excel, Google Sheets, or any CSV editor.
    *   **Add a new column** at the end of the header row (e.g., `translation_ja`).
    *   **Fill in the translations** for that column.
    *   *Note: Do not change the order of existing columns or rows.*
3.  **Submit your Work**
    Send the updated CSV back to the developers for integration.

---

## How It Works (Architecture)

The application separates **UI Language** (menus, buttons) from **Content Language** (vocabulary cards).

### 1. The Database (vocabulary.db)
The database builder (`tool/build_database.dart`) is dynamic. It scans the CSV header for any column starting with `translation_`. It automatically creates the necessary schema in the SQLite database.

### 2. The Language Registry (.arb files)
For Flutter to allow switching the locale to a new language, an `.arb` file must exist in `lib/l10n/`. The script `tool/generate_arb_from_csv.dart` automates this by creating placeholders based on the English template.

### 3. The User Interface
The App's Data Model (Word) loads dynamic columns into a map. When the user selects a language in the app, the UI simply requests the corresponding translation from this map.

---

## Cosmetic Tweaks

To display a proper name instead of a language code (e.g., "日本語" instead of "JA"):

1.  Open `lib/app_drawer.dart`.
2.  Find the `getLanguageName` function.
3.  Add a case for the new language:

```dart
String getLanguageName(String code) {
  switch (code) {
    case 'cs': return 'Čeština';
    case 'de': return 'Deutsch';
    case 'en': return 'English';
    case 'sk': return 'Slovenčina';
    case 'ru': return 'Русский';
    case 'ja': return '日本語';
    // Add your language here:
    default: return code.toUpperCase();
  }
}
```