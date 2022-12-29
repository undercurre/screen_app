package com.midea.light.device.explore.database.dao;


import androidx.room.Dao;
import androidx.room.Query;

import com.midea.light.device.explore.database.entity.CommonDeviceIconAndNameEntity;


/**
 * @ClassName CommonDeviceIconNameDao
 * @Description 通用型设备图标与名称。针对设备类别，挑选出通用的设备图标和设备名称
 * @Author weinp1
 * @Date 2021/11/25 16:57
 * @Version 1.0
 */
@Dao
public interface CommonDeviceIconNameDao {

    @Query("select * from com_device_icon_name where upper(first_code) = upper(:code)  ORDER BY id ASC LIMIT 1")
    CommonDeviceIconAndNameEntity find(String code);

}
