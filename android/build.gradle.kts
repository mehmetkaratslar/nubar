// android/build.gradle.kts
// Amaç: Android modülü için Gradle yapılandırmasını tanımlar.
// Konum: android/build.gradle.kts
// Bağlantı: Projenin genel Gradle yapılandırmasını yönetir.

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
}