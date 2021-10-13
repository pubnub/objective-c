/**
 * @author Serhii Mamontov
 * @copyright © 2010-2021 PubNub, Inc.
 */
#import "PNContractTestCase.h"
#import "PNMessageActionsContractTestSteps.h"
#import "PNSubscribeContractTestSteps.h"
#import "PNPublishContractTestSteps.h"
#import "PNHistoryContractTestSteps.h"
#import "PNAccessContractTestSteps.h"
#import "PNFilesContractTestSteps.h"
#import "PNPushContractTestSteps.h"
#import "PNTimeContractTestSteps.h"
#import <PubNub/PNPrivateStructures.h>



#pragma mark Types & Constants

/**
 * @brief Origin which should be used to reach mock server for contract testing.
 */
static NSString * const kPNMockServerAddress = @"localhost:8090";
static NSString * const kPNDefaultSubscribeKey = @"demo-36";
static NSString * const kPNDefaultPublishKey = @"demo-36";

typedef NSMutableArray<PNMessageResult *> PNTestChannelMessagesList;
typedef NSMutableDictionary<NSString *, PNTestChannelMessagesList *> PNTestClientMessagesList;
typedef NSMutableArray<PNStatus *> PNTestClientStatusesList;


#pragma mark Static

static PNConfiguration *_configuration;
static PubNub *_currentClient;
static NSMutableArray *_apiCallStatuses;
static NSMutableArray *_apiCallResults;
static NSMutableArray<void(^)(PubNub *client, PNStatus *statue)> *_statusHandlers;
static NSMutableDictionary<NSString *, PNTestClientStatusesList *> *_receivedStatuses;
static NSMutableArray<void(^)(PubNub *client, PNMessageResult *message)> *_messageHandlers;
static NSMutableDictionary<NSString *, PNTestClientMessagesList *> *_receivedMessages;
static PNOperationType _testedFeatureType;


NS_ASSUME_NONNULL_BEGIN

#pragma mark - Private interface declaration

@interface PNContractTestCase () <PNEventsListener>


#pragma mark - Information

@property (class, nonatomic, nullable, copy) PNConfiguration *configuration;

/**
 * @brief Client configured for current test scenario.
 */
@property (class, nonatomic, nullable, strong) PubNub *currentClient;

/**
 * @brief Array with PubNub REST API call error status objects or nulls.
 */
@property (class, nonatomic, strong) NSMutableArray *apiCallStatuses;

/**
 * @brief Array with PubNub REST API call result objects or nulls.
 */
@property (class, nonatomic, strong) NSMutableArray *apiCallResults;

/**
 * @brief List of GCD blocks which listens for PubNub client status change.
 */
@property (class, nonatomic, nullable, strong) NSMutableArray<void(^)(PubNub *client, PNStatus *statue)> *statusHandlers;

/**
 * @brief Statuses received during current scenario execution.
 */
@property (class, nonatomic, nullable) NSMutableDictionary<NSString *, PNTestClientStatusesList *> *receivedStatuses;

/**
 * @brief List of GCD blocks which listens for PubNub client message receive.
 */
@property (class, nonatomic, nullable, strong) NSMutableArray<void(^)(PubNub *client, PNMessageResult *message)> *messageHandlers;

/**
 * @brief Messages received during current scenario execution.
 */
@property (class, nonatomic, nullable, strong) NSMutableDictionary<NSString *, PNTestClientMessagesList *> *receivedMessages;


#pragma mark - Helpers

/**
 * @brief Check whether mock server should be configured / asked for expectation on \c scenario.
 *
 * @param scenario Cucumber scenario built from feature file.
 *
 * @return \c YES in case if mock server should be configured / checked for expectations.
 */
- (BOOL)shouldSetupMockServerForScenario:(CCIScenarioDefinition *)scenario;

/**
 * @brief Configure mock server to provide responses according to pre-defined feature \c scenario.
 *
 * @param scenario Cucumber scenario built from feature file.
 *
 * @return Mock server response data (if no error happened).
 */
- (nullable NSData *)setupMockServerForFeatureScenario:(CCIScenarioDefinition *)scenario;

