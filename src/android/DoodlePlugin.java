package org.apache.cordova.doodle;

import android.Manifest;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.graphics.Bitmap;
import android.support.v4.content.ContextCompat;
import android.util.Base64;

import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.CallbackContext;

import org.apache.cordova.PermissionHelper;
import org.apache.cordova.PluginResult;
import org.json.JSONArray;
import org.json.JSONException;

import cn.doodle.DoodleActivity;
import cn.doodle.DoodleParams;
import cn.doodle.DoodleView;
import cn.doodle.util.ImageUtils;


import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;

import static android.app.Activity.RESULT_OK;

/**
 * This class echoes a string called from JavaScript.
 */
public class DoodlePlugin extends CordovaPlugin {
    public static final String KEY_NATIVE_IMG = "applocal://native/images/";
    public static final String KEY_FILE_IMG = "file:///";
    public static final int REQUEST_CODE_SIGN_PAGE = 0x700;
    public static final int ERROR = 207;//失败
    private static final int TAKE_PIC_SEC = 0;
    public CallbackContext mCallbackContext;
    protected final static String[] permissions = {Manifest.permission.WRITE_EXTERNAL_STORAGE, Manifest.permission.READ_EXTERNAL_STORAGE};
    public static final int PERMISSION_DENIED_ERROR = 20;
    private DoodleParams params;

    @Override
    public boolean execute(String action, JSONArray args, CallbackContext callbackContext) throws JSONException {
        mCallbackContext = callbackContext;
        if (action.equals("doodle")) {
            this.doodle(args);
            return true;
        }
        return false;
    }

    private void doodle(JSONArray args) {
        // 涂鸦参数
        params = new DoodleParams();
        String path = args.optString(0);
        if (path.contains(KEY_NATIVE_IMG)) {
            params.mImagePath = path.substring(path.indexOf(KEY_NATIVE_IMG) + KEY_NATIVE_IMG.length(), path.length());
        } else if (path.contains(KEY_FILE_IMG)) {
            params.mImagePath = path.substring(path.indexOf(KEY_FILE_IMG) + KEY_FILE_IMG.length(), path.length());
        } else {
            params.mImagePath = path;
        }
        Bitmap bitmap = ImageUtils.createBitmapFromPath(params.mImagePath, cordova.getContext());
        if (bitmap == null) {
            mCallbackContext.error(ERROR);
            return;
        }
        params.mIsFullScreen = true;
        // 初始画笔大小
        params.mPaintUnitSize = DoodleView.DEFAULT_SIZE;
        // 启动涂鸦页面
        if (ContextCompat.checkSelfPermission(cordova.getActivity(),
                Manifest.permission.WRITE_EXTERNAL_STORAGE)
                != PackageManager.PERMISSION_GRANTED) {
            PermissionHelper.requestPermissions(this, TAKE_PIC_SEC, permissions);
        } else {
            start();
        }

    }

    private void start() {
        Intent intent = new Intent(cordova.getActivity(), DoodleActivity.class);
        intent.putExtra(DoodleActivity.KEY_PARAMS, params);
        cordova.startActivityForResult(this, intent, REQUEST_CODE_SIGN_PAGE);
    }

    @Override
    public void onActivityResult(int requestCode, int resultCode, Intent intent) {
        super.onActivityResult(requestCode, resultCode, intent);

        if (resultCode == RESULT_OK) {
            String image_path = intent.getStringExtra("key_image_path");
            File file = new File(image_path);
            String base64Str = encodeBase64File(file);
            mCallbackContext.success(base64Str);
        } else {
            mCallbackContext.error("fail");
        }
    }

    public String encodeBase64File(File file) {
        FileInputStream inputFile = null;
        String fileName = file.getName();
        String strHeaderMiddle = fileName.substring(fileName.lastIndexOf(".") + 1);
        String strHeader = "data:image/" + strHeaderMiddle + ";base64,";
        byte[] buffer = null;
        try {
            inputFile = new FileInputStream(file);
            buffer = new byte[(int) file.length()];
            inputFile.read(buffer);

        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            if (inputFile != null) {
                try {
                    inputFile.close();
                } catch (IOException e) {
                    e.printStackTrace();
                }
            }
        }
        return strHeader + Base64.encodeToString(buffer, Base64.DEFAULT);
    }

    public void onRequestPermissionResult(int requestCode, String[] permissions,
                                          int[] grantResults) throws JSONException {
        for (int r : grantResults) {
            if (r == PackageManager.PERMISSION_DENIED) {
                this.mCallbackContext.sendPluginResult(new PluginResult(PluginResult.Status.ERROR, PERMISSION_DENIED_ERROR));
                return;
            }
        }
        switch (requestCode) {
            case TAKE_PIC_SEC:
                start();
                break;
        }
    }
}
