package com.midea.light.push;

import android.content.Context;
import android.util.Log;

import com.alibaba.sdk.android.push.MessageReceiver;
import com.alibaba.sdk.android.push.notification.CPushMessage;
import com.midea.light.channel.Channels;
import com.midea.light.channel.method.AliPushChannel;

import java.util.Iterator;
import java.util.Map;
import java.util.Set;
import java.util.WeakHashMap;

import io.reactivex.rxjava3.functions.Consumer;

public class AliPushReceiver extends MessageReceiver {
    private AliPushChannel mChannel;

    public AliPushReceiver(AliPushChannel channel) {
        mChannel = channel;
    }

    public static final String REC_TAG = "receiver";

    @Override
    protected void onNotification(Context context, String title, String summary, Map<String, String> extraMap) {
        // TODO 处理推送通知
        Log.i("aliPushLog", "Receive notification, title: " + title + ", summary: " + summary + ", extraMap: " + extraMap);
        mChannel.notifyPushMessage(title);
    }

    @Override
    protected void onMessage(Context context, CPushMessage cPushMessage) {
        Log.i("aliPushLog", "onMessage, messageId: " + cPushMessage.getMessageId() + ", title: " + cPushMessage.getTitle() + ", content:" + cPushMessage.getContent());
        mChannel.notifyPushMessage(cPushMessage.getTitle());
    }

    @Override
    protected void onNotificationOpened(Context context, String title, String summary, String extraMap) {
        Log.i("aliPushLog", "onNotificationOpened, title: " + title + ", summary: " + summary + ", extraMap:" + extraMap);
    }

    @Override
    protected void onNotificationClickedWithNoAction(Context context, String title, String summary, String extraMap) {
        Log.i("aliPushLog", "onNotificationClickedWithNoAction, title: " + title + ", summary: " + summary + ", extraMap:" + extraMap);
    }
    @Override
    protected void onNotificationReceivedInApp(Context context, String title, String summary, Map<String, String> extraMap, int openType, String openActivity, String openUrl) {
        Log.i("aliPushLog", "onNotificationReceivedInApp, title: " + title + ", summary: " + summary + ", extraMap:" + extraMap + ", openType:" + openType + ", openActivity:" + openActivity + ", openUrl:" + openUrl);
    }
    @Override
    protected void onNotificationRemoved(Context context, String messageId) {
        Log.i("aliPushLog", "onNotificationRemoved");
    }

}