/**
 * @brief Check whether contract expectations are met or not.
 *
 * @param scenario Cucumber scenario built from feature file.
 *
 * @return Mock server response data (if no error happened).
 */
- (nullable NSData *)checkMockServerExpectationsForFeatureScenario:(CCIScenarioDefinition *)scenario;

/**
 * @brief Retrieve name of scenario file which mock server should use to provide responses.
 *
 * @param scenario Cucumber scenario built from feature file.
 *
 * @return Name of scenario contract declared in feature file (if declared).
 */
- (nullable NSString *)contractForScenario:(CCIScenarioDefinition *)scenario;

/**
 * @brief Get number of messages which has been sent to specific channel.
 *
 * @param client \b PubNub client for which count should be done.
 * @param channel Specific channel on which messages should be counted or all channels for \c client if \c nil.
 *
 * @return Number of messages for specified \c client and \c channel.
 */
- (NSUInteger)messagesCountForClient:(PubNub *)client onChannel:(nullable NSString *)channel;

/**
 * @brief Check whether currently tested feature expects to receive response from server or not.
 *
 * @return \c NO in case if used REST API endpoint receives only acknowledgment status object.
 */
- (BOOL)testedFeatureExpectResponse;

#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark - Interface implementation

@implementation PNContractTestCase


#pragma mark - Information

+ (PNConfiguration *)configuration {
    return _configuration;
}

+ (void)setConfiguration:(PNConfiguration *)configuration {
    _configuration = configuration;
}

+ (PubNub *)currentClient {
    return _currentClient;
}

+ (void)setCurrentClient:(PubNub *)currentClient {
    _currentClient = currentClient;
}

+ (NSMutableArray *)apiCallStatuses {
    return _apiCallStatuses;
}

+ (void)setApiCallStatuses:(NSMutableArray *)apiCallStatuses {
    _apiCallStatuses = apiCallStatuses;
}

+ (NSMutableArray *)apiCallResults {
    return _apiCallResults;
}

+ (void)setApiCallResults:(NSMutableArray *)apiCallResults {
    _apiCallResults = apiCallResults;
}

+ (NSMutableArray<void (^)(PubNub *, PNStatus *)> *)statusHandlers {
    return _statusHandlers;
}

+ (void)setStatusHandlers:(NSMutableArray<void (^)(PubNub *, PNStatus *)> *)statusHandlers {
    _statusHandlers = statusHandlers;
}

+ (NSMutableDictionary<NSString *,PNTestClientStatusesList *> *)receivedStatuses {
    return _receivedStatuses;
}

+ (void)setReceivedStatuses:(NSMutableDictionary<NSString *,PNTestClientStatusesList *> *)receivedStatuses {
    _receivedStatuses = receivedStatuses;
}

+ (NSMutableArray<void (^)(PubNub *, PNMessageResult *)> *)messageHandlers {
    return _messageHandlers;
}

+ (void)setMessageHandlers:(NSMutableArray<void (^)(PubNub *, PNMessageResult *)> *)messageHandlers {
    _messageHandlers = messageHandlers;
}

+ (NSMutableDictionary<NSString *,PNTestClientMessagesList *> *)receivedMessages {
    return _receivedMessages;
}

+ (void)setReceivedMessages:(NSMutableDictionary<NSString *,PNTestClientMessagesList *> *)receivedMessages {
    _receivedMessages = receivedMessages;
}

- (PubNub *)client {
    if (!PNContractTestCase.currentClient) {
        dispatch_queue_t queue = dispatch_queue_create("com.contract-test.callback-queue", DISPATCH_QUEUE_SERIAL);
        PNContractTestCase.currentClient = [PubNub clientWithConfiguration:self.configuration callbackQueue:queue];
        
        [PNContractTestCase.currentClient addListener:self];
    }
    
    return PNContractTestCase.currentClient;
}

- (PNConfiguration *)configuration {
    return PNContractTestCase.configuration;
}

- (PNOperationType)testedFeatureType {
    return _testedFeatureType;
}

