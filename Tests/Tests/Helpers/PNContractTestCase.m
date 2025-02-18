/**
 * @author Serhii Mamontov
 * @copyright © 2010-2021 PubNub, Inc.
 */
#import "PNContractTestCase.h"
#import "PNMessageActionsContractTestSteps.h"
#import "PNAppContextObjectsRelationMetadataContractTestSteps.h"
#import "PNAppContextObjectMetadataContractTestSteps.h"
#import "PNCryptoModuleContractTestSteps.h"
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

/**
 * @brief Cucumber hook notification names.
 */
static NSString * const kPNCucumberBeforeHook = @"PNCucumberBeforeHook";
static NSString * const kPNCucumberAfterHook = @"PNCucumberAfterHook";

typedef NSMutableArray<PNMessageResult *> PNTestChannelMessagesList;
typedef NSMutableDictionary<NSString *, PNTestChannelMessagesList *> PNTestClientMessagesList;
typedef NSMutableArray<PNStatus *> PNTestClientStatusesList;


#pragma mark Static

static PubNub *_currentClient;

/**
 * @brief Queue which is used to synchronize access to shared resources.
 */
static dispatch_queue_t _resourcesAccess;

/**
 * @brief Array with PubNub REST API call error status objects or nulls.
 */
static NSMutableArray *_apiCallStatuses;

/**
 * @brief Array with PubNub REST API call result objects or nulls.
 */
static NSMutableArray *_apiCallResults;

/**
 * @brief List of GCD blocks which listens for PubNub client status change.
 */
static NSMutableArray<void(^)(PubNub *client, PNStatus *statue)> *_statusHandlers;

/**
 * @brief Statuses received during current scenario execution.
 */
static NSMutableDictionary<NSString *, PNTestClientStatusesList *> *_receivedStatuses;

/**
 * @brief List of GCD blocks which listens for PubNub client message receive.
 */
static NSMutableArray<void(^)(PubNub *client, PNMessageResult *message)> *_messageHandlers;

/**
 * @brief Messages received during current scenario execution.
 */
static NSMutableDictionary<NSString *, PNTestClientMessagesList *> *_receivedMessages;

static PNOperationType _currentlyTestedFeatureType;

static NSMutableDictionary *_relationMetadataObject;
static NSMutableDictionary *_metadataObject;

static NSMutableString *_pubNubUserId;


NS_ASSUME_NONNULL_BEGIN

#pragma mark - Private interface declaration

@interface PNContractTestCase () <PNEventsListener>


#pragma mark - Information

/// Reference to the App Context mock metadata objects.
@property (nonatomic, copy) NSDictionary<NSString *, NSDictionary *> *metadataObjects;

@property (nonatomic, nullable, copy) PNConfiguration *currentConfiguration;


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

/// Load all JSON objects from the `data` folder.
- (void)loadAppContextObjects;

#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark - Interface implementation

@implementation PNContractTestCase


#pragma mark - Information

- (PNConfiguration *)configuration {
    if (!self.currentConfiguration) {
        self.currentConfiguration = [PNConfiguration configurationWithPublishKey:kPNDefaultPublishKey
                                                                    subscribeKey:kPNDefaultSubscribeKey
                                                                          userID:[NSUUID UUID].UUIDString];
        self.currentConfiguration.origin = kPNMockServerAddress;
        self.currentConfiguration.TLSEnabled = NO;

        if (_pubNubUserId.length) self.currentConfiguration.userID = _pubNubUserId;
    }
    
    return self.currentConfiguration;
}

- (void)setConfiguration:(PNConfiguration *)configuration {
    _currentConfiguration = [configuration copy];
}

- (PubNub *)client {
    dispatch_barrier_sync(_resourcesAccess, ^{
        if (!_currentClient) {
            dispatch_queue_t queue = dispatch_queue_create("com.contract-test.callback-queue", DISPATCH_QUEUE_SERIAL);
            _currentClient = [PubNub clientWithConfiguration:self.configuration callbackQueue:queue];
            
            [_currentClient addListener:self];
        }
    });
    
    return _currentClient;
}

