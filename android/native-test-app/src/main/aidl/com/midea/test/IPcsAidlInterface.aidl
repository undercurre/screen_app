// IPcsAidlInterface.aidl
package com.midea.test;
import com.midea.test.IMyCallback;
// Declare any non-default types here with import statements

interface IPcsAidlInterface {
    /**
     * Demonstrates some basic types that you can use as parameters
     * and return values in AIDL.
     */
    void basicTypes(int anInt, long aLong, boolean aBoolean, float aFloat,
            double aDouble, String aString);
    /**
    * 获取当前进程ID
    */
    int getPid();

    void showDialog();

    void throwException();

    void killProcess();

     void registerCallback(IMyCallback callback);

     void unregisterCallback(IMyCallback callback);

}