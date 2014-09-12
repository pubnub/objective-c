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
- (BOOL)pn_isValidState:(BOOL)isFirstLevelNesting;

#pragma mark -


@end


#pragma mark - Public interface implementation

@implementation NSDictionary (PNAdditions)


#pragma mark - Instance methods

- (BOOL)pn_isValidState {

    return [self count] && [self pn_isValidState:YES];
}

- (BOOL)pn_isValidState:(BOOL)isFirstLevelNesting {

    __block BOOL isValidState = YES;


    [self enumerateKeysAndObjectsUsingBlock:^(NSString *key, id value, BOOL *keysEnumeratorStop) {

        if ([value isKindOfClass:[NSDictionary class]]) {

            isValidState = NO;
            if (isFirstLevelNesting) {

                isValidState = [value pn_isValidState:NO];
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

- (NSString *)logDescription {
    
    __block NSString *logDescription = @"<{";
    __block NSUInteger entryIdx = 0;
    
    [self enumerateKeysAndObjectsUsingBlock:^(NSString *entryKey, id entry, BOOL *entryEnumeratorStop) {
        
        // Check whether parameter can be transformed for log or not
        if ([entry respondsToSelector:@selector(logDescription)]) {
            
            entry = [entry performSelector:@selector(logDescription)];
            entry = (entry ? entry : @"");
        }
        logDescription = [logDescription stringByAppendingFormat:@"%@:%@%@", entryKey, entry, (entryIdx + 1 != [self count] ? @"|" : @"}>")];
        entryIdx++;
    }];
    
    
    return logDescription;
}

#pragma mark -


@end
