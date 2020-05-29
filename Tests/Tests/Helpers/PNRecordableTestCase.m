/**
 * @author Serhii Mamontov
 * @copyright © 2010-2019 PubNub, Inc.
 */
#import <PubNub/PubNub+CorePrivate.h>
#import "PNRecordableTestCase.h"
#import "NSInvocation+PNTest.h"
#import "NSString+PNTest.h"
#import <OCMock/OCMock.h>


#pragma mark Defines

#define WRITING_CASSETTES 0
#define PUBNUB_LOGGER_ENABLED NO


#pragma mark - Types and structures

/**
 * @brief Type used to describe block for any PubNub callback.
 *
 * @param client \b PubNub client which used delegate callback.
 * @param data Data which has been passed with callback.
 * @param shouldRemove Whether handling block should be removed after call or not.
 */
typedef void (^PNTClientCallbackHandler)(PubNub *client, id data, BOOL *shouldRemove);


#pragma mark - Protected interface declaration

NS_ASSUME_NONNULL_BEGIN

@interface PNRecordableTestCase () <PNEventsListener>


#pragma mark - Information

/**
 * @brief List of \c UUID \c membership objects created during current test case.
 */
@property (nonatomic, strong) NSMutableDictionary<NSString *, NSMutableArray<PNMembership *> *> *uuidMembershipObjects;

/**
 * @brief List of \c channel \c members objects created during current test case.
 */
@property (nonatomic, strong) NSMutableDictionary<NSString *, NSMutableArray<PNMember *> *> *channelMembersObjects;

/**
 * @brief List of names which can be used as channel identifiers.
 */
@property (class, nonatomic, readonly, strong) NSArray<NSString *> *sharedChannelNamesList;

/**
 * @brief List of names which can be used as \b PubNub client identifiers or \c UUID for association
 * with \c metadata.
 */
@property (class, nonatomic, readonly, strong) NSArray<NSString *> *sharedUUIDsList;

/**
 * @brief List of generated and used user-provided values.
 */
@property (nonatomic, strong) NSMutableDictionary<NSString *, NSString *> *randomizedUserProvidedValues;

/**
 * @brief List of objects which has been pulled out from method invocation arguments.
 */
@property (class, nonatomic, readonly, strong) NSMutableArray *invocationObjects;

/**
 * @brief List of generated and used channel groups.
 */
@property (nonatomic, strong) NSMutableDictionary<NSString *, NSString *> *randomizedChannelGroups;

/**
 * @brief List of generated and used channels.
 */
@property (nonatomic, strong) NSMutableDictionary<NSString *, NSString *> *randomizedChannels;

/**
 * @brief Dictionary where original user authentication mapped to their randomized versions.
 */
@property (nonatomic, strong) NSMutableDictionary<NSString *, NSString *> *randomizedAuths;

/**
 * @brief Dictionary where original user identifiers mapped to their randomized versions.
 */
@property (nonatomic, strong) NSMutableDictionary<NSString *, NSString *> *randomizedUUIDs;

/**
 * @brief List of configured for test case \b PubNub client clone instances.
 */
@property (nonatomic, strong) NSMutableDictionary<NSString *, PubNub *> *clientClones;

/**
 * @brief List of configured for test case \b PubNub client instances.
 */
@property (nonatomic, strong) NSMutableDictionary<NSString *, PubNub *> *clients;

/**
 * @brief Resource access serialization queue.
 */
@property (nonatomic, nullable, strong) dispatch_queue_t resourceAccessQueue;

/**
 * @brief For how long negative test should wait till async operation completion.
 */
@property (nonatomic, assign) NSTimeInterval falseTestCompletionDelay;

/**
 * @brief List of \c channel \c metadata objects created during current test case.
 */
@property (nonatomic, strong) NSMutableArray<PNChannelMetadata *> *channelMetadataObjects;

/**
 * @brief List of \c UUID \c metadata objects created during current test case.
 */
@property (nonatomic, strong) NSMutableArray<PNUUIDMetadata *> *uuidMetadataObjects;

/**
 * @brief PubNub handlers list.
 */
@property (nonatomic, nullable, strong) NSMutableDictionary<NSString *, NSMutableDictionary<NSString *, NSMutableArray<PNTClientCallbackHandler> *> *> *pubNubHandlers;

/**
 * @brief For how long positive test should wait till async operation completion.
 */
@property (nonatomic, assign) NSTimeInterval testCompletionDelay;

/**
 * @brief Previously created mocking objects.
 */
@property (nonatomic, strong) NSMutableArray *instanceMocks;

/**
 * @brief Previously created mocking objects.
 */
@property (nonatomic, strong) NSMutableArray *classMocks;

/**
 * @brief Currently used \b PubNub client instance.
 *
 * @discussion Instance created lazily and take into account whether mocking enabled at this moment
 * or not.
 * As configuration instance will use \c defaultConfiguration and options provided by available
 * configuration callbacks.
 *
 * @note This client should be used only for unit tests, because they don't need to use multi-user
 * environment.
 */
@property (nonatomic, nullable, strong) PubNub *client;

/**
 * @brief \b PubNub PAM enabled subscribe key which should be used for client configuration.
 */
@property (nonatomic, copy) NSString *pamSubscribeKey;

/**
 * @brief \b PubNub PAM enabled publish key which should be used for client configuration.
 */
@property (nonatomic, copy) NSString *pamPublishKey;

/**
 * @brief \b PubNub subscribe key which should be used for client configuration.
 */
@property (nonatomic, copy) NSString *subscribeKey;

/**
 * @brief \b PubNub publish key which should be used for client configuration.
 */
@property (nonatomic, copy) NSString *publishKey;


#pragma mark - Objects

/**
 * @brief Remove list of \c UUID's \c membership objects which has been created during test case
 * run.
 *
 * @param uuid Identifier of user for which \c membership objects should be removed.
 * @param channels List of channel names with which \c UUID's membership should be removed.
 * @param client \b PubNub client which should be used to manage \c memberships. Will use
 *     \c self.client if passed \c nil.
 */
- (void)removeUUID:(NSString *)uuid membershipForChannels:(NSArray<NSString *> *)channels
       usingClient:(nullable PubNub *)client;

/**
 * @brief Remove list of \c channel \c member objects which has been created during test case run.
 *
 * @param channel Name of channel for which \c members should be removed.
 * @param uuids List of identifiers which should be removed from \c channel's members list.
 * @param client \b PubNub client which should be used to manage \c members. Will use \c self.client
 *     if passed \c nil.
 */
- (void)removeChannel:(NSString *)channel members:(NSArray<NSString *> *)uuids usingClient:(nullable PubNub *)client;


#pragma mark - Listeners

/**
 * @brief Add block which will be called for callbacks from \c client.
 *
 * @param type One of known event listener callback types: \c status, \c message or \c presence.
 * @param client \b PubNub client for which block should be added.
 * @param handler Block which should be called for specified callback \c type.
 */
- (void)addHandlerOfType:(NSString *)type forClient:(PubNub *)client withBlock:(PNTClientCallbackHandler)handler;

/**
 * @brief Removed list of blocks for callbacks from \c client.
 *
 * @param handlers List of handler blocks which should be removed for specified callback \c type.
 * @param type One of known event listener callback types: \c status, \c message or \c presence.
 * @param client \b PubNub client for which blocks should be removed.
 */
- (void)removeHandlers:(NSArray<PNTClientCallbackHandler> *)handlers ofType:(NSString *)type forClient:(PubNub *)client;

/**
 * @brief Receive block which will be called for callbacks from \c client.
 *
 * @param type One of known event listener callback types: \c status, \c message or \c presence.
 * @param client \b PubNub client for which block should be retrieved for specified \c type.
 *
 * @return List of callback handler blocks which can be called.
 */
- (nullable NSArray<PNTClientCallbackHandler> *)handlersOfType:(NSString *)type forClient:(PubNub *)client;


#pragma mark - Handlers

/**
 * @brief Test recorded (OCMExpect) stub call within specified interval.
 *
 * @param object Mock from object on which invocation call is expected.
 * @param invocation Invocation which is expected to be called.
 * @param shouldCall Whether tested \c invocation call or reject.
 * @param interval Number of seconds which test case should wait before it's continuation.
 * @param initialBlock GCD block which contain initialization of code required to invoke tested
 *     code.
 */
- (void)waitForObject:(id)object
    recordedInvocation:(id)invocation
                  call:(BOOL)shouldCall
        withinInterval:(NSTimeInterval)interval
            afterBlock:(void(^)(void))initialBlock;


#pragma mark - Misc

/**
 * @brief Generate randomized version of provided string which will persist during test case.
 *
 * @param string 'Normal' string value which should be randomized.
 *
 * @return String with randomized portion.
 */
- (NSString *)randomizedValueFrom:(NSString *)string;

/**
 * @brief Store randomized value in specified \c dictionary using \c string as key.
 *
 * @param string 'Normal' string value which should be randomized.
 * @param dictionary Dictionary inside of which randomized value should be stored.
 */
- (void)storeRandomizedValueFrom:(NSString *)string inDictionary:(NSMutableDictionary *)dictionary;

/**
 * @brief Load content of bundled 'tests-configuration.json' file and get publish / subscribe keys
 * from it.
 */
- (void)loadTestsConfiguration;

#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark - Interface implementation

@implementation PNRecordableTestCase


#pragma mark - Information

+ (NSArray<NSString *> *)sharedChannelNamesList {
    static NSArray<NSString *> *_sharedSpaceNamesList;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        _sharedSpaceNamesList = @[
            @"Chanted", @"Chipper", @"Solstice", @"Midnight", @"Wynn", @"Snowflake",
            @"Eos", @"Elmas", @"Sapphire", @"Auris", @"Happy", @"Mystic",
            @"Moriba", @"Sunny", @"Sigil", @"Euros", @"Zane", @"Majesty",
            @"Sparkles", @"Twilight", @"Unity", @"Grace", @"Giddy", @"Iris",
            @"Mawu", @"Meara", @"Mystery", @"Kaisa", @"Willow", @"Silvesse",
            @"Monterya", @"Robin", @"Jaden", @"Sable", @"Rune", @"Roshan",
            @"Jolly", @"Baine", @"Sterling", @"Chant"
        ];
    });
    
    return _sharedSpaceNamesList;
}

