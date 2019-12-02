package com.yeelinks.plugins

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

    fun selectAllPoints(): List<Map<String, Any>> {
        if (conn.isClosed) {
            conn = DriverManager.getConnection(url, username, password)
        }
        stat = conn.prepareStatement("""
            SELECT `pts`.`Status`, `pts`.`ADate`, `pts`.`ATime`, `pti`.* FROM `ptsts` AS `pts`, (
            	SELECT `PointID`, `BayName`, `PointName`, `GroupName` FROM `ptai`
            	UNION ALL
            	SELECT `PointID`, `BayName`, `PointName`, `GroupName` FROM `ptdi`
            ) AS `pti` WHERE `pts`.`PointID` = `pti`.`PointID`
        """.trimIndent())
        val rs = stat!!.executeQuery()
        val result: MutableList<Map<String, Any>> = ArrayList()
        while (rs.next()) {
            val pointID = rs.getString("PointID")
            result.add(mapOf(
                    "BayName" to rs.getString("BayName"),
                    "GroupName" to rs.getString("GroupName"),
                    "PointName" to rs.getString("PointName"),
                    "PointID" to pointID,
                    "Statue" to rs.getString("Status"),
                    "DateTime" to "${rs.getString("ADate")} ${rs.getString("ATime")}"
            ))
        }
        rs.close()
        stat!!.close()
        stat = null
        return result
    }
}