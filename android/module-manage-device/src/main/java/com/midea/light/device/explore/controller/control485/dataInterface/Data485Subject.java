package com.midea.light.device.explore.controller.control485.dataInterface;

public interface Data485Subject {
 void registerObserver(Data485Observer observer); // 注册观察者
 void removeObserver(Data485Observer observer); // 移除观察者
 void notifyObservers(String data); // 通知观察者
}
