//
//  BTScanViewController.m
//  AssetsTaking
//
//  Created by WangJiadong on 2017/2/8.
//  Copyright © 2017年 WangJiadong. All rights reserved.
//

#import "BTScanViewController.h"
#import <AVFoundation/AVFoundation.h>

//屏幕的宽高
#define WJDScreenW [UIScreen mainScreen].bounds.size.width
#define WJDScreenH [UIScreen mainScreen].bounds.size.height
#define WJDScreenB [UIScreen mainScreen].bounds

#define ScanSpaceOFFSET 0.15f

@interface BTScanViewController ()<AVCaptureMetadataOutputObjectsDelegate>

@property (nonatomic,strong) AVCaptureSession *session;
@property (nonatomic,strong) AVCaptureDeviceInput *input;
@property (nonatomic,strong) AVCaptureMetadataOutput *output;
@property (nonatomic,strong) AVCaptureVideoPreviewLayer *previewLayer;


@property (nonatomic,strong) CAShapeLayer *maskLayer;
@property (nonatomic,strong) CAShapeLayer *shadowLayer;
@property (nonatomic,strong) CAShapeLayer *scanRectLayer;

@property (nonatomic,assign) CGRect scanRect;
@property (nonatomic,strong) UILabel *remindLable;

//扫描线的frame
@property (nonatomic,assign) CGRect scanFrame;
//扫描线view
@property (nonatomic,strong )UIImageView *scanLineImageView;

@end

@implementation BTScanViewController

-(void)viewWillAppear:(BOOL)animated{
 
    [super viewWillAppear:animated];
    [self start];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
}
-(void)setupUI{

    self.view.backgroundColor = [UIColor colorWithWhite:0.f alpha:0.1f];
    [self.view.layer addSublayer:self.previewLayer];
    [self setupRectOfInterest];
    [self.view addSubview:self.remindLable];
    self.view.layer.masksToBounds = YES;
    self.navigationItem.title = self.customTitle != nil ? self.customTitle : @"二维码/条形码";
    UIImage *image = [[UIImage alloc] init];
    [self.navigationController.navigationBar setBackgroundImage:image forBarMetrics:UIBarMetricsDefault];
    
    self.navigationController.navigationBar.barStyle = UIBarStyleBlackOpaque;
}
#pragma mark ----开始扫描方法
-(void) start{
    
    CGRect scanF = self.scanFrame;
    //扫描线
    UIImageView *scanLineImageView = [[UIImageView alloc] initWithFrame: CGRectMake(scanF.origin.x, scanF.origin.y, scanF.size.width, 2)];
    
    scanLineImageView.image = [UIImage imageNamed:@"wanggexian"];
    self.scanLineImageView = scanLineImageView;
    [self.view addSubview:self.scanLineImageView];
    /* 添加动画 */
    [UIView animateWithDuration:self.scanLineDuration delay:0.0 options:UIViewAnimationOptionRepeat animations:^{
        
        self.scanLineImageView.frame = self.scanFrame;
        
    } completion:nil];
    [self.session startRunning];
    
}

- (AVCaptureSession *)session{
    if (!_session) {
        _session = [AVCaptureSession new];
        [_session setSessionPreset: AVCaptureSessionPresetHigh];
        [self setupIODevice];
    }
    return _session;
}

- (AVCaptureDeviceInput *)input{
    if (!_input) {
        AVCaptureDevice * device = [AVCaptureDevice defaultDeviceWithMediaType: AVMediaTypeVideo];
        _input = [AVCaptureDeviceInput deviceInputWithDevice: device error: nil];
    }
    return _input;
}

- (AVCaptureMetadataOutput *)output{
    if (!_output) {
        _output = [AVCaptureMetadataOutput new];
        [_output setMetadataObjectsDelegate: self queue: dispatch_get_main_queue()];
    }
    return _output;
}

- (AVCaptureVideoPreviewLayer *)previewLayer{
    if (!_previewLayer) {
        _previewLayer = [AVCaptureVideoPreviewLayer layerWithSession: self.session];
        _previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
        _previewLayer.frame = self.view.bounds;
    }
    return _previewLayer;
}

- (CGRect)scanRect{
    if (CGRectEqualToRect(_scanRect, CGRectZero)) {
        CGRect rectOfInterest = self.output.rectOfInterest;
        CGFloat xOffset = 1 - 2 * ScanSpaceOFFSET;
        _scanRect = CGRectMake(rectOfInterest.origin.y * WJDScreenW, rectOfInterest.origin.x * WJDScreenH, xOffset * WJDScreenW, xOffset * WJDScreenW);
        
    }
    return _scanRect;
}

- (UILabel *)remindLable{
    if (!_remindLable) {
        CGRect textRect = self.scanRect;
        textRect.origin.y += CGRectGetHeight(textRect) + 20;
        textRect.size.height = 25.f;
        
        _remindLable = [[UILabel alloc] initWithFrame: textRect];
        _remindLable.font = [UIFont systemFontOfSize: 15.f * WJDScreenW / 375.f];
        _remindLable.textColor = [UIColor colorWithWhite:.8f alpha:.8f];
        _remindLable.textAlignment = NSTextAlignmentCenter;
        _remindLable.text = @"请在扫描框内扫描";
        _remindLable.backgroundColor = [UIColor clearColor];
    }
    return _remindLable;
}

#pragma mark >> layer <<
/**
 *  扫描框
 */
