import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.xhesica.todolist"  // 这个可以保持不变
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    // 🔑 条件化签名配置 - 只在需要时创建
    val isCI = System.getenv("CI") != null
    val keystorePropertiesFile = rootProject.file("key.properties")
    val hasLocalKeystore = keystorePropertiesFile.exists()

    if (isCI || hasLocalKeystore) {
        signingConfigs {
            create("release") {
                if (isCI) {
                    // CI 环境配置
                    storeFile = file("todolist-key.jks")
                    storePassword = System.getenv("STORE_PASSWORD")
                    keyAlias = System.getenv("KEY_ALIAS")
                    keyPassword = System.getenv("KEY_PASSWORD")
                } else {
                    // 本地环境配置
                    val keystoreProperties = Properties()
                    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
                    
                    storeFile = file(keystoreProperties["storeFile"] as String)
                    storePassword = keystoreProperties["storePassword"] as String
                    keyAlias = keystoreProperties["keyAlias"] as String
                    keyPassword = keystoreProperties["keyPassword"] as String
                }
            }
        }
    }

    defaultConfig {
        // 🔧 修改为与密钥库匹配
        applicationId = "com.xhesica.todolist"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // 🔑 条件化签名：有自定义签名就用自定义的，否则用debug签名
            if (isCI || hasLocalKeystore) {
                signingConfig = signingConfigs.getByName("release")
            } else {
                // TODO: Add your own signing config for the release build.
                // Signing with the debug keys for now, so `flutter run --release` works.
                signingConfig = signingConfigs.getByName("debug")
            }
        }
    }
}

flutter {
    source = "../.."
}
