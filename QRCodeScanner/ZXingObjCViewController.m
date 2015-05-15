//
//  ZXingObjCViewController.m
//  QRCodeScanner
//
//  Created by dengjunjie on 15/5/14.
//  Copyright (c) 2015年 dengjunjie. All rights reserved.
//

#import "ZXingObjCViewController.h"

#import "ZXingObjC.h"

@interface ZXingObjCViewController () <ZXCaptureDelegate>

@property(nonatomic, strong) ZXCapture *capture;

@property(nonatomic, weak) UIView *scannerView;

@property(nonatomic, assign) BOOL isBusy;


// 其他变量
@property (nonatomic,weak) UIActivityIndicatorView *indicator;

@end

@implementation ZXingObjCViewController

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

#pragma mark - life cycle
- (void)dealloc
{
    
    NSLog(@"ZXingObjCViewController dealloc");
    [self.capture.layer removeFromSuperlayer];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor blackColor];
    
    self.capture = [[ZXCapture alloc] init];
    self.capture.camera = self.capture.back;
    self.capture.focusMode = AVCaptureFocusModeContinuousAutoFocus;
    self.capture.rotation = 90.0f;
    
    self.capture.layer.frame = self.view.bounds;
    [self.view.layer addSublayer:self.capture.layer];
    
    [self.view bringSubviewToFront:self.scannerView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    self.capture.delegate = self;
    self.capture.layer.frame = self.view.bounds;
    
    //    CGAffineTransform captureSizeTransform = CGAffineTransformMakeScale(320 / self.view.frame.size.width, 480 / self.view.frame.size.height);
    //    self.capture.scanRect = CGRectApplyAffineTransform(self.scannerView.frame, captureSizeTransform);
    
    CGFloat scanRectW = 200;
    CGFloat scanRectH = 200;
    CGFloat scanRectX = (self.view.frame.size.width - scanRectW) * 0.5;
    CGFloat scanRectY = 80;
    self.capture.scanRect = CGRectMake(scanRectX, scanRectY, scanRectW, scanRectH);
    [self drawScannerViewWithFrame:self.capture.scanRect];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [self.scannerView removeFromSuperview];
    self.scannerView = nil;
    
    [super viewDidDisappear:animated];
}

#pragma mark - delegate
- (void)captureResult:(ZXCapture *)capture result:(ZXResult *)result
{
    if (!result)
        return;
    
    NSLog(@"----%@", self.capture.running ? @"YES" : @"NO");
    
    if (self.capture.running)
    {
        
        
        if (!self.isBusy)
        {
            [self.capture stop];
            self.isBusy = YES;
            NSLog(@"扫码成功!");
            
            // 停止动画
            self.scannerView.layer.speed = 0;
            
            // 振动提示
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                self.isBusy = NO;
                [self.capture start];
            });
            

            
            
            NSLog(@"%@",result.text);
            
            // 跳到抢购页面
//            NSString *url = @"yaochufa://webview/http%3A%2F%2Factivity.yaochufa.com%2Fqueue%2F23%3Ftype%3D61%26active%3D20150509%26apptab";
//            [[YCFUrlHandleHelper shareInstance] handleOpenUrl:[NSURL URLWithString:url] defatuleTitle:@""];
            
        }
    }
    else
    {
        [self.capture stop];
    }
}

#pragma mark - Draw
-(void)drawScannerViewWithFrame:(CGRect)frame
{
    // 生成扫描框
    UIView *view = [[UIView alloc] initWithFrame:frame];
    view.backgroundColor = [UIColor blueColor];
    view.alpha = 0.3;
    self.scannerView = view;
    [self.view addSubview:view];
    
    UIImageView *line = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, view.bounds.size.width, 3)];
    line.backgroundColor = [UIColor orangeColor];
    [view addSubview:line];
    
    [UIView animateWithDuration:2.0 delay:0 options:UIViewAnimationOptionAutoreverse|UIViewAnimationOptionRepeat animations:^{
        line.frame = CGRectMake(0, view.bounds.size.height - 2, view.bounds.size.width, 3);
    } completion:^(BOOL finished) {
        
    }];
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

#pragma mark - 网络请求(request)

#pragma mark - 数据处理(dealWith)

#pragma mark - 系统Delegate

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
