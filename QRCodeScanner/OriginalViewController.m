//
//  OriginalViewController.m
//  QRCodeScanner
//
//  Created by dengjunjie on 15/5/14.
//  Copyright (c) 2015年 dengjunjie. All rights reserved.
//

#import "OriginalViewController.h"

#import <AVFoundation/AVFoundation.h>

@interface OriginalViewController () <AVCaptureMetadataOutputObjectsDelegate,UIAlertViewDelegate>
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
 viewDidLoad
 1.画自定义UI   (drawCustomView)
 2.显示菊花     (showLoading)
 
 viewDidAppear
 1.配置摄像头    (setupCamera)    -> 跳至未授权处理
 2.停止菊花     (hideLoading)
 3.开始摄像     (startCapture)
 
 未授权处理：
 1.停止菊花
 2.弹窗提示用户授权
 3.点击弹窗返回上一级
 */

#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor blackColor];
    
    // 转菊花
    [self showLoading];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    // 画自定义view
    [self drawCustomView];
    
    // 配置摄像头
    if ([self setupCamera])
    {
        // 停止菊花
        [self hideLoading];
        // 开始捕捉图像
        [self startCapture];
    }
    else
    {
        // 停止菊花
        [self hideLoading];
        // 提示
        [self showAlertWithTitle:nil andMessage:@"请在iPhone的“设置-私隐-相机”选项中，允许要出发周边游访问你的相机"];
    }
}

-(void)viewDidDisappear:(BOOL)animated
{
    [self stopCapture];
    
    [super viewDidDisappear:animated];
}

#pragma mark - draw
// 画自定义UI
- (void)drawCustomView
{
    CGFloat screenW = self.view.frame.size.width;
    CGFloat screenH = self.view.frame.size.height;
    
    UIView *container = [[UIView alloc] initWithFrame:self.view.bounds];
    container.backgroundColor = [UIColor clearColor];
    [self.view addSubview:container];
    
    // 显示的扫描区域比实际的扫描区域窄
    CGFloat middleViewW = self.cropRect.size.width - 60;
    CGFloat middleViewH = self.cropRect.size.height - 60;
    CGFloat middleViewX = self.cropRect.origin.x + 30;
    CGFloat middleViewY = self.cropRect.origin.y + 30;
    
    // middle View
    UIImageView *middleView = [[UIImageView alloc] initWithFrame:CGRectMake(middleViewX, middleViewY, middleViewW, middleViewH)];
    middleView.image = [UIImage imageNamed:@"QRCodeScanRect"];
    [container addSubview:middleView];
    
    UIImageView *scanLine = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, middleViewW, 3)];
    scanLine.image = [UIImage imageNamed:@"QRCodeScanLine"];
    [middleView addSubview:scanLine];
    
    [UIView animateWithDuration:3.0 delay:0 options:UIViewAnimationOptionRepeat|UIViewAnimationOptionAllowAnimatedContent animations:^{
        scanLine.frame = CGRectMake(0, middleViewH, middleViewW, 6);
    } completion:^(BOOL finished) {
        
    }];
    
    // top
    UIView *topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenW, middleViewY)];
    topView.backgroundColor = [UIColor blackColor];
    topView.alpha = 0.3;
    [container addSubview:topView];
    
    // left
    UIView *leftView = [[UIView alloc] initWithFrame:CGRectMake(0, middleViewY, middleViewX, screenH - middleViewY)];
    leftView.backgroundColor = [UIColor blackColor];
    leftView.alpha = 0.3;
    [container addSubview:leftView];
    
    // right
    UIView *rightView = [[UIView alloc] initWithFrame:CGRectMake(middleViewX + middleViewW, middleViewY, screenW - (middleViewX + middleViewW), screenH - middleViewY)];
    rightView.backgroundColor = [UIColor blackColor];
    rightView.alpha = 0.3;
    [container addSubview:rightView];
    
    // bottom
    UIView *bottomView = [[UIView alloc] initWithFrame:CGRectMake(middleViewX, middleViewY + middleViewH, middleViewW, screenH - (middleViewY + middleViewH))];
    bottomView.backgroundColor = [UIColor blackColor];
    bottomView.alpha = 0.3;
    [container addSubview:bottomView];
    
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

// 显示提示框
-(void)showAlertWithTitle:(NSString *)title andMessage:(NSString *)message
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
    [alertView show];
}

#pragma mark - delegate
// 结果回调
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

// AlertView代理
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        NSLog(@"确定");
        // 返回上一级
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark - private method
// 配置摄像头
- (BOOL)setupCamera
{
    // 相机是否授权
    if ([AVCaptureDevice respondsToSelector:@selector(authorizationStatusForMediaType:)])
    {
        if (!([AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo] == AVAuthorizationStatusAuthorized))
        {
            NSLog(@"CaptureDevice not authorized");
            return NO;
        }
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
    
    return YES;
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

#pragma mark - getter
-(CGRect)cropRect
{
    // 如果外部没有传进相应的参数，预设扫描区域
    if (_cropRect.size.width == 0 || _cropRect.size.height == 0)
    {
        CGFloat cropW = self.view.frame.size.width;
        CGFloat cropH = self.view.frame.size.width;
        CGFloat cropX = (self.view.frame.size.width - cropW) * 0.5;
        CGFloat cropY = 64;
        _cropRect = CGRectMake(cropX, cropY, cropW, cropH);
    }
    
    return _cropRect;
}

@end