+ (NSArray<NSString *> *)sharedUUIDsList {
    static NSArray<NSString *> *_sharedNamesList;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        _sharedNamesList = @[
               @"Serhii", @"Kim", @"Earline", @"Glen", @"Nicolas", @"Shannon",
               @"Dena", @"Donnell", @"Juanita", @"Brock", @"Abdul", @"Timothy",
               @"Rex", @"Wilfredo", @"Warner", @"Maribel", @"Gina", @"Effie",
               @"Leroy", @"Horace", @"Mariana", @"Connie", @"Garland", @"Clara",
               @"Jeannette", @"Nigel", @"Jeanne", @"Dale", @"Alyce", @"Judson",
               @"Elijah", @"Rachelle", @"Howard", @"Leopoldo", @"Adrienne", @"Naomi",
               @"Jamie", @"Tracy", @"Austin", @"Alfredo", @"Trevor"
        ];
    });
    
    return _sharedNamesList;
}

+ (NSMutableArray *)invocationObjects {
    static NSMutableArray *_invocationObjects;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        _invocationObjects = [NSMutableArray new];
    });
    
    return _invocationObjects;
}


#pragma mark - Configuration

- (void)setUp {
    [super setUp];
    
    [self loadTestsConfiguration];
    
    self.resourceAccessQueue = dispatch_queue_create("test-case", DISPATCH_QUEUE_SERIAL);
    self.usesMockedObjects = [self hasMockedObjectsInTestCaseWithName:self.name];
    self.testCompletionDelay = 15.f;
    self.falseTestCompletionDelay = YHVVCR.cassette.isNewCassette ? self.testCompletionDelay : 0.25f;
    self.randomizedUserProvidedValues = [NSMutableDictionary new];
    self.randomizedChannelGroups = [NSMutableDictionary new];
    self.uuidMembershipObjects = [NSMutableDictionary new];
    self.channelMembersObjects = [NSMutableDictionary new];
    self.randomizedChannels = [NSMutableDictionary new];
    self.randomizedAuths = [NSMutableDictionary new];
    self.randomizedUUIDs = [NSMutableDictionary new];
    self.pubNubHandlers = [NSMutableDictionary new];
    self.instanceMocks = [NSMutableArray new];
    self.clientClones = [NSMutableDictionary new];
    self.channelMetadataObjects = [NSMutableArray new];
    self.uuidMetadataObjects = [NSMutableArray new];
    self.classMocks = [NSMutableArray new];
    self.clients = [NSMutableDictionary new];
}

- (void)tearDown {
#if WRITING_CASSETTES
    BOOL shouldWaitToRecordResponses = [self shouldSetupVCR] && YHVVCR.cassette.isNewCassette;
#else
    BOOL shouldWaitToRecordResponses = NO;
#endif // WRITING_CASSETTES
    BOOL shouldPostponeTearDown = self.clients.count || self.clientClones.count;
    
#if WRITING_CASSETTES
    if (shouldPostponeTearDown && shouldWaitToRecordResponses) {
        NSLog(@"\nTest completed. Record final requests from clients.\n");
    }
#endif // WRITING_CASSETTES
    
    if ([self shouldSetupVCR] && shouldPostponeTearDown) {
        void(^unsubscribePubNubClients)(NSArray<PubNub *> *) = ^(NSArray<PubNub *> *clients) {
            for (PubNub *client in clients) {
                if (![client channels].count && ![client presenceChannels].count && ![client channelGroups].count) {
                    [client removeListener:self];
                    
                    continue;
                }
                
                PNWeakify(self);
                [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
                    [client unsubscribeFromAllWithCompletion:^(PNStatus *status) {
                        PNStrongify(self);
                        [client removeListener:self];
                        handler();
                    }];
                }];
            }
        };
        
        unsubscribePubNubClients(self.clientClones.allValues);
        unsubscribePubNubClients(self.clients.allValues);
    }
    
    dispatch_sync(self.resourceAccessQueue, ^{
        [self.pubNubHandlers removeAllObjects];
    });
    
    [self.channelMetadataObjects removeAllObjects];
    [self.uuidMetadataObjects removeAllObjects];
    
    [self.clientClones removeAllObjects];
    [self.clients removeAllObjects];
    [self.client removeListener:self];
    
    self.client = nil;
    
    if (self.instanceMocks.count || self.classMocks.count) {
        [self.instanceMocks makeObjectsPerformSelector:@selector(stopMocking)];
        [self.classMocks makeObjectsPerformSelector:@selector(stopMocking)];
    }
    
    [self.instanceMocks removeAllObjects];
    [self.classMocks removeAllObjects];
    
    if (shouldPostponeTearDown) {
        NSTimeInterval waitDelay = shouldWaitToRecordResponses ? 0.5f : 0.005f;

        if (![self shouldSetupVCR]) {
            waitDelay = 0.1f;
        }
        
        [self waitTask:@"clientsDestroyCompletion" completionFor:waitDelay];
    }
    
    [super tearDown];
}


#pragma mark - Test configuration

- (BOOL)usePAMEnabledKeysForTestCaseWithName:(NSString *)name {
    return NO;
}

- (NSString *)pubNubUUIDForTestCaseWithName:(NSString *)name {
    NSString *uuid = nil;
    
    for (uuid in [self class].sharedUUIDsList) {
        if (![self pubNubForUser:uuid]) {
            break;
        }
    }
    
    return uuid;
}

- (NSString *)pubNubAuthForTestCaseWithName:(NSString *)name {
    return nil;
}

- (BOOL)hasMockedObjectsInTestCaseWithName:(NSString *)name {
    return NO;
}

- (PNConfiguration *)configurationForTestCaseWithName:(NSString *)name {
    return [self defaultConfiguration];
}


#pragma mark - VCR configuration

- (BOOL)shouldSetupVCR {
    NSString *bundleIdentifier = [NSBundle bundleForClass:[self class]].bundleIdentifier;
    BOOL shouldSetupVCR = [bundleIdentifier rangeOfString:@"mocked-integration"].location != NSNotFound;
    
    if ([self.name rangeOfString:@"BadRequestStatus"].location != NSNotFound) {
        shouldSetupVCR = NO;
    }
    
    return shouldSetupVCR;
}

