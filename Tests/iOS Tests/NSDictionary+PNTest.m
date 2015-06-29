//
//  NSDictionary+PNTest.m
//  PubNub Tests
//
//  Created by Vadim Osovets on 6/30/15.
//
//

#import "NSDictionary+PNTest.h"

@implementation NSDictionary (PNTest)

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
