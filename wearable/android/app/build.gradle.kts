import java.util.Properties

plugins {
    id("com.android.application")

    id("dev.flutter.flutter-gradle-plugin")
}

val requestedRelease = gradle.startParameter.taskNames.any { name ->
    name.contains("Release", ignoreCase = true)
}


val syntheticWatchInput = providers.gradleProperty("studyBuddySyntheticWatchInput")
    .orNull?.toBooleanStrictOrNull() ?: !requestedRelease
val releaseSigningPropertiesFile = providers
    .gradleProperty("studyBuddySigningProperties")
    .orElse(providers.environmentVariable("STUDY_BUDDY_SIGNING_PROPERTIES"))
    .orNull?.let(project::file)
val releaseSigningProperties = Properties().apply {
    if (releaseSigningPropertiesFile?.isFile == true) {
        releaseSigningPropertiesFile.inputStream().use { input -> load(input) }
    }
}

check(!syntheticWatchInput || !requestedRelease) {
    "Synthetic watch input is forbidden in release builds."
}

android {
    namespace = "com.studybuddy.app"
    compileSdk = 36
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    buildFeatures {


        buildConfig = true
    }

    defaultConfig {
        applicationId = "com.studybuddy.app"


        minSdk = 33
        targetSdk = 36


        versionCode = flutter.versionCode
        versionName = flutter.versionName
        buildConfigField("boolean", "SYNTHETIC_INPUT", syntheticWatchInput.toString())
        ndk {


            abiFilters += listOf("arm64-v8a", "armeabi-v7a", "x86_64")
        }
    }

    signingConfigs {
        if (releaseSigningPropertiesFile?.isFile == true) {
            create("release") {
                storeFile = project.file(releaseSigningProperties.getProperty("storeFile"))
                storePassword = releaseSigningProperties.getProperty("storePassword")
                keyAlias = releaseSigningProperties.getProperty("keyAlias")
                keyPassword = releaseSigningProperties.getProperty("keyPassword")
            }
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.findByName("release")
        }
    }
}

tasks.configureEach {
    if ((name.startsWith("assemble") || name.startsWith("bundle")) && name.endsWith("Release")) {
        doFirst {
            check(releaseSigningPropertiesFile?.isFile == true) {
                "Release signing is not configured. Set STUDY_BUDDY_SIGNING_PROPERTIES to an ignored properties file shared by phone and watch."
            }
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}

dependencies {
    implementation("androidx.health:health-services-client:1.1.0-rc02")
    implementation("androidx.concurrent:concurrent-futures-ktx:1.2.0")
    implementation("androidx.wear:wear-ongoing:1.1.0")


    implementation("androidx.wear:wear:1.3.0")
    implementation("com.google.android.gms:play-services-wearable:18.2.0")
    implementation("org.jetbrains.kotlinx:kotlinx-coroutines-android:1.10.2")
    testImplementation("junit:junit:4.13.2")
}

val verifySynheartRuntimeAbi by tasks.registering {
    group = "verification"
    description = "Verifies the Synheart runtime packaged by the Wear OS app."
    doLast {
        val required = listOf(
            "synheart_core_new",
            "synheart_core_free",
            "synheart_core_start_session",
            "synheart_core_stop_session",
            "synheart_core_set_hsi_callback",
            "synheart_core_upload_queue_length",
        )
        val expectedAbis = setOf("arm64-v8a", "armeabi-v7a", "x86_64")
        val runtimeRoot = project.file("../../synheart/vendor/runtime/android/jniLibs")
        val libraries = runtimeRoot.listFiles()
            ?.filter { it.isDirectory && it.name in expectedAbis }
            ?.associate { abi -> abi.name to abi.resolve("libsynheart_core_runtime.so") }
            .orEmpty()
        check(libraries.keys == expectedAbis && libraries.values.all { it.isFile }) {
            "Wearable Synheart runtime is incomplete. Run `/tmp/synheart/bin sync` from wearable/. Expected ${expectedAbis.sorted()}."
        }
        libraries.forEach { (abi, library) ->
            val symbols = providers.exec {
                commandLine("nm", "-D", "--defined-only", library.absolutePath)
            }.standardOutput.asText.get()
            val missing = required.filter { symbol ->
                !Regex("(^|\\s)${Regex.escape(symbol)}(\\s|$)", RegexOption.MULTILINE)
                    .containsMatchIn(symbols)
            }
            check(missing.isEmpty()) {
                "Synheart runtime for $abi is incompatible. Missing: ${missing.joinToString()}. Restore wearable/synheart.lock with the Synheart CLI."
            }
        }
    }
}

tasks.named("preBuild").configure { dependsOn(verifySynheartRuntimeAbi) }