- (void)updateVCRConfigurationFromDefaultConfiguration:(YHVConfiguration *)configuration {
#if WRITING_CASSETTES
    NSString *cassettesPath = @"<project path>/Tests/Support Files/Fixtures";
    NSString *cassetteName = [NSStringFromClass([self class]) stringByAppendingPathExtension:@"bundle"];
    configuration.cassettesPath = [cassettesPath stringByAppendingPathComponent:cassetteName];
#endif // WRITING_CASSETTES
    
    if (![configuration.matchers containsObject:YHVMatcher.body]) {
        NSMutableArray *matchers = [configuration.matchers mutableCopy];
        [matchers addObject:YHVMatcher.body];
        
        configuration.matchers = matchers;
    }
    
    configuration.pathFilter = ^NSString *(NSURLRequest *request) {
        NSMutableArray *pathComponents = [[request.URL.path componentsSeparatedByString:@"/"] mutableCopy];
        
        for (NSString *component in [pathComponents copy]) {
            NSUInteger componentIdx = [pathComponents indexOfObject:component];
            BOOL isChannelsOrGroupsComponent = NO;
            id replacement = component;
            
            for (NSString *key in @[self.publishKey, self.subscribeKey, self.pamPublishKey, self.pamSubscribeKey]) {
                if ([replacement rangeOfString:key].location != NSNotFound) {
                    NSArray *subComponents = [replacement componentsSeparatedByString:key];
                    replacement = [subComponents componentsJoinedByString:@"demo"];
                }
            }

            for (NSString *uuid in [self.randomizedUUIDs copy]) {
                NSString *randomUUID = self.randomizedUUIDs[uuid];
                
                if ([replacement rangeOfString:randomUUID].location != NSNotFound) {
                    NSArray *subComponents = [replacement componentsSeparatedByString:randomUUID];
                    replacement = [subComponents componentsJoinedByString:uuid];
                }
            }
            
            for (NSString *userProvidedValue in [self.randomizedUserProvidedValues copy]) {
                NSString *randomUserProvidedValue = self.randomizedUserProvidedValues[userProvidedValue];
                
                if ([replacement rangeOfString:randomUserProvidedValue].location != NSNotFound) {
                    NSArray *subComponents = [replacement componentsSeparatedByString:randomUserProvidedValue];
                    replacement = [subComponents componentsJoinedByString:userProvidedValue];
                }
            }
            
            for (NSString *channelGroup in [self.randomizedChannelGroups copy]) {
                NSString *randomChannelGroup = self.randomizedChannelGroups[channelGroup];
                
                if ([replacement rangeOfString:randomChannelGroup].location != NSNotFound) {
                    NSArray *subComponents = [replacement componentsSeparatedByString:randomChannelGroup];
                    replacement = [subComponents componentsJoinedByString:channelGroup];
                    isChannelsOrGroupsComponent=YES;
                }
            }
            
            for (NSString *channel in [self.randomizedChannels copy]) {
                NSString *randomChannel = self.randomizedChannels[channel];
                
                if ([replacement rangeOfString:randomChannel].location != NSNotFound) {
                    NSArray *subComponents = [replacement componentsSeparatedByString:randomChannel];
                    replacement = [subComponents componentsJoinedByString:channel];
                    isChannelsOrGroupsComponent=YES;
                }
            }
            
            if (isChannelsOrGroupsComponent) {
                NSArray *channelsGroupsList = [replacement componentsSeparatedByString:@","];
                SEL sortSelector = @selector(caseInsensitiveCompare:);
                channelsGroupsList = [channelsGroupsList sortedArrayUsingSelector:sortSelector];
                replacement=[channelsGroupsList componentsJoinedByString:@","];
            }
            
            pathComponents[componentIdx] = replacement;
        }
        
        return [pathComponents componentsJoinedByString:@"/"];
    };
    
    configuration.queryParametersFilter = ^(NSURLRequest *request, NSMutableDictionary *queryParameters) {
        for (NSString *parameter in queryParameters.allKeys) {
            __block id value = queryParameters[parameter];
            BOOL isChannelsOrGroupsComponent = NO;
            BOOL valueSerializedToString = NO;
            
            if ([value isKindOfClass:[NSDictionary class]] || [value isKindOfClass:[NSArray class]]) {
                NSData *valueData = [NSJSONSerialization dataWithJSONObject:value options:(NSJSONWritingOptions)0 error:nil];
                value = [[NSString alloc] initWithData:valueData encoding:NSUTF8StringEncoding];
                valueSerializedToString = YES;
            }
            
            if ([parameter hasPrefix:@"l_"] || [parameter isEqualToString:@"deviceid"] ||
                [parameter isEqualToString:@"instanceid"] || [parameter isEqualToString:@"requestid"]) {

                [queryParameters removeObjectForKey:parameter];
                continue;
            }
            
            if ([parameter isEqualToString:@"pnsdk"]) {
                value = @"PubNub-ObjC-iOS/4.x.x";
            }
            
            if ([parameter isEqualToString:@"seqn"]) {
                value = @"1";
            }
            
            for (NSString *key in @[self.publishKey, self.subscribeKey, self.pamPublishKey, self.pamSubscribeKey]) {
                if (![value isKindOfClass:[NSString class]]) {
                    continue;
                }
                
                value = [[value componentsSeparatedByString:key] componentsJoinedByString:@"demo"];
            }
            
            for (NSString *userProvidedValue in [self.randomizedUserProvidedValues copy]) {
                NSString *randomUserProvidedValue = self.randomizedUserProvidedValues[userProvidedValue];
                
                if (![value isKindOfClass:[NSString class]]) {
                    continue;
                }
                
                if ([value rangeOfString:randomUserProvidedValue].location != NSNotFound) {
                    value = [[value componentsSeparatedByString:randomUserProvidedValue]
                             componentsJoinedByString:userProvidedValue];
                }
            }
            
            for (NSString *channelGroup in [self.randomizedChannelGroups copy]) {
                NSString *randomChannelGroup = self.randomizedChannelGroups[channelGroup];
                
                if (![value isKindOfClass:[NSString class]]) {
                    continue;
                }
                
                if ([value rangeOfString:randomChannelGroup].location != NSNotFound) {
                    value = [[value componentsSeparatedByString:randomChannelGroup]
                             componentsJoinedByString:channelGroup];
                    
                    isChannelsOrGroupsComponent = YES;
                }
            }
            
            for (NSString *channel in [self.randomizedChannels copy]) {
                NSString *randomChannel = self.randomizedChannels[channel];
                
                if (![value isKindOfClass:[NSString class]]) {
                    continue;
                }
                
                if ([value rangeOfString:randomChannel].location != NSNotFound) {
                    value = [[value componentsSeparatedByString:randomChannel]
                             componentsJoinedByString:channel];
                    
                    isChannelsOrGroupsComponent = YES;
                }
            }
            
            if (isChannelsOrGroupsComponent) {
                NSArray *channelsGroupsList = [value componentsSeparatedByString:@","];
                SEL sortSelector = @selector(caseInsensitiveCompare:);
                channelsGroupsList = [channelsGroupsList sortedArrayUsingSelector:sortSelector];
                value=[channelsGroupsList componentsJoinedByString:@","];
            }
            
            
            if ([parameter isEqualToString:@"uuid"] || [parameter isEqualToString:@"meta"] ||
                [parameter isEqualToString:@"filter-expr"]) {
                for (NSString *uuid in [self.randomizedUUIDs copy]) {
                    NSString *randomUUID = self.randomizedUUIDs[uuid];
                    
                    if (![value isKindOfClass:[NSString class]]) {
                        continue;
                    }

                    if ([value rangeOfString:randomUUID].location != NSNotFound) {
                        value = [[value componentsSeparatedByString:randomUUID]
                                 componentsJoinedByString:uuid];
                    }
                }
            }
            
            if ([parameter isEqualToString:@"auth"]) {
                for (NSString *auth in [self.randomizedAuths copy]) {
                    NSString *randomAuth = self.randomizedAuths[auth];
                    
                    if (![value isKindOfClass:[NSString class]]) {
                        continue;
                    }

                    if ([value rangeOfString:randomAuth].location != NSNotFound) {
                        value = [[value componentsSeparatedByString:randomAuth]
                                 componentsJoinedByString:auth];
                    }
                }
            }
            
            if (valueSerializedToString && [value isKindOfClass:[NSString class]]) {
                NSData *valueData = [value dataUsingEncoding:NSUTF8StringEncoding];
                value = [NSJSONSerialization JSONObjectWithData:valueData options:(NSJSONReadingOptions)0 error:nil];
            }
            
            queryParameters[parameter] = value;
        }
    };
    
    
    YHVPostBodyFilterBlock postBodyFilter = ^NSData * (NSURLRequest *request, NSData *body) {
        NSString *httpBodyString = [[NSString alloc] initWithData:body encoding:NSUTF8StringEncoding];
        
        for (NSString *key in @[self.publishKey, self.subscribeKey, self.pamPublishKey, self.pamSubscribeKey]) {
            NSArray *bodyComponents = [httpBodyString componentsSeparatedByString:key];
            
            httpBodyString = [bodyComponents componentsJoinedByString:@"demo"];
        }
        
        for (NSString *uuid in [self.randomizedUUIDs copy]) {
            NSString *randomUUID = self.randomizedUUIDs[uuid];
            NSArray *bodyComponents = [httpBodyString componentsSeparatedByString:randomUUID];
            
            httpBodyString = [bodyComponents componentsJoinedByString:uuid];
        }

        for (NSString *userProvidedValue in [self.randomizedUserProvidedValues copy]) {
            NSString *randomUserProvidedValue = self.randomizedUserProvidedValues[userProvidedValue];
            NSArray *bodyComponents = [httpBodyString componentsSeparatedByString:randomUserProvidedValue];
            
            httpBodyString = [bodyComponents componentsJoinedByString:userProvidedValue];
        }
        
        for (NSString *channelGroup in [self.randomizedChannelGroups copy]) {
            NSString *randomChannelGroup = self.randomizedChannelGroups[channelGroup];
            NSArray *bodyComponents = [httpBodyString componentsSeparatedByString:randomChannelGroup];
            
            httpBodyString = [bodyComponents componentsJoinedByString:channelGroup];
        }
        
        for (NSString *channel in [self.randomizedChannels copy]) {
            NSString *randomChannel = self.randomizedChannels[channel];
            NSArray *bodyComponents = [httpBodyString componentsSeparatedByString:randomChannel];
            
            httpBodyString = [bodyComponents componentsJoinedByString:channel];
        }
        
        return [httpBodyString dataUsingEncoding:NSUTF8StringEncoding];
    };
    
    configuration.postBodyFilter = postBodyFilter;
    
    configuration.responseBodyFilter = ^NSData * (NSURLRequest *request, NSHTTPURLResponse *response, NSData *data) {
        if (!data.length) {
            return data;
        }
        
        return postBodyFilter(request, data);
    };
}


#pragma mark - Client configuration

- (PNConfiguration *)defaultConfiguration {
    NSString *subscribeKey = self.subscribeKey;
    NSString *publishKey = self.publishKey;
    
    if ([self usePAMEnabledKeysForTestCaseWithName:self.name]) {
        subscribeKey = self.pamSubscribeKey;
        publishKey = self.pamPublishKey;
    }
    
    PNConfiguration *configuration = [PNConfiguration configurationWithPublishKey:publishKey
                                                                     subscribeKey:subscribeKey];
    configuration.uuid = [self uuidForUser:[self pubNubUUIDForTestCaseWithName:self.name]];
    configuration.authKey = [self pubNubAuthForTestCaseWithName:self.name];
    
    return configuration;
}

- (PubNub *)client {
    if (!_client) {
        PubNub *client = [self createPubNubForUser:[self pubNubUUIDForTestCaseWithName:self.name]];
        _client = !self.usesMockedObjects ? client : [self mockForObject:client];
    }
    
    return _client;
}

- (PubNub *)createPubNubForUser:(NSString *)user {
    PNConfiguration *configuration = [self configurationForTestCaseWithName:self.name];
    
    return [self createPubNubForUser:user withConfiguration:configuration];
}

- (PubNub *)createPubNubForUser:(NSString *)user withConfiguration:(PNConfiguration *)configuration {
    dispatch_queue_t callbackQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    configuration.uuid = [self uuidForUser:user];
    
    PubNub *client = [PubNub clientWithConfiguration:configuration callbackQueue:callbackQueue];
    client.logger.enabled = PUBNUB_LOGGER_ENABLED;
    client.logger.logLevel  = PUBNUB_LOGGER_ENABLED ? PNVerboseLogLevel : PNSilentLogLevel;
    client.logger.writeToConsole = PUBNUB_LOGGER_ENABLED;
    client.logger.writeToFile = PUBNUB_LOGGER_ENABLED;
    [client addListener:self];
    
    if (!self.clients[user]) {
        self.clients[user] = client;
    } else if (!self.clientClones[user]) {
        self.clientClones[user] = client;
    } else {
        NSString *reason = [@"Attempt to create more than 2 instances for: " stringByAppendingString:user];

        @throw [NSException exceptionWithName:@"PubNubSetup" reason:reason userInfo:nil];
    }
    
    return client;
}

- (NSArray<PubNub *> *)createPubNubClients:(NSUInteger)clientsCount {
    NSMutableArray<PubNub *> *clients = [NSMutableArray new];
    
    for (NSUInteger userIdx = 0; userIdx < clientsCount; userIdx++) {
        NSString *user = [self pubNubUUIDForTestCaseWithName:self.name];
        
        [clients addObject:[self createPubNubForUser:user]];
    }
    
    return clients;
}

- (void)completePubNubConfiguration:(PubNub *)client {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunused-variable"
    NSString *uuid = client.currentConfiguration.uuid;
#pragma clang diagnostic pop
}

