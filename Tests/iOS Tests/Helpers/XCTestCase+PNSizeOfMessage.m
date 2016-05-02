//
//  XCTestCase+PNSizeOfMessage.m
//  PubNub Tests
//
//  Created by Jordan Zucker on 4/27/16.
//
//

#import "XCTestCase+PNSizeOfMessage.h"

static NSInteger const kPNMessageSizeTolerance = 8;

@implementation XCTestCase (PNSizeOfMessage)

- (PNMessageSizeCalculationCompletionBlock)PN_messageSizeCompletionWithSize:(NSInteger)expectedSize {
    __block XCTestExpectation *sizeExpectation = [self expectationWithDescription:@"message size"];
    return ^void (NSInteger size) {
        XCTAssertEqualWithAccuracy(expectedSize, size, kPNMessageSizeTolerance);
        [sizeExpectation fulfill];
    };
}

@end
