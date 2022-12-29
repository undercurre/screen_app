package com.midea.light.device.explore.database.entity;

import androidx.room.ColumnInfo;
import androidx.room.Entity;
import androidx.room.PrimaryKey;

/**
 * @ClassName CommonDeviceIconAndNameEntity
 * @Description
 * @Author weinp1
 * @Date 2021/11/25 16:59
 * @Version 1.0
 */
@Entity(tableName = "com_device_icon_name")
public class CommonDeviceIconAndNameEntity {
    @PrimaryKey(autoGenerate = true)
    public int id;
    @ColumnInfo(name = "first_code")
    public String firstLevelCategoryCode;
    @ColumnInfo(name = "icon")
    public String icon;
    @ColumnInfo(name = "name")
    public String name;
}
