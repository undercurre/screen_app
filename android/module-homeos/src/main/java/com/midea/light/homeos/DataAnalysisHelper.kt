package com.midea.light.homeos

import android.util.Log
import org.json.JSONObject
import java.io.File
import java.io.RandomAccessFile
import java.text.SimpleDateFormat
import java.util.concurrent.Executors
import java.util.concurrent.ScheduledExecutorService
import java.util.concurrent.TimeUnit

val FindEvent = mutableMapOf<String, Long>(
    Pair("start", 0L),
    Pair("end", 0L),
)

val ConnectEvent = mutableMapOf<String, Long>(
    Pair("lose", 0L),
    Pair("connected", 0L),
    Pair("count", 0L)
)



object DataAnalysisHelper {

    var randomAccessFile: RandomAccessFile? = null
    var fileLimit = 30 * 1024 * 1024
    var executorService: ScheduledExecutorService? = null
    var requestTask: MutableMap<String, Long> = mutableMapOf()
    var sdf: SimpleDateFormat = SimpleDateFormat("yyyy-MM-dd HH:mm:ss.SSS")


    init {
        // 初始化文件
        var file = File("/data/data/com.midea.light/cache/controllerLog.txt")
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
        if(randomAccessFile == null || executorService == null) return

        executorService!!.execute{
            if(randomAccessFile!!.length() == 0L) {
                randomAccessFile!!.seek(0L)
            }
            randomAccessFile!!.write("$message\n".toByteArray(Charsets.UTF_8))
            if(randomAccessFile!!.length() > fileLimit) {
                randomAccessFile!!.seek(0)
            }
        }
    }

    /**
     * 事件分析入口
     */
    fun eventLogAnalysisEntrance(event: String) {
        if(randomAccessFile == null || executorService == null) return
        executorService!!.execute {

            if("discover send controller" == event
                || "replay host info controller" == event) {
                FindEvent["start"] = System.currentTimeMillis()
            } else if("recv host udp discover" == event
                || "recv host broastcast discover" == event) {
                FindEvent["end"] = System.currentTimeMillis()
                record("[探针UDP包] ${sdf.format(FindEvent["start"])} 到 ${sdf.format(FindEvent["end"])}")
            }

            if("connectLost" == event) {
                ConnectEvent["lose"] = System.currentTimeMillis()
                ConnectEvent["count"] = ConnectEvent["count"]!! + 1
                record("[连接] 断开 ${sdf.format(ConnectEvent["lose"])} 次数${ConnectEvent["count"]}")
            } else if("connectOk" == event) {
                ConnectEvent["connected"] = System.currentTimeMillis()
                record("[连接] 成功 ${sdf.format(ConnectEvent["connected"])}}")
            }


        }
    }

    /**
     * 设备状态上报数据分析入口
     */
    fun dataLogAnalysisEntrance(message: String) {
        if(randomAccessFile == null || executorService == null) return
        executorService!!.execute {
            var jsonObject = JSONObject(message)
            var requestId = jsonObject.optString("reqId")
            var ts = jsonObject.optString("ts")
            var topic = jsonObject.optString("topic")
            if("/local/subdeviceControl/ack" == topic) {
                controlReply(requestId, "设备控制")
            } else if("/local/groupControl/ack" == topic) {
                controlReply(requestId, "灯组控制")
            } else if("/local/sceneExcute/ack" == topic) {
                controlReply(requestId, "场景控制")
            }
        }
    }

    fun deviceControl(requestId: String, deviceId: String, action: String) {
        analysisControl(requestId, "设备控制")
    }

    fun groupControl(requestId: String, device: String, action: String) {
        analysisControl(requestId, "灯组控制")
    }

    fun sceneExcute(requestId: String, sceneId: String) {
        analysisControl(requestId, "场景控制")
    }

    private fun analysisControl(requestId: String, tag: String) {
        if(randomAccessFile == null || executorService == null) return
        executorService!!.execute {
            requestTask[requestId] = System.currentTimeMillis()
        }
        executorService!!.schedule(
            {
                if(requestTask.containsKey(requestId)) {
                    val startTime = requestTask.get(requestId) ?: System.currentTimeMillis()
                    val endTime = System.currentTimeMillis()
                    record("[$tag] #${requestId} 超时")
                    requestTask.remove(requestId)
                }
            },8, TimeUnit.SECONDS
        )
    }

    private fun controlReply(requestId: String, tag: String) {
        executorService!!.execute {
            if(requestTask.containsKey(requestId)) {
                var startTime = requestTask.get(requestId) ?: System.currentTimeMillis()
                var endTime = System.currentTimeMillis()
                record("[$tag] #${requestId} 正常 ${sdf.format(startTime)} 到${sdf.format(endTime)}")
                requestTask.remove(requestId)
            }
        }
    }


}