- (void)setTestedFeatureType:(PNOperationType)testedFeatureType {
    _testedFeatureType = testedFeatureType;
}


#pragma mark - Initialization & Configuration

- (void)setup {
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        before(^(CCIScenarioDefinition *scenario) {
            if ([self shouldSetupMockServerForScenario:scenario]) {
                NSData *response = [self setupMockServerForFeatureScenario:scenario];
                
                XCTAssertNotNil(response, @"Unable to get server init response");
            }
            
            PNContractTestCase.configuration = [PNConfiguration configurationWithPublishKey:kPNDefaultPublishKey
                                                                 subscribeKey:kPNDefaultSubscribeKey];
            self.configuration.origin = kPNMockServerAddress;
            self.configuration.TLSEnabled = NO;
            
            PNContractTestCase.apiCallStatuses = [NSMutableArray new];
            PNContractTestCase.apiCallResults = [NSMutableArray new];
            PNContractTestCase.receivedMessages = [NSMutableDictionary new];
            PNContractTestCase.receivedStatuses = [NSMutableDictionary new];
            PNContractTestCase.messageHandlers = [NSMutableArray new];
            PNContractTestCase.statusHandlers = [NSMutableArray new];
            
            [PNContractTestCase.currentClient removeListener:self];
            PNContractTestCase.currentClient = nil;
        });
        
        after(^(CCIScenarioDefinition *scenario) {
            if ([self shouldSetupMockServerForScenario:scenario]) {
                NSData *responseData = [self checkMockServerExpectationsForFeatureScenario:scenario];
                
                XCTAssertNotNil(responseData, @"Unable to get server expectations response");
                
                NSDictionary *response = [NSJSONSerialization JSONObjectWithData:responseData
                                                                         options:(NSJSONReadingOptions)0
                                                                           error:nil];
                
                NSArray<NSString *> *pendingExpectation = [response valueForKeyPath:@"expectations.pending"];
                if (pendingExpectation.count) {
                    XCTAssertTrue(false, @"Expectations not met: %@", [pendingExpectation componentsJoinedByString:@", "]);
                }
            }
            
            PNContractTestCase.messageHandlers = nil;
            PNContractTestCase.statusHandlers = nil;
            PNContractTestCase.currentClient = nil;
        });
        
        Given(@"the demo keyset", ^(NSArray<NSString *> *args, NSDictionary *userInfo) {
            // Nothing to do. Demo keys set by default if not explicitly set.
        });
        
        Given(@"the invalid keyset", ^(NSArray<NSString *> *args, NSDictionary *userInfo) {
            // Nothing to do. Mock server will simulate proper error here.
        });
        
        Then(@"I receive successful response", ^(NSArray<NSString *> *args, NSDictionary *userInfo) {
            PNStatus *status = [self lastStatus];
            PNResult *result = [self lastResult];
            
            if (status && status.operation == self.testedFeatureType) {
                XCTAssertFalse(status.isError, @"Last API call shouldn't fail.");
            }
            
            if ([self testedFeatureExpectResponse]) {
                XCTAssertNotNil(result, @"Last API should return result.");
            }
        });
        
        Then(@"I receive error response", ^(NSArray<NSString *> *args, NSDictionary *userInfo) {
            PNStatus *status = [self lastStatus];
            PNResult *result = [self lastResult];
            
            XCTAssertNotNil(status, @"Last API call should fail");
            XCTAssertTrue(status.operation == self.testedFeatureType,
                          @"Wrong last API call status operation type (expected: %@; got: %@)",
                          PNOperationTypeStrings[self.testedFeatureType], PNOperationTypeStrings[status.operation]);
            XCTAssertTrue(status.isError, @"Last API call should report error");
            
            if ([self testedFeatureExpectResponse]) {
                XCTAssertNil(result, @"Last API shouldn't return result.");
                XCTAssertTrue(result.operation == self.testedFeatureType, @"Wrong last API call result operation type");
            }
        });
        
        // Complete known contract steps configuration.
        [[PNAccessContractTestSteps new] setup];
        [[PNFilesContractTestSteps new] setup];
        [[PNHistoryContractTestSteps new] setup];
        [[PNMessageActionsContractTestSteps new] setup];
        [[PNPushContractTestSteps new] setup];
        [[PNPublishContractTestSteps new] setup];
        [[PNSubscribeContractTestSteps new] setup];
        [[PNTimeContractTestSteps new] setup];
    });
}


