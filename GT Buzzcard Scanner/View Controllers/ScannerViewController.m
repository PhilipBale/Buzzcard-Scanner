//
//  ScannerViewController.m
//  GT Buzzcard Scanner
//
//  Created by Philip Bale on 10/29/15.
//  Copyright © 2015 Philip Bale. All rights reserved.
//

#import "ScannerViewController.h"
#import <TWMessageBarManager.h>


@interface ScannerViewController ()
{
}

@property NSMutableArray *alreadyFoundIds;
@property NSString *lastNumber;

@end

@implementation ScannerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //    self.scanner = [[RSScannerViewController alloc] initWithCornerView:YES
    //                                                           controlView:YES
    //                                                       barcodesHandler:^(NSArray *barcodeObjects) {
    //                                                           for (AVMetadataObject *metaData in barcodeObjects) {
    //                                                               NSLog(@"Buzzcard number: %@", [metaData valueForKey:@"stringValue"]);
    //                                                               [TSMessage showNotificationInViewController:self.scanner
    //                                                                                                     title:@"Update available"
    //                                                                                                  subtitle:@"Please update the app"
    //                                                                                                     image:nil
    //                                                                                                      type:TSMessageNotificationTypeMessage
    //                                                                                                  duration:TSMessageNotificationDurationAutomatic
    //                                                                                                  callback:nil
    //                                                                                               buttonTitle:nil
    //                                                                                            buttonCallback:nil
    //                                                                                                atPosition:TSMessageNotificationPositionTop
    //                                                                                      canBeDismissedByUser:YES];
    //                                                           }
    //                                                       }
    //                                               preferredCameraPosition:AVCaptureDevicePositionBack];
    
    // Do any additional setup after loading the view.
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.alreadyFoundIds = [[NSMutableArray alloc] init];
        self.lastNumber = @"";
        
        
        __weak typeof(self) weakSelf = self;
        self.barcodesHandler = ^(NSArray *barcodeObjects) {
            NSLog(@"Found a barcode");
            for (AVMetadataObject *metadata in barcodeObjects) {
                NSString *buzzcardNumber = [metadata valueForKey:@"stringValue"];
                [weakSelf processBuzzcardNumber:buzzcardNumber];
                
            }
        };
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self setupUI];
        });
    }
    return self;
}

- (void)setupUI
{
    
    [self.scannerView setBackgroundColor:[UIColor clearColor]];
    self.scannerView.layer.borderWidth = 2;
    [self.scannerView.layer setBorderColor: [UIColor redColor].CGColor];
}

- (void)processBuzzcardNumber:(NSString *)buzzcardNumber
{
    if (![self.alreadyFoundIds containsObject:buzzcardNumber]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [[TWMessageBarManager sharedInstance] showMessageWithTitle:@"Found Buzzcard!"
                                                           description:buzzcardNumber
                                                                  type:TWMessageBarMessageTypeSuccess];
            [self.alreadyFoundIds addObject:buzzcardNumber];
        });
    } else if (![self.lastNumber isEqualToString:buzzcardNumber]) {
        NSLog(@"Already found");
        dispatch_async(dispatch_get_main_queue(), ^{
            [[TWMessageBarManager sharedInstance] showMessageWithTitle:@"Already Found this Buzzcard!"
                                                           description:buzzcardNumber
                                                                  type:TWMessageBarMessageTypeError];
        });
        
    }
    
    self.lastNumber = buzzcardNumber;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    //    dispatch_async(dispatch_get_main_queue(), ^{
    //        [self showScanner];
    //    });
}

- (void)showScanner
{
    [self presentViewController:self.scanner animated:YES completion:^{
        
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
