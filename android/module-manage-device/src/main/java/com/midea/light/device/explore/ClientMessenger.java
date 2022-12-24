package com.midea.light.device.explore;
import android.os.RemoteException;

import java.util.Objects;

/**
 * @ClassName ClientMessenger
 * @Description 二次封装android.os.Messenger类
 * @Author weinp1
 * @Date 2021/8/8 13:45
 * @Version 1.0
 */
public class ClientMessenger {
    android.os.Messenger mMessenger;
    android.os.Bundle requestData;

    public static ClientMessenger wrap(android.os.Messenger messenger) {
        return new ClientMessenger(messenger);
    }

    public ClientMessenger request(android.os.Bundle bundle) {
        setRequestData(bundle);
        return this;
    }

    public ClientMessenger(android.os.Messenger messenger) {
        this.mMessenger = messenger;
    }

    public void setRequestData(android.os.Bundle bundle) {
        requestData = bundle;
    }

    public void send(android.os.Message responseMessage) throws RemoteException {
        if (responseMessage.getData() == null) {
            throw new IllegalArgumentException("非法响应数据，必须带Bundle");
        }
        android.os.Bundle bundle = responseMessage.getData();
        bundle.putAll(requestData);
        this.mMessenger.send(responseMessage);
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass())
            return false;
        ClientMessenger that = (ClientMessenger) o;
        return Objects.equals(mMessenger, that.mMessenger);
    }

    public android.os.Messenger getAndroidOsMessenger() {
        return mMessenger;
    }

    @Override
    public int hashCode() {
        return Objects.hash(mMessenger);
    }
}