- (PubNub *)pubNubForUser:(NSString *)user {
    return self.clients[user];
}

- (PubNub *)pubNubCloneForUser:(NSString *)user {
    return self.clientClones[user];
}


#pragma mark - Subscription

- (void)subscribeClient:(PubNub *)client toChannels:(NSArray<NSString *> *)channels withPresence:(BOOL)usePresence {
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    __block BOOL handlerCalled = NO;
    
    [self addStatusHandlerForClient:client withBlock:^(PubNub *cClient, PNSubscribeStatus *status, BOOL *shouldRemove) {
        if (status.operation == PNSubscribeOperation) {
            NSSet *subscribedChannels = [NSSet setWithArray:status.subscribedChannels];

            if ([[NSSet setWithArray:channels] isSubsetOfSet:subscribedChannels]) {
                *shouldRemove = YES;
                handlerCalled = YES;
                
                dispatch_semaphore_signal(semaphore);
            }
        }
    }];
    
    [client subscribeToChannels:channels withPresence:usePresence];
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    
    if (!handlerCalled) {
        NSString *reason = [NSString stringWithFormat:@"Unable to complete subscription to: %@",
                            channels];
        
        @throw [NSException exceptionWithName:@"PNTestsConfigurationPubNub" reason:reason userInfo:nil];
    }
}

- (void)subscribeClient:(PubNub *)client toChannelGroups:(NSArray<NSString *> *)channelGroups withPresence:(BOOL)usePresence {
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    __block BOOL handlerCalled = NO;
    
    [self addStatusHandlerForClient:client withBlock:^(PubNub *cClient, PNSubscribeStatus *status, BOOL *shouldRemove) {
        if (status.operation == PNSubscribeOperation) {
            NSSet *subscribedChannelGroups = [NSSet setWithArray:status.subscribedChannelGroups];

            if ([[NSSet setWithArray:channelGroups] isSubsetOfSet:subscribedChannelGroups]) {
                *shouldRemove = YES;
                handlerCalled = YES;
                
                dispatch_semaphore_signal(semaphore);
            }
        }
    }];
    
    [client subscribeToChannelGroups:channelGroups withPresence:usePresence];
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    
    if (!handlerCalled) {
        NSString *reason = [NSString stringWithFormat:@"Unable to complete subscription to: %@",
                            channelGroups];
        
        @throw [NSException exceptionWithName:@"PNTestsConfigurationPubNub" reason:reason userInfo:nil];
    }
}

- (void)unsubscribeClient:(PubNub *)client fromChannels:(NSArray<NSString *> *)channels withPresence:(BOOL)usePresence {
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    __block BOOL handlerCalled = NO;
    
    [self addStatusHandlerForClient:client withBlock:^(PubNub *cClient, PNSubscribeStatus *status, BOOL *shouldRemove) {
        if (status.operation == PNUnsubscribeOperation) {
            NSMutableSet *clientChannelsAndGroups = [NSMutableSet setWithArray:cClient.channels];
            [clientChannelsAndGroups addObjectsFromArray:cClient.channelGroups];

            if (![[NSSet setWithArray:channels] isSubsetOfSet:clientChannelsAndGroups]) {
                *shouldRemove = YES;
                handlerCalled = YES;
                
                dispatch_semaphore_signal(semaphore);
            }
        }
    }];
    
    [client unsubscribeFromChannels:channels withPresence:usePresence];
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    
    if (!handlerCalled) {
        NSString *reason = [NSString stringWithFormat:@"Unable to complete unsubscription from: %@",
                            channels];
        
        @throw [NSException exceptionWithName:@"PNTestsConfigurationPubNub" reason:reason userInfo:nil];
    }
}

- (void)unsubscribeClient:(PubNub *)client fromChannelGroups:(NSArray<NSString *> *)channelGroups withPresence:(BOOL)usePresence {
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    __block BOOL handlerCalled = NO;
    
    [self addStatusHandlerForClient:client withBlock:^(PubNub *cClient, PNSubscribeStatus *status, BOOL *shouldRemove) {
        if (status.operation == PNUnsubscribeOperation) {
            NSMutableSet *clientChannelsAndGroups = [NSMutableSet setWithArray:cClient.channels];
            [clientChannelsAndGroups addObjectsFromArray:cClient.channelGroups];

            if (![[NSSet setWithArray:channelGroups] isSubsetOfSet:clientChannelsAndGroups]) {
                *shouldRemove = YES;
                handlerCalled = YES;
                
                dispatch_semaphore_signal(semaphore);
            }
        }
    }];
    
    [client unsubscribeFromChannelGroups:channelGroups withPresence:usePresence];
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    
    if (!handlerCalled) {
        NSString *reason = [NSString stringWithFormat:@"Unable to complete unsubscription from: %@",
                            channelGroups];
        
        @throw [NSException exceptionWithName:@"PNTestsConfigurationPubNub" reason:reason userInfo:nil];
    }
}


#pragma mark - Publish

- (NSArray<NSDictionary *> *)publishMessages:(NSUInteger)messagesCount toChannel:(NSString *)channel
                                 usingClient:(PubNub *)client {
    
    NSMutableArray *messages = [NSMutableArray new];
    client = client ?: self.client;
    NSUInteger time = 1577918412;
    
    for (NSUInteger messageIdx = 0; messageIdx < messagesCount; messageIdx++) {
        [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
            NSDictionary *metadata = nil;
            NSDictionary *message = @{
                @"messageIdx": [@[@"message", @(messageIdx)] componentsJoinedByString:@": "],
                @"time": @(time + messageIdx)
            };
            
            PNPublishAPICallBuilder *builder = client.publish().message(message).channel(channel);
            
            if (messageIdx % 2 == 0) {
                metadata = @{ @"time": message[@"time"] };
                builder = builder.metadata(metadata);
            }
            
            builder.performWithCompletion(^(PNPublishStatus *status) {
                XCTAssertFalse(status.isError);
                
                if (!status.isError) {
                    NSMutableDictionary *publishedMessage = [@{
                        @"message": message,
                        @"timetoken": status.data.timetoken
                    } mutableCopy];
                    
                    if (metadata) {
                        publishedMessage[@"metadata"] = metadata;
                    }
                    
                    [messages addObject:publishedMessage];
                }
                
                handler();
            });
        }];
        
        [self waitTask:@"throttleProtection" completionFor:(YHVVCR.cassette.isNewCassette ? 0.5f : 0.f)];
    }
    
    [self waitTask:@"waitForStorage" completionFor:(YHVVCR.cassette.isNewCassette ? 3.f : 0.f)];
    
    return messages;
}

- (NSDictionary<NSString *, NSArray<NSDictionary *> *> *)publishMessages:(NSUInteger)messagesCount
                                                              toChannels:(NSArray<NSString *> *)channels
                                                             usingClient:(PubNub *)client {
    
    NSMutableDictionary *channelMessages = [NSMutableDictionary new];
    
    for (NSString *channel in channels) {
        channelMessages[channel] = [self publishMessages:messagesCount
                                               toChannel:channel
                                             usingClient:client];
    }
    
    return channelMessages;
}

- (NSArray<PNMessageAction *> *)addActions:(NSUInteger)actionsCount
                                toMessages:(NSArray<NSNumber *> *)messages
                                 inChannel:(NSString *)channel
                               usingClient:(PubNub *)client {
    
    NSArray<NSString *> *types = @[@"reaction", @"receipt", @"custom"];
    NSArray<NSString *> *actionValues = [self randomizedValuesWithValues:@[
        @"value1", @"value2", @"value3", @"value4", @"value5",
        @"value6", @"value7", @"value8", @"value9", @"value10"
    ]];
    NSMutableArray *actions = [NSMutableArray new];
    client = client ?: self.client;
    
    
    for (NSUInteger messageIdx = 0; messageIdx < messages.count; messageIdx++) {
        NSNumber *messageTimetoken = messages[messageIdx];
        
        for (NSUInteger actionIdx = 0; actionIdx < actionsCount; actionIdx++) {
            [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
                client.addMessageAction()
                    .channel(channel)
                    .messageTimetoken(messageTimetoken)
                    .type(types[(actionIdx + 1)%3])
                    .value(actionValues[(actionIdx + 1)%10])
                    .performWithCompletion(^(PNAddMessageActionStatus *status) {
                        XCTAssertFalse(status.isError);
                        
                        if (!status.isError) {
                            [actions addObject:status.data.action];
                        }
                        
                        handler();
                    });
            }];
            
            [self waitTask:@"throttleProtection" completionFor:(YHVVCR.cassette.isNewCassette ? 0.5f : 0.f)];
        }
    }
    
    [self waitTask:@"waitForStorage" completionFor:(YHVVCR.cassette.isNewCassette ? 3.f : 0.f)];
    
    return actions;
}

- (void)verifyMessageActionsCountInChannel:(NSString *)channel
                             shouldEqualTo:(NSUInteger)count
                               usingClient:(PubNub *)client {
    
    client = client ?: self.client;
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        client.fetchMessageActions()
            .channel(channel)
            .performWithCompletion(^(PNFetchMessageActionsResult *result, PNErrorStatus *status) {
                XCTAssertFalse(status.isError);
                XCTAssertEqual(result.data.actions.count, count);
            
                handler();
            });
    }];
}


#pragma mark - History

- (void)deleteHistoryForChannel:(NSString *)channel usingClient:(PubNub *)client {
    [self deleteHistoryForChannels:@[channel] usingClient:client];
}

- (void)deleteHistoryForChannels:(NSArray<NSString *> *)channels usingClient:(PubNub *)client {
    client = client ?: self.client;
    
    for (NSString *channel in channels) {
        [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
            client.deleteMessage().channel(channel).performWithCompletion(^(PNAcknowledgmentStatus *status) {
                XCTAssertFalse(status.isError);
                handler();
            });
        }];
    }
    
    [self waitTask:@"waitForStorage" completionFor:(YHVVCR.cassette.isNewCassette ? 3.f : 0.05f)];
}


#pragma mark - Channel groups

