package com.midea.light.ai.utils;

/**
 * Created by MAIJW1 on 2018-3-29.
 */

import android.annotation.SuppressLint;
import android.content.Context;
import android.os.Environment;
import android.util.Base64;
import android.util.Log;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.FileReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.math.BigDecimal;
import java.nio.charset.Charset;
import java.security.MessageDigest;
import java.util.ArrayList;
import java.util.Enumeration;
import java.util.Iterator;
import java.util.zip.ZipEntry;
import java.util.zip.ZipFile;

/**
 * 文件操作工具
 * Created by Jusenr on 2016/12/10.
 */
public final class FileUtils {
    public static final String TAG = FileUtils.class.getSimpleName();
    public static final int BYTE = 1024;
    public static final String DOWNLOAD_APK_PATH = Environment.getExternalStorageDirectory() + "";

    /**
     * 格式化单位
     *
     * @param size
     * @return
     */
    public static String getFormatSize(double size) {
        double kiloByte = size / BYTE;
        if (kiloByte < 1) {
            return size + "B";
        }

        double megaByte = kiloByte / BYTE;
        if (megaByte < 1) {
            BigDecimal result1 = new BigDecimal(Double.toString(kiloByte));
            return result1.setScale(2, BigDecimal.ROUND_HALF_UP).toPlainString() + "KB";
        }

        double gigaByte = megaByte / BYTE;
        if (gigaByte < 1) {
            BigDecimal result2 = new BigDecimal(Double.toString(megaByte));
            return result2.setScale(2, BigDecimal.ROUND_HALF_UP).toPlainString() + "MB";
        }

        double teraBytes = gigaByte / BYTE;
        if (teraBytes < 1) {
            BigDecimal result3 = new BigDecimal(Double.toString(gigaByte));
            return result3.setScale(2, BigDecimal.ROUND_HALF_UP).toPlainString() + "GB";
        }
        BigDecimal result4 = new BigDecimal(teraBytes);
        return result4.setScale(2, BigDecimal.ROUND_HALF_UP).toPlainString() + "TB";
    }

    /**
     * 获取缓存文件大小
     *
     * @param context
     * @return
     */
    public static String getTotalCacheSize(Context context) {
        long cacheSize = getFolderSize(context.getCacheDir());
        if (Environment.getExternalStorageState().equals(Environment.MEDIA_MOUNTED)) {
            cacheSize += getFolderSize(context.getExternalCacheDir());
        }
        return getFormatSize(cacheSize);
    }

    /**
     * 清除应用缓存文件
     *
     * @param context
     */
    public static void clearAllCache(Context context) {
        delete(context.getCacheDir());
        if (Environment.getExternalStorageState().equals(Environment.MEDIA_MOUNTED)) {
            delete(context.getExternalCacheDir());
        }
    }

