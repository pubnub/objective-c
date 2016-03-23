//
//  NSDictionary+PNTest.h
//  PubNub Tests
//
//  Created by Jordan Zucker on 3/23/16.
//
//

#import <Foundation/Foundation.h>

@interface NSDictionary (PNTest)

- (NSString *)jsonDescription;
- (NSString *)testAssertionFormat;

@end