- (void)addChannels:(NSArray<NSString *> *)channels
     toChannelGroup:(NSString *)channelGroup
        usingClient:(PubNub *)client {
    
    client = client ?: self.client;
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [client addChannels:channels toGroup:channelGroup withCompletion:^(PNAcknowledgmentStatus *status) {
            XCTAssertFalse(status.isError);
            handler();
        }];
    }];
    
    [self waitTask:@"waitForDistribution" completionFor:(YHVVCR.cassette.isNewCassette ? 1.f : 0.f)];
}

- (void)verifyChannels:(NSArray<NSString *> *)channels
        inChannelGroup:(NSString *)channelGroup
           shouldEqual:(BOOL)shouldEqual
           usingClient:(PubNub *)client {
    
    NSSet *addedChannelsSet = [NSSet setWithArray:channels];
    client = client ?: self.client;
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [client channelsForGroup:channelGroup
                  withCompletion:^(PNChannelGroupChannelsResult *result, PNErrorStatus *status) {
            
            NSSet *fetchedChannelsSet = [NSSet setWithArray:result.data.channels];
            XCTAssertNil(status);
            XCTAssertNotNil(fetchedChannelsSet);
            
            if (shouldEqual) {
                XCTAssertTrue([fetchedChannelsSet isEqualToSet:addedChannelsSet]);
            } else {
                XCTAssertTrue([addedChannelsSet isSubsetOfSet:fetchedChannelsSet]);
            }
            
            handler();
        }];
    }];
}

- (void)removeChannelGroup:(NSString *)channelGroup usingClient:(PubNub *)client {
    client = client ?: self.client;
    
    [self waitTask:@"waitForDistribution" completionFor:(YHVVCR.cassette.isNewCassette ? 1.f : 0.f)];
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [client removeChannelsFromGroup:channelGroup withCompletion:^(PNAcknowledgmentStatus *status) {
            XCTAssertFalse(status.isError);
            handler();
        }];
    }];
}

#pragma mark - Presence

- (void)setState:(NSDictionary *)state onChannel:(NSString *)channel usingClient:(PubNub *)client {
    client = client ?: self.client;
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        [client setState:state forUUID:client.currentConfiguration.uuid onChannel:channel
          withCompletion:^(PNClientStateUpdateStatus *status) {
            XCTAssertFalse(status.isError);
            handler();
        }];
    }];
    
    [self waitTask:@"waitForDistribution" completionFor:(YHVVCR.cassette.isNewCassette ? 1.f : 0.f)];
}


#pragma mark - Objects

- (void)removeAllObjects {
    __block NSArray<NSString *> *channels = nil;
    __block NSArray<NSString *> *uuids = nil;
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.objects().allUUIDMetadata().performWithCompletion(^(PNFetchAllUUIDMetadataResult *result, PNErrorStatus *status) {
            uuids = [result.data.metadata valueForKey:@"uuid"] ?: @[];
            
            handler();
        });
    }];
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        self.client.objects().allChannelsMetadata().performWithCompletion(^(PNFetchAllChannelsMetadataResult *result, PNErrorStatus *status) {
            channels = [result.data.metadata valueForKey:@"channel"] ?: @[];
            
            handler();
        });
    }];
    
    for (NSString *uuid in uuids) {
        [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
            self.client.objects().memberships().uuid(uuid).performWithCompletion(^(PNFetchMembershipsResult *result, PNErrorStatus *status) {
                NSArray *channelNames = [result.data.memberships valueForKey:@"channel"] ?: @[];
                
                if (channelNames.count) {
                    self.client.objects().removeMemberships()
                        .uuid(uuid)
                        .channels(channelNames)
                        .performWithCompletion(^(PNManageMembershipsStatus *status) {
                            NSLog(@"%@ %@'s MEMBERSHIPS HAS BEEN REMOVED", @(channelNames.count), uuid);
                            handler();
                        });
                } else {
                    handler();
                }
            });
        }];
    }
    
    
    for (NSString *uuid in uuids) {
        [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
            self.client.objects().removeUUIDMetadata().uuid(uuid).performWithCompletion(^(PNAcknowledgmentStatus *status) {
                handler();
            });
        }];
    }
    
    for (NSString *channel in channels) {
        [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
            self.client.objects().removeChannelMetadata(channel).performWithCompletion(^(PNAcknowledgmentStatus *status) {
                handler();
            });
        }];
    }
    
    if (uuids.count || channels.count) {
        if (uuids.count) {
            NSLog(@"%@ UUIDs HAS BEEN REMOVED", @(uuids.count));
        }
        
        if (channels.count) {
            NSLog(@"%@ CHANNELS HAS BEEN REMOVED", @(channels.count));
        }
        
        [self waitTask:@"waitForDistribution" completionFor:1.f];
    }
}

- (NSArray<PNUUIDMetadata *> *)setUUIDMetadata:(NSUInteger)objectsCount usingClient:(PubNub *)client {
    objectsCount = MIN(objectsCount, [self class].sharedUUIDsList.count);
    NSMutableArray<NSString *> *uuids = [NSMutableArray new];
    
    for (NSUInteger objectIdx = 0; objectIdx < objectsCount; objectIdx++) {
        [uuids addObject:[self class].sharedUUIDsList[objectIdx]];
    }
    
    return [self setMetadataForUUIDs:uuids usingClient:client];
}

- (PNUUIDMetadata *)setMetadataForUUID:(NSString *)uuid usingClient:(PubNub *)client {
    return [self setMetadataForUUIDs:@[uuid] usingClient:client].firstObject;
}

- (NSArray<PNUUIDMetadata *> *)setMetadataForUUIDs:(NSArray<NSString *> *)uuids
                                       usingClient:(PubNub *)client {

    NSMutableArray *uuidsMetadata = [NSMutableArray new];
    client = client ?: self.client;
    
    for (NSString *uuid in uuids) {
        NSString *randomizedIdentifier = [self randomizedValuesWithValues:@[uuid]].firstObject;
        NSString *identifier = [@[randomizedIdentifier, @"uuid", @"identifier"] componentsJoinedByString:@"-"];
        NSDictionary *custom = @{
            @"uuid-custom1": [@[uuid, @"custom", @"data", @"1"] componentsJoinedByString:@"-"],
            @"uuid-custom2": [@[uuid, @"custom", @"data", @"2"] componentsJoinedByString:@"-"]
        };
        
        [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
            self.client.objects().setUUIDMetadata()
                .uuid(identifier)
                .name(uuid)
                .custom(custom)
                .includeFields(PNUUIDCustomField)
                .performWithCompletion(^(PNSetUUIDMetadataStatus *status) {
                    XCTAssertFalse(status.isError);
                    XCTAssertNotNil(status.data.metadata);
                    
                    [uuidsMetadata addObject:status.data.metadata];
                    [self.uuidMetadataObjects addObject:status.data.metadata];
                    
                    handler();
                });
        }];
    }
    
    [self waitTask:@"waitForDistribution" completionFor:(YHVVCR.cassette.isNewCassette ? 1.f : 0.f)];
    
    return uuidsMetadata;
}

- (void)verifyUUIDMetadataCountShouldEqualTo:(NSUInteger)count usingClient:(PubNub *)client {
    client = client ?: self.client;
    
    [self waitTask:@"waitForDistribution" completionFor:(YHVVCR.cassette.isNewCassette ? 1.f : 0.f)];
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        client.objects().allUUIDMetadata()
            .includeCount(YES)
            .performWithCompletion(^(PNFetchAllUUIDMetadataResult *result, PNErrorStatus *status) {
                XCTAssertNil(status);
                XCTAssertEqual(result.data.totalCount, count);
                
                handler();
            });
    }];
}

- (NSArray<PNMembership *> *)createUUIDsMembership:(NSArray<NSString *> *)uuids
                                        inChannels:(NSArray<NSString *> *)channels
                                       withCustoms:(NSArray<NSDictionary *> *)customs
                                       usingClient:(PubNub *)client {
    
    return [self createUUIDsMembership:uuids
                            inChannels:channels
                           withCustoms:customs
                       channelMetadata:NO
                           usingClient:client];
    
}

- (NSArray<PNMembership *> *)createUUIDsMembership:(NSArray<NSString *> *)uuids
                                        inChannels:(NSArray<NSString *> *)channels
                                       withCustoms:(NSArray<NSDictionary *> *)customs
                                   channelMetadata:(BOOL)shouldIncludeChannelMetadata
                                       usingClient:(PubNub *)client {

    NSMutableArray<PNMembership *> *createdUUIDMemberships = [NSMutableArray new];
    NSMutableArray *channelsForMembership = [NSMutableArray new];
    client = client ?: self.client;
    
    for (NSUInteger channelIdx = 0; channelIdx < channels.count; channelIdx++) {
        NSMutableDictionary *channelData = [@{ @"channel": channels[channelIdx] } mutableCopy];
        
        if (customs && channelIdx < customs.count) {
            channelData[@"custom"] = customs[channelIdx];
        }
        
        [channelsForMembership addObject:channelData];
    }
    
    PNMembershipFields fields = PNMembershipCustomField;
    
    if (shouldIncludeChannelMetadata) {
        fields |= PNMembershipChannelField;
    }
    
    
    for (NSString *uuid in uuids) {
        if (!self.uuidMembershipObjects[uuid]) {
            self.uuidMembershipObjects[uuid] = [NSMutableArray new];
        }
        
        [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
            client.objects().setMemberships()
                .uuid(uuid)
                .channels(channelsForMembership)
                .includeFields(fields)
                .performWithCompletion(^(PNManageMembershipsStatus *status) {
                XCTAssertFalse(status.isError);
                    XCTAssertNotNil(status.data.memberships);
                    
                    for (NSUInteger channelIdx = 0; channelIdx < channels.count; channelIdx++) {
                        for (PNMembership *membership in status.data.memberships) {
                            if ([membership.channel isEqualToString:channels[channelIdx]]) {
                                [createdUUIDMemberships addObject:membership];
                                break;
                            }
                        }
                    }
                    
                    [self.uuidMembershipObjects[uuid] addObjectsFromArray:status.data.memberships];
                    
                    handler();
                });
        }];
    }
    
    [self waitTask:@"waitForDistribution" completionFor:(YHVVCR.cassette.isNewCassette ? 1.f : 0.f)];
    
    return createdUUIDMemberships;
}

