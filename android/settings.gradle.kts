pluginManagement {
    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
    plugins {
        id("com.android.application") version "8.1.4"
        id("org.jetbrains.kotlin.android") version "1.9.20"
    }
}

include(":app")