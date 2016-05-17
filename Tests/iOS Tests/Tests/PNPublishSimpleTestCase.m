//
//  PNPublishSimpleTestCase.m
//  PubNub Tests
//
//  Created by Jordan Zucker on 4/22/16.
//
//

#import <PubNub_Testing/PubNubTesting.h>

@interface PNPublishSimpleTestCase : PNTClientTestCase

@end

@implementation PNPublishSimpleTestCase

- (BOOL)isRecording {
    return NO;
}

- (NSString *)publishChannel {
    return @"a";
}

- (void)testPublishString {
    [self.client publish:@"test" toChannel:self.publishChannel withCompletion:[self PNT_successfulPublishCompletionWithExpectedTimeToken:@14613480530866726]];
    [self waitFor:kPNTPublishTimeout];
}

- (void)testPublishNilMessage {
    // silence warnings for this test
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wnonnull"
    [self.client publish:nil toChannel:self.publishChannel withCompletion:[self PNT_failedPublishCompletion]];
#pragma clang diagnostic pop
    [self waitFor:kPNTPublishTimeout];
}

- (void)testPublishStringToNilChannel {
    // silence warnings for this test
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wnonnull"
    [self.client publish:@"test" toChannel:nil withCompletion:[self PNT_failedPublishCompletion]];
#pragma clang diagnostic pop
    [self waitFor:kPNTPublishTimeout];
}

- (void)DISABLE_testPublishNilMessageToNilChannel {
    // silence warnings for this test
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wnonnull"
    [self.client publish:nil toChannel:nil withCompletion:[self PNT_failedPublishCompletion]];
#pragma clang diagnostic pop
    [self waitFor:kPNTPublishTimeout];
}

- (void)testPublishDictionary {
    [self.client publish:@{@"test": @"test"} toChannel:self.publishChannel withCompletion:[self PNT_successfulPublishCompletionWithExpectedTimeToken:@14613480529107131]];
    [self waitFor:kPNTPublishTimeout];
}

- (void)testPublishNestedDictionary {
    [self.client publish:@{@"test": @{@"test": @"test"}} toChannel:self.publishChannel withCompletion:[self PNT_successfulPublishCompletionWithExpectedTimeToken:@14613480529971055]];
    [self waitFor:kPNTPublishTimeout];
}

@end
