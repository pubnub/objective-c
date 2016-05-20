//
//  PNPublishSizeOfMessageTestCase.m
//  PubNub Tests
//
//  Created by Jordan Zucker on 4/22/16.
//
//

#import <PubNubTesting/PubNubTesting.h>

@interface PNPublishSizeOfMessageTestCase : PNTClientTestCase

@end

@implementation PNPublishSizeOfMessageTestCase

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

- (NSString *)publishChannel {
    return @"a";
}

- (void)testSizeOfStringMessage {
    [self.client sizeOfMessage:@"test" toChannel:self.publishChannel withCompletion:[self PNT_messageSizeCompletionWithSize:341]];
    [self waitFor:kPNTSizeOfMessageTimeout];
}

@end
