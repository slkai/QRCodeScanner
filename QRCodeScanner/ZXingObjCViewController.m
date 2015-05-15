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
    
    // 画自定义UI
    [self drawCustomView];
    
    // 秀菊花
    [self showLoading];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    // 配置摄像头
    if ([self setupCamera])
    {
        [self hideLoading];
    }
    else
    {
        [self hideLoading];
        // 提示
        [self showAlertWithTitle:nil andMessage:@"请在iPhone的“设置-私隐-相机”选项中，允许要出发周边游访问你的相机"];
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [self.scannerView removeFromSuperview];
    self.scannerView = nil;
    
    [self stopCapture];
    
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

// AlertView代理
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        NSLog(@"确定");
        // 返回上一级
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark - Draw
// 画自定义UI
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

#pragma mark - 私有方法(p_xxx)
// 配置相机
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
    
    self.capture = [[ZXCapture alloc] init];
    self.capture.camera = self.capture.back;
    self.capture.focusMode = AVCaptureFocusModeContinuousAutoFocus;
    self.capture.rotation = 90.0f;
    
    [self.view.layer insertSublayer:self.capture.layer atIndex:0];  // 添加层之后就开始运行了
    
    self.capture.layer.frame = self.view.bounds;
    self.capture.delegate = self;
    
    //    CGAffineTransform captureSizeTransform = CGAffineTransformMakeScale(320 / self.view.frame.size.width, 480 / self.view.frame.size.height);
    //    self.capture.scanRect = CGRectApplyAffineTransform(self.scannerView.frame, captureSizeTransform);
    
    self.capture.scanRect = self.cropRect;
    
    return YES;
}

// 停止摄像
-(void)stopCapture
{
    [self.capture stop];
}

// 显示提示框
-(void)showAlertWithTitle:(NSString *)title andMessage:(NSString *)message
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
    [alertView show];
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
