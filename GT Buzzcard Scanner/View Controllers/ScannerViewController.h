//
//  ScannerViewController.h
//  GT Buzzcard Scanner
//
//  Created by Philip Bale on 10/29/15.
//  Copyright © 2015 Philip Bale. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <RSBarcodes/RSBarcodes.h>

@interface ScannerViewController : RSScannerViewController

@property (nonatomic, strong) RSScannerViewController *scanner;
@property (weak, nonatomic) IBOutlet UIView *scannerView;

@end
