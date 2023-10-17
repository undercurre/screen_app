package com.midea.light.common.utils;

import android.content.Intent;
import android.content.pm.PackageInfo;
import android.content.pm.PackageManager;
import android.os.Environment;

import com.midea.light.BaseApplication;

import java.io.File;

public class DataClearManager {

    /**
     * 重启APP
     */
    public static void restartApp() {
        final Intent intent = BaseApplication.getContext().getPackageManager().getLaunchIntentForPackage(BaseApplication.getContext().getPackageName());
        if (null != intent) {
            intent.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP);
            BaseApplication.getContext().startActivity(intent);
        }
        // 杀死以前的进程
        android.os.Process.killProcess(android.os.Process.myPid());
    }

    /**
     * 清除共有目录
     */
    public static void clearPublic() {
        String filePath = Environment.getExternalStorageDirectory().getPath() + "/" + getPackageInfo().packageName;
        File dir = new File(filePath);
        if (dir.exists()) {
            File[] files = dir.listFiles();
            if (null != files) {
                for (File file : files) {
                    deleteFolder(file.getAbsolutePath());
                }
            }
        }
    }

    /**
     * 清除私有目录
     */
    public static void clearPrivate() {
        // 清空文件夹
        File dir = BaseApplication.getContext().getFilesDir();
        String path = dir.getParent();
        if (null != path && !path.isEmpty()) {
            dir = new File(path);
        }
        if (!dir.exists()) {
            return;
        }

        File[] files = dir.listFiles();
        if (null != files) {
            for (File file : files) {
                if (!file.getName().contains("lib")) {
                    deleteFolder(file.getAbsolutePath());
                }
            }
        }
    }

    /**
     * 根据路径删除指定的目录或文件
     * @param folder 路径
     * @return 是否删除成功
     */
    private static boolean deleteFolder(String folder) {
        File file = new File(folder);
        if (!file.exists()) {
            return false;
        } else {
            if (file.isFile()) {
                return deleteSingleFile(folder);
            } else {
                return deleteDirectory(folder);
            }
        }
    }

    /**
     * 删除 文件夹
     * @param path 被删除文件夹的文件名
     * @return 是否删除成功
     */
    private static boolean deleteDirectory(String path) {
        if (!path.endsWith(File.separator)) {
            path = path + File.separator;
        }

        File dirFile = new File(path);
        if (!dirFile.exists() || !dirFile.isDirectory()) {
            return false;
        }

        boolean flag = true;
        File[] files = dirFile.listFiles();
        if (null != files) {
            for (File item : files) {
                if (item.isFile()) {
                    flag = deleteSingleFile(item.getAbsolutePath());
                } else {
                    flag = deleteDirectory(item.getAbsolutePath());
                }
                if (!flag) {
                    break;
                }
            }
        }
        if (!flag) {
            return false;
        }
        return dirFile.delete();
    }

    /**
     * 删除单个文件
     * @param path 被删除文件的文件名
     * @return 文件删除成功返回 true 否则返回 false
     */
    private static boolean deleteSingleFile(String path) {
        File file = new File(path);
        if (file.exists() && file.isFile()) {
            return file.delete();
        }
        return false;
    }

    /**
     * 获取包信息
     * @return PackageInfo
     */
    private static PackageInfo getPackageInfo() {
        PackageManager packageManager = BaseApplication.getContext().getPackageManager();
        PackageInfo packageInfo = null;
        try {
            packageInfo = packageManager.getPackageInfo(BaseApplication.getContext().getPackageName(), 0);
        } catch (PackageManager.NameNotFoundException e) {
            e.printStackTrace();
        }
        return packageInfo;
    }

    /**
     * 清除本应用所有的数据
     *
     * @param filepath
     */
    public static void cleanApplicationData(String... filepath) {
        cleanInternalCache();
        cleanExternalCache();
        cleanDatabases();
        cleanSharedPreference();
        cleanFiles();
        cleanUserData();
        for (String filePath : filepath) {
            cleanCustomCache(filePath);
        }
    }

    /**
     * 清除本应用内部缓存(/data/data/com.xxx.xxx/cache)
     */
    private static void cleanInternalCache() {
        deleteFilesByDirectory(BaseApplication.getContext().getCacheDir());
    }

    private static void cleanUserData() {
        deleteFilesByDirectory(new File("/data/user/0/" + BaseApplication.getContext().getPackageName()+"/cache"));
    }

    /**
     * 清除本应用所有数据库(/data/data/com.xxx.xxx/databases)
     */
    private static void cleanDatabases() {
        deleteFilesByDirectory(new File("/data/data/" + BaseApplication.getContext().getPackageName() + "/databases"));
    }

    /**
     * 清除本应用SharedPreference(/data/data/com.xxx.xxx/shared_prefs)
     */
    private static void cleanSharedPreference() {
        deleteFilesByDirectory(new File("/data/data/" + BaseApplication.getContext().getPackageName() + "/shared_prefs"));
    }

    /**
     * 按名字清除本应用数据库
     *
     * @param dbName db
     */
    private static void cleanDatabaseByName(String dbName) {
        BaseApplication.getContext().deleteDatabase(dbName);
    }

    /**
     * 清除/data/data/com.xxx.xxx/files下的内容
     */
    private static void cleanFiles() {
        deleteFilesByDirectory(BaseApplication.getContext().getFilesDir());
    }

    /**
     * 清除外部cache下的内容(/mnt/sdcard/android/data/com.xxx.xxx/cache)
     */
    private static void cleanExternalCache() {
        if (Environment.getExternalStorageState().equals(Environment.MEDIA_MOUNTED)) {
            deleteFilesByDirectory(BaseApplication.getContext().getExternalCacheDir());
        }
    }

    /**
     * 清除自定义路径下的文件，使用需小心，请不要误删。而且只支持目录下的文件删除
     */
    private static void cleanCustomCache(String filePath) {
        deleteFilesByDirectory(new File(filePath));
    }

    /**
     * 删除方法 这里只会删除某个文件夹下的文件，如果传入的directory是个文件，将不做处理
     *
     * @param directory File
     */
    private static void deleteFilesByDirectory(File directory) {
        FileUtils.deleteFolderFile(directory.getAbsolutePath());
//        if (directory != null && directory.exists() && directory.isDirectory()) {
//            File[] files = directory.listFiles();
//            if (null != files) {
//                for (File item : files) {
//                    item.delete();
//                }
//            }
//        }
    }
}