//
//  ZBarSDKViewController.m
//  QRCodeScanner
//
//  Created by dengjunjie on 15/5/14.
//  Copyright (c) 2015年 dengjunjie. All rights reserved.
//

#import "ZBarSDKViewController.h"

#import "ZBarSDK.h"

#import <AVFoundation/AVFoundation.h>

@interface ZBarSDKViewController () <ZBarReaderViewDelegate>
{
    ZBarReaderView *_readerView;
    UIView *_scanView;
}

// 其他变量
@property (nonatomic,weak) UIActivityIndicatorView *indicator;

@end

@implementation ZBarSDKViewController

/*
 viewDidLoad
 1.画自定义UI
 2.显示菊花
 
 viewDidAppear
 1.配置摄像头    -> 跳至未授权处理
 2.停止菊花
 3.开始摄像
 
 未授权处理：
 1.停止菊花
 2.弹窗提示用户授权
 3.点击弹窗返回上一级
 */

#pragma mark - Life Cycle
-(void)dealloc
{
    NSLog(@"ZBarSDKViewController dealloc");
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor blackColor];
    
    [self drawCustomView];
    
    [self showLoading];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if ([self setupCamera])
    {
        [self hideLoading];
        
        [self startCapture];
    }
    else
    {
        [self hideLoading];
        
        [self showAlertWithTitle:nil andMessage:@"请在iPhone的“设置-私隐-相机”选项中，允许要出发周边游访问你的相机"];
    }
}

-(void)viewDidDisappear:(BOOL)animated
{
    [self stopCapture];
    
    [super viewDidDisappear:animated];
}

-(BOOL)setupCamera
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
    
    _readerView= [[ZBarReaderView alloc] init];
    _readerView.frame =CGRectMake(0,64,self.view.frame.size.width, self.view.frame.size.height - 64);   // 全屏扫
    _readerView.tracksSymbols=NO;           //
    _readerView.readerDelegate =self;       // 代理
    _readerView.torchMode =0;               // 关闭闪光灯
    _readerView.zoom = 2.0;
    _readerView.scanCrop = [self convertRectOfInterest:self.cropRect];
    [self.view insertSubview:_readerView belowSubview:_scanView];
    
    return YES;
}

#pragma mark - Draw
// 画自定义UI
-(void)drawCustomView
{
    UIView *scanView = [[UIView alloc] initWithFrame:self.cropRect];
    scanView.backgroundColor = [UIColor blueColor];
    scanView.alpha = 0.3;
    _scanView = scanView;
    [self.view addSubview:scanView];
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


#pragma mark - 自定义Delegate
- (void) readerView: (ZBarReaderView*) readerView
     didReadSymbols: (ZBarSymbolSet*) symbols
          fromImage: (UIImage*) image
{
    for (ZBarSymbol *sym in symbols) {
        NSLog(@"%@",sym.data);
        
        // 振动提示
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
        [_readerView stop];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [_readerView start];
        });
        
        break;
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

#pragma mark - 私有方法
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

-(void)startCapture
{
    [_readerView start];
}

-(void)stopCapture
{
    [_readerView stop];
}


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
