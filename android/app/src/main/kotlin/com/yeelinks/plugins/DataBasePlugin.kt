package com.yeelinks.plugins

import android.content.Context
import android.util.Log
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodChannel
import java.sql.Connection
import java.sql.DriverManager
import java.sql.SQLException

object DataBasePlugin {
    // Channel名称
    private const val ChannelName = "com.yeelinks.plugins/database"

    @JvmStatic
    fun register(context: Context, messager: BinaryMessenger) = MethodChannel(messager, ChannelName).setMethodCallHandler { methodCall, result ->
        when (methodCall.method) {
            "ping" -> DataBasePlugin.ping()
        }
        result.success(null)
    }

    private fun ping() {
        Thread(Runnable {
            try {
                Class.forName("com.mysql.jdbc.Driver").newInstance()
                val conn: Connection = DriverManager.getConnection(
                        "jdbc:mysql://139.224.16.230:3306/dap", "dap", "admin"
                )
                val stat = conn.createStatement()
                val resSet = stat!!.executeQuery("SELECT * FROM `ups`")
                while (resSet.next()) {
                    Log.d("mysqlConnection: ", resSet.getString("name"))
                }
                stat.close()
                conn.close()
            } catch (e: ClassNotFoundException) {
                e.printStackTrace()
            } catch (e: SQLException) {
                e.printStackTrace()
            }
        }).start()
    }
}