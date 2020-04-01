#import <Cordova/CDV.h>
#import "DoodlePlugin.h"
#import <Photos/PHImageManager.h>
#import <Photos/PHAsset.h>
#import "LFPhotoEditingController.h"


@interface DoodlePlugin()<LFPhotoEditingControllerDelegate>
@property (copy) NSString* callbackId;
@property (nonatomic, strong) CDVPluginResult *pluginResult;
@property (nonatomic, strong) CDVInvokedUrlCommand *command;
@property (nonatomic, retain) UINavigationController *navigationController;
@property (nonatomic, strong) NSArray<NSNumber *> *durations;
@property (nonatomic, strong) LFPhotoEdit *photoEdit;
@property (nonatomic, strong) UIImage *image;
@end

@implementation DoodlePlugin

- (void)doodle:(CDVInvokedUrlCommand*)command
{
    _command = command;
    self.callbackId = command.callbackId;
    NSString* imagePath = [command.arguments objectAtIndex:0];
    if (imagePath != nil && [imagePath length] > 0&&[imagePath hasPrefix:@"assets-library"]) {
        PHFetchResult * re = [PHAsset fetchAssetsWithALAssetURLs:[NSArray arrayWithObject:[NSURL URLWithString:imagePath]] options:nil];
        [re enumerateObjectsUsingBlock:^(PHAsset * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [[PHCachingImageManager defaultManager] requestImageDataForAsset:obj options:nil resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
                self.image = [UIImage imageWithData:imageData];
                [self editPhoto: self.image];

            }];
        }];
    } else {
        [self sendErrorResultWithMessage:@"Failed to read image data from data url"];
    }
}

- (void) editPhoto:(UIImage *)image{
    dispatch_async(dispatch_get_main_queue(), ^{
        LFPhotoEditingController *lfPhotoEditVC = [[LFPhotoEditingController alloc] init];
        lfPhotoEditVC.operationType = LFPhotoEditOperationType_draw | LFPhotoEditOperationType_text | LFPhotoEditOperationType_splash | LFPhotoEditOperationType_crop;
        lfPhotoEditVC.delegate = self;
        LFPhotoEdit *photoEdit = self.photoEdit;

        if (photoEdit) {
            lfPhotoEditVC.photoEdit = photoEdit;
        } else {
            [lfPhotoEditVC setEditImage:self.image durations:self.durations];
        }
        self.navigationController = [[UINavigationController alloc] initWithRootViewController:lfPhotoEditVC];
        [self.navigationController setNavigationBarHidden:YES];
        self.navigationController.modalPresentationStyle = UIModalPresentationFullScreen;
        [self.navigationController setToolbarHidden:YES animated:NO];
        [self.viewController presentViewController:self.navigationController animated:YES completion:nil];
    });
}

#pragma mark - PhotoViewDelegate
//编辑完成返回base64码
-(void)didFinish:(UIImage *)image{
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), ^{
        NSData  *drawingData = UIImageJPEGRepresentation(image, 1.0f);
        NSString *message = [NSString stringWithFormat:@"data:image/jpg;base64,%@", [drawingData base64EncodedStringWithOptions:0]];

        dispatch_async(dispatch_get_main_queue(), ^{
            if (message) {
                [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:message]
                                            callbackId:self.callbackId];
            }
            [self.navigationController dismissViewControllerAnimated:YES completion:nil];
        });
    });
}

//取消编辑返回
-(void)didCancel{

    [self sendErrorResultWithMessage:@""];

    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void) sendErrorResultWithMessage:(NSString *)message
{
    [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:message]
                                callbackId:self.callbackId];
}
- (void)lf_PhotoEditingController:(LFPhotoEditingController *)photoEditingVC didFinishPhotoEdit:(LFPhotoEdit *)photoEdit {
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), ^{
        NSData  *drawingData = UIImageJPEGRepresentation(self.image, 1.0f);
        NSString *message = [NSString stringWithFormat:@"data:image/jpg;base64,%@", [drawingData base64EncodedStringWithOptions:0]];

        dispatch_async(dispatch_get_main_queue(), ^{
            if (message) {
                [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:message]
                                            callbackId:self.callbackId];
            }
            [self.navigationController dismissViewControllerAnimated:YES completion:nil];
        });
    });

}

- (void)lf_PhotoEditingControllerDidCancel:(LFPhotoEditingController *)photoEditingVC {
    [self sendErrorResultWithMessage:@""];
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

@end

