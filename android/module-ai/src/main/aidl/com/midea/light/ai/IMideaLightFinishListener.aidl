// IMideaLightFinishListener.aidl
package com.midea.light.ai;

// Declare any non-default types here with import statements

interface IMideaLightFinishListener {
        void onAllFinish();
        void onNextPartStart();
        void onLastPartEnd();
}