# Flutter Local Notifications - Preserve generic signatures
-keep class com.dexterous.flutterlocalnotifications.** { *; }
-keepattributes Signature
-keepattributes *Annotation*

# Gson - Preserve generic type information
-keepattributes Signature
-keep class com.google.gson.reflect.TypeToken { *; }
-keep class * extends com.google.gson.reflect.TypeToken
-keep public class * implements java.lang.reflect.Type

# Keep generic signature of Call, Response (R8 full mode strips signatures from non-kept items)
-keep,allowobfuscation,allowshrinking interface retrofit2.Call
-keep,allowobfuscation,allowshrinking class retrofit2.Response

# With R8 full mode generic signatures are stripped for classes that are not
# kept. Suspend functions are wrapped in continuations where the type argument
# is used.
-keep,allowobfuscation,allowshrinking class kotlin.coroutines.Continuation

# Firebase
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }

# Keep all model classes that might be serialized
-keep class * implements android.os.Parcelable {
  public static final android.os.Parcelable$Creator *;
}
