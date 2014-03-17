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
 Method allow to check on nested objects whether valid dictionary has been provided for state or not.

 @param isFirstLevelNesting
 If set to \c YES, then values will be checked to be simple type in other case dictionary is allowed.

 @return \c YES if provided dictionary conforms to the requirements.
*/
- (BOOL)isValidState:(BOOL)isFirstLevelNesting;

#pragma mark -


@end


#pragma mark - Public interface implementation

@implementation NSDictionary (PNAdditions)


#pragma mark - Instance methods

- (BOOL)isValidState {

    return [self count] && [self isValidState:YES];
}

- (BOOL)isValidState:(BOOL)isFirstLevelNesting {

    __block BOOL isValidState = YES;


    [self enumerateKeysAndObjectsUsingBlock:^(NSString *key, id value, BOOL *keysEnumeratorStop) {

        if ([value isKindOfClass:[NSDictionary class]]) {

            isValidState = NO;
            if (isFirstLevelNesting) {

                isValidState = [value isValidState:NO];
            }
        }
        else {

            isValidState = ([value isKindOfClass:[NSNumber class]] || [value isKindOfClass:[NSString class]] ||
                               [value isKindOfClass:[NSNull class]]);
        }

        *keysEnumeratorStop = !isValidState;
    }];


    return isValidState;
}

#pragma mark -


@end
