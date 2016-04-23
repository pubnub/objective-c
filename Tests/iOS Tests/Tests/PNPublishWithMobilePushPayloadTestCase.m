//
//  PNPublishWithMobilePushPayloadTestCase.m
//  PubNub Tests
//
//  Created by Jordan Zucker on 4/22/16.
//
//

#import "PNClientTestCase.h"
#import "XCTestCase+PNPublish.h"

@interface PNPublishWithMobilePushPayloadTestCase : PNClientTestCase

@end

@implementation PNPublishWithMobilePushPayloadTestCase

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

- (void)testPublishStringWithMobilePushPayload {
    NSDictionary *payload = @{@"aps" :
                                  @{@"alert" : @"You got your emails.@",
                                    @"badge" : @(9),
                                    @"sound" : @"bingbong.aiff"},
                              @"acme 1" : @(42)};
    [self.client publish:@"test" toChannel:self.publishChannel mobilePushPayload:payload withCompletion:[self PN_successfulPublishCompletionWithExpectedTimeToken:@14613497217595275]];
    [self waitFor:kPNPublishTimeout];
}

@end
