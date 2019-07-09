/**
 * @author Serhii Mamontov
 * @copyright © 2010-2019 PubNub, Inc.
 */
#import <PubNub/PubNub.h>
#import <OCMock/OCMock.h>
#import "PNTestCase.h"


#pragma mark Test interface declaration

@interface PNSignalIntegrationTest : PNTestCase


#pragma mark - Information

@property (nonatomic, strong) PubNub *client;

#pragma mark -


@end


#pragma mark - Tests

@implementation PNSignalIntegrationTest

#pragma mark - Setup / Tear down

- (void)setUp {
    
    [super setUp];
    
    
    dispatch_queue_t callbackQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    PNConfiguration *configuration = [PNConfiguration configurationWithPublishKey:self.publishKey
                                                                     subscribeKey:self.subscribeKey];
    configuration.stripMobilePayload = NO;
    
    self.client = [PubNub clientWithConfiguration:configuration callbackQueue:callbackQueue];
}

- (void)tearDown {
    
    [self removeAllHandlersForClient:self.client];
    
    
    [super tearDown];
}


#pragma mark - Tests :: signal

- (void)testSignal_ShouldSendString_WhenStringMessagePassed {
    
    NSString *channel = [NSUUID UUID].UUIDString;
    id message = @"Hello real-time!";
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.signal().message(message).channel(channel)
        .performWithCompletion(^(PNSignalStatus *status) {
            XCTAssertFalse(status.isError);
            handler();
        });
    }];
}

- (void)testSignal_ShouldPassFilter_WhenMetaPassed {
    
    self.client.filterExpression = @"(senderID=='PubNub')";
    NSString *channel = [NSUUID UUID].UUIDString;
    id message = @{ @"hello": @"real-time!" };
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self addMessageHandlerForClient:self.client
                               withBlock:^(PubNub *client, PNMessageResult *message, BOOL *shouldRemove) {
                                   *shouldRemove = YES;
                                   handler();
                               }];
        
        self.client.signal().message(message).channel(channel).metadata(@{ @"senderID": @"PubNub" })
            .performWithCompletion(^(PNSignalStatus *status) {
                XCTAssertFalse(status.isError);
            });
    }];
}

- (void)testSignal_ShouldNotPassFilter_WhenMetaConditionsNotMet {
    
    self.client.filterExpression = @"(senderID=='PubNub')";
    NSString *channel = [NSUUID UUID].UUIDString;
    id message = @{ @"hello": @"real-time!" };
    
    [self waitToNotCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self addMessageHandlerForClient:self.client
                               withBlock:^(PubNub *client, PNMessageResult *message, BOOL *shouldRemove) {
                                   *shouldRemove = YES;
                                   handler();
                               }];
        
        self.client.signal().message(message).channel(channel).metadata(@{ @"senderID": @"Serhii" })
            .performWithCompletion(^(PNSignalStatus *status) {
                XCTAssertFalse(status.isError);
            });
    }];
}

#pragma mark -


@end