    /**
     * 获取文件大小
     *
     * @param file
     * @return
     * @throws Exception
     */
    //Context.getExternalFilesDir() --> SDCard/Android/data/你的应用的包名/files/ 目录，一般放一些长时间保存的数据
    //Context.getExternalCacheDir() --> SDCard/Android/data/你的应用包名/cache/目录，一般存放临时缓存数据
    public static long getFolderSize(File file) {
        long size = 0;
        try {
            File[] fileList = file.listFiles();
            for (int i = 0; i < fileList.length; i++) {
                // 如果下面还有文件
                if (fileList[i].isDirectory()) {
                    size = size + getFolderSize(fileList[i]);
                } else {
                    size = size + fileList[i].length();
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return size;
    }

    /**
     * 读取文件内容
     *
     * @param file    文件
     * @param charset 文件编码
     * @return 文件内容
     */
    public static String readFile(File file, String charset) {
        String fileContent = "";
        try {
            InputStreamReader read = new InputStreamReader(new FileInputStream(file), charset);
            BufferedReader reader = new BufferedReader(read);
            String line = "";
            int i = 0;
            while ((line = reader.readLine()) != null) {
                if (i == 0)
                    fileContent = line;
                else
                    fileContent = fileContent + "\n" + line;
                i++;
            }
            read.close();
        } catch (Exception e) {
            Log.e("读取文件内容操作出错", e.getMessage());
        }
        return fileContent;
    }

    /**
     * 读取文件内容
     *
     * @param file 文件
     * @return 文件内容
     */
    public static String readFile(File file) {
        return readFile(file, "UTF-8");
    }

    /**
     * 获取文件的SHA1值
     *
     * @param file 目标文件
     * @return 文件的SHA1值
     */
    public static String getSHA1ByFile(File file) {
        if (file == null || !file.exists()) return "文件不存在";
        long time = System.currentTimeMillis();
        InputStream in = null;
        String value = null;
        try {
            in = new FileInputStream(file);
            byte[] buffer = new byte[1024];
            MessageDigest digest = MessageDigest.getInstance("SHA-1");
            int numRead = 0;
            while (numRead != -1) {
                numRead = in.read(buffer);
                if (numRead > 0) digest.update(buffer, 0, numRead);
            }
            byte[] sha1Bytes = digest.digest();
            String t = new String(buffer);
            value = convertHashToString(sha1Bytes);
        } catch (Exception e) {

        } finally {
            if (in != null)
                try {
                    in.close();
                } catch (IOException e) {

                }
        }
        return value;
    }

    /**
     * @param hashBytes
     * @return
     */
    private static String convertHashToString(byte[] hashBytes) {
        String returnVal = "";
        for (int i = 0; i < hashBytes.length; i++) {
            returnVal += Integer.toString((hashBytes[i] & 0xff) + 0x100, 16).substring(1);
        }
        return returnVal.toLowerCase();
    }

    /**
     * 获取上传文件的文件名
     *
     * @param filePath
     * @return
     */
    public static String getFileName(String filePath) {
        String filename = new File(filePath).getName();
        if (filename.length() > 80) {
            filename = filename.substring(filename.length() - 80, filename.length());
        }
        return filename;
    }

    /**
     * 创建文件夹
     *
     * @param path 文件夹
     */
    public static boolean createMkdirs(String path) {
        File filepath = new File(path);
        return filepath.mkdirs();
    }

    /**
     * 创建文件
     *
     * @param file 文件
     */
    public static boolean createFile(File file) {
        if (!file.exists()) {
            try {
                return file.createNewFile();
            } catch (IOException e) {
                e.printStackTrace();
                return false;
            }
        }
        return false;
    }

    /**
     * 获得下载文件名
     *
     * @param url 下载url
     * @return 文件名
     */
    public static String getDownloadFileName(String url) {
        return url.substring(url.lastIndexOf("/") + 1);
    }

    /**
     * 获得应用的图片保存目录
     *
     * @return
     */
    public static String getPicDirectory(Context context) {
        File picFile = context.getExternalFilesDir(Environment.DIRECTORY_PICTURES);
        if (picFile != null) {
            return picFile.getAbsolutePath();
        } else {
            return context.getFilesDir().getAbsolutePath() + "/Pictures";
        }
    }


    /**
     * 删除文件
     *
     * @param filePath 文件路径
     * @return 是否刪除成功
     */
    public static boolean delete(String filePath) {
        File file = new File(filePath);
        return delete(file);
    }

    /**
     * 删除文件
     *
     * @param file 文件
     * @return 是否刪除成功
     */
    public static boolean delete(File file) {
        if (file == null || !file.exists()) return false;
        if (file.isFile()) {
            final File to = new File(file.getAbsolutePath() + System.currentTimeMillis());
            file.renameTo(to);
            to.delete();
        } else {
            File[] files = file.listFiles();
            if (files != null && files.length > 0)
                for (File innerFile : files) {
                    delete(innerFile);
                }
            final File to = new File(file.getAbsolutePath() + System.currentTimeMillis());
            file.renameTo(to);
            return to.delete();
        }
        return false;
    }

    /**
     * 获得文件内容
     *
     * @param filePath 文件路径
     * @return 文件内容
     */
    public static String getFileContent(String filePath) {
        File file = new File(filePath);
        if (file.exists()) {
            try {
                BufferedReader br = new BufferedReader(new FileReader(file));//构造一个BufferedReader类来读取文件
                String result = null;
                String s = null;
                while ((s = br.readLine()) != null) {//使用readLine方法，一次读一行
                    result = result + "\n" + s;
                }
                br.close();
                return result;
            } catch (Exception e) {
                e.printStackTrace();

            }
        } else {
            return null;
        }
        return null;
    }

    /**
     * 保存文本到文件
     *
     * @param fileName 文件名字
     * @param content  内容
     * @param append   是否累加
     * @return 是否成功
     */
    public static boolean saveTextValue(String fileName, String content, boolean append) {
        try {
            File textFile = new File(fileName);
            if (!append && textFile.exists()) textFile.delete();
            FileOutputStream os = new FileOutputStream(textFile);
            os.write(content.getBytes("UTF-8"));
            os.close();
        } catch (Exception ee) {
            return false;
        }
        return true;
    }



    /**
     * 保存文件
     *
     * @param in       文件输入流
     * @param filePath 文件保存路径
     */
    public static File saveFile(InputStream in, String filePath) {
        File file = new File(filePath);
        byte[] buffer = new byte[4096];
        int len = 0;
        FileOutputStream fos = null;
        try {
            FileUtils.createFile(file);
            fos = new FileOutputStream(file);
            while ((len = in.read(buffer)) != -1) {
                fos.write(buffer, 0, len);
            }
            fos.flush();
        } catch (IOException e) {
            ;
        } finally {
            try {
                if (in != null) in.close();
                if (fos != null) fos.close();
            } catch (IOException e) {

            }
        }
        return file;
    }

    /**
     * 复制文件到SD卡
     *
     * @param mActivity
     * @param mAssetsPath 复制的文件名
     * @param mSavePath   保存的目录路径
     * @return
     */
    public static void copyAssetsFilesAndDelete(android.app.Activity mActivity, String mAssetsPath, String mSavePath) {
        try {
            // 获取assets目录下的所有文件及目录名
            String[] fileNames = mActivity.getResources().getAssets().list(mAssetsPath);
            if (fileNames.length > 0) {
                // 若是目录
                for (String fileName : fileNames) {
                    String newAssetsPath = "";
                    // 确保Assets路径后面没有斜杠分隔符，否则将获取不到值
                    if ((mAssetsPath == null) || "".equals(mAssetsPath) || "/".equals(mAssetsPath)) {
                        newAssetsPath = fileName;
                    } else {
                        if (mAssetsPath.endsWith("/")) {
                            newAssetsPath = mAssetsPath + fileName;
                        } else {
                            newAssetsPath = mAssetsPath + "/" + fileName;
                        }
                    }
                    // 递归调用
                    copyAssetsFilesAndDelete(mActivity, newAssetsPath, mSavePath + "/" + fileName);
                }
            } else {
                // 若是文件
                File file = new File(mSavePath);
                // 若文件夹不存在，则递归创建父目录
                file.getParentFile().mkdirs();
                InputStream is = mActivity.getResources().getAssets().open(mAssetsPath);
                FileOutputStream fos = new FileOutputStream(new File(mSavePath));
                byte[] buffer = new byte[1024];
                int byteCount = 0;
                // 循环从输入流读取字节
                while ((byteCount = is.read(buffer)) != -1) {
                    // 将读取的输入流写入到输出流
                    fos.write(buffer, 0, byteCount);
                }
                // 刷新缓冲区
                fos.flush();
                fos.close();
                is.close();
            }
        } catch (Throwable e) {
            e.printStackTrace();
        }
    }


    public static boolean isEmpty(String filePath) {
        File file = new File(filePath);
        File[] listFiles = file.listFiles();
        if (listFiles.length > 0) {
            //文件夹下有文件
            return false;
        } else {
            //文件夹下没有文件
            return true;
        }
    }

    /**
     * 文件Base64加密
     *
     * @param path
     * @return
     */
    public static String fileToBase64String(String path) {
        FileInputStream inputStream = null;
        try {
            File file = new File(path);
            inputStream = new FileInputStream(file);
            byte[] fileBytes = new byte[inputStream.available()];
            inputStream.read(fileBytes);
            String base64String = Base64.encodeToString(fileBytes, Base64.DEFAULT);
            return base64String;
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            if (inputStream != null)
                try {
                    inputStream.close();
                } catch (IOException e) {
                    e.printStackTrace();
                }
        }
        return null;
    }

    /**
     * 判断文件是否存在
     *
     * @param strPath
     * @return
     */
    public static boolean isExists(String strPath) {
        if (strPath == null) {
            return false;
        }

        final File strFile = new File(strPath);

        if (strFile.exists()) {
            return true;
        }
        return false;

    }

    public static boolean isFolderExists(String strFolder) {
        File file = new File(strFolder);
        if (!file.exists()) {
            if (file.mkdirs()) {
                return true;
            } else {
                return false;

            }
        }
        return true;

    }

    @SuppressLint("NewApi")
    public static void unZipFiles(File zipFile, String descDir) {
        ZipFile zip;
        try {
            zip = new ZipFile(zipFile, Charset.forName("GBK"));//解决中文文件夹乱码
            String name = zip.getName().substring(zip.getName().lastIndexOf('\\') + 1, zip.getName().lastIndexOf('.'));
            File pathFile = new File(descDir + name);
            if (!pathFile.exists()) {
                pathFile.mkdirs();
            }
            for (Enumeration<? extends ZipEntry> entries = zip.entries(); entries.hasMoreElements(); ) {
                ZipEntry entry = entries.nextElement();
                String zipEntryName = entry.getName();
                InputStream in = zip.getInputStream(entry);
                String outPath = (descDir + name + "/" + zipEntryName).replaceAll("\\*", "/");
                // 判断路径是否存在,不存在则创建文件路径
                File file = new File(outPath.substring(0, outPath.lastIndexOf('/')));
                if (!file.exists()) {
                    file.mkdirs();
                }
                // 判断文件全路径是否为文件夹,如果是上面已经上传,不需要解压
                if (new File(outPath).isDirectory()) {
                    continue;
                }
                // 输出文件路径信息
                FileOutputStream out = new FileOutputStream(outPath);
                byte[] buf1 = new byte[1024];
                int len;
                while ((len = in.read(buf1)) > 0) {
                    out.write(buf1, 0, len);
                }
                in.close();
                out.close();
            }
        } catch (IOException e) {
            e.printStackTrace();
        }
        return;
    }

    /**
     * 递归删除 文件/文件夹
     *
     * @param file
     */
    public static void deleteFile(File file) {

        Log.i("TAG", "delete file path=" + file.getAbsolutePath());

        if (file.exists()) {
            if (file.isFile()) {
                file.delete();
            } else if (file.isDirectory()) {
                File files[] = file.listFiles();
                for (int i = 0; i < files.length; i++) {
                    deleteFile(files[i]);
                }
            }
            file.delete();
        } else {
            Log.e("TAG", "delete file no exists " + file.getAbsolutePath());
        }
    }

    /*
     * 创建新集合将重复元素去掉
     * 1,明确返回值类型,返回ArrayList
     * 2,明确参数列表ArrayList
     *
     * 分析:
     * 1,创建新集合
     * 2,根据传入的集合(老集合)获取迭代器
     * 3,遍历老集合
     * 4,通过新集合判断是否包含老集合中的元素,如果包含就不添加,如果不包含就添加
     */
    public static ArrayList getSingle(ArrayList list) {
        ArrayList tempList = new ArrayList();                    //1,创建新集合
        Iterator it = list.iterator();                            //2,根据传入的集合(老集合)获取迭代器

        while (it.hasNext()) {                                    //3,遍历老集合
            Object obj = it.next();                                //记录住每一个元素
            if (!tempList.contains(obj)) {                        //如果新集合中不包含老集合中的元素
                tempList.add(obj);                                //将该元素添加
            }
        }

        return tempList;
    }

    /**
     * 删除目录下所有文件，不包括自身文件夹
     *
     * @param Path 路径
     */
    public static boolean deleteFolderFile(String Path) {
        boolean flag = false;
        File file = new File(Path);
        if (!file.exists()) {
            return flag;
        }
        if (!file.isDirectory()) {
            return flag;
        }
        String[] tempList = file.list();
        File temp = null;
        for (int i = 0; i < tempList.length; i++) {
            if (Path.endsWith(File.separator)) {
                temp = new File(Path + tempList[i]);
            } else {
                temp = new File(Path + File.separator + tempList[i]);
            }
            if (temp.isFile()) {
                temp.delete();
            }
            if (temp.isDirectory()) {
                deleteFolderFile(Path + "/" + tempList[i]);//先删除文件夹里面的文件
                deleteAllFile(Path + "/" + tempList[i]);//再删除空文件夹
                flag = true;
            }
        }
        return flag;

    }

    /**
     * 删除目录下所有文件，包括自身文件夹
     *
     * @param folderPath 路径
     */
    public static void deleteAllFile(String folderPath) {
        try {
            deleteFolderFile(folderPath); //删除完里面所有内容
            String filePath = folderPath;
            File myFilePath = new File(filePath);
            myFilePath.delete(); //删除空文件夹
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

}