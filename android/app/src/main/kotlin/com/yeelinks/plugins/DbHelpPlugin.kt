package com.yeelinks.plugins

import android.annotation.TargetApi
import android.os.Build
import android.os.Handler
import android.os.Message
import android.util.Log
import io.flutter.plugin.common.EventChannel

@TargetApi(Build.VERSION_CODES.CUPCAKE)
object DbHelpPlugin : EventChannel.StreamHandler {
    // Channel名称
    const val ChannelName = "com.yeelinks.plugins/db_help"
    var dbHelper: DbHelper? = null
    var queryJob: Thread? = null
    val handler: Handler = Handler(Handler.Callback { msg ->
        if (eventSink != null) {
            eventSink!!.success(msg!!.obj)
            true
        } else {
            false
        }
    })
    var eventSink: EventChannel.EventSink? = null

    override fun onListen(args: Any?, events: EventChannel.EventSink?) {
        eventSink = events
        Thread(Runnable {
            dbHelper = DbHelper(
                    "jdbc:mysql://139.224.16.230:3306/dap", "dap", "admin"
            )
            Log.d("yeelinks", "Database ping: " + dbHelper!!.ping())
        }).start()
        queryJob = object : Thread() {
            override fun run() {
                while (!isInterrupted) {
                    if (dbHelper == null || !dbHelper!!.isConnected()) {
                        continue
                    }
                    handler.sendMessage(handler.obtainMessage(
                            1, dbHelper!!.selectAllFromUPS()
                    ))
                    sleep(2000)
                }
            }
        }
        queryJob!!.start()
    }

    override fun onCancel(p0: Any?) {
        queryJob!!.interrupt()
        dbHelper!!.disconnect()
    }
}