package com.midea.homlux.ai.AiSpeech;

import android.app.Activity;
import android.app.Dialog;
import android.content.Context;
import android.graphics.Color;
import android.graphics.drawable.ColorDrawable;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.Window;
import android.view.WindowManager;
import android.view.animation.Animation;
import android.view.animation.AnimationUtils;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;
import android.widget.TextView;

import androidx.annotation.NonNull;

import com.aispeech.dui.dds.DDS;
import com.aispeech.dui.dds.exceptions.DDSNotInitCompleteException;
import com.github.penfeizhou.animation.apng.APNGDrawable;
import com.github.penfeizhou.animation.loader.ResourceStreamLoader;
import com.midea.homlux.ai.services.MideaAiService;
import com.midea.light.ai.R;

public class AiDialog extends Dialog {

    private LinearLayout llBollBack, llLarge;
    private RelativeLayout llParent;
    private TextView tvAi,tvNoticeString,tvLarge;
    private MideaAiService sever;
    private ImageView imgBoll;
    private boolean isFirstWakeUpInDuplexMode=true;


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

    @Override
    public void show() {
        super.show();
        tvAi.setVisibility(View.GONE);
        tvLarge.setVisibility(View.GONE);
        llBollBack.setBackground(null);
        Animation animation = AnimationUtils.loadAnimation(mContext, R.anim.anim_scale_in);
        imgBoll.startAnimation(animation);
        animation.setAnimationListener(new Animation.AnimationListener() {
            @Override
            public void onAnimationStart(Animation animation) {

            }

            @Override
            public void onAnimationEnd(Animation animation) {
                ResourceStreamLoader resourceLoader = new ResourceStreamLoader(mContext, R.raw.ai_boll);
                APNGDrawable apngDrawable = new APNGDrawable(resourceLoader);
                apngDrawable.setLoopLimit(-1);
                imgBoll.setImageDrawable(apngDrawable);
            }

            @Override
            public void onAnimationRepeat(Animation animation) {

            }
        });
    }

    private void initView() {
        llBollBack = findViewById(R.id.llBollBack);
        llLarge = findViewById(R.id.llLarge);
        llParent = findViewById(R.id.llParent);
        tvAi = findViewById(R.id.tvAi);
        tvNoticeString = findViewById(R.id.tvNoticeString);
        imgBoll= findViewById(R.id.imgBoll);
        tvLarge= findViewById(R.id.tvLarge);
        llBollBack.setBackground(null);
        tvNoticeString.setVisibility(View.VISIBLE);
        llLarge.setVisibility(View.GONE);


    }

    private void initDate() {
        llParent.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
//                sever.out();
                try {
                    DDS.getInstance().getAgent().stopDialog();
                } catch (DDSNotInitCompleteException e) {
                    e.printStackTrace();
                }
                dismissDialog();
            }
        });
    }

    public void think() {

    }

    public void initalDialog() {
        tvAi.setVisibility(View.GONE);
        tvLarge.setVisibility(View.GONE);
        llBollBack.setBackground(null);
    }

    public void addAnsAskItem(String item) {
        if(item.length()>15){
            tvAi.setVisibility(View.GONE);
            tvNoticeString.setVisibility(View.GONE);
            llBollBack.setBackground(mContext.getDrawable(R.drawable.ai_text_large_bg));
            tvLarge.setText(item);
            tvLarge.setVisibility(View.VISIBLE);
            llLarge.setVisibility(View.VISIBLE);
            if(item.length()>300){
                LinearLayout.LayoutParams lp = (LinearLayout.LayoutParams) llLarge.getLayoutParams();
                lp.height=270;
                llLarge.setLayoutParams(lp);
            }
        }else{
            tvAi.setVisibility(View.VISIBLE);
            tvNoticeString.setVisibility(View.VISIBLE);
            llBollBack.setBackground(mContext.getDrawable(R.drawable.ai_text_bg));
            llLarge.setVisibility(View.GONE);
            tvAi.setText(item);
        }

    }


    public void wakeupInitialData() {
        tvNoticeString.setVisibility(View.VISIBLE);
        llBollBack.setBackground(null);
        llLarge.setVisibility(View.GONE);
        tvAi.setVisibility(View.GONE);

    }


    public void dismissDialog() {
//        if(sever.mWakUpStateCallBack!=null){
//            sever.mWakUpStateCallBack.wakUpState(false);
//        }
        dismiss();
    }

    public void wakeupShow110() {
        tvNoticeString.setVisibility(View.VISIBLE);
        llBollBack.setBackground(null);
        llLarge.setVisibility(View.GONE);
        tvAi.setVisibility(View.GONE);

    }

}
