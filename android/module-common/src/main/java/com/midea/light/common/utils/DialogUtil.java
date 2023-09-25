package com.midea.light.common.utils;

import android.app.AlertDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.os.Looper;
import android.view.Gravity;
import android.view.View;
import android.widget.AdapterView;
import android.widget.TextView;
import android.widget.Toast;

import androidx.annotation.StringRes;
import androidx.fragment.app.DialogFragment;
import androidx.fragment.app.FragmentActivity;
import androidx.fragment.app.FragmentTransaction;

import com.midea.light.BaseApplication;
import com.midea.light.common.R;

/**
 * Created by MAIJW1 on 2018-3-16.
 */

public class DialogUtil {
    private static LoadingDialog loadingDialog;

    /**
     * Toast实例，用于对本页出现的所有Toast进行处理
     */
    private static Toast myToast;

    /**
     * 此处是一个封装的Toast方法，可以取消掉上一次未完成的，直接进行下一次Toast
     *
     * @param text 需要toast的内容
     */
    public static void showToast(String text) {
        if (Looper.myLooper() == null)
            return;
        if (myToast != null) {
            myToast.cancel();
        }
        myToast = Toast.makeText(BaseApplication.getContext(), text, Toast.LENGTH_SHORT);
        myToast.setGravity(Gravity.TOP,0,31);
        View view = View.inflate(BaseApplication.getContext(), R.layout.common_toast, null);
        TextView tvMsg=view.findViewById(R.id.tv_msg);
        tvMsg.setText(text);
        myToast.setView(view);
        myToast.show();
    }

    public static void showToast(@StringRes int strRes) {
        showToast(BaseApplication.getContext().getText(strRes).toString());
    }


    public interface DialogListener {
        public void sure();

        public void cancle();
    }

    public interface InputDialogListener {
        public void sure(String data);

        public void cancle();
    }


    public static void showChoise(Context context, String title, String[] datas, DialogInterface.OnClickListener listener) {

        AlertDialog.Builder builder = new AlertDialog.Builder(context);
        builder.setTitle(title);
        //    指定下拉列表的显示数据
        //    设置一个下拉的列表选择项
        builder.setItems(datas, listener);
        builder.show();
    }


    public static class DialogOnItemClick implements AdapterView.OnItemClickListener {
        AlertDialog dialog;
        DialogSelect dialogSelect;

        DialogOnItemClick(AlertDialog dialog, DialogSelect dialogSelect) {
            this.dialog = dialog;
            this.dialogSelect = dialogSelect;
        }

        @Override
        public void onItemClick(AdapterView<?> adapterView, View view, int i, long l) {
            if (dialog != null) {
                dialog.dismiss();
            }
            if (dialogSelect != null) {
                dialogSelect.select(i);
            }
        }
    }


    public interface DialogSelect {

        void select(int position);

    }

    public static void showLoadingMessage(Context context, String mess) {
        LoadingDialog.Builder loadBuilder = new LoadingDialog.Builder(context)
                .setMessage(mess)
                .setCancelable(true)
                .setCancelOutside(true);
        loadingDialog = loadBuilder.create();
        loadingDialog.show();
    }
    public static void closeLoadingDialog() {
        try {
            if (loadingDialog != null) {
                loadingDialog.dismiss();
                loadingDialog = null;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }



    public static void showDialog(Context context, String Title, String message, String posBtn, String negBtn, final DialogListener listener) {
        final AlertDialog.Builder normalDialog =
                new AlertDialog.Builder(context);
        normalDialog.setIcon(android.R.drawable.ic_dialog_info);
        normalDialog.setTitle(Title);
        normalDialog.setMessage(message);
        normalDialog.setCancelable(false);
        normalDialog.setPositiveButton(posBtn == null ? "确定" : posBtn,
                new DialogInterface.OnClickListener() {
                    @Override
                    public void onClick(DialogInterface dialog, int which) {
                        //...To-do;
                        listener.sure();

                    }
                });
        normalDialog.setNegativeButton(negBtn == null ? "取消" : negBtn,
                new DialogInterface.OnClickListener() {
                    @Override
                    public void onClick(DialogInterface dialog, int which) {
                        dialog.dismiss();
                        listener.cancle();
                    }
                });
        // 显示
        normalDialog.show();
    }

    public static void showoneBtnDialog(Context context, String Title, String message, String btn, final DialogListener listener) {
        final AlertDialog.Builder normalDialog =
                new AlertDialog.Builder(context);
        normalDialog.setIcon(android.R.drawable.ic_dialog_info);
        normalDialog.setTitle(Title);
        normalDialog.setMessage(message);
        normalDialog.setCancelable(false);
        normalDialog.setPositiveButton(btn == null ? "知道了" : btn,
                new DialogInterface.OnClickListener() {
                    @Override
                    public void onClick(DialogInterface dialog, int which) {
                        //...To-do;
                        listener.sure();

                    }
                });
        // 显示
        normalDialog.show();
    }

    public static void showDialogAllowDismiss(FragmentActivity activity, DialogFragment dialogFragment) {
        FragmentTransaction ft = activity.getSupportFragmentManager().beginTransaction();
        ft.add(dialogFragment, dialogFragment.getClass().toString());
        ft.commitAllowingStateLoss();
    }


}
