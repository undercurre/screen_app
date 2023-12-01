package com.midea.light.ai.AiSpeech;

import android.app.Activity;
import android.app.Dialog;
import android.content.Context;
import android.graphics.Color;
import android.graphics.drawable.ColorDrawable;
import android.icu.util.Calendar;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.text.TextUtils;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.Window;
import android.view.WindowManager;
import android.widget.ImageView;
import android.widget.RelativeLayout;
import android.widget.TextView;

import androidx.annotation.NonNull;

import com.midea.light.ai.R;
import com.midea.light.ai.services.MideaAiService;

public class WeatherDialog extends Dialog {

    private RelativeLayout llParent;
    private TextView tvPlace, tvLowTemp, tvHighTemp, tvWeather, tvLevel;
    private MideaAiService sever;
    private ImageView imgWeatherIcon;


    public Context mContext;


    public WeatherDialog(@NonNull Context context, MideaAiService sever) {
        super(context);
        this.mContext = context;
        this.sever = sever;
        requestWindowFeature(Window.FEATURE_NO_TITLE);
        View contentView = LayoutInflater.from(mContext).inflate(R.layout.ai_weather_dialog, null, false);
        setContentView(contentView);
        setCanceledOnTouchOutside(true);
        //设置window背景，默认的背景会有Padding值，不能全屏。当然不一定要是透明，你可以设置其他背景，替换默认的背景即可。
        getWindow().setBackgroundDrawable(new ColorDrawable(Color.TRANSPARENT));
        //一定要在setContentView之后调用，否则无效
        getWindow().setLayout(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT);
        getWindow().setType(WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY);
        initView();
        initDate();
    }

    public WeatherDialog(@NonNull Activity context, int themeResId) {
        super(context, themeResId);
        this.mContext = context;
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

    }

    private void initView() {
        tvPlace = findViewById(R.id.tvPlace);
        tvLowTemp = findViewById(R.id.tvLowTemp);
        llParent = findViewById(R.id.llParent);
        tvHighTemp = findViewById(R.id.tvHighTemp);
        tvWeather = findViewById(R.id.tvWeather);
        tvLevel = findViewById(R.id.tvLevel);
        imgWeatherIcon = findViewById(R.id.imgWeatherIcon);
        llParent.setBackground(null);

    }

    private void initDate() {
        llParent.setOnClickListener(view -> {
            sever.out();
            dismissDialog();
        });
    }

    public void dismissDialog() {
        dismiss();
    }

    public void timeOut() {
        new Thread(() -> {
            try {
                Thread.sleep(3000);
                Message msg = new Message();
                msg.arg1 = 1;
                mHandler.sendMessage(msg);
            } catch (InterruptedException e) {
                e.printStackTrace();
            }
        }).start();

    }

    private Handler mHandler = new Handler(message -> {
        switch (message.arg1) {
            case 1:
                dismissDialog();
                break;

        }
        return true;
    });

    public void setWeatherDetail(String place, String low, String high, String weather, String level) {
        tvPlace.setText(place);
        tvLowTemp.setText(low);
        tvHighTemp.setText(high);
        tvWeather.setText(weather);
        tvLevel.setText(level);
        if (TextUtils.isEmpty(weather)) {
            return;
        }
        if (weather.contains("雨") && weather.contains("雪")) {
            llParent.setBackground(getContext().getResources().getDrawable(R.drawable.rain_snow_bk));
            imgWeatherIcon.setImageResource(R.drawable.rain_snow_icon);
        } else if (weather.contains("晴")) {
            llParent.setBackground(getContext().getResources().getDrawable(R.drawable.sun_bk));
            imgWeatherIcon.setImageResource(R.drawable.sun_icon);
        } else if (weather.contains("雪")) {
            if(isDayOrNight()){
                llParent.setBackground(getContext().getResources().getDrawable(R.drawable.snow_bk));
                imgWeatherIcon.setImageResource(R.drawable.snow_icon);
            }else {
                llParent.setBackground(getContext().getResources().getDrawable(R.drawable.snow_night_bk));
                imgWeatherIcon.setImageResource(R.drawable.snow_night_icon);
            }
        } else if (weather.contains("雷")) {
            llParent.setBackground(getContext().getResources().getDrawable(R.drawable.thunderstorm_bk));
            imgWeatherIcon.setImageResource(R.drawable.thunderstorm_icon);
        } else if (weather.contains("阴")||weather.contains("霾")) {
            llParent.setBackground(getContext().getResources().getDrawable(R.drawable.overcast_bk));
            imgWeatherIcon.setImageResource(R.drawable.overcast_icon);
        } else if (weather.contains("云")) {
            llParent.setBackground(getContext().getResources().getDrawable(R.drawable.cloud_bk));
            imgWeatherIcon.setImageResource(R.drawable.cloud_icon);
        } else if (weather.contains("雨")) {
            if(isDayOrNight()){
                llParent.setBackground(getContext().getResources().getDrawable(R.drawable.rainy_bk));
                imgWeatherIcon.setImageResource(R.drawable.rainy_icon);
            }else {
                llParent.setBackground(getContext().getResources().getDrawable(R.drawable.rain_night_bk));
                imgWeatherIcon.setImageResource(R.drawable.rain_night_icon);
            }
        }else{
            llParent.setBackground(getContext().getResources().getDrawable(R.drawable.overcast_bk));
            imgWeatherIcon.setImageResource(R.drawable.overcast_icon);
        }
    }

    /**
     * true day 白天   return false晚上
     * @return
     */
    public  boolean isDayOrNight() {
        if (get24HourMode()) {
            //24小时制
            Calendar c = Calendar.getInstance();
            int currHour =  c.get(c.HOUR_OF_DAY);
            if (currHour >= 6 && currHour < 18){
                return true;
            }
        } else {
            //12小时制
            Calendar c = Calendar.getInstance();
            int currHour = c.get(c.HOUR);
            if (c.get(Calendar.AM_PM) == 0) {
                //上午
                if (currHour >=6 && currHour <= 12){
                    return true;
                }
            } else {
                //下午
                if (currHour >=0 && currHour < 6){
                    return true;
                }
            }
        }
        return false;
    }
    //返回true是24小时制，否则是12小时制
    public  boolean get24HourMode() {
        return android.text.format.DateFormat.is24HourFormat(getContext());
    }



}
