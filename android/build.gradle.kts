allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

// AGP 8+: Android library modules must set `namespace`. Legacy plugins (e.g. ar_flutter_plugin)
// omit it; derive from AndroidManifest package= using a hook registered before evaluation order issues.
gradle.beforeProject {
    afterEvaluate {
        val androidExt = extensions.findByName("android") ?: return@afterEvaluate
        val androidAny = androidExt as Any

        fun hasNamespace(ext: Any): Boolean {
            return try {
                val m = (ext as Any).javaClass.methods.firstOrNull { it.name == "getNamespace" && it.parameterCount == 0 }
                val ns = m?.invoke(ext) ?: return false
                ns.toString().isNotBlank()
            } catch (_: Exception) {
                false
            }
        }

        if (hasNamespace(androidAny)) return@afterEvaluate

        val manifestFile = file("src/main/AndroidManifest.xml")
        if (!manifestFile.exists()) return@afterEvaluate
        val text = manifestFile.readText(Charsets.UTF_8)
        val pkg =
            Regex("""package\s*=\s*"([^"]+)"""").find(text)?.groupValues?.get(1)
                ?: return@afterEvaluate

        try {
            val setter =
                androidAny.javaClass.methods.firstOrNull {
                    it.name == "setNamespace" && it.parameterCount == 1 && it.parameterTypes[0] == String::class.java
                }
            setter?.invoke(androidAny, pkg)
        } catch (_: Exception) {
            // Ignore; incompatible AGP APIs
        }
    }
}

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
