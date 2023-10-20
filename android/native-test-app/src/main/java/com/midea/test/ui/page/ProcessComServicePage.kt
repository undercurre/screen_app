package com.midea.test.ui.page

import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.ServiceConnection
import android.os.IBinder
import android.util.Log
import android.widget.Toast
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.*
import androidx.compose.runtime.Composable
import androidx.compose.runtime.DisposableEffect
import androidx.compose.runtime.remember
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalContext
import androidx.lifecycle.ViewModel
import com.midea.test.IMyCallback
import com.midea.test.IPcsAidlInterface
import com.midea.test.service.ProcessComService
import java.util.Timer
import java.util.TimerTask

class ProcessComServicePageViewModel(val context: Context) : ViewModel() {

    var binder: IPcsAidlInterface? = null

    private val callback = object: IMyCallback.Stub() {

        override fun onDataChanged(data: String?) {
            Log.i("wnp", "接收到回调数据：${data}");
        }

    }

    val connection = object : ServiceConnection {

        override fun onServiceConnected(name: ComponentName?, service: IBinder?) {
            Log.i("wnp", "Service connected")
            binder = IPcsAidlInterface.Stub.asInterface(service)
            binder?.registerCallback(callback)
        }

        override fun onServiceDisconnected(name: ComponentName?) {
            Log.i("wnp", "Service lose connected with")
            binder = null
//            Timer().apply {
//                schedule(object : TimerTask() {
//                    override fun run() {
//                        initPcs(context)
//                    }
//                }, 1000)
//            }
        }

    }

    fun initPcs(context: Context) {
        val intent = Intent(context, ProcessComService::class.java)
        context.bindService(
            intent,
            connection,
            Context.BIND_IMPORTANT or Context.BIND_AUTO_CREATE
        )
    }

    fun stopPcs(context: Context) {
        try {
            context.unbindService(connection)
            val tempBind = binder
            binder = null
            tempBind?.killProcess()
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

    fun binderTest1() {
        binder?.apply {
            Log.i("wnp", "biner test1 result = ${showDialog()}")
        }
    }

    fun binderTest2() {
        binder?.apply {
            Log.i("wnp", "biner test2 result = ${pid}")
        }
    }

    fun binderTest3() {
        binder?.apply {
            Log.i("wnp", "biner test3 result = ${throwException()}")
        }
    }

    fun binderTest4() {
        try {
            binder?.apply {
                Log.i("wnp", "biner test3 result = ${killProcess()}")
            }
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun ProcessComServicePage(modifier: Modifier = Modifier) {
    val context = LocalContext.current

    val viewModel: ProcessComServicePageViewModel = remember {
        ProcessComServicePageViewModel(context)
    }

    DisposableEffect(Unit) {
        onDispose {

        }
    }
    Scaffold(
        modifier = modifier,
        topBar = { TopAppBar(title = { Text(text = "多进程间通信例子") }) },
        content = { it ->
            Box(Modifier.padding(it), contentAlignment = Alignment.Center) {
                Column(horizontalAlignment = Alignment.CenterHorizontally) {
                    Button(onClick = {
                        viewModel.initPcs(context)
                    }) {
                        Text(text = "初始化进程pcs")
                    }
                    Button(onClick = {
                        viewModel.stopPcs(context)
                    }) {
                        Text(text = "停止进程pcs")
                    }
                    Button(onClick = {
                        viewModel.binderTest1()
                    }) {
                        Text(text = "测试 Binder test1")
                    }

                    Button(onClick = {
                        viewModel.binderTest2()
                    }) {
                        Text(text = "测试 Binder test2")
                    }

                    Button(onClick = {
                        viewModel.binderTest3()
                    }) {
                        Text(text = "测试 Binder test3")
                    }

                    Button(onClick = {
                        viewModel.binderTest4()
                    }) {
                        Text(text = "测试 Binder test4")
                    }
                }
            }
        }
    )
}

