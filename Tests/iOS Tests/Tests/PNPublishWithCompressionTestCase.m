//
//  PNPublishWithCompressionTestCase.m
//  PubNub Tests
//
//  Created by Jordan Zucker on 4/22/16.
//
//

#import <PubNubTesting/PubNubTesting.h>

@interface PNPublishWithCompressionTestCase : PNTClientTestCase

@end

@implementation PNPublishWithCompressionTestCase

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

- (void)testPublishStringWithCompression {
    PNTTestPublishStatus *expectedStatus = [PNTTestPublishStatus successfulStatusWithClient:self.client timeToken:@14666254530494384];
    [self.client publish:@"test" toChannel:self.publishChannel compressed:YES withCompletion:[self PNT_completionWithExpectedPublishStatus:expectedStatus]];
    [self waitFor:kPNTPublishTimeout];
}

- (void)testPublishStringWithNoCompression {
    PNTTestPublishStatus *expectedStatus = [PNTTestPublishStatus successfulStatusWithClient:self.client timeToken:@14666254531237488];
    [self.client publish:@"test" toChannel:self.publishChannel compressed:NO withCompletion:[self PNT_completionWithExpectedPublishStatus:expectedStatus]];
    [self waitFor:kPNTPublishTimeout];
}

- (void)testPublishNilMessageCompressed {
    PNTTestPublishStatus *expectedStatus = [PNTTestPublishStatus failedStatusWithClient:self.client];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wnonnull"
    [self.client publish:nil toChannel:self.publishChannel compressed:YES withCompletion:[self PNT_completionWithExpectedPublishStatus:expectedStatus]];
#pragma clang diagnostic pop
    [self waitFor:kPNTPublishTimeout];
}

- (void)testPublishNilMessageNotCompressed {
    PNTTestPublishStatus *expectedStatus = [PNTTestPublishStatus failedStatusWithClient:self.client];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wnonnull"
    [self.client publish:nil toChannel:self.publishChannel compressed:NO withCompletion:[self PNT_completionWithExpectedPublishStatus:expectedStatus]];
#pragma clang diagnostic pop
    [self waitFor:kPNTPublishTimeout];
}

- (void)testPublishDictionaryCompressed {
    PNTTestPublishStatus *expectedStatus = [PNTTestPublishStatus successfulStatusWithClient:self.client timeToken:@14666254523212140];
    [self.client publish:@{@"foo": @"bar"} toChannel:self.publishChannel compressed:YES withCompletion:[self PNT_completionWithExpectedPublishStatus:expectedStatus]];
    [self waitFor:kPNTPublishTimeout];
}

- (void)testPublishDictionaryNotCompressed {
    PNTTestPublishStatus *expectedStatus = [PNTTestPublishStatus successfulStatusWithClient:self.client timeToken:@14666254528926243];
    [self.client publish:@{@"foo": @"bar"} toChannel:self.publishChannel compressed:NO withCompletion:[self PNT_completionWithExpectedPublishStatus:expectedStatus]];
    [self waitFor:kPNTPublishTimeout];
}

- (void)testPublishArrayCompressed {
    PNTTestPublishStatus *expectedStatus = [PNTTestPublishStatus successfulStatusWithClient:self.client timeToken:@14666254521232642];
    [self.client publish:@[@"foo", @"bar"] toChannel:self.publishChannel compressed:YES withCompletion:[self PNT_completionWithExpectedPublishStatus:expectedStatus]];
    [self waitFor:kPNTPublishTimeout];
}

- (void)testPublishArrayNotCompressed {
    PNTTestPublishStatus *expectedStatus = [PNTTestPublishStatus successfulStatusWithClient:self.client timeToken:@14666254522200385];
    [self.client publish:@[@"foo", @"bar"] toChannel:self.publishChannel compressed:NO withCompletion:[self PNT_completionWithExpectedPublishStatus:expectedStatus]];
    [self waitFor:kPNTPublishTimeout];
}

- (void)testPublishStringToNilChannelCompressed {
    PNTTestPublishStatus *expectedStatus = [PNTTestPublishStatus failedStatusWithClient:self.client];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wnonnull"
    [self.client publish:@"test" toChannel:nil compressed:YES withCompletion:[self PNT_completionWithExpectedPublishStatus:expectedStatus]];
#pragma clang diagnostic pop
    [self waitFor:kPNTPublishTimeout];
}

- (void)testPublishStringToNilChannelNotCompressed {
    PNTTestPublishStatus *expectedStatus = [PNTTestPublishStatus failedStatusWithClient:self.client];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wnonnull"
    [self.client publish:@"test" toChannel:nil compressed:NO withCompletion:[self PNT_completionWithExpectedPublishStatus:expectedStatus]];
#pragma clang diagnostic pop
    [self waitFor:kPNTPublishTimeout];
}

@end
