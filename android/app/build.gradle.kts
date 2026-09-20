plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val uploadStoreFile = providers.environmentVariable("MUSCLE_MAP_UPLOAD_STORE_FILE").orNull
val uploadStorePassword = providers.environmentVariable("MUSCLE_MAP_UPLOAD_STORE_PASSWORD").orNull
val uploadKeyAlias = providers.environmentVariable("MUSCLE_MAP_UPLOAD_KEY_ALIAS").orNull
val uploadKeyPassword = providers.environmentVariable("MUSCLE_MAP_UPLOAD_KEY_PASSWORD").orNull
val releaseSigningConfigured = listOf(
    uploadStoreFile,
    uploadStorePassword,
    uploadKeyAlias,
    uploadKeyPassword,
).all { !it.isNullOrBlank() }

android {
    namespace = "com.musle.musle_map"
    compileSdk = 36
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.musle.musle_map"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = 36
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        if (releaseSigningConfigured) {
            create("release") {
                storeFile = file(uploadStoreFile!!)
                storePassword = uploadStorePassword
                keyAlias = uploadKeyAlias
                keyPassword = uploadKeyPassword
            }
        }
    }

    buildTypes {
        release {
            signingConfig = if (releaseSigningConfigured) {
                signingConfigs.getByName("release")
            } else {
                null
            }
        }
    }
}

gradle.taskGraph.whenReady {
    val needsReleaseSigning = allTasks.any {
        it.name == "bundleRelease" || it.name == "assembleRelease"
    }
    if (needsReleaseSigning && !releaseSigningConfigured) {
        throw GradleException(
            "Release signing is not configured. Set the MUSCLE_MAP_UPLOAD_* environment variables.",
        )
    }
}

flutter {
    source = "../.."
}
