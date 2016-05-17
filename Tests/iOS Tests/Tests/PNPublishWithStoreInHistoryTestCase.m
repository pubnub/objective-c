//
//  PNPublishWithStoreInHistoryTestCase.m
//  PubNub Tests
//
//  Created by Jordan Zucker on 4/22/16.
//
//

#import <PubNub_Testing/PubNubTesting.h>

@interface PNPublishWithStoreInHistoryTestCase : PNTClientTestCase

@end

@implementation PNPublishWithStoreInHistoryTestCase

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

- (void)testPublishStringWithStoreInHistory {
    [self.client publish:@"test" toChannel:self.publishChannel storeInHistory:YES withCompletion:[self PNT_successfulPublishCompletionWithExpectedTimeToken:@14613497218336166]];
    [self waitFor:kPNTPublishTimeout];
}

@end
