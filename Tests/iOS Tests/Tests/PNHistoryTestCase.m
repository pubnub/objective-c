//
//  PNHistoryTestCase.m
//  PubNub Tests
//
//  Created by Jordan Zucker on 5/13/16.
//
//

#import <PubNub_Testing/PubNubTesting.h>

@interface PNHistoryTestCase : PNTClientTestCase
@property (nonatomic, strong, readonly) NSString *historyChannel;
@end

@implementation PNHistoryTestCase

- (BOOL)isRecording {
    return NO;
}

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (NSString *)historyChannel {
    return @"a";
}

- (void)testGetHistory {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
    [self.client historyForChannel:self.historyChannel withCompletion:[self PNT_historyCompletionBlock]];
    [self waitFor:kPNTHistoryTimeout];
}

@end