- (void)verifyUUIDMembershipsCount:(NSString *)uuid shouldEqualTo:(NSUInteger)count usingClient:(PubNub *)client {
    client = client ?: self.client;
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        client.objects().memberships()
            .uuid(uuid)
            .performWithCompletion(^(PNFetchMembershipsResult *result, PNErrorStatus *status) {
                NSArray<PNMembership *> *memberships = result.data.memberships;
                XCTAssertNil(status);
                XCTAssertNotNil(memberships);
                XCTAssertEqual(memberships.count, count);
                
                handler();
            });
    }];
}

- (void)removeUUID:(NSString *)uuid cachedMembershipForChannel:(NSString *)channel {
    PNMembership *membership = nil;
    
    for (membership in self.uuidMembershipObjects[uuid]) {
        if ([membership.channel isEqualToString:channel]) {
            break;
        }
    }
    
    [self.uuidMembershipObjects[uuid] removeObject:membership];
}

- (void)removeUUID:(NSString *)uuid
 membershipObjects:(NSArray<PNMembership *> *)memberships
       usingClient:(nullable PubNub *)client {

    [self removeUUID:uuid membershipForChannels:[memberships valueForKey:@"channel"] usingClient:client];
}

- (void)removeUUIDs:(NSArray<NSString *> *)uuids membershipObjectsUsingClient:(nullable PubNub *)client {
    for (NSString *uuid in uuids) {
        [self removeUUID:uuid membershipObjectsUsingClient:client];
    }
}

- (void)removeUUID:(NSString *)uuid membershipObjectsUsingClient:(nullable PubNub *)client {
    if (!self.uuidMembershipObjects[uuid].count) {
        return;
    }
    
    NSArray<NSString *> *channels = [self.uuidMembershipObjects[uuid] valueForKey:@"channel"];

    [self removeUUID:uuid membershipForChannels:channels usingClient:client];
}

- (void)removeUUID:(NSString *)uuid membershipForChannels:(NSArray<NSString *> *)channels usingClient:(PubNub *)client {
    client = client ?: self.client;
    
    if (!channels.count) {
        return;
    }
    
    [self waitTask:@"waitForDistribution" completionFor:(YHVVCR.cassette.isNewCassette ? 1.f : 0.f)];
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        client.objects().removeMemberships()
            .uuid(uuid)
            .channels(channels)
            .performWithCompletion(^(PNManageMembershipsStatus *status) {
                XCTAssertFalse(status.isError);
                
                if (status.isError) {
                    NSLog(@"'%@' UUID MEMBERSHIP REMOVE ERROR: %@\n%@",
                          uuid, status.errorData.information,
                          [status valueForKey:@"clientRequest"]);
                }
                
                handler();
            });
    }];
}

- (void)removeCachedUUIDMetadata:(NSString *)uuid {
    PNUUIDMetadata *metadata = nil;
    
    for (metadata in self.uuidMetadataObjects) {
        if ([metadata.uuid isEqualToString:uuid]) {
            break;
        }
    }
    
    [self.uuidMetadataObjects removeObject:metadata];
}

- (void)removeUUIDsMetadata:(NSArray<NSString *> *)uuids usingClient:(nullable PubNub *)client {
    client = client ?: self.client;
    
    if (!uuids.count) {
        return;
    }
    
    for (NSString *uuid in uuids) {
        [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
            client.objects().removeUUIDMetadata()
                .uuid(uuid)
                .performWithCompletion(^(PNAcknowledgmentStatus *status) {
                    XCTAssertFalse(status.isError);
                    
                    if (status.isError) {
                        NSLog(@"'%@' UUID METADATA REMOVE ERROR: %@\n%@",
                              uuid, status.errorData.information,
                              [status valueForKey:@"clientRequest"]);
                    }
                    
                    handler();
                });
        }];
    }
    
    [self waitTask:@"waitForDistribution" completionFor:(YHVVCR.cassette.isNewCassette ? 1.f : 0.f)];
}

- (void)removeAllUUIDMetadataUsingClient:(nullable PubNub *)client {
    if (!self.uuidMetadataObjects.count) {
        return;
    }

    [self removeUUIDsMetadata:[self.uuidMetadataObjects valueForKey:@"uuid"] usingClient:client];
}

- (NSArray<PNChannelMetadata *> *)setChannelsMetadata:(NSUInteger)objectsCount usingClient:(PubNub *)client {
    objectsCount = MIN(objectsCount, [self class].sharedChannelNamesList.count);
    NSMutableArray<NSString *> *channelNames = [NSMutableArray new];
    
    for (NSUInteger objectIdx = 0; objectIdx < objectsCount; objectIdx++) {
        [channelNames addObject:[self class].sharedChannelNamesList[objectIdx]];
    }
    
    return [self setMetadataForChannels:channelNames usingClient:client];
}

- (PNChannelMetadata *)setMetadataForChannel:(NSString *)channel usingClient:(PubNub *)client {
    return [self setMetadataForChannels:@[channel] usingClient:client].firstObject;
}

- (NSArray<PNChannelMetadata *> *)setMetadataForChannels:(NSArray<NSString *> *)channels
                                             usingClient:(PubNub *)client {
    NSMutableArray *channelsMetadata = [NSMutableArray new];
    client = client ?: self.client;
    
    for (NSString *channel in channels) {
        NSString *randomizedIdentifier = [self randomizedValuesWithValues:@[channel]].firstObject;
        NSString *identifier = [@[randomizedIdentifier, @"channel", @"identifier"] componentsJoinedByString:@"-"];
        NSDictionary *custom = @{
            @"channel-custom1": [@[channel, @"custom", @"data", @"1"] componentsJoinedByString:@"-"],
            @"channel-custom2": [@[channel, @"custom", @"data", @"2"] componentsJoinedByString:@"-"]
        };
        
        [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
            client.objects().setChannelMetadata(identifier)
                .name(channel)
                .custom(custom)
                .includeFields(PNChannelCustomField)
                .performWithCompletion(^(PNSetChannelMetadataStatus *status) {
                    XCTAssertFalse(status.isError);
                    XCTAssertNotNil(status.data.metadata);
                    
                    [channelsMetadata addObject:status.data.metadata];
                    [self.channelMetadataObjects addObject:status.data.metadata];
                    
                    handler();
                });
        }];
    }
    
    [self waitTask:@"waitForDistribution" completionFor:(YHVVCR.cassette.isNewCassette ? 1.f : 0.f)];
    
    return channelsMetadata;
}

- (void)verifyChannelsMetadataCountShouldEqualTo:(NSUInteger)count usingClient:(PubNub *)client {
    client = client ?: self.client;
    
    [self waitTask:@"waitForDistribution" completionFor:(YHVVCR.cassette.isNewCassette ? 1.f : 0.f)];
    
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        client.objects().allChannelsMetadata()
            .includeCount(YES)
            .performWithCompletion(^(PNFetchAllChannelsMetadataResult *result, PNErrorStatus *status) {
                XCTAssertNil(status);
                XCTAssertEqual(result.data.totalCount, count);
                
                handler();
            });
    }];
}

- (NSArray<PNMember *> *)addMembers:(NSArray<NSString *> *)uuids
                         toChannels:(NSArray<NSString *> *)channels
                        withCustoms:(nullable NSArray<NSDictionary *> *)customs
                        usingClient:(nullable PubNub *)client {
    
    return [self addMembers:uuids
                 toChannels:channels
                withCustoms:customs
               uuidMetadata:NO
                usingClient:client];
}

- (NSArray<PNMember *> *)addMembers:(NSArray<NSString *> *)uuids
                         toChannels:(NSArray<NSString *> *)channels
                        withCustoms:(nullable NSArray<NSDictionary *> *)customs
                       uuidMetadata:(BOOL)shouldIncludeUUIDMetadata
                        usingClient:(nullable PubNub *)client {

    NSMutableArray *createdChannelMembers = [NSMutableArray new];
    NSMutableArray *membersToAdd = [NSMutableArray new];
    client = client ?: self.client;
    
    for (NSUInteger memberIdx = 0; memberIdx < uuids.count; memberIdx++) {
        NSMutableDictionary *memberData = [@{ @"uuid": uuids[memberIdx] } mutableCopy];
        
        if (customs && memberIdx < customs.count) {
            memberData[@"custom"] = customs[memberIdx];
        }
        
        [membersToAdd addObject:memberData];
    }
    
    PNMemberFields fields = PNMemberCustomField;
    
    if (shouldIncludeUUIDMetadata) {
        fields |= PNMemberUUIDField;
    }
    
    for (NSString *channel in channels) {
        if (!self.channelMembersObjects[channel]) {
            self.channelMembersObjects[channel] = [NSMutableArray new];
        }
        
        [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
            client.objects()
                .setMembers(channel)
                .uuids(membersToAdd)
                .includeFields(fields)
                .performWithCompletion(^(PNManageMembersStatus *status) {
                    XCTAssertFalse(status.isError);
                    XCTAssertNotNil(status.data.members);
                    
                    for (NSUInteger memberIdx = 0; memberIdx < uuids.count; memberIdx++) {
                        for (PNMember *member in status.data.members) {
                            if ([member.uuid isEqualToString:uuids[memberIdx]]) {
                                [createdChannelMembers addObject:member];
                                break;
                            }
                        }
                    }
                    
                    [self.channelMembersObjects[channel] addObjectsFromArray:status.data.members];
                    
                    handler();
                });
        }];
    }
    
    [self waitTask:@"waitForDistribution" completionFor:(YHVVCR.cassette.isNewCassette ? 1.f : 0.f)];
    
    return createdChannelMembers;
}

- (void)verifyChannelMembersCount:(NSString *)channel shouldEqualTo:(NSUInteger)count usingClient:(PubNub *)client {
    client = client ?: self.client;
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        client.objects().members(channel)
            .performWithCompletion(^(PNFetchMembersResult *result, PNErrorStatus *status) {
                NSArray<PNMember *> *members = result.data.members;
                XCTAssertNil(status);
                XCTAssertNotNil(members);
                XCTAssertEqual(members.count, count);
                
                handler();
            });
    }];
}

