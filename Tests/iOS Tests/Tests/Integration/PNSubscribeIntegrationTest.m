/**
 * @author Serhii Mamontov
 * @copyright © 2010-2019 PubNub, Inc.
 */
#import <PubNub/PubNub.h>
#import "PNTestCase.h"


#pragma mark Test interface declaration

@interface PNSubscribeIntegrationTest : PNTestCase


#pragma mark - Information

@property (nonatomic, strong) PubNub *client;

#pragma mark -


@end


#pragma mark - Tests

@implementation PNSubscribeIntegrationTest


#pragma mark - Setup / Tear down

- (void)setUp {
    
    [super setUp];
    
    
    dispatch_queue_t callbackQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    PNConfiguration *configuration = [PNConfiguration configurationWithPublishKey:self.publishKey
                                                                     subscribeKey:self.subscribeKey];
    
    if ([self.name rangeOfString:@"SubscriptionIdleTimeout_ShouldReconnect_WhenRequestTimeout"].location != NSNotFound) {
        configuration.subscribeMaximumIdleTime = 10.f;
    }
    
    self.client = [PubNub clientWithConfiguration:configuration callbackQueue:callbackQueue];
}

- (void)tearDown {
    
    if ([self.name rangeOfString:@"SubscriptionIdleTimeout_ShouldReconnect_WhenRequestTimeout"].location != NSNotFound) {
        [self removeAllHandlersForClient:self.client];
        [self.client removeListener:self];
    }
    
    [super tearDown];
}


#pragma mark - Tests :: subscription idle

/**
 * @brief Fix of \b CE-3744 ensure, what after unexpected disconnect client will report
 * 'reconnected' at the next second after 'unexpected disconnect'.
 */
- (void)testSubscriptionIdleTimeout_ShouldReconnect_WhenRequestTimeout {
    
    NSTimeInterval delay = self.client.currentConfiguration.subscribeMaximumIdleTime * 0.5f;
    NSString *expectedChannel = [NSUUID UUID].UUIDString;
    [self.client addListener:self];
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [self addStatusHandlerForClient:self.client withBlock:^(PubNub * client, PNSubscribeStatus * status, BOOL * shouldRemove) {
            if (status.category == PNUnexpectedDisconnectCategory) {
                *shouldRemove = YES;

                handler();
            }
        }];
        
        self.client.subscribe().channels(@[expectedChannel]).perform();
    }];
    
    [self waitToCompleteIn:delay codeBlock:^(dispatch_block_t handler) {
        [self addStatusHandlerForClient:self.client withBlock:^(PubNub * client, PNSubscribeStatus * status, BOOL * shouldRemove) {
            if (status.category == PNReconnectedCategory) {
                *shouldRemove = YES;
                
                handler();
            }
        }];
    }];
}

#pragma mark -


@end