- (PNOperationType)testedFeatureType {
    return _currentlyTestedFeatureType;
}

- (void)setTestedFeatureType:(PNOperationType)testedFeatureType {
    _currentlyTestedFeatureType = testedFeatureType;
}

- (NSDictionary *)metadata {
    return _metadataObject;
}

- (NSDictionary *)relationMetadata {
    return _relationMetadataObject;
}

#pragma mark - Initialization & Configuration

- (void)startCucumberHookEventsListening {
    NSNotificationCenter *center = NSNotificationCenter.defaultCenter;
    
    [center addObserverForName:kPNCucumberBeforeHook object:nil queue:nil usingBlock:^(NSNotification *note) {
        [self handleBeforeHook];
    }];
    
    [center addObserverForName:kPNCucumberAfterHook object:nil queue:nil usingBlock:^(NSNotification *note) {
        [self handleAfterHook];
    }];
}

- (void)setup {
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        _pubNubUserId = [NSMutableString new];
        _relationMetadataObject = [NSMutableDictionary new];
        _metadataObject = [NSMutableDictionary new];
        _apiCallStatuses = [NSMutableArray new];
        _apiCallResults = [NSMutableArray new];
        _receivedMessages = [NSMutableDictionary new];
        _receivedStatuses = [NSMutableDictionary new];
        _messageHandlers = [NSMutableArray new];
        _statusHandlers = [NSMutableArray new];
        
        _resourcesAccess = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        
        before(^(CCIScenarioDefinition *scenario) {
            if ([self shouldSetupMockServerForScenario:scenario]) {
                NSData *response = [self setupMockServerForFeatureScenario:scenario];
                
                XCTAssertNotNil(response, @"Unable to get server init response");
            }
            
            [self handleBeforeHook];
            [NSNotificationCenter.defaultCenter postNotificationName:kPNCucumberBeforeHook object:nil];
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
            
            [self handleAfterHook];
            [NSNotificationCenter.defaultCenter postNotificationName:kPNCucumberAfterHook object:nil];
        });

        Given(@"the demo keyset", ^(NSArray<NSString *> *args, NSDictionary *userInfo) {
            // Nothing to do. Demo keys set by default if not explicitly set.
        });

        Given(@"the invalid keyset", ^(NSArray<NSString *> *args, NSDictionary *userInfo) {
            // Nothing to do. Mock server will simulate proper error here.
        });

        Given(@"I have a keyset with Objects V2 enabled", ^(NSArray<NSString *> *args, NSDictionary *userInfo) {
            // Nothing to do. Demo keys set by default if not explicitly set.
        });

        Then(@"^I receive (a )?successful response$", ^(NSArray<NSString *> *args, NSDictionary *userInfo) {
            PNStatus *status = [self lastStatus];
            PNOperationResult *result = [self lastResult];
            
            if (status && status.operation == self.testedFeatureType) {
                XCTAssertFalse(status.isError, @"Last API call shouldn't fail.");
            }
            
            if ([self testedFeatureExpectResponse]) {
                XCTAssertNotNil(result, @"Last API should return result.");
            }
        });
        
        Then(@"I receive error response", ^(NSArray<NSString *> *args, NSDictionary *userInfo) {
            PNStatus *status = [self lastStatus];
            PNOperationResult *result = [self lastResult];
            
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


        Given(@"^current user is '(.*)' persona$", ^(NSArray<NSString *> *args, NSDictionary *userInfo) {
            [_metadataObject addEntriesFromDictionary:[self mockForAppContextMetadataWithName:args[0]]];
            [_pubNubUserId setString:_metadataObject[@"id"]];
            XCTAssertTrue(_metadataObject.count > 0);
        });

        Match(@[@"Given", @"And"], @"^the (id|data) for '(.*)' (persona|channel|membership|member)( that we want to remove)?$", ^(NSArray<NSString *> *args, NSDictionary *userInfo) {
            if ([args.lastObject isEqual:@"persona"] || [args.lastObject isEqual:@"channel"]) {
                [_metadataObject addEntriesFromDictionary:[self mockForAppContextMetadataWithName:args[1]]];
                XCTAssertTrue(_metadataObject.count > 0);
            } else {
                [_relationMetadataObject addEntriesFromDictionary:[self mockForAppContextMetadataWithName:args[1]]];
                XCTAssertTrue(_relationMetadataObject.count > 0);
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
        [[PNCryptoModuleContractTestSteps new] setup];
        [[PNAppContextObjectsRelationMetadataContractTestSteps new] setup];
        [[PNAppContextObjectMetadataContractTestSteps new] setup];
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
    
    [_statusHandlers addObject:^void(PubNub *receiver, PNStatus *status) {
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
    
    [_statusHandlers addObject:^void(PubNub *receiver, PNStatus *status) {
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
        __block BOOL receivedRequiredCount = NO;
        
        dispatch_sync(_resourcesAccess, ^{
            NSString *clientIdentifier = receiver.currentConfiguration.userID;

            if ([client.currentConfiguration.userID isEqualToString:clientIdentifier]) {
                receivedRequiredCount = messagesCount >= [weakSelf messagesCountForClient:receiver onChannel:channel];
            }
            
            if (receivedRequiredCount) {
                PNTestClientMessagesList *clientMessages = _receivedMessages[clientIdentifier];
                
                if (channel) {
                    messages = clientMessages[channel];
                } else {
                    messages = [clientMessages.allValues valueForKeyPath: @"@unionOfArrays.self"];
                }
            }
        });
        
        return receivedRequiredCount;
    };
    
    
    [_messageHandlers addObject:^void(PubNub *receiver, PNMessageResult *message) {
        if (checkMessagesCount(receiver)) {
            completedInTime = YES;
            dispatch_semaphore_signal(semaphore);
        }
    }];
    
    if (!checkMessagesCount(client)){
        dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, 30 * NSEC_PER_SEC));
    } else {
        completedInTime = YES;
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
        __block BOOL receivedRequiredCount = NO;
        
        dispatch_sync(_resourcesAccess, ^{
            NSString *clientIdentifier = receiver.currentConfiguration.userID;

            if ([client.currentConfiguration.userID isEqualToString:clientIdentifier]) {
                receivedRequiredCount = statusesCount >= _receivedStatuses[clientIdentifier].count;
            }
            
            if (receivedRequiredCount) {
                statuses = _receivedStatuses[clientIdentifier];
            }
        });
        
        return receivedRequiredCount;
    };
    
    
    [_statusHandlers addObject:^void(PubNub *receiver, PNStatus *message) {
        if (checkStatusesCount(receiver)) {
            completedInTime = YES;
            dispatch_semaphore_signal(semaphore);
        }
    }];
    
    if (!checkStatusesCount(client)) {
        dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, 30 * NSEC_PER_SEC));
    } else {
        completedInTime = YES;
    }
    
    XCTAssertTrue(completedInTime, @"%@ statutes count not received in time", @(statusesCount));
    
    return statuses;
}


#pragma mark - Result & Status handling

- (void)storeRequestResult:(nullable PNOperationResult *)result {
    dispatch_barrier_async(_resourcesAccess, ^{
        [_apiCallResults addObject:result ? result : [NSNull null]];
    });
}

- (PNOperationResult *)lastResult {
    __block id result;
    
    dispatch_sync(_resourcesAccess, ^{
        result = _apiCallResults.lastObject;
    });
    
    return ![result isEqual:[NSNull null]] ? result : nil;
}

- (void)storeRequestStatus:(PNStatus *)status {
    dispatch_barrier_async(_resourcesAccess, ^{
        [_apiCallStatuses addObject:status ? status : [NSNull null]];
    });
}

- (PNStatus *)lastStatus {
    __block id status;
    
    dispatch_sync(_resourcesAccess, ^{
        status = _apiCallStatuses.lastObject;
    });
    
    return ![status isEqual:[NSNull null]] ? status : nil;
}


#pragma mark - Hooks handler

- (void)handleBeforeHook {
    self.currentConfiguration = nil;
    [self loadAppContextObjects];
}

- (void)handleAfterHook {
    [_pubNubUserId setString:@""];
    [_relationMetadataObject removeAllObjects];
    [_metadataObject removeAllObjects];
    [_apiCallStatuses removeAllObjects];
    [_apiCallResults removeAllObjects];
    [_receivedMessages removeAllObjects];
    [_receivedStatuses removeAllObjects];
    [_messageHandlers removeAllObjects];
    [_statusHandlers removeAllObjects];
    
    dispatch_barrier_sync(_resourcesAccess, ^{
        [_currentClient removeListener:self];
        [_currentClient unsubscribeFromAll];
        _currentClient = nil;
    });
}


#pragma mark - App Context helpers

- (NSDictionary *)mockForAppContextMetadataWithName:(NSString *)name {
    return self.metadataObjects[name.lowercaseString];
}

- (NSDictionary *)mockForAppContextMetadataWithId:(NSString *)identifier {
    for (NSString *name in self.metadataObjects.allKeys) {
        if ([self.metadataObjects[name][@"id"] isEqual:identifier]) return self.metadataObjects[name];
    }

    return nil;
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
    
    dispatch_after(date, dispatch_queue_create("wait-queue", DISPATCH_QUEUE_SERIAL), ^{
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
    PNTestClientMessagesList *clientMessages = _receivedMessages[client.currentConfiguration.userID];
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

- (void)loadAppContextObjects {
    NSString *resourcesPath = [NSBundle bundleForClass:[self class]].resourcePath;
    NSString *appContextMockPath = [resourcesPath stringByAppendingPathComponent:@"Features/data"];
    NSArray<NSString*> *mockNames = [NSFileManager.defaultManager contentsOfDirectoryAtPath:appContextMockPath error:nil];
    NSMutableDictionary *objects = mockNames.count ? [NSMutableDictionary new] : nil;

    [mockNames enumerateObjectsUsingBlock:^(NSString *name, NSUInteger __unused idx, BOOL * __unused stop) {
        NSData *data = [NSData dataWithContentsOfFile:[appContextMockPath stringByAppendingPathComponent:name]];
        NSString *entityName = name.lowercaseString.stringByDeletingPathExtension;
        if (data) objects[entityName] = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    }];

    self.metadataObjects = objects;
}


#pragma mark - PubNub event listener callbacks

- (void)client:(PubNub *)client didReceiveStatus:(PNStatus *)status {
    dispatch_barrier_async(_resourcesAccess, ^{
        PNTestClientStatusesList *clientStatuses = _receivedStatuses[client.currentConfiguration.userID];

        if (!clientStatuses) {
            clientStatuses = [NSMutableArray new];
            _receivedStatuses[client.currentConfiguration.userID] = clientStatuses;
        }
        
        if (status) {
            [clientStatuses addObject:status];
        }
        
        [_statusHandlers enumerateObjectsUsingBlock:^(void (^block)(PubNub *, PNStatus *), NSUInteger idx, BOOL *stop) {
            block(client, status);
        }];
    });
}

- (void)client:(PubNub *)client didReceiveMessage:(PNMessageResult *)message {
    dispatch_barrier_async(_resourcesAccess, ^{
        PNTestClientMessagesList *clientMessages = _receivedMessages[client.currentConfiguration.userID];

        if (!clientMessages) {
            clientMessages = [NSMutableDictionary new];
            _receivedMessages[client.currentConfiguration.userID] = clientMessages;
        }
        
        PNTestChannelMessagesList *channelMessages = clientMessages[message.data.channel];
        
        if (!channelMessages) {
            channelMessages = [NSMutableArray new];
            clientMessages[message.data.channel] = channelMessages;
        }
        
        [channelMessages addObject:message];
        
        [_messageHandlers enumerateObjectsUsingBlock:^(void (^block)(PubNub *, PNMessageResult *), NSUInteger idx, BOOL *stop) {
            block(client, message);
        }];
    });
}

#pragma mark -


@end
