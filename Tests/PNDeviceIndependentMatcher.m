//
//  PNDeviceIndependentMatcher.m
//  PubNub Tests
//
//  Created by Jordan Zucker on 10/30/15.
//
//

#import <BlocksKit/BlocksKit.h>

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
    if (![components.host isEqualToString:otherComponents.host]) {
        return NO;
    }
    if (![components.path isEqualToString:otherComponents.path]) {
        return NO;
    }
    return [self compareQueryItems:[self _queryItemsForComponents:components]
                 toOtherQueryItems:[self _queryItemsForComponents:otherComponents]];
    
}

- (BOOL)compareQueryItems:(NSArray *)queryItems toOtherQueryItems:(NSArray *)otherQueryItems {
    NSArray *trimmedQueryItems = [queryItems bk_reject:^BOOL(id obj) {
        NSDictionary *queryItem = (NSDictionary *)obj;
        if ([queryItem[@"name"] isEqualToString:@"pnsdk"]) {
            return YES;
        }
        return NO;
    }];
    
    NSArray *trimmedOtherQueryItems = [otherQueryItems bk_reject:^BOOL(id obj) {
        NSDictionary *queryItem = (NSDictionary *)obj;
        if ([queryItem[@"name"] isEqualToString:@"pnsdk"]) {
            return YES;
        }
        return NO;
    }];
    NSCountedSet *querySet = [NSCountedSet setWithArray:trimmedQueryItems];
    NSCountedSet *otherQuerySet = [NSCountedSet setWithArray:trimmedOtherQueryItems];
    
    
    
    return [querySet isEqualToSet:otherQuerySet];
}

- (NSArray *)_queryItemsForComponents:(NSURLComponents *)components {
    // transforming all queryItems into dicts so this works on iOS 7 and iOS 8
#ifdef __IPHONE_7_0
    // http://stackoverflow.com/questions/3997976/parse-nsurl-query-property
    if ([components.query length]==0) {
        return nil;
    }
    NSMutableArray *parameters = [NSMutableArray array];
    for(NSString* parameter in [components.query componentsSeparatedByString:@"&"]) {
        NSRange range = [parameter rangeOfString:@"="];
        if(range.location!=NSNotFound) {
            NSDictionary *item = @{
                                   @"name" : [[parameter substringToIndex:range.location] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
                                   @"value" : [[parameter substringFromIndex:range.location+range.length] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]
                                   };
            [parameters addObject:item];
        } else {
            NSDictionary *item = @{
                                   @"name" : [parameter stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
                                   @"value" : @""
                                   };
            [parameters addObject:item];
        }
    }
    return [parameters copy];
#endif
    return [components.queryItems bk_map:^id(id obj) {
        NSURLQueryItem *item = (NSURLQueryItem *)obj;
        NSMutableDictionary *itemDict = [@{
                                           @"name" : item.name
                                           } mutableCopy];
        // in case the query doesn't have a value
        if (item.value) {
            [itemDict setObject:item.value forKey:@"value"];
        }
        return [itemDict copy];
    }];
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
