# Mantener clases de Stripe
-keep class com.stripe.android.** { *; }
-keep interface com.stripe.android.** { *; }
-dontwarn com.stripe.android.**

# Mantener clases de push provisioning
-keep class com.stripe.android.pushProvisioning.** { *; }
-dontwarn com.stripe.android.pushProvisioning.**

# Mantener clases de Firebase
-keep class com.google.firebase.** { *; }
-dontwarn com.google.firebase.**

# Mantener clases de Kotlin
-keep class kotlin.** { *; }
-dontwarn kotlin.**

# Mantener clases de shared_preferences
-keep class io.flutter.plugins.sharedpreferences.** { *; }
-dontwarn io.flutter.plugins.sharedpreferences.**