package com.yeelinks.app.yeelinks_server_monitor

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.Intent.ACTION_BOOT_COMPLETED
import android.content.Intent.FLAG_ACTIVITY_NEW_TASK

class BootCompletedReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context?, intent: Intent?) {
        if (intent?.action.equals(ACTION_BOOT_COMPLETED)) {
            val intt = Intent(context, MainActivity::class.java)
            intt.addFlags(FLAG_ACTIVITY_NEW_TASK)
            context?.startActivity(intt)
        }
    }
}