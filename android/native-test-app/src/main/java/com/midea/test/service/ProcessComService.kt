package com.midea.test.service

import android.app.ActivityManager
import android.app.AlertDialog
import android.app.Service
import android.content.Context
import android.content.Intent
import android.os.Handler
import android.os.IBinder
import android.os.Looper
import android.util.Log
import android.view.WindowManager
import android.widget.Toast
import com.midea.test.IMyCallback
import com.midea.test.IPcsAidlInterface

fun getCurProcessName(context: Context, pid: Int): String {
    val manager = context.getSystemService(Context.ACTIVITY_SERVICE) as ActivityManager
    for (processInfo in manager.runningAppProcesses) {
        if (processInfo.pid == pid) {
            println("Process Name: " + processInfo.processName)
            return processInfo.processName;
        }
    }
    return "未知进程";
}

class ProcessComService : Service() {

    private val binder = object: IPcsAidlInterface.Stub() {

        var callback: IMyCallback? = null;

        override fun basicTypes(
            anInt: Int,
            aLong: Long,
            aBoolean: Boolean,
            aFloat: Float,
            aDouble: Double,
            aString: String?
        ) {

        }

        override fun getPid(): Int {
            return android.os.Process.myPid()
        }

        override fun showDialog() {
            val handler = Handler(Looper.getMainLooper())
            handler.post {
                Log.i("wnp", "showDialog")
                callback?.onDataChanged("你好客户端")
                Toast.makeText(this@ProcessComService, "点击成功", Toast.LENGTH_SHORT).show()
                val builder: AlertDialog.Builder = AlertDialog.Builder(applicationContext)
                builder.setTitle("Title")
                    .setMessage("Message")
                    .setPositiveButton("OK"
                    ) { dialog, which ->
                        // 点击 OK 按钮后的操作
                        dialog.cancel()
                        Toast.makeText(this@ProcessComService, "点击成功", Toast.LENGTH_SHORT).show()
                    }
                    .setNegativeButton("Cancel") { dialog, which ->
                        // 点击 OK 按钮后的操作
                        dialog.cancel()
                        Toast.makeText(this@ProcessComService, "点击成功", Toast.LENGTH_SHORT).show()
                    }
                val dialog: AlertDialog = builder.create()
//            dialog.window!!.setType(WindowManager.LayoutParams.TYPE_SYSTEM_ALERT)
                dialog.window!!.setType(WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY)
                dialog.show()
            }
        }

        override fun throwException() {
            throw RuntimeException("执行异常")
        }

        override fun killProcess() {
            android.os.Process.killProcess(android.os.Process.myPid());
        }

        override fun registerCallback(callback: IMyCallback?) {
            this.callback = callback;
        }

        override fun unregisterCallback(callback: IMyCallback?) {
            this.callback = callback;
        }

    }

    override fun onBind(intent: Intent): IBinder {
        return binder;
    }

    override fun onCreate() {
        super.onCreate()
        Log.i("wnp", "ProcessComService onCreate")
        Log.i("wnp", "ProcessComService -> ${getCurProcessName(this, android.os.Process.myPid())}")
    }


    override fun onDestroy() {
        super.onDestroy()
        Log.i("wnp", "ProcessComService onDestroy")
    }


}