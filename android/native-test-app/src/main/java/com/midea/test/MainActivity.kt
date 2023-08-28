package com.midea.test

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.compose.material3.MaterialTheme
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.navigation.NavHostController
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import androidx.navigation.compose.rememberNavController
import com.midea.test.ui.page.Home
import com.midea.test.ui.page.Homos
import com.midea.test.ui.theme.AndroidTheme

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContent {
            AndroidTheme {
                MyAppNavHost()
            }
        }
    }
}

@Composable
fun MyAppNavHost(modifier: Modifier = Modifier,
                 navController: NavHostController = rememberNavController(),
                 startDestination: String = "profile") {
    NavHost(modifier = modifier, navController = navController, startDestination = "homos") {
        composable("/") { Home() }
        composable("homos") { Homos() }
    }
}
