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

@end

@implementation ZXingObjCViewController


#pragma mark - life cycle
- (void)dealloc
{
    
    NSLog(@"YCFQrcodeScanViewController dealloc");
    [self.capture.layer removeFromSuperlayer];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
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

#pragma mark - draw
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
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                self.isBusy = NO;
            });
            
            [self.navigationController popViewControllerAnimated:NO];
//            [YCFGlobalNavigationCtrl popViewControllerAnimated:NO];
            
            
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

#pragma mark - 网络请求(request)

#pragma mark - 数据处理(dealWith)

#pragma mark - 系统Delegate

#pragma mark - 自定义Delegate

#pragma mark - 通知（handle）

#pragma mark - IBAction(Action结尾)

#pragma mark - 私有方法(p_xxx)

#pragma mark - getter

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
