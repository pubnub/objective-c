//
//  PNDeviceIndependentMatcher.m
//  PubNub Tests
//
//  Created by Jordan Zucker on 10/30/15.
//
//

#import "PNDeviceIndependentMatcher.h"

@implementation PNDeviceIndependentMatcher

- (NSDictionary *)requestComparisonOptions {
    NSMutableDictionary *superComparisonOptions = [super requestComparisonOptions].mutableCopy;
    superComparisonOptions[kBKRIgnoreQueryItemNamesOptionsKey] = @[
                                                                   @"pnsdk",
                                                                   @"l_pub",
                                                                   @"l_hist",
                                                                   @"l_pres",
                                                                   @"l_cg",
                                                                   @"l_push",
                                                                   @"l_time"
                                                         ];
    return superComparisonOptions.copy;
}

@end
