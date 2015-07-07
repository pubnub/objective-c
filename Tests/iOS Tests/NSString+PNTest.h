//
//  NSString+PNTest.h
//  PubNub Tests
//
//  Created by Vadim Osovets on 6/19/15.
//
//

#import <Foundation/Foundation.h>

@interface NSString (PNTest)

+ (NSString *)randomAlphanumericStringWithLength:(NSInteger)length;

- (NSData *)dataFromHexString:(NSString *)string;

@end
