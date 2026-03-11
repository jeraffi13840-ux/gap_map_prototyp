import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("kotlin-android")
    // Le plugin Flutter doit être après Android et Kotlin
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    // À adapter si ton namespace est différent
    namespace = "com.example.gap_map_prototype"

    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        // Kotlin DSL : il faut un "="
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        // Kotlin DSL : string entre guillemets "
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        // Mets ici ton applicationId (peut être le même que namespace)
        applicationId = "com.example.gap_map_prototype"

        // Ces valeurs viennent de la config Flutter
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // Pour l’instant : on signe avec la clé debug
            // pour que `flutter run --release` fonctionne aussi.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    // Chemin vers le projet Flutter
    source = "../.."
}
