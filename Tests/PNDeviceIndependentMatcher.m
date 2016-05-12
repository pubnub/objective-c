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
                                                         @"pnsdk"
                                                         ];
    return superComparisonOptions.copy;
}

@end
