//
//  OriginalViewController.h
//  QRCodeScanner
//
//  Created by dengjunjie on 15/5/14.
//  Copyright (c) 2015年 dengjunjie. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OriginalViewController : UIViewController


@property (nonatomic,assign) CGRect cropRect;   // 扫描区域


@property (nonatomic,assign) BOOL qrcodeFlag;   // 只需要二维码时，传YES

@end