- (void)removeChannel:(NSString *)channel cachedMemberForUUID:(NSString *)uuid {
    PNMember *member = nil;
    
    for (member in self.channelMembersObjects[channel]) {
        if ([member.uuid isEqualToString:uuid]) {
            break;
        }
    }
    
    [self.channelMembersObjects[channel] removeObject:member];
}

- (void)removeChannels:(NSArray<NSString *> *)channels membersObjectsUsingClient:(nullable PubNub *)client {
    for (NSString *channel in channels) {
        [self removeChannel:channel membersObjectsUsingClient:client];
    }
}

- (void)removeChannel:(NSString *)channel memberObjects:(NSArray<PNMember *> *)members usingClient:(nullable PubNub *)client {
    [self removeChannel:channel members:[members valueForKey:@"uuid"] usingClient:client];
}

- (void)removeChannel:(NSString *)channel membersObjectsUsingClient:(nullable PubNub *)client {
    if (!self.channelMembersObjects[channel].count) {
        return;
    }

    [self removeChannel:channel members:[self.channelMembersObjects[channel] valueForKey:@"uuid"] usingClient:client];
}

- (void)removeChannel:(NSString *)channel members:(NSArray<NSString *> *)uuids usingClient:(nullable PubNub *)client {
    client = client ?: self.client;
    
    if (!uuids.count) {
        return;
    }
    
    [self waitTask:@"waitForDistribution" completionFor:(YHVVCR.cassette.isNewCassette ? 1.f : 0.f)];
    
    [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
        client.objects().removeMembers(channel).uuids(uuids).performWithCompletion(^(PNManageMembersStatus *status) {
            XCTAssertFalse(status.isError);
            
            if (status.isError) {
                NSLog(@"'%@' CHANNEL MEMBERS REMOVE ERROR: %@\n%@",
                      channel, status.errorData.information,
                      [status valueForKey:@"clientRequest"]);
            }
            
            handler();
        });
    }];
}

- (void)removeCachedChannelsMetadata:(NSString *)channels {
    PNChannelMetadata *metadata = nil;
    
    for (metadata in self.channelMetadataObjects) {
        if ([metadata.channel isEqualToString:channels]) {
            break;
        }
    }
    
    [self.channelMetadataObjects removeObject:metadata];
}

- (void)removeChannelsMetadata:(NSArray<NSString *> *)channels usingClient:(nullable PubNub *)client {
    client = client ?: self.client;
    
    if (!channels.count) {
        return;
    }
    
    for (NSString *channel in channels) {
        [self waitToCompleteIn:self.testCompletionDelay codeBlock:^(dispatch_block_t handler) {
            client.objects().removeChannelMetadata(channel).performWithCompletion(^(PNAcknowledgmentStatus *status) {
                XCTAssertFalse(status.isError);
                
                if (status.isError) {
                    NSLog(@"'%@' CHANNEL METADATA REMOVE ERROR: %@\n%@",
                          channel, status.errorData.information,
                          [status valueForKey:@"clientRequest"]);
                }
                
                handler();
            });
        }];
    }
    
    [self waitTask:@"waitForDistribution" completionFor:(YHVVCR.cassette.isNewCassette ? 1.f : 0.f)];
}

- (void)removeChannelsMetadataUsingClient:(nullable PubNub *)client {
    if (!self.channelMetadataObjects.count) {
        return;
    }

    [self removeChannelsMetadata:[self.channelMetadataObjects valueForKey:@"channel"] usingClient:client];
}


#pragma mark - Mocking

- (BOOL)isObjectMocked:(id)object {
    return [self.classMocks containsObject:object] || [self.instanceMocks containsObject:object];
}

- (id)mockForObject:(id)object {
    BOOL isClass = object_isClass(object);
    __unsafe_unretained id mock = isClass ? OCMClassMock(object) : OCMPartialMock(object);
    
    if (isClass) {
        [self.classMocks addObject:mock];
    } else {
        [self.instanceMocks addObject:mock];
    }
    
    return mock;
}


#pragma mark - Listeners

- (void)addHandlerOfType:(NSString *)type forClient:(PubNub *)client withBlock:(PNTClientCallbackHandler)handler {
    NSString *instanceID = client.instanceID;
    
    dispatch_async(self.resourceAccessQueue, ^{
        NSMutableDictionary *handlersByType = self.pubNubHandlers[instanceID];
        
        if (!handlersByType) {
            handlersByType = [NSMutableDictionary new];
            self.pubNubHandlers[instanceID] = handlersByType;
        }
        
        NSMutableArray *handlers = handlersByType[type];
        
        if (!handlers) {
            handlers = [NSMutableArray new];
            handlersByType[type] = handlers;
        }
        
        [handlers addObject:handler];
    });
}

- (void)removeHandlers:(NSArray<PNTClientCallbackHandler> *)handlers ofType:(NSString *)type forClient:(PubNub *)client {
    NSString *instanceID = client.instanceID;
    
    dispatch_async(self.resourceAccessQueue, ^{
        NSMutableDictionary *handlersByType = self.pubNubHandlers[instanceID];
        [handlersByType[type] removeObjectsInArray:handlers];
    });
}

- (NSArray<PNTClientCallbackHandler> *)handlersOfType:(NSString *)type forClient:(PubNub *)client {
    __block NSArray<PNTClientCallbackHandler> *handlers = nil;
    NSString *instanceID = client.instanceID;
    
    dispatch_sync(self.resourceAccessQueue, ^{
        handlers = [self.pubNubHandlers[instanceID][type] copy];
    });
    
    return handlers;
}

- (void)addStatusHandlerForClient:(PubNub *)client withBlock:(PNTClientDidReceiveStatusHandler)handler {
    [self addHandlerOfType:@"status" forClient:client withBlock:handler];
}

- (void)addMessageHandlerForClient:(PubNub *)client withBlock:(PNTClientDidReceiveMessageHandler)handler {
    [self addHandlerOfType:@"message" forClient:client withBlock:handler];
}

- (void)addSignalHandlerForClient:(PubNub *)client withBlock:(PNTClientDidReceiveSignalHandler)handler {
    [self addHandlerOfType:@"signal" forClient:client withBlock:handler];
}

- (void)addPresenceHandlerForClient:(PubNub *)client withBlock:(PNTClientDidReceivePresenceEventHandler)handler {
    [self addHandlerOfType:@"presence" forClient:client withBlock:handler];
}

- (void)addObjectHandlerForClient:(PubNub *)client withBlock:(PNTClientDidReceiveObjectEventHandler)handler {
    [self addHandlerOfType:@"object" forClient:client withBlock:handler];
}

- (void)addActionHandlerForClient:(PubNub *)client withBlock:(PNTClientDidReceiveMessageActionHandler)handler {
    [self addHandlerOfType:@"actions" forClient:client withBlock:handler];
}

- (void)removeAllHandlersForClient:(PubNub *)client {
    NSString *instanceID = client.instanceID;
    
    dispatch_sync(self.resourceAccessQueue, ^{
        [self.pubNubHandlers removeObjectForKey:instanceID];
    });
}


#pragma mark - Handlers

- (void)handleClient:(PubNub *)client eventWithData:(id)data type:(NSString *)eventType {
    NSMutableArray<PNTClientCallbackHandler> *handlersForRemoval = [NSMutableArray new];
    NSArray<PNTClientCallbackHandler> *handlers = [self handlersOfType:eventType forClient:client];
    
    for (PNTClientCallbackHandler handler in handlers) {
        BOOL shouldRemoved = NO;
        
        handler(client, data, &shouldRemoved);
        
        if (shouldRemoved) {
            [handlersForRemoval addObject:handler];
        }
    }
    
    [self removeHandlers:handlersForRemoval ofType:eventType forClient:client];
}

- (void)client:(PubNub *)client didReceiveStatus:(PNStatus *)status {
    [self handleClient:client eventWithData:status type:@"status"];
}

- (void)client:(PubNub *)client didReceivePresenceEvent:(PNPresenceEventResult *)event {
    [self handleClient:client eventWithData:event type:@"presence"];
}

- (void)client:(PubNub *)client didReceiveMessage:(PNMessageResult *)message {
    [self handleClient:client eventWithData:message type:@"message"];
}

- (void)client:(PubNub *)client didReceiveSignal:(PNSignalResult *)signal {
    [self handleClient:client eventWithData:signal type:@"signal"];
}

- (void)client:(PubNub *)client didReceiveMessageAction:(PNMessageActionResult *)action {
    [self handleClient:client eventWithData:action type:@"actions"];
}

- (void)client:(PubNub *)client didReceiveObjectEvent:(PNObjectEventResult *)event {
    [self handleClient:client eventWithData:event type:@"object"];
}

- (void)waitForObject:(id)object
    recordedInvocation:(id)invocation
                  call:(BOOL)shouldCall
        withinInterval:(NSTimeInterval)interval
            afterBlock:(void(^)(void))initialBlock {
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    __block BOOL handlerCalled = NO;
    
    ((OCMStubRecorder *)invocation).andDo(^(NSInvocation *expectedInvocation) {
        handlerCalled = YES;
        dispatch_semaphore_signal(semaphore);
    });
    
    if (initialBlock) {
        initialBlock();
    }
    
    dispatch_time_t timeout = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(interval * NSEC_PER_SEC));
    dispatch_semaphore_wait(semaphore, timeout);

    if (shouldCall) {
        XCTAssertTrue(handlerCalled);
    } else {
        XCTAssertFalse(handlerCalled);
    }

    OCMVerifyAll(object);
}

- (void)waitForObject:(id)object
    recordedInvocationCall:(id)invocation
                afterBlock:(void(^)(void))initialBlock {

    [self waitForObject:object
     recordedInvocationCall:invocation
             withinInterval:self.testCompletionDelay
                 afterBlock:initialBlock];
}

