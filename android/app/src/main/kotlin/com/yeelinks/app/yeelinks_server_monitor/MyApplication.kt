package com.yeelinks.app.yeelinks_server_monitor

import io.flutter.app.FlutterApplication
import io.flutter.plugin.common.PluginRegistry
import vn.hunghd.flutterdownloader.FlutterDownloaderPlugin

internal class MyApplication : FlutterApplication(), PluginRegistry.PluginRegistrantCallback {
    override fun registerWith(registry: PluginRegistry?) {
        FlutterDownloaderPlugin.registerWith(registry?.registrarFor("vn.hunghd.flutterdownloader.FlutterDownloaderPlugin"))
    }
}