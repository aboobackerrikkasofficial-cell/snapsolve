# SnapSolve Enterprise ProGuard Rules

# 1. Keep basic Flutter classes
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# 2. Obfuscate application classes
# We keep the entry point but obfuscate everything else
-keep class com.snapsolve.ai.MainActivity { *; }

# 3. Protect sensitive models from field renaming if they use reflection (JSON)
-keepclassmembers class * extends com.snapsolve.ai.models.** {
    <fields>;
    <methods>;
}

# 4. Strip debug info and log messages
-assumenosideeffects class android.util.Log {
    public static *** d(...);
    public static *** v(...);
    public static *** i(...);
}

# 5. Native methods protection
-keepclasseswithmembernames class * {
    native <methods>;
}

# 6. Secure storage and encryption classes
-keep class javax.crypto.** { *; }
-keep class org.bouncycastle.** { *; }
