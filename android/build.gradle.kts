// Dosya: android/build.gradle.kts
// Amaç: Android modülü için Gradle yapılandırmasını tanımlar.
// Konum: android/build.gradle.kts
// Bağlantı: Projenin genel Gradle yapılandırmasını yönetir.
// Not: ArtifactRepositoryContainer import'u kaldırıldı, yapılandırma modernize edildi.

import org.gradle.api.tasks.Delete
import org.gradle.api.file.Directory

// Bağımlılıkları ve eklentileri tanımlayan buildscript bloğu
buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        // Google Services eklentisi (Firebase için gerekli)
        classpath("com.google.gms:google-services:4.4.2")
    }
}

// Tüm projeler için depolar
allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// Build dizinini özelleştirme: Build çıktılarını ../../build dizinine taşı
val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.set(newBuildDir)

// Alt projeler için build dizinini özelleştirme
subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.set(newSubprojectBuildDir)
}

// Alt projelerin :app modülüne bağımlı olmasını sağla
subprojects {
    project.evaluationDependsOn(":app")
}

// Clean görevini tanımla: Build dizinini siler
tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
    doLast {
        println("Clean task completed: Build directory ${rootProject.layout.buildDirectory.get().asFile.path} deleted.")
    }
}