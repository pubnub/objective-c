//
//  PNDeviceIndependentMatcherWithTiming.m
//  PubNub Tests
//
//  Created by Jordan Zucker on 4/11/16.
//
//

#import "PNDeviceIndependentMatcherWithTiming.h"

@implementation PNDeviceIndependentMatcherWithTiming

- (NSDictionary *)requestComparisonOptions {
    NSMutableDictionary *superComparisonOptions = [super requestComparisonOptions].mutableCopy;
    superComparisonOptions[kBKRIgnoreQueryItemNamesOptionsKey] = @[
                                                                   @"pnsdk"
                                                                   ];
    return superComparisonOptions.copy;
}

@end
