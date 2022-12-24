package com.midea.light.device.explore.database;


import androidx.room.Database;
import androidx.room.RoomDatabase;

import com.midea.light.device.explore.database.dao.CommonDeviceIconNameDao;
import com.midea.light.device.explore.database.entity.CommonDeviceIconAndNameEntity;


@Database(entities = {CommonDeviceIconAndNameEntity.class}, version = 6, exportSchema = false)
public abstract class DeviceDatabase extends RoomDatabase {
    public abstract CommonDeviceIconNameDao CommonDeviceIconNameDao();
}