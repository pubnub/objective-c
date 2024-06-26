/**
 * @author Serhii Mamontov
 * @copyright © 2010-2019 PubNub, Inc.
 */
#import <PubNub/PubNub+CorePrivate.h>
#import <PubNub/PNStatus+Private.h>
#import <PubNub/PNSignalRequest.h>
#import "PNRecordableTestCase.h"
#import <PubNub/PNString.h>
#import <OCMock/OCMock.h>


#pragma mark Interface declaration

@interface PNSignalTest : PNRecordableTestCase


#pragma mark - Information

/**
 * @brief Signal encryption / decryption key.
 */
@property (nonatomic, copy) NSString *cipherKey;

#pragma mark -


@end


#pragma mark - Tests

@implementation PNSignalTest

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-retain-cycles"
#pragma clang diagnostic ignored "-Wdeprecated-declarations"


#pragma mark - Setup / Tear down

- (PNConfiguration *)configurationForTestCaseWithName:(NSString *)name {
    PNConfiguration *configuration = [super configurationForTestCaseWithName:name];
    
    if ([self.name rangeOfString:@"Encrypt"].location != NSNotFound) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        configuration.cipherKey = self.cipherKey;
#pragma clang diagnostic pop
    }
    
    return configuration;
}

- (BOOL)hasMockedObjectsInTestCaseWithName:(NSString *)__unused name {
    return YES;
}

- (void)setUp {
    [super setUp];
    
    
    self.cipherKey = @"enigma";
    
    [self completePubNubConfiguration:self.client];
}


#pragma mark - Tests :: Builder

- (void)testItShouldCreateSignalBuilder {
    XCTAssertTrue([self.client.signal() isKindOfClass:[PNSignalAPICallBuilder class]]);
}


#pragma mark - Tests :: Call

- (void)testItShouldProcessOperation {
    id message = @"Hello real-time world!";
    NSString *expectedMessage = [PNString percentEscapedString:[NSString stringWithFormat:@"\"%@\"", message]];
    NSString *expectedChannel = [NSUUID UUID].UUIDString;
    
    
    id recorded = OCMExpect([(id)self.client performRequest:[OCMArg isKindOfClass:[PNSignalRequest class]]
                                        withCompletion:[OCMArg any]])
        .andDo(^(NSInvocation *invocation) {
            PNSignalRequest *request = [self objectForInvocation:invocation argumentAtIndex:1];
            
            XCTAssertNil([request validate]);
            XCTAssertEqualObjects(request.channel, expectedChannel);
            XCTAssertEqualObjects(request.path.lastPathComponent, expectedMessage);
        });
    
    
    [self waitForObject:self.client recordedInvocationCall:recorded afterBlock:^{
        self.client.signal()
            .channel(expectedChannel)
            .message(message)
            .performWithCompletion(^(PNSignalStatus * status) { });
    }];
}

- (void)testItShouldNotEncryptWhenCipherKeyIsSet {
    NSString *expectedMessage = [PNString percentEscapedString:@"{\"such\":\"object\"}"];
    NSString *expectedChannel = [NSUUID UUID].UUIDString;
    id message = @{ @"such": @"object" };
    
    
    id recorded = OCMExpect([(id)self.client performRequest:[OCMArg isKindOfClass:[PNSignalRequest class]]
                                             withCompletion:[OCMArg any]])
        .andDo(^(NSInvocation *invocation) {
            PNSignalRequest *request = [self objectForInvocation:invocation argumentAtIndex:1];

            XCTAssertNil([request validate]);
            XCTAssertEqualObjects(request.channel, expectedChannel);
            XCTAssertEqualObjects(request.path.lastPathComponent, expectedMessage);
        });
    
    [self waitForObject:self.client recordedInvocationCall:recorded afterBlock:^{
        self.client.signal().channel(expectedChannel).message(message)
            .performWithCompletion(^(PNSignalStatus * status) { });
    }];
}


#pragma mark - Tests :: Retry

- (void)testItShouldRetryWhenPreviousCallFails {
    __block PNErrorStatus *errorStatus = nil;
    id message = @"Hello real-time world!";


    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.signal().message(message)
            .performWithCompletion(^(PNSignalStatus * status) {
                errorStatus = status;
                // Hack. Non-error status doesn't have retry block.
                status.retryBlock = ^{
                    [self.client signal:@"Hello" channel:@"channel" withCompletion:nil];
                };
                handler();
            });
    }];
    
    id recorded = OCMExpect([(id)self.client performRequest:[OCMArg isKindOfClass:[PNSignalRequest class]]
                                             withCompletion:[OCMArg any]]);

    [self waitForObject:self.client recordedInvocationCall:recorded afterBlock:^{
        [errorStatus retry];
    }];
}

#pragma mark -

#pragma clang diagnostic pop

@end
