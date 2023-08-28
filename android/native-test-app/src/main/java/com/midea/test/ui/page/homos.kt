package com.midea.test.ui.page

import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.*
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalContext
import com.midea.light.homeos.HomeOsClient
import com.midea.light.homeos.controller

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun Homos(modifier: Modifier = Modifier) {
    val context = LocalContext.current
    Scaffold(
        modifier = modifier,
        topBar = { TopAppBar(title = { Text(text = "首頁") }) },
        content = { it ->
            Box(Modifier.padding(it), contentAlignment = Alignment.Center) {
                Column(horizontalAlignment = Alignment.CenterHorizontally) {
                    Button(onClick = {
                        initHomos();
                    }) {
                        Text(text = "初始化Homos")
                    }
                }
            }
        }
    )
}

fun initHomos() {
    HomeOsClient.getOsController().init()
    HomeOsClient.getOsController().login("123", "456")
    HomeOsClient.getOsController().logout()
    HomeOsClient.getOsController().deviceInfo
    HomeOsClient.getOsController().groupInfo
    HomeOsClient.getOsController().sceneInfo
}