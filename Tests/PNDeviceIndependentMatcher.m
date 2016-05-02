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
    superComparisonOptions[kBKROverrideNSURLComponentsPropertiesOptionsKey] = @[@"path"];
    return superComparisonOptions.copy;
}

- (BOOL)hasMatchForURLComponent:(NSString *)URLComponent withRequestComponentValue:(id)requestComponentValue possibleMatchComponentValue:(id)possibleMatchComponentValue {
    if ([URLComponent isEqualToString:@"path"]) {
        if (!requestComponentValue && !possibleMatchComponentValue) {
            return YES;
        }
        if (
            (!requestComponentValue && possibleMatchComponentValue) ||
            (requestComponentValue && !possibleMatchComponentValue)
            ) {
            return NO;
        }
        if (
            ![requestComponentValue isKindOfClass:[NSString class]] ||
            ![possibleMatchComponentValue isKindOfClass:[NSString class]]
            ) {
            NSLog(@"How can a path not be a string?");
            return NO;
        }
        NSString *requestPath = (NSString *)requestComponentValue;
        NSString *possibleMatchPath = (NSString *)possibleMatchComponentValue;
        
        if (
            [requestPath.lastPathComponent hasPrefix:@"{"] &&
            [possibleMatchPath.lastPathComponent hasPrefix:@"{"]
            ) {
            
            // first compare rest of path
            NSString *restOfPath = [requestPath stringByDeletingLastPathComponent];
            NSString *otherRestOfPath = [possibleMatchPath stringByDeletingLastPathComponent];
            if (![restOfPath isEqualToString:otherRestOfPath]) {
                return NO;
            }
            
            // Now convert publish to JSON and compare objects
            NSData *data = [requestPath.lastPathComponent dataUsingEncoding:NSUTF8StringEncoding];
            NSData *possibleMatchData = [requestPath.lastPathComponent dataUsingEncoding:NSUTF8StringEncoding];
            id message = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
            id possibleMatchMessage = [NSJSONSerialization JSONObjectWithData:possibleMatchData options:kNilOptions error:nil];
            if (![message isEqual:possibleMatchMessage]) {
                return NO;
            }
            return YES;
        } else {
            return [requestPath isEqualToString:possibleMatchPath];
        }
    }
    return YES;
}

@end
