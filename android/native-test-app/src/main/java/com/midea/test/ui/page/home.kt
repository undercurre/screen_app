package com.midea.test.ui.page

import android.content.Context
import android.media.MediaPlayer
import android.net.Uri
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.*
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Alignment.Companion.Center
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalContext
import java.io.IOException


/**
 * @ClassName home
 * @Description 首页
 * @Author weinp1
 * @Date 2023/3/21 19:54
 * @Version 1.0
 */


@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun Home(modifier: Modifier = Modifier) {
    val context = LocalContext.current
    Scaffold(
        modifier = modifier,
        topBar = { TopAppBar(title = { Text(text = "首頁") }) },
        content = { it ->
            Box(Modifier.padding(it), contentAlignment = Center) {
                Column(horizontalAlignment = Alignment.CenterHorizontally) {
                    Button(onClick = {
                        loadRingtone(context)
                    }) {
                        Text(text = "填充Ringtone")
                    }
                    Button(onClick = {
                        playRingtone(context)
                    }) {
                        Text(text = "播放")
                    }
                    Button(onClick = {
                        stopRingtone(context)
                    }) {
                        Text(text = "暂停")
                    }
                    Button(onClick = {
                        loop5PlayRingtone(context)
                    }) {
                        Text(text = "循环播放五次")
                    }
                }
            }
        }
    )
}

fun loadRingtone(context: Context) {

}

fun playRingtone(context: Context) {}

fun stopRingtone(context: Context) {}

fun loop5PlayRingtone(context: Context) {}

