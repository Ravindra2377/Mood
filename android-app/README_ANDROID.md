[![Android JVM Unit Tests](https://github.com/Ravindra2377/Mood/actions/workflows/android-unit-tests.yml/badge.svg)](https://github.com/Ravindra2377/Mood/actions/workflows/android-unit-tests.yml)

Android app starter

Open this folder in Android Studio.

Steps:
1. Open Android Studio and select "Open an existing project" and choose this `android-app` folder.
2. Let Gradle sync and download dependencies.
3. Run the emulator or connect a device. If running on the emulator, use `http://10.0.2.2:8000/` to reach the backend running on your host machine.
4. Update `baseUrl` in `LoginActivity` to point to your backend URL or use a BuildConfig field.

Next suggested tasks:
- Wire in ViewModel and LiveData for the auth flow
- Implement SignupActivity and token refresh handling
- Add Room DB for offline moods
- Add navigation and main activity

Auth scaffold included in this commit:
- `AuthInterceptor` (simple synchronous refresh-on-401 implementation)
- `AuthViewModel` (basic LiveData-based ViewModel)
- `SignupActivity` and `MainActivity` stubs

Mood feature:
- `MoodTrackingActivity` — pastel-themed mood logging UI (emoji slider, note, save FAB).
- Room cache: `AppDatabase`, `MoodEntryEntity`, `MoodDao` in `com.mhaiapp.models`.
- ViewModel & repo: `MoodViewModel` and `MoodRepository` in `com.mhaiapp.viewmodels` / `com.mhaiapp.repositories`.

Run the app and select the Mood tab in the bottom navigation to open the mood screen.
