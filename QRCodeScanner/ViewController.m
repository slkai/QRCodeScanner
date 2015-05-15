//
//  ViewController.m
//  QRCodeScanner
//
//  Created by dengjunjie on 15/5/14.
//  Copyright (c) 2015年 dengjunjie. All rights reserved.
//

#import "ViewController.h"

#import "OriginalViewController.h"
#import "ZXingObjCViewController.h"
#import "ZBarSDKViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    // 原生按钮
    UIButton *originalBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 100, 30)];
    originalBtn.backgroundColor = [UIColor grayColor];
    originalBtn.center = CGPointMake(self.view.center.x, self.view.center.y - 60);
    originalBtn.tag = 101;
    [originalBtn setTitle:@"原生" forState:UIControlStateNormal];
    [originalBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:originalBtn];
    
    // ZXingObjC按钮
    UIButton *originalZXing = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 100, 30)];
    originalZXing.backgroundColor = [UIColor grayColor];
    originalZXing.tag = 102;
    originalZXing.center = CGPointMake(self.view.center.x, self.view.center.y);
    [originalZXing setTitle:@"ZXingObjC" forState:UIControlStateNormal];
    [originalZXing addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:originalZXing];
    
    // ZBarSDK按钮
    UIButton *originalZBar = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 100, 30)];
    originalZBar.backgroundColor = [UIColor grayColor];
    originalZBar.tag = 103;
    originalZBar.center = CGPointMake(self.view.center.x, self.view.center.y + 60);
    [originalZBar setTitle:@"ZBarSDK" forState:UIControlStateNormal];
    [originalZBar addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:originalZBar];
    
}

-(void)btnClick:(UIButton *)btn
{
    switch (btn.tag) {
        case 101:{
            OriginalViewController *scanner = [[OriginalViewController alloc] init];
            [self.navigationController pushViewController:scanner animated:YES];
        }
            break;
            
        case 102:{
            ZXingObjCViewController *scanner = [[ZXingObjCViewController alloc] init];
            [self.navigationController pushViewController:scanner animated:YES];
        }
            break;
            
        case 103:{
            ZBarSDKViewController *scanner = [[ZBarSDKViewController alloc] init];
            [self.navigationController pushViewController:scanner animated:YES];
        }
            break;
            
        default:
            break;
    }
}

@end
