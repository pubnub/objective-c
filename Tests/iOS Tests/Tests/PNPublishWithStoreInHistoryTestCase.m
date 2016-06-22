//
//  PNPublishWithStoreInHistoryTestCase.m
//  PubNub Tests
//
//  Created by Jordan Zucker on 4/22/16.
//
//

#import <PubNubTesting/PubNubTesting.h>

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
    PNTTestPublishStatus *expectedStatus = [PNTTestPublishStatus successfulStatusWithClient:self.client timeToken:@14666264735035579];
    [self.client publish:@"test" toChannel:self.publishChannel storeInHistory:YES withCompletion:[self PNT_completionWithExpectedPublishStatus:expectedStatus]];
    [self waitFor:kPNTPublishTimeout];
}

- (void)testPublishStringWithNoStoreInHistory {
    PNTTestPublishStatus *expectedStatus = [PNTTestPublishStatus successfulStatusWithClient:self.client timeToken:@14666264733533904];
    [self.client publish:@"test" toChannel:self.publishChannel storeInHistory:NO withCompletion:[self PNT_completionWithExpectedPublishStatus:expectedStatus]];
    [self waitFor:kPNTPublishTimeout];
}

- (void)testPublishNilMessageWithStoreInHistory {
    PNTTestPublishStatus *expectedStatus = [PNTTestPublishStatus failedStatusWithClient:self.client];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wnonnull"
    [self.client publish:nil toChannel:self.publishChannel storeInHistory:YES withCompletion:[self PNT_completionWithExpectedPublishStatus:expectedStatus]];
#pragma clang diagnostic pop
    [self waitFor:kPNTPublishTimeout];
}

- (void)testPublishNilMessageWithNoStoreInHistory {
    PNTTestPublishStatus *expectedStatus = [PNTTestPublishStatus failedStatusWithClient:self.client];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wnonnull"
    [self.client publish:nil toChannel:self.publishChannel storeInHistory:NO withCompletion:[self PNT_completionWithExpectedPublishStatus:expectedStatus]];
#pragma clang diagnostic pop
    [self waitFor:kPNTPublishTimeout];
}

- (void)testPublishStringToNilChannelWithStoreInHistory {
    PNTTestPublishStatus *expectedStatus = [PNTTestPublishStatus failedStatusWithClient:self.client];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wnonnull"
    [self.client publish:@"test" toChannel:nil storeInHistory:YES withCompletion:[self PNT_completionWithExpectedPublishStatus:expectedStatus]];
#pragma clang diagnostic pop
    [self waitFor:kPNTPublishTimeout];
}

- (void)testPublishStringToNilChannelWithNoStoreInHistory {
    PNTTestPublishStatus *expectedStatus = [PNTTestPublishStatus failedStatusWithClient:self.client];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wnonnull"
    [self.client publish:@"test" toChannel:nil storeInHistory:NO withCompletion:[self PNT_completionWithExpectedPublishStatus:expectedStatus]];
#pragma clang diagnostic pop
    [self waitFor:kPNTPublishTimeout];
}

- (void)testPublishDictionaryWithStoreInHistory {
    PNTTestPublishStatus *expectedStatus = [PNTTestPublishStatus successfulStatusWithClient:self.client timeToken:@14666264731233591];
    [self.client publish:@"test" toChannel:self.publishChannel storeInHistory:YES withCompletion:[self PNT_completionWithExpectedPublishStatus:expectedStatus]];
    [self waitFor:kPNTPublishTimeout];
}

- (void)testPublishDictionaryWithNoStoreInHistory {
    PNTTestPublishStatus *expectedStatus = [PNTTestPublishStatus successfulStatusWithClient:self.client timeToken:@14666264730181057];
    [self.client publish:@"test" toChannel:self.publishChannel storeInHistory:NO withCompletion:[self PNT_completionWithExpectedPublishStatus:expectedStatus]];
    [self waitFor:kPNTPublishTimeout];
}

- (void)testPublishArrayWithStoreInHistory {
    PNTTestPublishStatus *expectedStatus = [PNTTestPublishStatus successfulStatusWithClient:self.client timeToken:@14666264729177648];
    [self.client publish:@"test" toChannel:self.publishChannel storeInHistory:YES withCompletion:[self PNT_completionWithExpectedPublishStatus:expectedStatus]];
    [self waitFor:kPNTPublishTimeout];
}

- (void)testPublishArrayWithNoStoreInHistory {
    PNTTestPublishStatus *expectedStatus = [PNTTestPublishStatus successfulStatusWithClient:self.client timeToken:@14666264728065741];
    [self.client publish:@"test" toChannel:self.publishChannel storeInHistory:NO withCompletion:[self PNT_completionWithExpectedPublishStatus:expectedStatus]];
    [self waitFor:kPNTPublishTimeout];
}

@end