#pragma mark - Subscribe handling

- (void)subscribeClient:(PubNub *)client
synchronouslyToChannels:(NSArray *)channels
                 groups:(NSArray *)groups
           withPresence:(BOOL)withPresence
              timetoken:(NSNumber *)timetoken {
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    __block BOOL subscribeCompletedInTime = NO;
    client = client ?: self.client;
    
    [PNContractTestCase.statusHandlers addObject:^void(PubNub *receiver, PNStatus *status) {
        if (status.operation == PNSubscribeOperation && status.category == PNConnectedCategory) {
            subscribeCompletedInTime = YES;
            dispatch_semaphore_signal(semaphore);
        }
    }];
    
    client.subscribe()
        .channels(channels)
        .channelGroups(groups)
        .withPresence(withPresence)
        .withTimetoken(timetoken)
        .perform();
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, 10 * NSEC_PER_SEC));
    
    XCTAssertTrue(subscribeCompletedInTime, @"Subscribe operation timeout.");
}

- (void)unsubscribeClient:(PubNub *)client
synchronouslyFromChannels:(NSArray *)channels
                   groups:(NSArray *)groups
             withPresence:(BOOL)withPresence {
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    __block BOOL unsubscribeCompletedInTime = NO;
    client = client ?: self.client;
    
    [PNContractTestCase.statusHandlers addObject:^void(PubNub *receiver, PNStatus *status) {
        if (status.operation == PNUnsubscribeOperation && status.category == PNDisconnectedCategory) {
            unsubscribeCompletedInTime = YES;
            dispatch_semaphore_signal(semaphore);
        }
    }];
    
    client.unsubscribe()
        .channels(channels)
        .channelGroups(groups)
        .withPresence(withPresence)
        .perform();
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, 10 * NSEC_PER_SEC));
    
    XCTAssertTrue(unsubscribeCompletedInTime, @"Unsubscribe operation timeout.");
}

- (NSArray<PNMessageResult *> *)waitClient:(PubNub *)client
                         toReceiveMessages:(NSUInteger)messagesCount
                                 onChannel:(NSString *)channel {
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    __block PNTestChannelMessagesList *messages = nil;
    __block BOOL completedInTime = NO;
    client = client ?: self.client;
    
    __weak __typeof(self) weakSelf = self;
    BOOL(^checkMessagesCount)(PubNub *) = ^BOOL(PubNub *receiver) {
        NSString *clientIdentifier = receiver.currentConfiguration.uuid;
        
        if ([client.currentConfiguration.uuid isEqualToString:clientIdentifier]) {
            completedInTime = messagesCount >= [weakSelf messagesCountForClient:receiver onChannel:channel];
        }
        
        if (completedInTime) {
            PNTestClientMessagesList *clientMessages = PNContractTestCase.receivedMessages[clientIdentifier];
            
            if (channel) {
                messages = clientMessages[channel];
            } else {
                messages = [clientMessages.allValues valueForKeyPath: @"@unionOfArrays.self"];
            }
        }
        
        return completedInTime;
    };
    
    
    [PNContractTestCase.messageHandlers addObject:^void(PubNub *receiver, PNMessageResult *message) {
        if (checkMessagesCount(receiver)) {
            dispatch_semaphore_signal(semaphore);
        }
    }];
    
    if (!checkMessagesCount(client)){
        dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, 30 * NSEC_PER_SEC));
    }
    
    XCTAssertTrue(completedInTime, @"%@ messages not received in time", @(messagesCount));
    
    return messages;
}

