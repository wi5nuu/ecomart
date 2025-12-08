// android/app/build.gradle

plugins {
    id("com.android.application")
    id("kotlin-android")
    // *** TAMBAHAN: Plugin Google Services untuk Firebase ***
    id("com.google.gms.google-services")
    // ****************************************************

    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.ecomart.ecomart"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "com.ecomart.ecomart"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

// *** DEPENDENSI FIREBASE ***
dependencies {
    // Implementasi Kotlin standard library
    implementation("org.jetbrains.kotlin:kotlin-stdlib-jdk7:1.8.0")

    // Firebase Bill of Materials (BOM) - untuk manajemen versi yang kompatibel
    implementation(platform("com.google.firebase:firebase-bom:32.7.0"))

    // Dependencies produk Firebase yang dibutuhkan:
    implementation("com.google.firebase:firebase-analytics")
    implementation("com.google.firebase:firebase-auth") // Untuk Login/Daftar
    implementation("com.google.firebase:firebase-firestore") // Untuk Database
}
// *************************