- (CAShapeLayer *)scanRectLayer{
    if (!_scanRectLayer) {
        CGRect scanRect = self.scanRect;
        scanRect.origin.x -= 1;
        scanRect.origin.y -= 1;
        scanRect.size.width += 2;
        scanRect.size.height += 2;
        
        _scanRectLayer = [CAShapeLayer layer];
        _scanRectLayer.path = [UIBezierPath bezierPathWithRect: scanRect].CGPath;
        _scanRectLayer.fillColor = [UIColor clearColor].CGColor;
        _scanRectLayer.strokeColor = [UIColor orangeColor].CGColor;
        _scanRectLayer.lineDashPattern = @[@50,@70];
        
    }
    return _scanRectLayer;
}

#pragma mark ----懒加载
-(CAShapeLayer *)shadowLayer{
    
    if (!_shadowLayer) {
        _shadowLayer = [CAShapeLayer layer];
        
        _shadowLayer.path = [UIBezierPath bezierPathWithRect:self.view.bounds].CGPath;
        _shadowLayer.fillColor = [UIColor colorWithWhite:0 alpha:0.75].CGColor;
        _shadowLayer.mask = self.maskLayer;
    }
    
    return _shadowLayer;
}

-(CAShapeLayer *)maskLayer{
    if (!_maskLayer) {
        
        _maskLayer = [CAShapeLayer layer];
        _maskLayer = [self generateMaskLayerWithRect:WJDScreenB exceptRect:self.scanRect];
    }
    return _maskLayer;
}

- (CAShapeLayer *)generateMaskLayerWithRect: (CGRect)rect exceptRect: (CGRect)exceptRect
{
    CAShapeLayer * maskLayer = [CAShapeLayer layer];
    if (!CGRectContainsRect(rect, exceptRect)) {
        return nil;
    }
    else if (CGRectEqualToRect(rect, CGRectZero)) {
        maskLayer.path = [UIBezierPath bezierPathWithRect: rect].CGPath;
        return maskLayer;
    }

    CGFloat boundsInitX = CGRectGetMinX(rect);
    CGFloat boundsInitY = CGRectGetMinY(rect);
    CGFloat boundsWidth = CGRectGetWidth(rect);
    CGFloat boundsHeight = CGRectGetHeight(rect);

    CGFloat minX = CGRectGetMinX(exceptRect);
    CGFloat maxX = CGRectGetMaxX(exceptRect);
    CGFloat minY = CGRectGetMinY(exceptRect);
    CGFloat maxY = CGRectGetMaxY(exceptRect);
    CGFloat width = CGRectGetWidth(exceptRect);
    CGFloat height = CGRectGetHeight(exceptRect);

    self.scanFrame = CGRectMake(minX, minY, width, height);

    UIBezierPath * path = [UIBezierPath bezierPathWithRect: CGRectMake(boundsInitX, boundsInitY, minX, boundsHeight)];
    [path appendPath: [UIBezierPath bezierPathWithRect: CGRectMake(minX, boundsInitY, width, minY)]];
    [path appendPath: [UIBezierPath bezierPathWithRect: CGRectMake(maxX, boundsInitY, boundsWidth - maxX, boundsHeight)]];
    [path appendPath: [UIBezierPath bezierPathWithRect: CGRectMake(minX, maxY, width, boundsHeight - maxY)]];
    maskLayer.path = path.CGPath;
    
    return maskLayer;
}

-(void) setupIODevice{
    
    if ([self.session canAddInput:self.input]) {
        [_session addInput:_input];
    }
    if ([self.session canAddOutput:self.output]) {
        [_session addOutput:_output];
        _output.metadataObjectTypes = @[
                                AVMetadataObjectTypeUPCECode,
                                AVMetadataObjectTypeCode39Code,
                                AVMetadataObjectTypeCode39Mod43Code,
                                AVMetadataObjectTypeEAN13Code,
                                AVMetadataObjectTypeEAN8Code,
                                AVMetadataObjectTypeCode93Code,
                                AVMetadataObjectTypeCode128Code,
                                AVMetadataObjectTypePDF417Code,
                                AVMetadataObjectTypeQRCode,
                                AVMetadataObjectTypeAztecCode,
                                AVMetadataObjectTypeInterleaved2of5Code,
                                AVMetadataObjectTypeITF14Code,
                                AVMetadataObjectTypeDataMatrixCode];
    }
}

-(void) setupRectOfInterest{
    
    CGFloat size = WJDScreenW *(1 - 2 * ScanSpaceOFFSET);
    CGFloat minY = (WJDScreenH - size) * 0.4 / WJDScreenH;
    self.output.rectOfInterest = CGRectMake(minY, ScanSpaceOFFSET, size / WJDScreenH, 1 - ScanSpaceOFFSET *2);
    
    [self.view.layer addSublayer:self.shadowLayer];
    [self.view.layer addSublayer:self.scanRectLayer];
}

-(void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection{
    
    if (metadataObjects.count > 0) {
        
        AVMetadataMachineReadableCodeObject *metadataObject = metadataObjects[0];

        NSString *str = [NSString stringWithFormat:@"%@",metadataObject.stringValue];
        [self stop];
        [self.scanLineImageView removeFromSuperview];
        !self.returnScanStringBlock ?  : self.returnScanStringBlock(str);
        [self.navigationController popViewControllerAnimated:YES];
    }
}

-(void) stop{
    
    [self.session stopRunning];
}
/**
 *  释放前停止会话
 */
- (void)dealloc
{
    [self stop];
}

@end
