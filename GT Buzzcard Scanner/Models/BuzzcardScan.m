//
//  BuzzcardScan.m
//  GT Buzzcard Scanner
//
//  Created by Philip Bale on 12/23/15.
//  Copyright © 2015 Philip Bale. All rights reserved.
//

#import "BuzzcardScan.h"

@implementation BuzzcardScan

+ (NSString *)primaryKey
{
    return @"scanId";
}

+ (NSDictionary *)defaultPropertyValues {
    return @{@"scanId": [[NSUUID UUID] UUIDString]};
}

@end
