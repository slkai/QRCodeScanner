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
    
    [self setScanView];
    
    _readerView= [[ZBarReaderView alloc] init];
    _readerView.frame =CGRectMake(0,64,self.view.frame.size.width, self.view.frame.size.height - 64);   // 全屏扫
    _readerView.tracksSymbols=NO;           //
    _readerView.readerDelegate =self;       // 代理
    _readerView.torchMode =0;               // 关闭闪光灯
    _readerView.zoom = 2.0;
    
    CGFloat cropW = self.view.frame.size.width;
    CGFloat cropH = self.view.frame.size.width;
    CGFloat cropX = (self.view.frame.size.width - cropW) * 0.5;
    CGFloat cropY = 44;
    
    CGFloat screenW = [UIScreen mainScreen].bounds.size.width;
    CGFloat screenH = [UIScreen mainScreen].bounds.size.height;
    
    CGFloat convertX = cropY / screenH;
    CGFloat convertY = ((screenW - cropW) / 2) / screenW;
    CGFloat convertW = cropH / screenH;
    CGFloat convertH = cropW / screenW;
    
    _readerView.scanCrop = CGRectMake(convertX,convertY,convertW,convertH);
    
    [_readerView addSubview:_scanView];

    [self.view addSubview:_readerView];
    
    [_readerView start];
}

-(void)viewDidAppear:(BOOL)animated
{
    [_readerView start];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [_readerView stop];
}



#pragma mark - Draw
// 设置scanView
-(void)setScanView
{
    UIView *scanView = [[UIView alloc] initWithFrame:CGRectMake((self.view.frame.size.width - 220) * 0.5, 44, 220, 220)];
    scanView.backgroundColor = [UIColor blueColor];
    scanView.alpha = 0.3;
    _scanView = scanView;
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
