//
//  HistoryViewController.m
//  GT Buzzcard Scanner
//
//  Created by Philip Bale on 10/29/15.
//  Copyright © 2015 Philip Bale. All rights reserved.
//

#import "HistoryViewController.h"
#import "BuzzcardScan.h"
#import <DateTools.h>
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>


@interface HistoryViewController ()<MFMailComposeViewControllerDelegate>

@property RLMResults *scans;

@end

@implementation HistoryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    self.scans = [[BuzzcardScan allObjects] sortedResultsUsingProperty:@"timestamp" ascending:NO];
    self.automaticallyAdjustsScrollViewInsets = NO;
}

- (void)viewDidAppear:(BOOL)animated
{
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.scans.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"scanCell" forIndexPath:indexPath];
    BuzzcardScan *scan = [self.scans objectAtIndex:indexPath.row];
    NSString *labelText = [NSString stringWithFormat:@"%@ (%li)", scan.buzzcardNumber, scan.scanNumber];
    cell.textLabel.text = labelText;
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:scan.timestamp];
    cell.detailTextLabel.text = [date timeAgoSinceNow];
    return cell;
}

- (IBAction)sendButtonClicked:(id)sender {
    MFMailComposeViewController *composer = [[MFMailComposeViewController alloc] init];
    composer.mailComposeDelegate = self;
    
    [composer setSubject:@"Buzzcard Scan Data"];
    
    NSString *scanData = @"Buzzcard Number, Scan Number, Date, Time \r\n";
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    [dateFormatter setDateStyle:NSDateFormatterShortStyle];
    for (BuzzcardScan *scan in self.scans) {
        NSDate *timestamp = [NSDate dateWithTimeIntervalSince1970:scan.timestamp];
        NSString *scanEntry = [NSString stringWithFormat:@"%@, %li, %@ \r\n", scan.buzzcardNumber, scan.scanNumber, [dateFormatter stringFromDate:timestamp]];
        scanData = [scanData stringByAppendingString:scanEntry];
    }
    
    [composer addAttachmentData:[scanData dataUsingEncoding:NSUTF8StringEncoding]
                       mimeType:@"text/plain"
                       fileName:@"BuzzcardData.csv"];
    NSString *emailBody = @"Here is some Buzzcard data that I collected from the GT Buzzcard Scanner.  Please check out GT Buzzcard Scanner on the App Store.";
    [composer setMessageBody:emailBody isHTML:YES];
    
    [self presentViewController:composer animated:YES completion:nil];
}

-(void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error{
    [controller dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)clearButtonClicked:(id)sender {
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Clear History Confirmation"
                                                                   message:@"Are you sure you want to clear the scan history?"
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel"
                                                           style:UIAlertActionStyleCancel handler:^(UIAlertAction * action) {
                                                               NSLog(@"Clear Cancelled");
                                                           }];
    UIAlertAction *clearAction = [UIAlertAction actionWithTitle:@"Clear"
                                                          style:UIAlertActionStyleDestructive handler:^(UIAlertAction * action) {
                                                              NSLog(@"Clear Confirmed");
                                                              [[RLMRealm defaultRealm] beginWriteTransaction];
                                                              {
                                                                  [[RLMRealm defaultRealm] deleteObjects:self.scans];
                                                              }
                                                              [[RLMRealm defaultRealm] commitWriteTransaction];
                                                              dispatch_async(dispatch_get_main_queue(), ^{
                                                                  [self.tableView reloadData];
                                                              });
                                                          }];
    
    [alert addAction:cancelAction];
    [alert addAction:clearAction];
    
    [self presentViewController:alert animated:YES completion:nil];
}

@end
