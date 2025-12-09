// android/build.gradle.kts (Solusi Final dengan Hardcode)

// Top-level build file where you can add configuration options common to all sub-projects/modules.
buildscript {

    // *** DEFINISIKAN VERSI KOTLIN LANGSUNG DI DALAM BLOK INI ***
    val KOTLIN_VERSION = "1.8.0" // Deklarasi variabel lokal yang jelas
    // *************************************************************

    repositories {
        google()
        mavenCentral()
    }

    dependencies {
        // Plugin Android Gradle (ganti dengan versi yang sesuai)
        classpath("com.android.tools.build:gradle:8.1.0")

        // CLASS PATH UNTUK GOOGLE SERVICES
        classpath("com.google.gms:google-services:4.4.1")

        // Plugin Kotlin: Gunakan variabel lokal yang baru
        classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:$KOTLIN_VERSION")
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// Logic untuk mengubah direktori build
val newBuildDir = rootProject.layout.buildDirectory
    .dir("../../build")
    .get()
rootProject.layout.buildDirectory.set(newBuildDir)

subprojects {
    val newSubprojectBuildDir = newBuildDir.dir(project.name)
    project.layout.buildDirectory.set(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}

apply(plugin = "com.google.gms.google-services")