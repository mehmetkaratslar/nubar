// Dosya: android/app/build.gradle.kts
// Amaç: Android uygulaması için Gradle yapılandırmasını tanımlar.
// Konum: android/app/build.gradle.kts
// Bağlantı: Projenin Android modülünü yapılandırır, Firebase ve Flutter ile entegre çalışır.
// Not: ENABLE_IMPELLER ayarı doğrulandı.

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services") // Firebase için google-services eklentisi
}

android {
    namespace = "com.example.nubar"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_21 // Java 21'e düşürüldü
        targetCompatibility = JavaVersion.VERSION_21 // Java 21'e düşürüldü
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_21.toString() // Java 21 ile uyumlu
    }

    defaultConfig {
        applicationId = "com.example.nubar"
        minSdk = 23
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // Debug signing config yerine release için uygun bir yapılandırma önerilir
            signingConfig = signingConfigs.getByName("debug")
            isMinifyEnabled = false // ProGuard veya R8 ile küçültme (release için önerilir)
            isShrinkResources = false // Kaynak küçültme
        }
        debug {
            signingConfig = signingConfigs.getByName("debug")
            isDebuggable = true
        }
    }

    // Impeller rendering backend'i devre dışı bırakma
    buildFeatures {
        buildConfig = true
    }

    buildTypes.forEach {
        it.buildConfigField("boolean", "ENABLE_IMPELLER", "false")
    }
}

flutter {
    source = "../.."
}

dependencies {
    // Firebase bağımlılıkları (BOM ile versiyon yönetimi)
    implementation(platform("com.google.firebase:firebase-bom:33.2.0")) // En son BOM sürümü
    implementation("com.google.firebase:firebase-auth")
    implementation("com.google.firebase:firebase-firestore")
    implementation("com.google.firebase:firebase-storage")
    implementation("com.google.firebase:firebase-analytics")

    // Diğer bağımlılıklar
    implementation("org.jetbrains.kotlin:kotlin-stdlib-jdk8:2.1.0") // Kotlin sürümü 2.1.0 ile uyumlu
}