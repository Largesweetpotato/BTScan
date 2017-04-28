//
//  BTScanViewController.h
//  AssetsTaking
//
//  Created by WangJiadong on 2017/2/8.
//  Copyright © 2017年 WangJiadong. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BTScanViewController : UIViewController

@property (nonatomic, copy) void (^returnScanStringBlock)(NSString *);
@property (nonatomic, assign) double scanLineDuration;
@property (nonatomic, copy) NSString *customTitle;

@end
