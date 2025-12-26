buildscript {
    repositories {
        google()
        mavenCentral()
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// ВАЖНО: правильный clean для Kotlin DSL
tasks.register<Delete>("clean") {
    delete(rootProject.buildDir)
}
