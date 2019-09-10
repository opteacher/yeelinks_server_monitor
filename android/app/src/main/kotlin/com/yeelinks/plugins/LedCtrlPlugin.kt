package com.yeelinks.plugins

import android.content.Context
import android.os.Handler
import com.example.elcapi.jnielc
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodChannel

object LedCtrlPlugin {

    // Channel名称
    private const val ChannelName = "com.yeelinks.plugins/led_ctrl"

    private val currentColor = 0xa3
    private var currentBrightness = 0;
    private val ColorMapper = mapOf(
            "RED" to 0xa1,
            "GREEN" to 0xa2,
            "BLUE" to 0xa3
    )
    private val handler = Handler();

    @JvmStatic
    fun register(context: Context, messager: BinaryMessenger) = MethodChannel(messager, ChannelName).setMethodCallHandler { methodCall, result ->
        when (methodCall.method) {
            "lightUp" -> methodCall.argument<String>("color")?.let { methodCall.argument<Int>("brightness")?.let { it1 -> lightUp(it, it1) } }
            "adjust" -> methodCall.argument<Int>("brightness")?.let { adjust(it) }
            "lightDown" -> lightDown()
            "flash" -> flash()
        }
        result.success(null)
    }

    private fun lightUp(color: String, brightness: Int) {
        jnielc.seekstart()
        ColorMapper[color]?.let { jnielc.ledseek(it, brightness) }
        jnielc.seekstop()
    }

    private fun adjust(brightness: Int) {
        jnielc.seekstart()
        jnielc.ledseek(currentColor, brightness)
        jnielc.seekstop()
    }

    private fun lightDown() {
        currentBrightness = 0
        handler.postDelayed(Runnable {
            val fb = jnielc.open()
            jnielc.ledoff(fb)
        }, 1000)
    }

    private fun flash() {
        currentBrightness = 100
        lightUp("RED", currentBrightness)
        handler.post(Runnable {
            jnielc.seekstart()
            while (currentBrightness > 0) {
                if (currentBrightness == 1) {
                    currentBrightness = 100
                } else {
                    currentBrightness--
                }
                jnielc.ledseek(0xa1, currentBrightness)
                Thread.sleep(500)
            }
            jnielc.seekstop()
        })
    }
}