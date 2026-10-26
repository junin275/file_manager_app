pluginManagement {
    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
        maven {
            url = uri("${System.getenv(\"FLUTTER_ROOT\")}/packages/flutter_tools/gradle")
        }
    }
    plugins {
        id("com.android.application") version "8.1.4"
        id("org.jetbrains.kotlin.android") version "1.9.20"
        id("dev.flutter.flutter-gradle-plugin")
    }
}

include(":app")