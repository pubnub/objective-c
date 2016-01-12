//
//  PNDeviceIndependentMatcher.m
//  PubNub Tests
//
//  Created by Jordan Zucker on 10/30/15.
//
//

#import "PNDeviceIndependentMatcher.h"

@implementation PNDeviceIndependentMatcher

+ (id<JSZVCRMatching>)matcher {
    return [[self alloc] init];
}

- (BOOL)hasResponseForRequest:(NSURLRequest *)request inRecordings:(NSArray *)recordings {
    NSDictionary *info = [self infoForRequest:request inRecordings:recordings];
    return (info != nil);
}

- (NSDictionary *)infoForRequest:(NSURLRequest *)request inRecordings:(NSArray *)recordings {
    NSURLComponents *matchingComponents = [NSURLComponents componentsWithURL:request.URL resolvingAgainstBaseURL:NO];
    for (NSDictionary *info in recordings) {
        NSString *currentRequestURLString = info[@"request"][@"currentRequest"][@"URL"];
        NSString *originalRequestURLString = info[@"request"][@"originalRequest"][@"URL"];
        
        NSURLComponents *currentComponents = [NSURLComponents componentsWithString:currentRequestURLString];
        NSURLComponents *originalComponents = [NSURLComponents componentsWithString:originalRequestURLString];
        if ([self _compareComponents:matchingComponents toOtherComponents:currentComponents] ||
            [self _compareComponents:matchingComponents toOtherComponents:originalComponents]) {
            return info;
        }
    }
    return nil;
}

- (BOOL)_compareComponents:(NSURLComponents *)components toOtherComponents:(NSURLComponents *)otherComponents {
    if (![components.scheme isEqualToString:otherComponents.scheme]) {
        return NO;
    }
    if (![components.path isEqualToString:otherComponents.path]) {
        return NO;
    }
    return [self compareQueryItems:[self _queryItemsForComponents:components]
                 toOtherQueryItems:[self _queryItemsForComponents:otherComponents]];
    
}

- (BOOL)compareQueryItems:(NSArray *)queryItems toOtherQueryItems:(NSArray *)otherQueryItems {
//    NSArray *trimmedQueryItems = [queryItems bk_reject:^BOOL(id obj) {
//        NSDictionary *queryItem = (NSDictionary *)obj;
//        if ([queryItem[@"name"] isEqualToString:@"pnsdk"]) {
//            return YES;
//        }
//        return NO;
//    }];
//    
//    NSArray *trimmedOtherQueryItems = [otherQueryItems bk_reject:^BOOL(id obj) {
//        NSDictionary *queryItem = (NSDictionary *)obj;
//        if ([queryItem[@"name"] isEqualToString:@"pnsdk"]) {
//            return YES;
//        }
//        return NO;
//    }];
    
    NSArray *trimmedQueryItems = [self rejectDictionaryQueryItemWithValue:@"pnsdk" fromArray:queryItems];
    NSArray *trimmedOtherQueryItems = [self rejectDictionaryQueryItemWithValue:@"pnsdk" fromArray:otherQueryItems];
    
    
    
    NSCountedSet *querySet = [NSCountedSet setWithArray:trimmedQueryItems];
    NSCountedSet *otherQuerySet = [NSCountedSet setWithArray:trimmedOtherQueryItems];
    
    
    
    return [querySet isEqualToSet:otherQuerySet];
}

- (NSArray *)rejectDictionaryQueryItemWithValue:(NSString *)value fromArray:(NSArray *)array {
    NSMutableArray *rejectedArray = [NSMutableArray array];
    [array enumerateObjectsUsingBlock:^(NSURLQueryItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (![obj isKindOfClass:[NSDictionary class]]) {
            return;
        }
        NSDictionary *item = (NSDictionary *)obj;
        if (!item[@"name"]) {
            return;
        }
        if (![item[@"name"] isEqualToString:value]) {
            [rejectedArray addObject:item];
        }
    }];
    return rejectedArray.copy;
}

- (NSArray *)_queryItemsForComponents:(NSURLComponents *)components {
    NSMutableArray *mappedArray = [NSMutableArray array];
    [components.queryItems enumerateObjectsUsingBlock:^(NSURLQueryItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSURLQueryItem *item = (NSURLQueryItem *)obj;
        NSMutableDictionary *itemDict = [@{
                                           @"name" : item.name
                                           } mutableCopy];
        // in case the query doesn't have a value
        if (item.value) {
            [itemDict setObject:item.value forKey:@"value"];
        }
        [mappedArray addObject:[itemDict copy]];
    }];
    return [mappedArray copy];
}

- (NSDictionary *)responseForRequest:(NSURLRequest *)request inRecordings:(NSArray *)recordings {
    NSDictionary *info = [self infoForRequest:request inRecordings:recordings];
    if (!info) {
        return nil;
    }
    // TODO: should handle better than just returning nil for cancelled requests
    //    if ([info[@"cancelled"] boolValue] == YES) {
    //        return @{
    //                 @"error" : info[@"error"]
    //                 };
    //    }
    if (info[@"error"]) {
        return @{
                 @"error" : info[@"error"]
                 };
    }
    NSDictionary *responseDictionary = info[@"response"][@"response"];
    NSNumber *responseCode = responseDictionary[@"statusCode"];
    NSDictionary *headersDict = responseDictionary[@"allHeaderFields"];
    NSData *data = info[@"data"][@"data"];
    return @{
             @"statusCode" : responseCode,
             @"httpHeaders" : headersDict,
             @"data" : data
             };
}

@end
