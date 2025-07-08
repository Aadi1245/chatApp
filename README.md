# chattest

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

# code for App size reducing 

1. first create proguard-rules.pro file

# Keep Google Play Core classes for split installs and dynamic feature modules
-keep class com.google.android.play.core.** { *; }
-dontwarn com.google.android.play.core.**

# Flutter wrapper classes
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Keep your app’s classes
-keep class com.example.chattest.** { *; }

# Prevent shrinking of entry points
-keep class MainActivity
-keep class *.MainActivity { *; }

2. add this code in your app level build.gradle

   splits {
  abi {
    enable true
    reset()
    include 'armeabi-v7a', 'arm64-v8a'
    universalApk false
  }
}


    buildTypes {
        release {
            shrinkResources true
        minifyEnabled true
        proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'
         signingConfig signingConfigs.debug
          //  signingConfig signingConfigs.release
        }
    }

3. now open terminal and run this command "flutter pub deps --style=compact" after this run this command "flutter build apk --split-per-abi" in order to reduce size  



