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

- (void)testSizeOfStringMessageToNilChannel {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wnonnull"
    [self.client sizeOfMessage:@"test" toChannel:nil withCompletion:[self PNT_messageSizeCompletionWithSize:-1]];
#pragma clang diagnostic pop
    [self waitFor:kPNTSizeOfMessageTimeout];
}

- (void)testSizeOfStringMessageWithStoreInHistory {
    [self.client sizeOfMessage:@"test" toChannel:self.publishChannel storeInHistory:YES withCompletion:[self PNT_messageSizeCompletionWithSize:341]];
    [self waitFor:kPNTSizeOfMessageTimeout];
}

- (void)testSizeOfStringMessageCompressed {
    [self.client sizeOfMessage:@"test" toChannel:self.publishChannel compressed:YES withCompletion:[self PNT_messageSizeCompletionWithSize:451]];
    [self waitFor:kPNTSizeOfMessageTimeout];
}

- (void)testSizeOfStringMessageWithStoreInHistoryAndCompressed {
    [self.client sizeOfMessage:@"test" toChannel:self.publishChannel compressed:YES storeInHistory:YES withCompletion:[self PNT_messageSizeCompletionWithSize:451]];
    [self waitFor:kPNTSizeOfMessageTimeout];
}

- (void)testSizeOfStringMessageWithStoreInHistoryAndNotCompressed {
    [self.client sizeOfMessage:@"test" toChannel:self.publishChannel compressed:NO storeInHistory:YES withCompletion:[self PNT_messageSizeCompletionWithSize:341]];
    [self waitFor:kPNTSizeOfMessageTimeout];
}

- (void)testSizeOfStringMessageWithNoStoreInHistoryAndNotCompressed {
    [self.client sizeOfMessage:@"test" toChannel:self.publishChannel compressed:NO storeInHistory:NO withCompletion:[self PNT_messageSizeCompletionWithSize:341]];
    [self waitFor:kPNTSizeOfMessageTimeout];
}

- (void)testSizeOfStringMessageWithNoStoreInHistoryAndCompressed {
    [self.client sizeOfMessage:@"test" toChannel:self.publishChannel compressed:YES storeInHistory:NO withCompletion:[self PNT_messageSizeCompletionWithSize:459]];
    [self waitFor:kPNTSizeOfMessageTimeout];
}

- (void)DISABLE_testSize10kCharacterStringMessageWithStoreInHistoryAndCompressed {
    [self.client sizeOfMessage:@"test" toChannel:self.publishChannel compressed:YES storeInHistory:YES withCompletion:[self PNT_messageSizeCompletionWithSize:341]];
    [self waitFor:kPNTSizeOfMessageTimeout];
}

- (void)DISABLE_testSizeOf100kCharacterStringWithStoreInHistoryAndCompressed {
    [self.client sizeOfMessage:@"test" toChannel:self.publishChannel compressed:YES storeInHistory:YES withCompletion:[self PNT_messageSizeCompletionWithSize:341]];
    [self waitFor:kPNTSizeOfMessageTimeout];
}

- (void)testSizeOfDictionaryMessageWithStoreInHistoryAndCompressed {
    NSDictionary *message = @{@"1": @"3", @"2": @"3"};
    [self.client sizeOfMessage:message toChannel:self.publishChannel compressed:YES storeInHistory:YES withCompletion:[self PNT_messageSizeCompletionWithSize:458]];
    [self waitFor:kPNTSizeOfMessageTimeout];
}

- (void)testSizeOfNestedDictionaryMessageWithStoreInHistoryAndCompressed {
    NSDictionary *message = @{@"1": @{@"1": @{@"3": @"5"}}, @"2": @"3"};
    [self.client sizeOfMessage:message toChannel:self.publishChannel compressed:YES storeInHistory:YES withCompletion:[self PNT_messageSizeCompletionWithSize:468]];
    [self waitFor:kPNTSizeOfMessageTimeout];
}

- (void)testSizeOfArrayMessageWithStoreInHistoryAndCompressed {
    NSArray *message = @[@"1", @"2", @"3", @"4"];
    [self.client sizeOfMessage:message toChannel:self.publishChannel compressed:YES storeInHistory:YES withCompletion:[self PNT_messageSizeCompletionWithSize:459]];
    [self waitFor:kPNTSizeOfMessageTimeout];
}

- (void)testSizeOfComplexArrayMessageWithStoreInHistoryAndCompressed {
    NSArray *message =   @[@"1", @{@"1": @{@"1": @"2"}}, @[@"1", @"2", @(2)], @(567)];
    [self.client sizeOfMessage:message toChannel:self.publishChannel compressed:YES storeInHistory:YES withCompletion:[self PNT_messageSizeCompletionWithSize:474]];
    [self waitFor:kPNTSizeOfMessageTimeout];
}

@end