- (NSArray<PNStatus *> *)waitClient:(PubNub *)client toReceiveStatuses:(NSUInteger)statusesCount {
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    __block PNTestClientStatusesList *statuses = nil;
    __block BOOL completedInTime = NO;
    client = client ?: self.client;
    
    BOOL(^checkStatusesCount)(PubNub *) = ^BOOL(PubNub *receiver) {
        NSString *clientIdentifier = receiver.currentConfiguration.uuid;
        
        if ([client.currentConfiguration.uuid isEqualToString:clientIdentifier]) {
            completedInTime = statusesCount >= PNContractTestCase.receivedStatuses[clientIdentifier].count;
        }
        
        if (completedInTime) {
            statuses = PNContractTestCase.receivedStatuses[clientIdentifier];
        }
        
        return completedInTime;
    };
    
    
    [PNContractTestCase.statusHandlers addObject:^void(PubNub *receiver, PNStatus *message) {
        if (checkStatusesCount(receiver)) {
            dispatch_semaphore_signal(semaphore);
        }
    }];
    
    if (!checkStatusesCount(client)) {
        dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, 30 * NSEC_PER_SEC));
    }
    
    XCTAssertTrue(completedInTime, @"%@ statutes count not received in time", @(statusesCount));
    
    return statuses;
}


#pragma mark - Result & Status handling

- (void)storeRequestResult:(nullable PNResult *)result {
    [PNContractTestCase.apiCallResults addObject:result ? result : [NSNull null]];
}

- (PNResult *)lastResult {
    id result = PNContractTestCase.apiCallResults.lastObject;
    
    return ![result isEqual:[NSNull null]] ? result : nil;
}

- (void)storeRequestStatus:(PNStatus *)status {
    [PNContractTestCase.apiCallStatuses addObject:status ? status : [NSNull null]];
}

- (PNStatus *)lastStatus {
    id status = PNContractTestCase.apiCallStatuses.lastObject;
    
    return ![status isEqual:[NSNull null]] ? status : nil;
}


#pragma mark - Helpers

- (BOOL)checkInUserInfo:(NSDictionary *)userInfo testingFeature:(NSString *)featureName {
    NSString *caseName = ((XCTestCase *)userInfo[@"XCTestCase"]).name;
    NSString *featureCaseName = [NSString stringWithFormat:@"CCI%@", featureName];
    
    return [caseName rangeOfString:featureCaseName].location != NSNotFound;
}

- (void)callCodeSynchronously:(void(^)(dispatch_block_t completion))block {
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    __block BOOL callCompletedInTime = NO;
    
    block(^{
        callCompletedInTime = YES;
        dispatch_semaphore_signal(semaphore);
    });
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, 60 * NSEC_PER_SEC));
    
    XCTAssertTrue(callCompletedInTime, @"Synchronous code execution timeout.");
}

- (void)pauseMainQueueFor:(NSTimeInterval)delay {
    dispatch_time_t date = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC));
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    
    dispatch_after(date, dispatch_get_main_queue(), ^{
        dispatch_semaphore_signal(semaphore);
    });
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * 2 * NSEC_PER_SEC)));
}

- (BOOL)shouldSetupMockServerForScenario:(CCIScenarioDefinition *)scenario {
    return [self contractForScenario:scenario] != nil;
}

- (NSData *)setupMockServerForFeatureScenario:(CCIScenarioDefinition *)scenario {
    NSString *urlString = [NSString stringWithFormat:@"http://%@/init?__contract__script__=%@",
                           kPNMockServerAddress, [self contractForScenario:scenario]];
    
    return [self synchronousMockServerRequestWithURL:[NSURL URLWithString:urlString]];
}

- (NSData *)checkMockServerExpectationsForFeatureScenario:(CCIScenarioDefinition *)scenario {
    NSString *urlString = [NSString stringWithFormat:@"http://%@/expect", kPNMockServerAddress];
    return [self synchronousMockServerRequestWithURL:[NSURL URLWithString:urlString]];
}

- (NSData *)synchronousMockServerRequestWithURL:(NSURL *)url {
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    __block NSData *responseData;
    
    [[NSURLSession.sharedSession dataTaskWithURL:url
                                  completionHandler:^(NSData *data, NSURLResponse *response,
                                                      NSError * error) {
        responseData = data;
        XCTAssertNil(error, @"Mock server call error: %@", error);
        dispatch_semaphore_signal(semaphore);
    }] resume];
    
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, 5 * NSEC_PER_SEC));
    
    return responseData;
}

