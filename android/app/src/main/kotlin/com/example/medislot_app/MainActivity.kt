package com.example.medislot_app

import io.flutter.embedding.android.FlutterFragmentActivity

// MainActivity uses FlutterFragmentActivity instead of FlutterActivity
// This is required by the local_auth (fingerprint) package to work correctly on Android
// Without this change, fingerprint authentication would not function
class MainActivity: FlutterFragmentActivity()