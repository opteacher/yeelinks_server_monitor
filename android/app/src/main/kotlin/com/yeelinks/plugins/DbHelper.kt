package com.yeelinks.plugins

import java.sql.Connection
import java.sql.DriverManager
import java.sql.Statement

class DbHelper(url: String, username: String, password: String) {
    private var conn: Connection
    private var stat: Statement? = null

    init {
        Class.forName("com.mysql.jdbc.Driver").newInstance()
        conn = DriverManager.getConnection(url, username, password)
    }

    fun ping(): Boolean {
        if (conn.isClosed) {
            throw Exception("Connection closed")
        }
        stat = conn.createStatement()
        val rs = stat!!.executeQuery("SHOW TABLES")
        val result = rs.next()
        stat!!.close()
        return result
    }

    fun disconnect() {
        conn.close()
        stat!!.close()
    }

    fun isConnected(): Boolean {
        return !conn.isClosed
    }

    fun selectAllFromUPS(): MutableList<String> {
        if (conn.isClosed) {
            throw Exception("Connection closed")
        }
        stat = conn.createStatement()
        val rs = stat!!.executeQuery("SELECT * FROM `ups`")
        val result: MutableList<String> = ArrayList()
        while (rs.next()) {
            result.add(rs.getString("name"))
        }
        stat!!.close()
        return result
    }
}