- (NSString *)contractForScenario:(CCIScenarioDefinition *)scenario {
    NSString *contract;
    
    for (NSString *tagValuePair in scenario.tags) {
        if ([tagValuePair hasPrefix:@"contract="]) {
            contract = [tagValuePair componentsSeparatedByString:@"="].lastObject;
            break;
        }
    }
    
    return contract;
}

- (NSUInteger)messagesCountForClient:(PubNub *)client onChannel:(NSString *)channel {
    PNTestClientMessagesList *clientMessages = PNContractTestCase.receivedMessages[client.currentConfiguration.uuid];
    __block NSUInteger messagesCount = 0;
    
    if (channel) {
        messagesCount = clientMessages[channel].count;
    } else {
        [clientMessages enumerateKeysAndObjectsUsingBlock:^(NSString *channel, PNTestChannelMessagesList *messages, BOOL *stop) {
            messagesCount += messages.count;
        }];
    }
    
    return messagesCount;
}

- (BOOL)testedFeatureExpectResponse {
    BOOL responseExpected = NO;
    
    switch (self.testedFeatureType) {
        case PNFetchMessagesActionsOperation:
        case PNHistoryForChannelsOperation:
        case PNHistoryWithActionsOperation:
        case PNMessageCountOperation:
        case PNWhereNowOperation:
        case PNHereNowGlobalOperation:
        case PNHereNowForChannelOperation:
        case PNHereNowForChannelGroupOperation:
        case PNGetStateOperation:
        case PNStateForChannelOperation:
        case PNStateForChannelGroupOperation:
        case PNChannelGroupsOperation:
        case PNChannelsForGroupOperation:
        case PNPushNotificationEnabledChannelsOperation:
        case PNPushNotificationEnabledChannelsV2Operation:
        case PNFetchUUIDMetadataOperation:
        case PNFetchAllUUIDMetadataOperation:
        case PNFetchChannelMetadataOperation:
        case PNFetchAllChannelsMetadataOperation:
        case PNFetchMembershipsOperation:
        case PNFetchChannelMembersOperation:
        case PNListFilesOperation:
        case PNDownloadFileOperation:
        case PNTimeOperation:
            responseExpected = YES;
            break;
            
        default:
            break;
    }
    
    return responseExpected;
}


#pragma mark - PubNub event listener callbacks

- (void)client:(PubNub *)client didReceiveStatus:(PNStatus *)status {
    PNTestClientStatusesList *clientStatuses = PNContractTestCase.receivedStatuses[client.currentConfiguration.uuid];
    
    if (!clientStatuses) {
        clientStatuses = [NSMutableArray new];
        PNContractTestCase.receivedStatuses[client.currentConfiguration.uuid] = clientStatuses;
    }
    
    if (status) {
        [clientStatuses addObject:status];
    }
    
    [PNContractTestCase.statusHandlers enumerateObjectsUsingBlock:^(void (^block)(PubNub *, PNStatus *), NSUInteger idx, BOOL *stop) {
        block(client, status);
    }];
}

- (void)client:(PubNub *)client didReceiveMessage:(PNMessageResult *)message {
    PNTestClientMessagesList *clientMessages = PNContractTestCase.receivedMessages[client.currentConfiguration.uuid];
    
    if (!clientMessages) {
        clientMessages = [NSMutableDictionary new];
        PNContractTestCase.receivedMessages[client.currentConfiguration.uuid] = clientMessages;
    }
    
    PNTestChannelMessagesList *channelMessages = clientMessages[message.data.channel];
    
    if (!channelMessages) {
        channelMessages = [NSMutableArray new];
        clientMessages[message.data.channel] = channelMessages;
    }
    
    [channelMessages addObject:message];
    
    [PNContractTestCase.messageHandlers enumerateObjectsUsingBlock:^(void (^block)(PubNub *, PNMessageResult *), NSUInteger idx, BOOL *stop) {
        block(client, message);
    }];
}

#pragma mark -


@end
