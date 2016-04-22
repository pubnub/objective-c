//
//  PNPublishSimpleTestCase.m
//  PubNub Tests
//
//  Created by Jordan Zucker on 4/22/16.
//
//

#import "PNClientTestCase.h"
#import "XCTestCase+PNPublish.h"

@interface PNPublishSimpleTestCase : PNClientTestCase

@end

@implementation PNPublishSimpleTestCase

- (BOOL)isRecording {
    return NO;
}

- (NSString *)publishChannel {
    return @"a";
}

- (void)testPublishString {
    [self.client publish:@"test" toChannel:self.publishChannel withCompletion:[self PN_successfulPublishCompletionWithExpectedTimeToken:@14613480530866726]];
    [self waitFor:kPNPublishTimeout];
}

- (void)testPublishNilMessage {
    // silence warnings for this test
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wnonnull"
    [self.client publish:nil toChannel:self.publishChannel withCompletion:[self PN_failedPublishCompletion]];
#pragma clang diagnostic pop
    [self waitFor:kPNPublishTimeout];
}

- (void)testPublishStringToNilChannel {
    // silence warnings for this test
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wnonnull"
    [self.client publish:@"test" toChannel:nil withCompletion:[self PN_failedPublishCompletion]];
#pragma clang diagnostic pop
    [self waitFor:kPNPublishTimeout];
}

- (void)DISABLE_testPublishNilMessageToNilChannel {
    // silence warnings for this test
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wnonnull"
    [self.client publish:nil toChannel:nil withCompletion:[self PN_failedPublishCompletion]];
#pragma clang diagnostic pop
    [self waitFor:kPNPublishTimeout];
}

- (void)testPublishDictionary {
    [self.client publish:@{@"test": @"test"} toChannel:self.publishChannel withCompletion:[self PN_successfulPublishCompletionWithExpectedTimeToken:@14613480529107131]];
    [self waitFor:kPNPublishTimeout];
}

- (void)testPublishNestedDictionary {
    [self.client publish:@{@"test": @{@"test": @"test"}} toChannel:self.publishChannel withCompletion:[self PN_successfulPublishCompletionWithExpectedTimeToken:@14613480529971055]];
    [self waitFor:kPNPublishTimeout];
}

@end
