//
//  ViewController.m
//  BTScanVC
//
//  Created by WangJiadong on 2017/3/16.
//  Copyright © 2017年 WangJiadong. All rights reserved.
//

#import "ViewController.h"
#import "BTScanViewController.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UILabel *scanResultLabel;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

}

- (IBAction)scanBtnClick:(id)sender {
    
    BTScanViewController *scanVC = [[BTScanViewController alloc] init];
    [self.navigationController pushViewController:scanVC animated:YES];
    scanVC.scanLineDuration = 1.0;
    scanVC.customTitle = @"scan";
    scanVC.returnScanStringBlock = ^(NSString * returnStr){
    
        NSLog(@"%@",returnStr);
        self.scanResultLabel.text = returnStr;

    };
}

@end
