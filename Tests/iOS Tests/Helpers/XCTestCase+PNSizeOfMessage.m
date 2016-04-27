//
//  XCTestCase+PNSizeOfMessage.m
//  PubNub Tests
//
//  Created by Jordan Zucker on 4/27/16.
//
//

#import "XCTestCase+PNSizeOfMessage.h"

@implementation XCTestCase (PNSizeOfMessage)

- (PNMessageSizeCalculationCompletionBlock)PN_messageSizeCompletionWithSize:(NSInteger)expectedSize {
    __block XCTestExpectation *sizeExpectation = [self expectationWithDescription:@"message size"];
    return ^void (NSInteger size) {
        XCTAssertEqual(expectedSize, size);
        [sizeExpectation fulfill];
    };
}

@end
