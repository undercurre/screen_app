package com.midea.light.device.explore.database;

import androidx.annotation.NonNull;
import androidx.room.Room;
import androidx.room.RoomDatabase;
import androidx.sqlite.db.SupportSQLiteDatabase;

import com.midea.light.BaseApplication;
import com.midea.light.device.explore.database.entity.CommonDeviceIconAndNameEntity;
import com.midea.light.log.LogUtil;

/**
 * @ClassName DeviceDatabaseHelper
 * @Description
 * @Author weinp1
 * @Date 2021/7/19 21:50
 * @Version 1.0
 */
public class DeviceDatabaseHelper {

    private DeviceDatabaseHelper() {

    }

    static DeviceDatabaseHelper helper;
    DeviceDatabase deviceDatabase;
    boolean init = false;

    public synchronized void init() {
        if (init) {
            return;
        }
        deviceDatabase = Room
                .databaseBuilder(BaseApplication.getContext(), DeviceDatabase.class, "find_device.db")
                .createFromAsset("databases/device_info_5.db", new RoomDatabase.PrepackagedDatabaseCallback() {
                    @Override
                    public void onOpenPrepackagedDatabase(@NonNull SupportSQLiteDatabase db) {
                        super.onOpenPrepackagedDatabase(db);
                        LogUtil.i("device_info_5.db Open Prepackaged Database");
                    }
                })
                .addMigrations(MLMigration.V_5_6)
                .build();
        init = true;
    }

    public static synchronized DeviceDatabaseHelper getInstant() {
        if (helper == null) {
            helper = new DeviceDatabaseHelper();
        }
        return helper;
    }

    public CommonDeviceIconAndNameEntity finDeviceInCommon(String code) {
        return deviceDatabase.CommonDeviceIconNameDao().find(code);
    }
}
