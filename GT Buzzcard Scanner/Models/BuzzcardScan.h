//
//  BuzzcardScan.h
//  GT Buzzcard Scanner
//
//  Created by Philip Bale on 12/23/15.
//  Copyright © 2015 Philip Bale. All rights reserved.
//

#import <Realm/Realm.h>

@interface BuzzcardScan : RLMObject

@property NSString* scanId;
@property NSInteger timestamp; // Unix timestamp
@property NSString *buzzcardNumber;
@property NSInteger scanNumber; // Number of times this card has been scanned


@end

// This protocol enables typed collections. i.e.:
// RLMArray<BuzzcardScan>
RLM_ARRAY_TYPE(BuzzcardScan)
