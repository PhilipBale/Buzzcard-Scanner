//
//  ScannerViewController.m
//  GT Buzzcard Scanner
//
//  Created by Philip Bale on 10/29/15.
//  Copyright © 2015 Philip Bale. All rights reserved.
//

#import "ScannerViewController.h"
#import <TWMessageBarManager.h>
#import "BuzzcardScan.h"
#import <Realm/RLMRealm.h>

@interface ScannerViewController ()
{
}

@property NSMutableArray *alreadyFoundIds;
@property NSString *lastNumber;

@end

@implementation ScannerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
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
    BOOL alreadyFound = [self.alreadyFoundIds containsObject:buzzcardNumber];
    BOOL isLastFound = [self.lastNumber isEqualToString:buzzcardNumber];
    
    if (!alreadyFound) {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [[TWMessageBarManager sharedInstance] showMessageWithTitle:@"Found Buzzcard!"
                                                           description:buzzcardNumber
                                                                  type:TWMessageBarMessageTypeSuccess];
            [self.alreadyFoundIds addObject:buzzcardNumber];
            [self persistBuzzcardNumber:buzzcardNumber];
        });
    } else if (!isLastFound) {
        NSLog(@"Already found");
        dispatch_async(dispatch_get_main_queue(), ^{
            [[TWMessageBarManager sharedInstance] showMessageWithTitle:@"Already Found this Buzzcard!"
                                                           description:buzzcardNumber
                                                                  type:TWMessageBarMessageTypeError];
            
            [self persistBuzzcardNumber:buzzcardNumber];
        });
        
    }
    
    self.lastNumber = buzzcardNumber;
}

- (void)persistBuzzcardNumber:(NSString *)buzzcardNumber {
    [[RLMRealm defaultRealm] beginWriteTransaction];
    {
        BuzzcardScan *scan = [[BuzzcardScan alloc] init];
        [scan setBuzzcardNumber:buzzcardNumber];
        [scan setTimestamp:[[NSDate date] timeIntervalSince1970]];
        NSInteger previousScans = [BuzzcardScan objectsWhere:@"buzzcardNumber == %@", buzzcardNumber].count;
        [scan setScanNumber:previousScans + 1];
        [BuzzcardScan createInDefaultRealmWithValue:scan];
    }
    [[RLMRealm defaultRealm] commitWriteTransaction];
    
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
