package com.midea.test;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.provider.Settings;
import android.widget.Button;

import androidx.annotation.Nullable;

public class StartServiceActivity extends Activity {



    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.start_service_layout);
        Button button=findViewById(R.id.button);
        Button button2=findViewById(R.id.button2);
        Button button3=findViewById(R.id.button3);

        button2.setOnClickListener(v->{
            Intent intent =  new Intent(Settings.ACTION_SETTINGS);
            startActivity(intent);
        });
        button3.setOnClickListener(v->{
            finish();
        });
        if (!Settings.canDrawOverlays(this)) {
            Intent intent = new Intent();
            intent.setAction(Settings.ACTION_MANAGE_OVERLAY_PERMISSION);
            startActivity(intent);
        }
    }


}
