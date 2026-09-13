import java.util.Properties

plugins {
    id("com.android.application")

    id("dev.flutter.flutter-gradle-plugin")
}

val releaseSigningPropertiesFile = providers
    .gradleProperty("studyBuddySigningProperties")
    .orElse(providers.environmentVariable("STUDY_BUDDY_SIGNING_PROPERTIES"))
    .orNull?.let(project::file)
val releaseSigningProperties = Properties().apply {
    if (releaseSigningPropertiesFile?.isFile == true) {
        releaseSigningPropertiesFile.inputStream().use { input -> load(input) }
    }
}

android {
    namespace = "com.studybuddy.app"
    compileSdk = flutter.compileSdkVersion
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


        minSdk = 28
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName

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


    splits {
        abi {
            isEnable = project.hasProperty("splitApks")
            reset()
            include("arm64-v8a", "armeabi-v7a", "x86_64")
            isUniversalApk = false
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.findByName("release")
        }
    }

    packaging {
        jniLibs {


            useLegacyPackaging = false
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

dependencies {


    implementation("com.google.android.gms:play-services-wearable:18.2.0")
}

flutter {
    source = "../.."
}

val verifySynheartRuntimeAbi by tasks.registering {
    group = "verification"
    description = "Verifies the pinned Synheart Core runtime ABI used by the published Flutter SDK."
    doLast {
        val required = listOf(
            "synheart_core_new",
            "synheart_core_free",
            "synheart_core_start_session",
            "synheart_core_stop_session",
            "synheart_core_set_hsi_callback",
            "synheart_core_get_hsi_windows",
            "synheart_core_upload_queue_length",
            "synheart_core_sdk_set_crypto_callbacks",
            "synheart_core_sdk_register_device",
            "synheart_core_sdk_device_auth_status",
            "synheart_core_sdk_build_proof_header",
        )
        val runtimeRoot = project.file("../../synheart/vendor/runtime/android/jniLibs")
        val libraries = runtimeRoot.walkTopDown()
            .filter { it.isFile && it.name == "libsynheart_core_runtime.so" }
            .toList()
        check(libraries.isNotEmpty()) {
            "Pinned Synheart Core runtime is missing. Restore mobile/synheart.lock with the Synheart CLI."
        }
        libraries.forEach { library ->
            val symbols = providers.exec {
                commandLine("nm", "-D", "--defined-only", library.absolutePath)
            }.standardOutput.asText.get()
            val missing = required.filter { symbol ->
                !Regex("(^|\\s)${Regex.escape(symbol)}(\\s|$)", RegexOption.MULTILINE)
                    .containsMatchIn(symbols)
            }
            check(missing.isEmpty()) {
                "Installed Synheart Core runtime is incompatible with synheart_core Flutter. " +
                    "Artifact: ${library.absolutePath}. Missing symbols: ${missing.joinToString()}. " +
                    "Restore the pinned runtime and send sanitized diagnostics to Synheart support if it persists."
            }
        }
    }
}

tasks.named("preBuild").configure { dependsOn(verifySynheartRuntimeAbi) }
