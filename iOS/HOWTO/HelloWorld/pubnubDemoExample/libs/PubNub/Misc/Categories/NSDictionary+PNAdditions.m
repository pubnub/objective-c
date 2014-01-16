//
//  NSDictionary+PNAdditions.m
//  pubnub
//
//  Created by Sergey Mamontov on 1/11/14.
//  Copyright (c) 2014 PubNub Inc. All rights reserved.
//

#import "NSDictionary+PNAdditions.h"


#pragma mark Public interface implementation

@implementation NSDictionary (PNAdditions)


#pragma mark - Instance methods

- (BOOL)isValidMetadata {

    __block BOOL isValidMetadata = YES;

    [self enumerateKeysAndObjectsUsingBlock:^(NSString *key, id value, BOOL *keysEnumeratorStop) {

        if ([key rangeOfString:@"^(_|pn)" options:NSRegularExpressionSearch].location != NSNotFound) {

            isValidMetadata = NO;
        }

        if (isValidMetadata) {

            isValidMetadata = ([value isKindOfClass:[NSNumber class]] || [value isKindOfClass:[NSString class]] ||
                               [value isKindOfClass:[NSNull class]]);
        }

        *keysEnumeratorStop = !isValidMetadata;
    }];


    return isValidMetadata;
}

#pragma mark -


@end
