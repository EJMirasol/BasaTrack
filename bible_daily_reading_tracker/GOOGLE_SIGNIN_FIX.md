# Fixing Google Sign-In Error (Error Code 10)

## Problem

You're seeing this error:
```
Sign in failed: Failed to sign in with Google: PlatformException(sign_in_failed, com.google.android.gms.common.api.ApiException: 10, null, null)
```

**Error Code 10** means `DEVELOPER_ERROR` - This happens when the SHA-1 certificate fingerprint is not configured in Firebase Console.

---

## Solution: Add SHA-1 Fingerprint to Firebase

### Step 1: Get Your SHA-1 Fingerprint

Run this command in your terminal (PowerShell or Command Prompt):

```powershell
cd %USERPROFILE%\.android
keytool -list -v -keystore debug.keystore -alias androiddebugkey -storepass android -keypass android
```

Or if using Git Bash:

```bash
cd ~/.android
keytool -list -v -keystore debug.keystore -alias androiddebugkey -storepass android -keypass android
```

**Look for the SHA-1 line** in the output. It will look like:
```
SHA1: AA:BB:CC:DD:EE:FF:00:11:22:33:44:55:66:77:88:99:AA:BB:CC:DD
```

**Copy this SHA-1 value.**

---

### Step 2: Add SHA-1 to Firebase Console

1. Go to [Firebase Console](https://console.firebase.google.com)
2. Select your project: **basatrack**
3. Click the gear icon (⚙️) next to "Project Overview" → **Project settings**
4. Scroll down to "Your apps" section
5. Find your Android app: `com.lrph.bible_daily_reading_tracker`
6. Click "Add fingerprint" button
7. Paste your SHA-1 fingerprint
8. Click "Save"

---

### Step 3: Download Updated google-services.json (Optional)

Firebase will automatically update the OAuth configuration. However, to be safe:

1. In Firebase Console, under your Android app
2. Click "Download google-services.json"
3. Replace the existing file at: `android/app/google-services.json`

---

### Step 4: Enable Google Sign-In (If Not Already Done)

1. In Firebase Console, go to **Authentication** → **Sign-in method**
2. Click on **Google** provider
3. Click **Enable** toggle
4. Add your support email
5. Click **Save**

---

### Step 5: Rebuild and Test

```bash
flutter clean
flutter run
```

Then try signing in with Google again.

---

## Alternative: Quick Fix Command

If `keytool` is not found, you need to add Java to your PATH. The keytool is located in your Java JDK installation.

**Find Java installation:**
```bash
where java
```

Then run keytool from that directory, for example:
```bash
"C:\Program Files\Java\jdk-17\bin\keytool" -list -v -keystore %USERPROFILE%\.android\debug.keystore -alias androiddebugkey -storepass android -keypass android
```

---

## Expected Outcome

After adding the SHA-1 fingerprint to Firebase:
- ✅ Google Sign-In will work
- ✅ You'll see the Google account picker
- ✅ You'll be redirected to the home screen
- ✅ Data will sync to Firestore

---

## Still Having Issues?

If you're still seeing errors:

1. **Check package name**: Ensure Firebase has `com.lrph.bible_daily_reading_tracker`
2. **Check OAuth client**: In Firebase Console → Authentication → Settings → Authorized domains
3. **Check SHA-1**: Make sure it's for the debug keystore you're using
4. **Restart app**: Sometimes changes take a moment to propagate

---

## For Production Builds

When you're ready to release your app, you'll also need to add the SHA-1 from your **release keystore**:

```bash
keytool -list -v -keystore your-release-key.keystore -alias your-key-alias
```
