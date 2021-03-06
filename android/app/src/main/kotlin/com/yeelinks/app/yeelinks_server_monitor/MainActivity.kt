package com.yeelinks.app.yeelinks_server_monitor

import android.os.Bundle
import com.yeelinks.plugins.DbHelpPlugin
import com.yeelinks.plugins.LedCtrlPlugin

import io.flutter.app.FlutterActivity
import io.flutter.plugin.common.EventChannel
import io.flutter.plugins.GeneratedPluginRegistrant

class MainActivity: FlutterActivity() {
  override fun onCreate(savedInstanceState: Bundle?) {
    super.onCreate(savedInstanceState)
    GeneratedPluginRegistrant.registerWith(this)
//    LedCtrlPlugin.register(this, flutterView)
    EventChannel(flutterView, DbHelpPlugin.ChannelName)
            .setStreamHandler(DbHelpPlugin)
  }
}
