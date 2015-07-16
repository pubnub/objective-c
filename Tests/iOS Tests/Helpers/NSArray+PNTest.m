//
//  NSArray+PNTest.m
//  PubNub Tests
//
//  Created by Vadim Osovets on 7/16/15.
//
//

#import "NSArray+PNTest.h"

@implementation NSArray (PNTest)

- (NSString *)jsonDescription {
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:self options:NSJSONWritingPrettyPrinted error:nil];
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}

- (NSString *)codeFormatDescription {
    NSString *res = [self jsonDescription];
    
    res = [res stringByReplacingOccurrencesOfString:@" \"" withString:@" @\""];
    res = [res stringByReplacingOccurrencesOfString:@" [" withString:@" @["];
    res = [res stringByReplacingOccurrencesOfString:@" {" withString:@" @{"];
    
    return res;
}

@end
