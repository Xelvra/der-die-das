# Vocabulary Data & Database Generation

### ⚠️ Important Note
**The application is ready to run out-of-the-box.**
A pre-built database containing the official vocabulary is already included at `assets/db/vocabulary.db`. You do **not** need to generate anything to use the app.

### Source Data
The source CSV files used to generate the official database are **proprietary** and are not included in this open-source repository. Therefore, this folder is empty by default.

### Custom Database
Use this folder and the build script **only if you want to replace the official database with your own custom vocabulary.**

#### How to build a custom database:
1.  Create a file named `vocabulary.csv` in this folder (`raw_data/`).
2.  Ensure it follows the structure: `word,article,translation_en,translation_cs,level,category,plural` (with a header row).
3.  Run the build script:
    ```bash
    dart run tool/build_database.dart
    ```
    *This will overwrite the existing `assets/db/vocabulary.db` file.*