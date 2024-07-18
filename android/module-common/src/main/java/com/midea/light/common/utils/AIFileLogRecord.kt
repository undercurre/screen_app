package com.midea.light.common.utils

import android.util.Log
import org.json.JSONObject
import java.io.File
import java.io.RandomAccessFile
import java.text.SimpleDateFormat
import java.util.concurrent.Executors
import java.util.concurrent.ScheduledExecutorService
import java.util.concurrent.TimeUnit

object AIFileLogRecord {

    var randomAccessFile: RandomAccessFile? = null
    var fileLimit = 30 * 1024 * 1024
    var executorService: ScheduledExecutorService? = null
    var sdf: SimpleDateFormat = SimpleDateFormat("MM-dd HH:mm:ss.SSS")


    init {
        // 初始化文件
        var file = File("/data/data/com.midea.light/cache/AIMideaLog.txt")
        var createFileSuc = true
        if(!file.exists()) {
            var dir = file.parentFile!!
            if(!dir.exists()) {
                if(dir.mkdirs() && file.createNewFile()) {
                    Log.i(this.javaClass.simpleName, "创建文件成功")
                } else {
                    Log.i(this.javaClass.simpleName, "创建文件失败")
                    createFileSuc = false
                }
            }
        }
        if(createFileSuc) {
            randomAccessFile = RandomAccessFile(file, "rws")
            if(randomAccessFile!!.length() > fileLimit) {
                randomAccessFile!!.seek(0)
            }
            executorService =  Executors.newSingleThreadScheduledExecutor()
        }
    }

    fun record(message: String) {
        if (randomAccessFile == null || executorService == null) return

        executorService!!.execute {
            if (randomAccessFile!!.length() == 0L) {
                randomAccessFile!!.seek(0L)
            }
            randomAccessFile!!.write("${sdf.format(System.currentTimeMillis())} $message\n".toByteArray(Charsets.UTF_8))
            if (randomAccessFile!!.length() > fileLimit) {
                randomAccessFile!!.seek(0)
            }
        }
    }

}