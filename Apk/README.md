Apk folder
=========

This folder contains an APK file named with a timestamp.

IMPORTANT: The included APK file is a placeholder and is NOT a valid Android package. The execution environment used to create this repository does not have the Android SDK or build tools installed, so it cannot produce a real APK.

How to create a real APK locally
--------------------------------
1. Install Flutter (>= stable) and Android SDK on your Windows machine.
2. Set environment variables (PowerShell example):

   $env:ANDROID_HOME = 'C:\Android\sdk'
   $env:PATH += ';' + "$env:ANDROID_HOME\platform-tools"

   (Adjust paths to where you installed the SDK.)

3. In project root (this repo):

   flutter pub get
   flutter build apk --release

4. The built APK will be at:

   build\app\outputs\flutter-apk\app-release.apk

5. Copy that file into this folder and commit:

   git add Apk\app-release.apk
   git commit -m "Add release APK (timestamped)"
   git push origin main

CI alternative (I can add this)
-------------------------------
I can add a GitHub Actions workflow that builds the APK on push or on tag and uploads the APK as an artifact. Tell me which trigger you prefer (on push to `main`, on push to a specific branch, or on creating a release/tag), and I'll add the workflow file.

Notes
-----
- If you'd like, I can also add steps to automatically upload the artifact to a release or to a storage bucket, but that requires additional configuration.
