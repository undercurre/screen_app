package com.midea.light.ai.AiSpeech;

import android.app.Activity;
import android.app.Dialog;
import android.content.Context;
import android.graphics.Color;
import android.graphics.drawable.ColorDrawable;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.Window;
import android.view.WindowManager;
import android.view.animation.Animation;
import android.view.animation.TranslateAnimation;
import android.widget.LinearLayout;
import android.widget.TextView;

import com.midea.light.ai.R;
import com.midea.light.ai.services.MideaAiService;
import com.midea.light.ai.widget.WaveViewByBezier;

import androidx.annotation.NonNull;

public class AiDialog extends Dialog {

    private LinearLayout llAskAns, ll, llNotify, llAns;
    private LinearLayout llWakeUp;
    private WaveViewByBezier wave;
    private TextView tvAns;
    private MideaAiService sever;


    public Context mContext;


    public AiDialog(@NonNull Context context, MideaAiService sever) {
        super(context);
        this.mContext = context;
        this.sever = sever;
        requestWindowFeature(Window.FEATURE_NO_TITLE);
        View contentView = LayoutInflater.from(mContext).inflate(R.layout.ai_dialog, null, false);
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

    public AiDialog(@NonNull Activity context, int themeResId) {
        super(context, themeResId);
        this.mContext = context;
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

    }


    private void initView() {
        llAskAns = findViewById(R.id.llAskAns);
        llWakeUp = findViewById(R.id.llWakeUp);
        llNotify = findViewById(R.id.llNotify);
        wave = findViewById(R.id.wave);
        ll = findViewById(R.id.ll);
        tvAns = findViewById(R.id.tvAns);
        llAns = findViewById(R.id.llAns);
        Animation animation = new TranslateAnimation(0, 0, 500, 0);
        animation.setDuration(400);//动画时间
        animation.setRepeatCount(0);//动画的反复次数
        animation.setFillAfter(true);//设置为true，动画转化结束后被应用
        llNotify.startAnimation(animation);
        new Thread() {
            @Override
            public void run() {
                try {
                    Thread.sleep(1100);
                    Message msg = new Message();
                    msg.arg1 = 1;
                    mHandler.sendMessage(msg);
                } catch (InterruptedException e) {
                    e.printStackTrace();
                }
            }

        }.start();

    }

    private void initDate() {
        ll.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                sever.out();
                dismissDialog();
            }
        });
    }

    private Handler mHandler = new Handler(new Handler.Callback() {
        @Override
        public boolean handleMessage(Message message) {
            switch (message.arg1) {
                case 1:
                    wave.startAnim();
                    break;
                case 2:
                    if (llWakeUp.getVisibility() != View.VISIBLE) {
                        dismissDialog();
                    }
                    break;

            }
            return true;
        }
    });

    public void think() {
        if (llAskAns != null && llWakeUp != null  && llAns != null) {
            llAskAns.setVisibility(View.VISIBLE);
            llWakeUp.setVisibility(View.GONE);
            llAns.setVisibility(View.INVISIBLE);
        }
    }

    public void addAnsAskItem(String item) {
        tvAns.setText(item);
        llAskAns.setVisibility(View.VISIBLE);
        llWakeUp.setVisibility(View.GONE);
        llAns.setVisibility(View.VISIBLE);


    }


    public void wakeupInitialData() {
        llAskAns.setVisibility(View.GONE);
        llWakeUp.setVisibility(View.VISIBLE);
        if (!isShowing()) {
            Animation animation2 = new TranslateAnimation(0, 0, 500, 0);
            animation2.setDuration(400);//动画时间
            animation2.setRepeatCount(0);//动画的反复次数
            animation2.setFillAfter(true);//设置为true，动画转化结束后被应用
            llNotify.startAnimation(animation2);
        }


    }

    public void timeOut() {
        if (llWakeUp.getVisibility() == View.VISIBLE) {
            return;
        }

        new Thread() {
            @Override
            public void run() {
                try {
                    Thread.sleep(3000);
                    Message msg = new Message();
                    msg.arg1 = 2;
                    mHandler.sendMessage(msg);
                } catch (InterruptedException e) {
                    e.printStackTrace();
                }
            }

        }.start();

    }

    public void dismissDialog() {
        if(sever.mWakUpStateCallBack!=null){
            sever.mWakUpStateCallBack.wakUpState(false);
        }
//        GateWayLightControlUtil.stopLightShow();
        dismiss();
    }

    public void wakeupShow110() {
        llAns.setVisibility(View.VISIBLE);
        llWakeUp.setVisibility(View.GONE);
    }
}
