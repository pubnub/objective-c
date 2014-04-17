//
//  PNNumberBadgeView.m
//  pubnub
//
//  Created by Sergey Mamontov on 3/24/14.
//  Copyright (c) 2014 PubNub Inc. All rights reserved.
//

#import "PNNumberBadgeView.h"


#pragma mark Public interface implementation

@implementation PNNumberBadgeView


#pragma mark - Instance methods

- (void)updateIntegerBadgeValueTo:(NSInteger)badgeValue {
    
    [super updateBadgeValueTo:[NSString stringWithFormat:@"%d", (unsigned int)badgeValue]];
}

#pragma mark -


@end
