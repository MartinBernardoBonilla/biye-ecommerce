// Archivo: android/build.gradle.kts

// El bloque de plugins ya está en settings.gradle.kts
// plugins { ... }

// Esto asegura que todos los módulos de tu proyecto usen los mismos repositorios
allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// Configuración personalizada para el directorio de compilación
val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}

subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}