package com.yeelinks.plugins

import android.util.Log
import java.sql.Connection
import java.sql.DriverManager
import java.sql.PreparedStatement

class DbHelper(private val url: String, private val username: String, private val password: String) {
    private var conn: Connection
    private var stat: PreparedStatement? = null

    init {
        Class.forName("com.mysql.jdbc.Driver").newInstance()
        conn = DriverManager.getConnection(url, username, password)
    }

    fun ping(): Boolean {
        if (conn.isClosed) {
            throw Exception("Connection closed")
        }
        stat = conn.prepareStatement("SHOW TABLES")
        val rs = stat!!.executeQuery()
        val result = rs.next()
        stat!!.close()
        stat = null
        return result
    }

    fun disconnect() {
        conn.close()
        stat!!.close()
        stat = null
    }

    fun isConnected(): Boolean {
        return !conn.isClosed
    }

    fun isWorking(): Boolean {
        return stat != null
    }

    fun selectAllPointByRSName(rsName: String): List<Map<String, Any>> {
        if (conn.isClosed) {
            conn = DriverManager.getConnection(url, username, password)
        }
        stat = conn.prepareStatement("SELECT `PointID`, `BayName`, `PointName`, `GroupName` FROM `ptai` WHERE `RSName` = ?")
        stat!!.setString(1, rsName)
        var rs = stat!!.executeQuery()
        val result: MutableMap<String, Map<String, Any>> = HashMap()
        while (rs.next()) {
            val pointID = rs.getString("PointID")
            result[pointID] = mapOf(
                    "BayName" to rs.getString("BayName"),
                    "GroupName" to rs.getString("GroupName"),
                    "PointName" to rs.getString("PointName"),
                    "PointID" to pointID
            )
        }
        rs.close()
        stat!!.close()
        Log.d("yeelinks", result.size.toString())
        stat = conn.prepareStatement("SELECT `PointID`, `Status`, `ADate`, `ATime` FROM `ptsts`")
        rs = stat!!.executeQuery()
        while (rs.next()) {
            val pointID = rs.getString("PointID")
            if (!result.containsKey(pointID)) {
                continue
            }
            result[pointID]!!.plus(mapOf(
                    "Status" to rs.getString("Status"),
                    "Time" to "${rs.getString("ADate")} ${rs.getString("ATime")}"
            ))
        }
        stat!!.close()
        stat = null
        return result.values.toList()
    }
}