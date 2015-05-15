//
//  OriginalViewController.m
//  QRCodeScanner
//
//  Created by dengjunjie on 15/5/14.
//  Copyright (c) 2015年 dengjunjie. All rights reserved.
//

#import "OriginalViewController.h"

#import <AVFoundation/AVFoundation.h>

@interface OriginalViewController () <AVCaptureMetadataOutputObjectsDelegate>
{
    BOOL _isReading;
    
    AVCaptureSession *_captureSession;
    
    AVCaptureVideoPreviewLayer *_videoPreviewLayer;
}



// 其他变量
@property (nonatomic,weak) UIActivityIndicatorView *indicator;

@end

@implementation OriginalViewController

/*
 1.显示加载中
 2.画自定义UI
 3.配置摄像头
 4.隐藏加载文字
 5.开始捕捉图像
 */


#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    // 画自定义view
    [self drawCustomView];
    
    // 转菊花
    [self showLoading];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    // 配置摄像头
    if ([self setupCamera]) {
        // 停止菊花
        [self hideLoading];
        
        // 开始捕捉图像
//        [self startCapture];
    };
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

    
}

// 开始捕捉图像
- (void)startCapture
{
    if (_captureSession && ![_captureSession isRunning]) {
        [_captureSession startRunning];
        _isReading = YES;
    }
}

// 停止捕捉图像
- (void)stopCapture
{
    if ([_captureSession isRunning]) {
        [_captureSession stopRunning];
        _isReading = NO;
    }
}

// 配置摄像头
- (BOOL)setupCamera
{
    
    
    // 相机是否授权
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (!(status == AVAuthorizationStatusAuthorized)) {
        NSLog(@"CaptureDevice not authorized");
        return NO;
    }
    
    // 添加捕捉设备
    AVCaptureDevice *captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    // 添加输入流
    NSError *error;
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:captureDevice error:&error];
    
    if (!input) {
        NSLog(@"%@", [error localizedDescription]);
        return NO;
    }
    
    // 添加session
    _captureSession = [[AVCaptureSession alloc] init];
    _captureSession.sessionPreset = AVCaptureSessionPresetHigh; // 最高质量
    
    // 添加input
    [_captureSession addInput:input];
    
    // 添加output
    AVCaptureMetadataOutput *captureMetadataOutput = [[AVCaptureMetadataOutput alloc] init];
    captureMetadataOutput.rectOfInterest = [self convertRectOfInterest:self.cropRect];
    
    [_captureSession addOutput:captureMetadataOutput];
    
    // 异步处理代理方法，不妨碍主线程
    dispatch_queue_t dispatchQueue;
    dispatchQueue = dispatch_queue_create("myQueue", NULL);
    [captureMetadataOutput setMetadataObjectsDelegate:self queue:dispatchQueue];
    
    // 仅仅用来扫二维码时，可以设置qrcodeFlag = YES;
    if (self.qrcodeFlag)
        [captureMetadataOutput setMetadataObjectTypes:[NSArray arrayWithObject:AVMetadataObjectTypeQRCode]];
    else
    {
        [captureMetadataOutput setMetadataObjectTypes:[NSArray arrayWithObjects:AVMetadataObjectTypeEAN13Code, AVMetadataObjectTypeEAN8Code, AVMetadataObjectTypeCode128Code, AVMetadataObjectTypeQRCode, nil]];
    }
    
    // 添加previewlayer,关联session
    _videoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:_captureSession];
    [_videoPreviewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    [_videoPreviewLayer setFrame:self.view.layer.bounds];
    [self.view.layer insertSublayer:_videoPreviewLayer atIndex:0];
//    [self.view.layer addSublayer:_videoPreviewLayer];
    
    
    // 设置焦距
    if ([captureDevice lockForConfiguration:nil])
    {
        NSLog(@"VideoMaxZoomFactor: %f",captureDevice.activeFormat.videoMaxZoomFactor);
        if (captureDevice.activeFormat.videoMaxZoomFactor >= 2.0)
        {
            captureDevice.videoZoomFactor = 2.0;
        }
        [captureDevice unlockForConfiguration];
    }

    [self startCapture];
    
//    _isReading = YES;
//    [_captureSession startRunning];
    
    return YES;
}

// 根据屏幕坐标系的rect返回设置rectOfInterest的Rect
- (CGRect)convertRectOfInterest:(CGRect)rect
{
    CGFloat screenW = [UIScreen mainScreen].bounds.size.width;
    CGFloat screenH = [UIScreen mainScreen].bounds.size.height;
    
    CGFloat convertX = rect.origin.y / screenH;
    CGFloat convertY = ((screenW - rect.size.width) / 2) / screenW;
    CGFloat convertW = rect.size.height / screenH;
    CGFloat convertH = rect.size.width / screenW;
    
    return CGRectMake(convertX, convertY, convertW, convertH);
}

// 添加UI
- (void)drawCustomView
{
    UIView *targetView = [[UIView alloc] initWithFrame:self.cropRect];
    targetView.backgroundColor = [UIColor redColor];
    targetView.alpha = 0.1;
    [self.view addSubview:targetView];
    
    UIView *scannerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 220, 220)];
    scannerView.center = CGPointMake(targetView.frame.size.width * 0.5, targetView.frame.origin.y + targetView.frame.size.height * 0.5);
    scannerView.backgroundColor = [UIColor blueColor];
    scannerView.alpha = 0.3;
    [self.view addSubview:scannerView];
}




// 显示菊花
- (void)showLoading
{
    if (!self.indicator)
    {
        UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        indicator.center = self.view.center;
        indicator.hidden = NO;
        self.indicator = indicator;
        [self.view addSubview:indicator];
        
        [self.view bringSubviewToFront:indicator];
    }
    [self.indicator startAnimating];
}

// 隐藏菊花
-(void)hideLoading
{
    if (self.indicator && [self.indicator isAnimating]) {
        [self.indicator stopAnimating];
    }
}

#pragma mark - Draw

#pragma mark - 网络请求(request)

#pragma mark - 数据处理(dealWith)

#pragma mark - 系统Delegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    if (!_isReading) return;
    
    if (metadataObjects != nil && [metadataObjects count] > 0) {
        AVMetadataMachineReadableCodeObject *metadataObj = [metadataObjects objectAtIndex:0];
        
        NSLog(@"%@",metadataObj.stringValue);
        
        [_captureSession stopRunning];
        
        // 振动提示
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [_captureSession startRunning];
        });
    }
}

#pragma mark - 自定义Delegate

#pragma mark - 通知（handle）

#pragma mark - IBAction(Action结尾)

#pragma mark - 私有方法(p_xxx)

#pragma mark - getter
-(CGRect)cropRect
{
    if (_cropRect.size.width == 0 || _cropRect.size.height == 0)
    {
        CGFloat cropW = self.view.frame.size.width;
        CGFloat cropH = self.view.frame.size.width;
        CGFloat cropX = (self.view.frame.size.width - cropW) * 0.5;
        CGFloat cropY = 44;
        _cropRect = CGRectMake(cropX, cropY, cropW, cropH);
    }
    
    return _cropRect;
}

@end
