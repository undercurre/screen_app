package com.midea.test

import android.os.Bundle
import android.view.View.OnClickListener
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.sp
import com.midea.test.ui.theme.AndroidTheme

class MainActivity : ComponentActivity(){
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContent {
            AndroidTheme {
                // A surface container using the 'background' color from the theme
                Surface(
                    modifier = Modifier.fillMaxSize(),
                    color = MaterialTheme.colorScheme.background
                ) {
                    Greeting("Android",this)
                }
            }
        }

    }
}

@Composable
fun Greeting(name: String, mainActivity: MainActivity) {
    Column {
        Text(text = "Hello $name!", color = Color.Blue)
        Text(text = "Hello $name!", fontSize = 12.sp)
        Text(text = "点击退出", Modifier.clickable(onClick = { mainActivity.finish() }))
    }
}
