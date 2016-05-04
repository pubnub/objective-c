//
//  PNDeviceIndependentMatcher.m
//  PubNub Tests
//
//  Created by Jordan Zucker on 10/30/15.
//
//

#import "PNDeviceIndependentMatcher.h"

typedef NSArray<NSURLQueryItem *> PNQueryItemArray;

@implementation PNDeviceIndependentMatcher

- (NSDictionary *)requestComparisonOptions {
    NSMutableDictionary *superComparisonOptions = [super requestComparisonOptions].mutableCopy;
    // ignored query items won't be passed to the override method
    superComparisonOptions[kBKRIgnoreQueryItemNamesOptionsKey] = @[
                                                         @"pnsdk"
                                                         ];
    superComparisonOptions[kBKROverrideNSURLComponentsPropertiesOptionsKey] = @[@"path", @"queryItems"];
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
    } else if ([URLComponent isEqualToString:@"queryItems"]) {
        PNQueryItemArray *requestQueryItems = (PNQueryItemArray *)requestComponentValue;
        PNQueryItemArray *otherRequestQueryItems = (PNQueryItemArray *)possibleMatchComponentValue;
        // need to separate into two arrays, one with query items that need to be turned into objects and one for everything else
        NSArray<NSString *> *specialQueryItemsNames = @[
                                                        @"state",
                                                        ];
        
        // pull out all simple matching query items
        NSPredicate *removeSpecialQueryItemNamesPredicate = [NSPredicate predicateWithFormat:@"NOT (name IN %@)", specialQueryItemsNames];
        PNQueryItemArray *simpleRequestQueryItems = [requestQueryItems filteredArrayUsingPredicate:removeSpecialQueryItemNamesPredicate];
        PNQueryItemArray *simpleOtherRequestQueryItems = [otherRequestQueryItems filteredArrayUsingPredicate:removeSpecialQueryItemNamesPredicate];
        
        BOOL simpleMatch = [NSURLComponents BKR_componentQueryItems:simpleRequestQueryItems matchesOtherComponentQueryItems:simpleOtherRequestQueryItems withOptions:[self requestComparisonOptions]];
        
        // pull out all special query items
        NSPredicate *removeNonSpecialQueryItemNamesPredicate = [NSPredicate predicateWithFormat:@"(name IN %@)", specialQueryItemsNames];
        PNQueryItemArray *objectRequestQueryItems = [requestQueryItems filteredArrayUsingPredicate:removeNonSpecialQueryItemNamesPredicate];
        PNQueryItemArray *objectOtherRequestQueryItems = [otherRequestQueryItems filteredArrayUsingPredicate:removeNonSpecialQueryItemNamesPredicate];
        
        BOOL objectMatch = YES;
        for (NSInteger i=0; i<objectRequestQueryItems.count; i++) {
            NSURLQueryItem *queryItem = objectRequestQueryItems[i];
            NSURLQueryItem *otherQueryItem = objectOtherRequestQueryItems[i];
            // Now convert publish to JSON and compare objects
            NSData *data = [queryItem.value dataUsingEncoding:NSUTF8StringEncoding];
            NSData *possibleMatchData = [otherQueryItem.value dataUsingEncoding:NSUTF8StringEncoding];
            id object = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
            id otherObject = [NSJSONSerialization JSONObjectWithData:possibleMatchData options:kNilOptions error:nil];
            if (![object isEqual:otherObject]) {
                objectMatch = NO;
                break;
            }
        }
        
        return (
                simpleMatch &&
                objectMatch
                );
        
    }
    return YES;
}

@end