- (void)waitForObject:(id)object
    recordedInvocationCall:(id)invocation
            withinInterval:(NSTimeInterval)interval
                afterBlock:(void(^)(void))initialBlock {
    
    [self waitForObject:object
     recordedInvocation:invocation
                   call:YES
         withinInterval:interval
             afterBlock:initialBlock];
}

- (void)waitToCompleteIn:(NSTimeInterval)delay
               codeBlock:(void(^)(dispatch_block_t handler))codeBlock {
    
    [self waitToCompleteIn:delay codeBlock:codeBlock afterBlock:nil];
}

- (void)waitToCompleteIn:(NSTimeInterval)delay
               codeBlock:(void(^)(dispatch_block_t handler))codeBlock
              afterBlock:(void(^)(void))initialBlock {
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    __block BOOL handlerCalled = NO;
    
    codeBlock(^{
        if (!handlerCalled) {
            handlerCalled = YES;
            dispatch_semaphore_signal(semaphore);
        }
    });
    
    if (initialBlock) {
        initialBlock();
    }
    
    
    dispatch_time_t timeout = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC));
    dispatch_semaphore_wait(semaphore, timeout);
    
    XCTAssertTrue(handlerCalled);
}

- (void)waitForObject:(id)object
    recordedInvocationNotCall:(id)invocation
                   afterBlock:(void(^)(void))initialBlock {

    [self waitForObject:object
     recordedInvocationNotCall:invocation
                withinInterval:self.falseTestCompletionDelay
                    afterBlock:initialBlock];
}

- (void)waitForObject:(id)object
    recordedInvocationNotCall:(id)invocation
               withinInterval:(NSTimeInterval)interval
                   afterBlock:(nullable void(^)(void))initialBlock {
    
    [self waitForObject:object recordedInvocation:invocation call:NO withinInterval:interval
             afterBlock:initialBlock];
}

- (void)waitToNotCompleteIn:(NSTimeInterval)delay
                  codeBlock:(void(^)(dispatch_block_t handler))codeBlock {
    
    [self waitToNotCompleteIn:delay codeBlock:codeBlock afterBlock:nil];
}

- (void)waitToNotCompleteIn:(NSTimeInterval)delay
                  codeBlock:(void(^)(dispatch_block_t handler))codeBlock
                 afterBlock:(void(^)(void))initialBlock {
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    __block BOOL handlerCalled = NO;
    
    codeBlock(^{
        handlerCalled = YES;
        dispatch_semaphore_signal(semaphore);
    });
    
    if (initialBlock) {
        initialBlock();
    }
    
    dispatch_time_t timeout = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC));
    dispatch_semaphore_wait(semaphore, timeout);
    
    XCTAssertFalse(handlerCalled);
}

- (XCTestExpectation *)waitTask:(NSString *)taskName completionFor:(NSTimeInterval)seconds {
    if (seconds <= 0.f) {
        return nil;
    }
    
    XCTestExpectation *waitExpectation = [self expectationWithDescription:taskName];
    dispatch_time_t date = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(seconds * NSEC_PER_SEC));
    
    dispatch_after(date, dispatch_get_main_queue(), ^{
        [waitExpectation fulfill];
    });

    [self waitForExpectations:@[waitExpectation] timeout:(seconds + 0.3f)];
    
    return waitExpectation;
}


#pragma mark - Helpers

- (BOOL)shouldSkipTestWithManuallyModifiedMockedResponse {
    static BOOL _isMockedIntegration;
    static dispatch_once_t onceToken;
    BOOL shouldSkip = NO;
    
    dispatch_once(&onceToken, ^{
        NSString *bundleIdentifier = [NSBundle bundleForClass:[self class]].bundleIdentifier;
        _isMockedIntegration = [bundleIdentifier pnt_includesString:@"mocked-integration"];
    });
    
    if (_isMockedIntegration) {
        if (YHVVCR.cassette.isNewCassette) {
            NSString *logSeparator1 = @"\n------------\n\n\n";
            NSString *logSeparator2 = @"\n\n\n------------";
            NSLog(@"%@%@ REQUIRE CASSETTE MODIFICATION. CHECK TEST DOCUMENTATION%@",
                  logSeparator1, self.name, logSeparator2);
        }
    } else {
        shouldSkip = YES;
    }
    
    return shouldSkip;
}

- (NSArray<NSString *> *)randomizedValuesWithValues:(NSArray<NSString *> *)values {
    NSMutableArray *randomizedValues = [NSMutableArray new];
    
    for (NSString *value in values) {
        if (!self.randomizedUserProvidedValues[value]) {
            [self storeRandomizedValueFrom:value inDictionary:self.randomizedUserProvidedValues];
        }

        [randomizedValues addObject:self.randomizedUserProvidedValues[value]];
    }
    
    return randomizedValues;
}

- (NSArray<NSString *> *)channelGroupsWithNames:(NSArray<NSString *> *)channelGroups {
    NSMutableArray *randomizedChannelGroups = [NSMutableArray new];
    
    for (NSString *channelGroup in channelGroups) {
        [randomizedChannelGroups addObject:[self channelGroupWithName:channelGroup]];
    }
    
    return randomizedChannelGroups;
}

- (NSString *)channelGroupWithName:(NSString *)channelGroup {
    if (self.randomizedChannelGroups[channelGroup]) {
        return self.randomizedChannelGroups[channelGroup];
    }

    [self storeRandomizedValueFrom:channelGroup inDictionary:self.randomizedChannelGroups];
    
    return self.randomizedChannelGroups[channelGroup];
}

- (NSArray<NSString *> *)channelsWithNames:(NSArray<NSString *> *)channels {
    NSMutableArray *randomizedChannels = [NSMutableArray new];
    
    for (NSString *channel in channels) {
        [randomizedChannels addObject:[self channelWithName:channel]];
    }
    
    return randomizedChannels;
}

- (NSString *)channelWithName:(NSString *)channel {
    if (self.randomizedChannels[channel]) {
        return self.randomizedChannels[channel];
    }

    [self storeRandomizedValueFrom:channel inDictionary:self.randomizedChannels];
    
    return self.randomizedChannels[channel];
}

- (NSString *)uuidForUser:(NSString *)user {
    if (self.randomizedUUIDs[user]) {
        return self.randomizedUUIDs[user];
    }

    [self storeRandomizedValueFrom:user inDictionary:self.randomizedUUIDs];
    
    return self.randomizedUUIDs[user];
}

- (NSString *)authForUser:(NSString *)auth {
    if (self.randomizedAuths[auth]) {
        return self.randomizedAuths[auth];
    }
    
    [self storeRandomizedValueFrom:auth inDictionary:self.randomizedAuths];
    
    return self.randomizedAuths[auth];
}

- (id)objectForInvocation:(NSInvocation *)invocation argumentAtIndex:(NSUInteger)index {
    __strong id object = [invocation objectForArgumentAtIndex:(index + 1)];
    
    [[PNRecordableTestCase invocationObjects] addObject:object];
    
    return object;
}


#pragma mark - Misc

- (NSString *)randomizedValueFrom:(NSString *)string {
    NSString *uuid = [NSUUID UUID].UUIDString;
    NSArray<NSString *> *components = @[
        [uuid substringToIndex:8],
        string,
        [uuid substringWithRange:NSMakeRange(19, 4)]
    ];
    
    return [components componentsJoinedByString:@"-"];
}

- (void)storeRandomizedValueFrom:(NSString *)string inDictionary:(NSMutableDictionary *)dictionary {
    NSString *randomizedString = [self randomizedValueFrom:string];

    if (YHVVCR.cassette) {
        dictionary[string] = YHVVCR.cassette.isNewCassette ? randomizedString : string;
    } else {
        dictionary[string] = randomizedString;
    }
}

- (void)loadTestsConfiguration {
    static NSDictionary *_sharedTestsConfiguration;
    __block NSException *exception = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        NSBundle *testBundle = [NSBundle bundleForClass:[self class]];
        NSString *configurationPath = [testBundle pathForResource:@"tests-configuration"
                                                           ofType:@"json"];
        NSData *configurationData = [NSData dataWithContentsOfFile:configurationPath];
        NSError *error;
        
        if (!configurationData) {
            NSString *errorReason = @"'test-configuration.json' file not found in bundle.";
            
            exception = [NSException exceptionWithName:@"PNTestsConfiguration"
                                                reason:errorReason
                                              userInfo:nil];
        } else {
            NSJSONReadingOptions options = NSJSONReadingFragmentsAllowed;
            _sharedTestsConfiguration = [NSJSONSerialization JSONObjectWithData:configurationData
                                                                        options:options
                                                                          error:&error];
        }
        
        
        if (!_sharedTestsConfiguration || error) {
            NSString *errorReason = @"'test-configuration.json' file parsing error.";
            NSDictionary *userInfo = error ? @{ NSUnderlyingErrorKey: error } : nil;
            
            exception = [NSException exceptionWithName:@"PNTestsConfiguration"
                                                reason:errorReason
                                              userInfo:userInfo];
        }
    });
    
    self.pamSubscribeKey = [_sharedTestsConfiguration valueForKeyPath:@"keys.subscribe-pam"];
    self.pamPublishKey = [_sharedTestsConfiguration valueForKeyPath:@"keys.publish-pam"];
    self.subscribeKey = [_sharedTestsConfiguration valueForKeyPath:@"keys.subscribe"];
    self.publishKey = [_sharedTestsConfiguration valueForKeyPath:@"keys.publish"];
    
    if (self.subscribeKey.length == 0 || self.publishKey.length == 0) {
        NSString *errorReason = @"'keys.subscribe' or 'keys.publish' keys is missing";
        
        exception = [NSException exceptionWithName:@"PNTestsConfiguration"
                                            reason:errorReason
                                          userInfo:nil];
    }
    
    if (self.pamSubscribeKey.length == 0 || self.pamPublishKey.length == 0) {
        NSString *errorReason = @"'keys.subscribe-pam' or 'keys.publish-pam' keys is missing";
        
        exception = [NSException exceptionWithName:@"PNTestsConfiguration"
                                            reason:errorReason
                                          userInfo:nil];
    }
    
    if (exception) {
        @throw exception;
    }
}

#pragma mark -


@end
