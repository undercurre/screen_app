package com.midea.light.homeos;

import android.util.Log;

import java.util.concurrent.Executors;
import java.util.concurrent.LinkedBlockingQueue;
import java.util.concurrent.ScheduledExecutorService;
import java.util.concurrent.TimeUnit;

/**
 * 消息处理辅助类。用于调整处理HomOS传输数据的处理效率，防止频繁处理导致程序卡死或者崩溃
 * 存在两个挡位控制消息处理速度。
 * <pre>
 *     // 消息缓冲队列
 *     var messageQueue = MessageQueue(object : MessageQueue.Callback {
 *
 *         override fun filter(topic: String?, message: String?): Boolean {
 *             // 是否将此消息插入消息队列中。false则会丢弃该消息处理
 *             return true
 *         }
 *
 *         override fun handler(msg: String?) {
 *             val topic = "暂未用到字段"
 *             // 处理消息
 *         }
 *
 *     })
 *     // 启动运行
 *     messageQueue.start();
 *     // 停止运行
 *     messageQueue.stop();
 *     // 调整到缓慢模式
 *     messageQueue.adjustSpeedToLow();
 *     // 调整到正常模式
 *     messageQueue.adjustSpeedToNormal();
 *     // HomOS消息过来时，将消息入队
 *     messageQueue.addMessage(topic, msg);
 * </pre>
 * <p>
 *     正常模式与缓慢模式
 *     <ul>
 *         <li>正常模式：每秒处理10条消息 设备正常使用时，可启动此模式</li>
 *         <li>缓慢模式：每秒处理1条消息 设备在睡眠时，可启动此模式</li>
 *     </ul>
 * </p>
 */
public class MessageQueue {

    /**
     * 消息处理回调
     */
    public interface Callback {
        /**
         * 队列满了，该消息是否可以丢弃
         * @param topic
         * @param message HomOS返回的数据
         * @return false 则忽略此数据
         */
        boolean filter(String topic, String message);

        /**
         * 处理消息
         * @param message HomOS返回的数据
         */
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

    /**
     * 调整处理速率到正常
     */
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

    /**
     * 启动
     */
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

    /**
     * 停止
     */
    public void stop() {
        if(isStart) {
            isStart = false;
            isStop = true;
            Log.i("homlux-lan", "暂停缓冲队列");
            executor.shutdown();
        }
    }

    /**
     * 将HomOS发送过来数据填充到消息队列中
     * @param topic 消息主题
     * @param message 消息体
     * @throws InterruptedException
     */
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
