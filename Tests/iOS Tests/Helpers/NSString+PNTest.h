//
//  NSString+PNTest.h
//  PubNub Tests
//
//  Created by Jordan Zucker on 3/23/16.
//
//

#import <Foundation/Foundation.h>

@interface NSString (PNTest)

+ (NSString *)randomAlphanumericStringWithLength:(NSInteger)length;

- (NSData *)dataFromHexString:(NSString *)string;

@end
