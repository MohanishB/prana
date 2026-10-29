package com.pranabydimpleacademy.prana

import android.app.NotificationChannel
import android.app.NotificationManager
import android.os.Build
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        createNotificationChannel()
    }

    // Android 8+ shows pushes only through a channel. The server names this channel
    // (FCM_ANDROID_CHANNEL = prana_general) and the manifest uses it as the default.
    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return
        val channel = NotificationChannel(
            "prana_general",
            "PRANA updates",
            NotificationManager.IMPORTANCE_HIGH
        ).apply {
            description = "Class reminders, booking updates and messages from Prana"
        }
        getSystemService(NotificationManager::class.java).createNotificationChannel(channel)
    }
}
