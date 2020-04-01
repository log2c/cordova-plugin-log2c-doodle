# cordova-plugin-log2c-doodle

Cordova Doodle插件 对图片进行标记涂鸦 添加文字和打马赛克功能,`iOS`基于[LFMediaEditingController](https://github.com/lincf0912/LFMediaEditingController)

## Install

1. 安装`plugin`
    ```
    cordova plugin add cordova-plugin-log2c-doodle
    ```
2. `config.xml`中添加`iOS`需要的权限
    
    ```xml
        <edit-config target="NSCameraUsageDescription" file="*-Info.plist" mode="merge">
            <string>need camera access to take pictures</string>
        </edit-config>
        <edit-config target="NSCameraUsageDescription" file="*-Info.plist" mode="merge">
            <string>need camera access to take pictures</string>
        </edit-config>
        <edit-config target="NSLocationWhenInUseUsageDescription" file="*-Info.plist" mode="merge">
            <string>need location access to find things nearby</string>
        </edit-config>
        <edit-config target="NSPhotoLibraryAddUsageDescription" file="*-Info.plist" mode="merge">
            <string>need photo library access to save pictures there</string>
        </edit-config>
        <edit-config target="NSPhotoLibraryUsageDescription" file="*-Info.plist" mode="merge">
            <string>need photo library access to save pictures there</string>
        </edit-config>
    ```
    
## API
```cordova.exec(success, error, 'DoodlePlugin', 'doodle', [arg0]);```

    参数：arg0 为图片路径(android:applocal://native/images/或者file:///开头的图片路径，iOS：assets-library)
    返回结果为图片的Base64编码

 示例：
```cordova.exec(
      (res) => { //Base64 },
      (err) => {  },
      'DoodlePlugin',
      'doodle',
      ['file:///storage/emulated/0/Android/data/io.ionic.starter/cache/1568251761843.jpg']);```
