package com.yeelinks.plugins

import android.annotation.TargetApi
import android.app.admin.DeviceAdminReceiver
import android.app.admin.DevicePolicyManager
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.os.Build
import android.provider.Settings
import android.widget.Toast
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodChannel

object BrightCtrlPlugin {

    private const val ChannelName = "com.yeelinks.plugins/bright_ctrl"

    private val SCN_BRI_NOD = Settings.System.SCREEN_BRIGHTNESS_MODE
    private val MIN_BRIGHT = 10
    private var DFT_BRIGHT = 100
    private var brightness = DFT_BRIGHT

    @JvmStatic
    fun register(context: Context, messager: BinaryMessenger) = MethodChannel(messager, ChannelName).setMethodCallHandler { methodCall, result ->
        when (methodCall.method) {
            "turnOn" -> turnOn(context)
            "turnOff" -> turnOff(context)
        }
        result.success(null)
    }

    private fun turnOn(context: Context) {
        val curBri = Settings.System.getInt(context.contentResolver, SCN_BRI_NOD)
        if (curBri < MIN_BRIGHT) {
            brightness = DFT_BRIGHT
        } else {
            brightness = curBri
        }
        Settings.System.putInt(context.contentResolver, SCN_BRI_NOD, brightness)
    }

    @TargetApi(Build.VERSION_CODES.CUPCAKE)
    private fun turnOff(context: Context) {
//        brightness = Settings.System.getInt(context.contentResolver, SCN_BRI_NOD)
//        if (brightness > MIN_BRIGHT) {
//            DFT_BRIGHT = brightness
//        }
//        Timer().schedule(object: TimerTask() {
//            override fun run() {
//                if (brightness >= MIN_BRIGHT) {
//                    Settings.System.putInt(context.contentResolver, SCN_BRI_NOD, --brightness)
//                } else {
//                    cancel()
//                }
//            }
//        }, 0, 2000)

//        val pm = context.getSystemService(Context.POWER_SERVICE) as PowerManager
//        val wakeLock = pm.newWakeLock(PowerManager.PARTIAL_WAKE_LOCK, "yeelinks_server_monitor:wake-lock")
//        wakeLock.acquire(2000)
//        wakeLock.release()
        val pm = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.FROYO) {
            context.getSystemService(Context.DEVICE_POLICY_SERVICE) as DevicePolicyManager
        } else {
            TODO("VERSION.SDK_INT < FROYO")
        }
        val adminReceiver = ComponentName(context, ScreenOffAdminReceiver::class.java)
        val admin = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.FROYO) {
            pm.isAdminActive(adminReceiver)
        } else {
            TODO("VERSION.SDK_INT < FROYO")
        }
        if (admin) {
            pm.lockNow()
        } else {
            Toast.makeText(context, "没有设备管理权限", Toast.LENGTH_LONG).show()
        }
    }
}

@TargetApi(Build.VERSION_CODES.FROYO)
class ScreenOffAdminReceiver: DeviceAdminReceiver() {

    private fun showToast(context: Context, msg: String) {
        Toast.makeText(context, msg, Toast.LENGTH_SHORT).show();
    }

    override fun onEnabled(context: Context, intent: Intent) {
        showToast(context, "设备管理器使能");
    }

    @Override
    override fun onDisabled(context: Context, intent: Intent) {
        showToast(context, "设备管理器没有使能");
    }
}