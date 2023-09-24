package com.midea.light.homeos;

import android.util.Log;

import java.util.concurrent.Executors;
import java.util.concurrent.LinkedBlockingQueue;
import java.util.concurrent.ScheduledExecutorService;
import java.util.concurrent.TimeUnit;

public class MessageQueue {

    public interface Callback {
        // 队列满了，消息是否可以丢弃
        boolean filter(String topic, String message);
        // 处理消息
        void handler(String message);
    }
    public static final int MAX_CAPACITY = 2000;
    public static final int PER_EXECUTE_CAP = 2;
    public static final int NORMAL_PROCESS_INTERVAL = 200;

    public static final int LOW_PROCESS_INTERVAL = 2000;

    private final LinkedBlockingQueue<String> queue;
    private ScheduledExecutorService executor;

    private final Callback callback;

    private boolean isStart = false;
    private boolean isStop = true;


    public MessageQueue(Callback callback) {
        this.callback = callback;
        queue = new LinkedBlockingQueue<>(MAX_CAPACITY);
    }

    // 调整处理速率到慢速
    public void adjustSpeedToLow() {
        if(isStart) {
            stop();
            executor = Executors.newScheduledThreadPool(1, r -> {
                Thread t = new Thread(r);
                t.setName("message-control");
                return t;
            });
            executor.scheduleAtFixedRate(this::processHandle, 0, LOW_PROCESS_INTERVAL, TimeUnit.MILLISECONDS);
            isStart = true;
            isStop = false;
            Log.i("homlux-lan", "调整速率到缓慢");
        }
    }

    // 调整处理速率到正常
    public void adjustSpeedToNormal() {
        if(isStart) {
            stop();
            executor = Executors.newScheduledThreadPool(1, r -> {
                Thread t = new Thread(r);
                t.setName("message-control");
                return t;
            });
            executor.scheduleAtFixedRate(this::processHandle, 0, NORMAL_PROCESS_INTERVAL, TimeUnit.MILLISECONDS);
            isStart = true;
            isStop = false;
            Log.i("homlux-lan", "调整速率到正常");
        }
    }

    public void start() {
        if(isStop) {
            Log.i("homlux-lan", "启动缓冲队列");
            executor = Executors.newScheduledThreadPool(1, r -> {
                Thread t = new Thread(r);
                t.setName("message-control");
                return t;
            });
            executor.scheduleAtFixedRate(this::processHandle, 0, NORMAL_PROCESS_INTERVAL, TimeUnit.MILLISECONDS);
            isStart = true;
            isStop = false;
        }
    }

    public void stop() {
        if(isStart) {
            isStart = false;
            isStop = true;
            Log.i("homlux-lan", "暂停缓冲队列");
            executor.shutdown();
        }
    }

    /// 子线程中执行
    public void addMessage(String topic, String message) throws InterruptedException {
        if(!queue.offer(message)) {
            String _message = queue.peek();
            boolean filter = callback.filter(topic, _message);
            if(filter) {
                queue.poll();
                boolean result = queue.offer(message);
                Log.i("homlux-lan", "移除消息" + _message + "添加消息" + message + (result ? "成功" : "失败"));
            } else {
                queue.put(message);
            }
        }
    }

    private void processHandle() {
        int count = 0;
        while (count < PER_EXECUTE_CAP) {
            String message = queue.poll();
            if(message == null) {
                break;
            }
            // 处理业务逻辑
            callback.handler(message);
            count++;
        }
    }
}
