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
    PNTTestPublishStatus *expectedStatus = [PNTTestPublishStatus successfulStatusWithClient:self.client timeToken:@14635351328797872];
    [self.client publish:@"test" toChannel:self.publishChannel withCompletion:[self PNT_completionWithExpectedPublishStatus:expectedStatus]];
    [self waitFor:kPNTPublishTimeout];
//    PNTTestPublishStatus *status = [PNTTestPublishStatus successfulStatusWithClient:self.client timeToken:@14635151139158093];
//    [self.client publish:@"test" toChannel:self.publishChannel withCompletion:[self PNT_assertWithExpectedPublishStatus:status]];
//    [self waitFor:kPNTPublishTimeout];
}

//- (void)testPublishNilMessage {
//    // silence warnings for this test
//    PNTTestPublishStatus *expectedStatus = [PNTTestPublishStatus failedStatusWithClient:self.client timeToken:nil];
//#pragma clang diagnostic push
//#pragma clang diagnostic ignored "-Wnonnull"
//    [self.client publish:nil toChannel:self.publishChannel withCompletion:[self PNT_completionWithExpectedPublishStatus:expectedStatus]];
//#pragma clang diagnostic pop
//    [self waitFor:kPNTPublishTimeout];
//}
//
//- (void)testPublishStringToNilChannel {
//    // silence warnings for this test
//#pragma clang diagnostic push
//#pragma clang diagnostic ignored "-Wnonnull"
//    [self.client publish:@"test" toChannel:nil withCompletion:[self PNT_failedPublishCompletion]];
//#pragma clang diagnostic pop
//    [self waitFor:kPNTPublishTimeout];
//}
//
//- (void)DISABLE_testPublishNilMessageToNilChannel {
//    // silence warnings for this test
//#pragma clang diagnostic push
//#pragma clang diagnostic ignored "-Wnonnull"
//    [self.client publish:nil toChannel:nil withCompletion:[self PNT_failedPublishCompletion]];
//#pragma clang diagnostic pop
//    [self waitFor:kPNTPublishTimeout];
//}

- (void)testPublishDictionary {
    PNTTestPublishStatus *expectedStatus = [PNTTestPublishStatus successfulStatusWithClient:self.client timeToken:@14635351327138983];
    [self.client publish:@{@"test": @"test"} toChannel:self.publishChannel withCompletion:[self PNT_completionWithExpectedPublishStatus:expectedStatus]];
    [self waitFor:kPNTPublishTimeout];
}

- (void)testPublishNestedDictionary {
    PNTTestPublishStatus *expectedStatus = [PNTTestPublishStatus successfulStatusWithClient:self.client timeToken:@14635351328021386];
    [self.client publish:@{@"test": @{@"test": @"test"}} toChannel:self.publishChannel withCompletion:[self PNT_completionWithExpectedPublishStatus:expectedStatus]];
    [self waitFor:kPNTPublishTimeout];
}

@end
