package com.midea.light.device.explore.database;

import androidx.annotation.NonNull;
import androidx.room.migration.Migration;
import androidx.sqlite.db.SupportSQLiteDatabase;

/**
 * @ClassName MLMigration
 * @Description TODO
 * @Author weinp1
 * @Date 2021/9/26 10:51
 * @Version 1.0
 */


/**
 * 迁移过程中涉及到预填充数据库的低版本问题，可参考官方文档进行处理
 * <p>
 *
 * @see <a href="https://developer.android.google.cn/training/data-storage/room/prepopulate">Room迁移文档</a>
 * </p>
 * 每次调整数据库版本号时，需要考虑两个问题：
 * 1.老用户在旧版本升级到新版本时，数据库采取的迁移数据的策略。包括（不全部）：
 * · 丢弃原有的数据库实例，创建一个新的数据库实例，破坏掉原有数据库的数据
 * · 在原有的数据库实例，进行向下兼容，保留原有数据库的数据
 * 2.新用户安装最新的APK，是否需要考虑数据的预填充。需要考虑预填充数据库的版本号，是否需要进行预填充的数据库升级等
 *
 * <p>
 * 预填充数据库
 * 预填充数据库的生成步骤
 * 1.卸载app, 并重新安装app
 * 2.初始化最新版的数据库实例
 * 3.填充数据到数据库中
 * 4.通过手机系统，导出生成的数据库并重新命名为 'device_info_{$version}.db'最后拼接上版本号
 * 5.重新导入到assets文件中，供数据库初始化时使用
 * </>
 */
public interface MLMigration {

    Migration V_5_6 = new Migration(5, 6) {
        @Override
        public void migrate(@NonNull SupportSQLiteDatabase database) {
            /**
             * 迁移说明：将原本命名的凉霸重新命名为吊顶电器
             */
            database.execSQL("UPDATE `com_device_icon_name` SET name = \'浴霸/凉霸\' WHERE first_code = 40");
            database.execSQL("UPDATE `com_device_icon_name` SET name = \'毛巾架/晾衣架\' WHERE first_code = 17");
            database.execSQL("UPDATE `com_device_icon_name` SET icon = \'http://dsdcp.smartmidea.net/DCP/prod/2021/3/4/66896a07956e4e5781ac607adcc838c4/bb3fafc8c7f34199995e3d57122ab530.png\' WHERE first_code = 17");
        }
    };
}
