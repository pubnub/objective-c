//
//  NSDictionary+PNAdditions.m
//  pubnub
//
//  Created by Sergey Mamontov on 1/11/14.
//  Copyright (c) 2014 PubNub Inc. All rights reserved.
//

#import "NSDictionary+PNAdditions.h"


#pragma mark Private interface declaration

@interface NSDictionary (PNAdditionsPrivate)


#pragma mark - Instance methods

/**
 Method allow to check on nested objects whether valid dictionary has been provided for metadata or not.

 @param isFirstLevelNesting
 If set to \c YES, then values will be checked to be simple type in other case dictionary is allowed.

 @return \c YES if provided dictionary conforms to the requirements.
*/
- (BOOL)isValidMetadata:(BOOL)isFirstLevelNesting;

#pragma mark -


@end


#pragma mark - Public interface implementation

@implementation NSDictionary (PNAdditions)


#pragma mark - Instance methods

- (BOOL)isValidMetadata {

    return [self isValidMetadata:YES];
}

- (BOOL)isValidMetadata:(BOOL)isFirstLevelNesting {

    __block BOOL isValidMetadata = YES;


    [self enumerateKeysAndObjectsUsingBlock:^(NSString *key, id value, BOOL *keysEnumeratorStop) {

        if ([value isKindOfClass:[NSDictionary class]]) {

            isValidMetadata = NO;
            if (isFirstLevelNesting) {

                isValidMetadata = [value isValidMetadata:NO];
            }
        }
        else {

            isValidMetadata = ([value isKindOfClass:[NSNumber class]] || [value isKindOfClass:[NSString class]] ||
                               [value isKindOfClass:[NSNull class]]);
        }

        *keysEnumeratorStop = !isValidMetadata;
    }];


    return isValidMetadata;
}

#pragma mark -


@end
