allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}


fun Project.raiseCompileSdk(required: Int = 36) {
    val extension = extensions.findByName("android")
    if (extension !is com.android.build.gradle.BaseExtension) return
    val current = extension.compileSdkVersion?.removePrefix("android-")?.toIntOrNull()
    if (current != null && current < required) {
        logger.lifecycle("Raising $name compileSdk $current -> $required")
        extension.compileSdkVersion(required)
    }
}

subprojects {
    if (state.executed) {
        raiseCompileSdk()
    } else {
        afterEvaluate { raiseCompileSdk() }
    }
}

subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
