pluginManagement {
    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
        maven {
            val flutterRoot = System.getenv("FLUTTER_ROOT")
            url = uri("${flutterRoot}/packages/flutter_tools/gradle")
        }
    }
    plugins {
        id("com.android.application") version "8.1.4"
        id("org.jetbrains.kotlin.android") version "1.9.20"
        id("dev.flutter.flutter-gradle-plugin")
    }
}

include(":app")