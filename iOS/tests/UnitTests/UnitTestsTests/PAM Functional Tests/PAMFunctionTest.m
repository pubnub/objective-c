//
//  PAMFunctionTest.m
//  UnitTests
//
//  Created by Sergey Kazanskiy on 4/2/15.
//  Copyright (c) 2015 PubNub Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

static const NSUInteger kOnPeriod = 10;

@interface PAMFunctionTest : XCTestCase  <PNDelegate>

@end

@implementation PAMFunctionTest {
    
    GCDGroup *_resGroup;
    PubNub *_testClient;
    PNChannel *_testChannel;
    PNChannelGroup *_testGroup;
    NSString *_testSpace;
    PNChannelGroupNamespace *_testNameSpace;
    NSString *_testMessage;
    NSException *_stopTestException;
}

- (void)setUp {
    
    [super setUp];
    [PubNub disconnect];
    
    _testChannel = [PNChannel channelWithName:@"testChannel"];
    _testGroup = [PNChannelGroup channelGroupWithName:@"testGroup" inNamespace:@"testNameSpace"];
    _testNameSpace = [PNChannelGroupNamespace namespaceWithName:@"testNameSpace"];
    _testSpace = @"testNameSpace";
    _testMessage = @"Hello World";
    
    _stopTestException = [NSException exceptionWithName:@"StopTestException"
                                                 reason:nil
                                               userInfo:nil];
}

- (void)tearDown {
    
    _testClient = nil;
    _testChannel = nil;
    _testGroup = nil;
    _testMessage = nil;
    _stopTestException = nil;
    _resGroup = nil;
    
    [PubNub disconnect];
    
    [super tearDown];
}

#pragma mark - Tests

- (void)testApplicationAccessRights {
    
    _testClient = [PubNub clientWithConfiguration:[PNConfiguration accessManagerTestConfiguration] andDelegate:self];
    [self connectClient];
    
    NSArray *channels = @[_testChannel];
    
    // AllAccessRights
    [self changeApplicationAccessRightsTo:PNAllAccessRights onPeriod:kOnPeriod];
    XCTAssertTrue([self auditAccessRightsForApplication].rights == PNAllAccessRights);
    
    XCTAssertTrue(([self subscribeOn:channels]));
    XCTAssertTrue(([self unsubscribeFrom:channels]));
    XCTAssertTrue(([self sendMessage:_testMessage toChannel:_testChannel]));
    XCTAssertTrue(([self getHistoryForChannel:_testChannel]));
    XCTAssertTrue(([self getParticipantsListFor:channels]));
    
    // ReadAccessRights
    [self changeApplicationAccessRightsTo:PNReadAccessRight onPeriod:kOnPeriod];
    XCTAssertTrue([self auditAccessRightsForApplication].rights == PNReadAccessRight);
    
    XCTAssertTrue(([self subscribeOn:channels]));
    XCTAssertTrue(([self unsubscribeFrom:channels]));
    XCTAssertFalse(([self sendMessage:_testMessage toChannel:_testChannel]));
    XCTAssertTrue(([self getHistoryForChannel:_testChannel]));
    XCTAssertTrue(([self getParticipantsListFor:channels]));
    
    // WriteAccessRights
    [self changeApplicationAccessRightsTo:PNWriteAccessRight onPeriod:kOnPeriod];
    XCTAssertTrue([self auditAccessRightsForApplication].rights == PNWriteAccessRight);
    
    XCTAssertFalse(([self subscribeOn:channels])); // ???
    XCTAssertTrue(([self unsubscribeFrom:channels]));
    XCTAssertTrue(([self sendMessage:_testMessage toChannel:_testChannel]));
    XCTAssertFalse(([self getHistoryForChannel:_testChannel]));
    XCTAssertTrue(([self getParticipantsListFor:channels]));
    
    // NoAccessRights
    [self changeApplicationAccessRightsTo:PNNoAccessRights onPeriod:kOnPeriod];
    XCTAssertTrue([self auditAccessRightsForApplication].rights == PNNoAccessRights);
    
    XCTAssertFalse(([self subscribeOn:channels]));
    XCTAssertTrue(([self unsubscribeFrom:channels]));
    XCTAssertFalse(([self sendMessage:_testMessage toChannel:_testChannel]));
    XCTAssertFalse(([self getHistoryForChannel:_testChannel]));
    XCTAssertFalse(([self getParticipantsListFor:channels]));

    [_testClient disconnect];
}

- (void)testChannelAccessRights {
    
    _testClient = [PubNub clientWithConfiguration:[PNConfiguration accessManagerTestConfiguration] andDelegate:self];
    [self connectClient];
    
    NSArray *channels = @[_testChannel];
    
     // AllAccessRights
    [self changeApplicationAccessRightsTo:PNAllAccessRights onPeriod:kOnPeriod];
    [self changeAccessRightsFor:channels accessRights:PNAllAccessRights onPeriod:kOnPeriod];
    XCTAssertTrue([self auditAccessRightsFor:channels].rights == PNAllAccessRights);
    
    XCTAssertTrue(([self subscribeOn:channels]));
    XCTAssertTrue(([self unsubscribeFrom:channels]));
    XCTAssertTrue(([self sendMessage:_testMessage toChannel:_testChannel]));
    XCTAssertTrue(([self getHistoryForChannel:_testChannel]));
    XCTAssertTrue(([self getParticipantsListFor:channels]));
    
    // ReadAccessRights
    [self changeApplicationAccessRightsTo:PNReadAccessRight onPeriod:kOnPeriod];
    [self changeAccessRightsFor:channels accessRights:PNReadAccessRight onPeriod:kOnPeriod];
    XCTAssertTrue([self auditAccessRightsFor:channels].rights == PNReadAccessRight);
    
    XCTAssertTrue(([self subscribeOn:channels]));
    XCTAssertTrue(([self unsubscribeFrom:channels]));
    XCTAssertFalse(([self sendMessage:_testMessage toChannel:_testChannel]));
    XCTAssertTrue(([self getHistoryForChannel:_testChannel]));
    XCTAssertTrue(([self getParticipantsListFor:channels]));
    
    // WriteAccessRights
    [self changeApplicationAccessRightsTo:PNWriteAccessRight onPeriod:kOnPeriod];
    [self changeAccessRightsFor:channels accessRights:PNWriteAccessRight onPeriod:kOnPeriod];
    XCTAssertTrue([self auditAccessRightsFor:channels].rights == PNWriteAccessRight);
    
    XCTAssertTrue(([self subscribeOn:channels]));
    XCTAssertTrue(([self unsubscribeFrom:channels]));
    XCTAssertTrue(([self sendMessage:_testMessage toChannel:_testChannel]));
    XCTAssertFalse(([self getHistoryForChannel:_testChannel]));
    XCTAssertTrue(([self getParticipantsListFor:channels]));
    
    // NoAccessRights
    [self changeApplicationAccessRightsTo:PNNoAccessRights onPeriod:kOnPeriod];
    [self changeAccessRightsFor:channels accessRights:PNNoAccessRights onPeriod:kOnPeriod];
    XCTAssertTrue([self auditAccessRightsFor:channels].rights == PNNoAccessRights);
    
    XCTAssertFalse(([self subscribeOn:channels]));
    XCTAssertTrue(([self unsubscribeFrom:channels]));
    XCTAssertFalse(([self sendMessage:_testMessage toChannel:_testChannel]));
    XCTAssertFalse(([self getHistoryForChannel:_testChannel]));
    XCTAssertFalse(([self getParticipantsListFor:channels]));
    
    [_testClient disconnect];
}

- (void)testGroupAccessRights {
    
    NSArray *channels = @[_testChannel];
    
    _testClient = [PubNub clientWithConfiguration:[PNConfiguration accessManagerTestConfiguration] andDelegate:self];
    [self connectClient];
    
    // AllAccessRights
    [self changeAccessRightsFor:@[_testNameSpace] accessRights:(PNReadAccessRight | PNManagementRight) onPeriod:kOnPeriod];
    [self changeAccessRightsFor:@[_testGroup] accessRights:(PNReadAccessRight | PNManagementRight) onPeriod:kOnPeriod];
     XCTAssertTrue([self auditAccessRightsFor:@[_testGroup]].rights == (PNReadAccessRight | PNManagementRight));
    
    if (![self addChannel:channels toGroup:_testGroup]) {
        
        XCTFail(@"Fail");
    } else {
    
        XCTAssertTrue(([self subscribeOn:@[_testGroup]]));
        XCTAssertTrue(([self unsubscribeFrom:@[_testGroup]]));

        XCTAssertTrue(([self requestChannelsForGroup:_testGroup]));
        XCTAssertTrue(([self requestGroupsForNamespace:_testSpace]));
        
        XCTAssertTrue(([self getParticipantsListFor:@[_testGroup]]));
        
        XCTAssertTrue(([self removeChannels:channels fromGroup:_testGroup]));
        XCTAssertTrue(([self removeGroup:_testGroup]));
    }
    
    // ReadAccessRights
    [self changeAccessRightsFor:@[_testNameSpace] accessRights:PNReadAccessRight onPeriod:kOnPeriod];
    [self changeAccessRightsFor:@[_testGroup] accessRights:PNReadAccessRight onPeriod:kOnPeriod];
     XCTAssertTrue([self auditAccessRightsFor:@[_testGroup]].rights == PNReadAccessRight);
    
    if (![self addChannel:channels toGroup:_testGroup]) {
        
        XCTFail(@"Fail");
    } else {

        XCTAssertFalse(([self subscribeOn:@[_testGroup]]));
        XCTAssertTrue(([self unsubscribeFrom:@[_testGroup]]));
        
        XCTAssertTrue(([self requestChannelsForGroup:_testGroup]));
        XCTAssertTrue(([self requestGroupsForNamespace:_testSpace]));
        
        XCTAssertTrue(([self getParticipantsListFor:@[_testGroup]]));
        
        XCTAssertFalse(([self removeChannels:channels fromGroup:_testGroup]));
        XCTAssertFalse(([self removeGroup:_testGroup]));
    }
    
    // ManagementAccessRights
    [self changeAccessRightsFor:@[_testNameSpace] accessRights:PNManagementRight onPeriod:kOnPeriod];
    [self changeAccessRightsFor:@[_testGroup] accessRights:PNManagementRight onPeriod:kOnPeriod];
    XCTAssertTrue([self auditAccessRightsFor:@[_testGroup]].rights == PNManagementRight);
    
    if (![self addChannel:channels toGroup:_testGroup]) {
        
        XCTFail(@"Fail");
    } else {

        XCTAssertFalse(([self subscribeOn:@[_testGroup]]));
        XCTAssertTrue(([self unsubscribeFrom:@[_testGroup]]));
        
        XCTAssertFalse(([self requestChannelsForGroup:_testGroup]));
        XCTAssertFalse(([self requestGroupsForNamespace:_testSpace]));
        
        XCTAssertFalse(([self getParticipantsListFor:@[_testGroup]]));
        
        XCTAssertTrue(([self removeChannels:channels fromGroup:_testGroup]));
        XCTAssertTrue(([self removeGroup:_testGroup]));
    }
    
    // NoAccessRights
    [self changeAccessRightsFor:@[_testNameSpace] accessRights:PNNoAccessRights onPeriod:1];
    [self changeAccessRightsFor:@[_testGroup] accessRights:PNNoAccessRights onPeriod:1];
    XCTAssertTrue([self auditAccessRightsFor:@[_testGroup]].rights == PNNoAccessRights);
    
    if ([self addChannel:channels toGroup:_testGroup]) {
        XCTFail(@"Fail");
    
        XCTAssertFalse(([self subscribeOn:@[_testGroup]]));
        XCTAssertTrue(([self unsubscribeFrom:@[_testGroup]]));

        XCTAssertFalse(([self requestChannelsForGroup:_testGroup]));
        XCTAssertFalse(([self requestGroupsForNamespace:_testSpace]));
        
        XCTAssertFalse(([self getParticipantsListFor:@[_testGroup]]));
        
        XCTAssertFalse(([self removeChannels:channels fromGroup:_testGroup]));
        XCTAssertFalse(([self removeGroup:_testGroup]));
    }
    
    [_testClient disconnect];
}

- (void)testNamespacesAccessRights {
    
    NSArray *channels = @[_testChannel];
    
    _testClient = [PubNub clientWithConfiguration:[PNConfiguration accessManagerTestConfiguration] andDelegate:self];
    [self connectClient];
    
    // AllAccessRights
    [self changeAccessRightsFor:@[_testNameSpace] accessRights:(PNReadAccessRight | PNManagementRight) onPeriod:kOnPeriod];
    XCTAssertTrue([self auditAccessRightsFor:@[_testNameSpace]].rights == (PNReadAccessRight | PNManagementRight));
    
    if (![self addChannel:channels toGroup:_testGroup]) {
        
        XCTFail(@"Fail");
    } else {
        
        XCTAssertTrue(([self subscribeOn:@[_testGroup]]));
        XCTAssertTrue(([self unsubscribeFrom:@[_testGroup]]));
        
        XCTAssertTrue(([self requestChannelsForGroup:_testGroup]));
        XCTAssertTrue(([self requestGroupsForNamespace:_testSpace]));
        XCTAssertFalse(([self requestNamespaces]));
        
        XCTAssertTrue(([self getParticipantsListFor:@[_testGroup]]));
        
        XCTAssertTrue(([self removeChannels:channels fromGroup:_testGroup]));
        XCTAssertTrue(([self removeGroup:_testGroup]));
    }
    
    // ReadAccessRights
    [self changeAccessRightsFor:@[_testNameSpace] accessRights:PNReadAccessRight onPeriod:kOnPeriod];
    XCTAssertTrue([self auditAccessRightsFor:@[_testNameSpace]].rights == PNReadAccessRight);
    
    if (![self addChannel:channels toGroup:_testGroup]) {
        
        XCTFail(@"Fail");
    } else {
    
        XCTAssertFalse(([self subscribeOn:@[_testGroup]]));
        XCTAssertTrue(([self unsubscribeFrom:@[_testGroup]]));
        
        XCTAssertTrue(([self requestChannelsForGroup:_testGroup]));
        XCTAssertTrue(([self requestGroupsForNamespace:_testSpace]));
        XCTAssertFalse(([self requestNamespaces]));
            
        XCTAssertTrue(([self getParticipantsListFor:@[_testGroup]]));
        
        XCTAssertFalse(([self removeChannels:channels fromGroup:_testGroup]));
        XCTAssertFalse(([self removeGroup:_testGroup]));
    }
    
    // ManagementAccessRights
    [self changeAccessRightsFor:@[_testNameSpace] accessRights:PNManagementRight onPeriod:kOnPeriod];
    XCTAssertTrue([self auditAccessRightsFor:@[_testNameSpace]].rights == PNManagementRight);
    
    if (![self addChannel:channels toGroup:_testGroup]) {
        
        XCTFail(@"Fail");
    } else {

        XCTAssertFalse(([self subscribeOn:@[_testGroup]]));
        XCTAssertTrue(([self unsubscribeFrom:@[_testGroup]]));
        
        XCTAssertFalse(([self requestChannelsForGroup:_testGroup]));
        XCTAssertFalse(([self requestGroupsForNamespace:_testSpace]));
        XCTAssertFalse(([self requestNamespaces]));
        
        XCTAssertFalse(([self getParticipantsListFor:@[_testGroup]]));
        
        XCTAssertTrue(([self removeChannels:channels fromGroup:_testGroup]));
        XCTAssertTrue(([self removeGroup:_testGroup]));
    }
    
    // NoAccessRights
    [self changeAccessRightsFor:@[_testNameSpace] accessRights:PNNoAccessRights onPeriod:kOnPeriod];
    XCTAssertTrue([self auditAccessRightsFor:@[_testNameSpace]].rights == PNNoAccessRights);
    
    if ([self addChannel:channels toGroup:_testGroup]) {
        XCTFail(@"Fail");
    
        XCTAssertFalse(([self subscribeOn:@[_testGroup]]));
        XCTAssertTrue(([self unsubscribeFrom:@[_testGroup]]));
        
        XCTAssertFalse(([self requestChannelsForGroup:_testGroup]));
        XCTAssertFalse(([self requestGroupsForNamespace:_testSpace]));
        XCTAssertFalse(([self requestNamespaces]));
        
        XCTAssertFalse(([self getParticipantsListFor:@[_testGroup]]));
        
        XCTAssertFalse(([self removeChannels:channels fromGroup:_testGroup]));
        XCTAssertFalse(([self removeGroup:_testGroup]));
    }
    [_testClient disconnect];
}


#pragma mark - Private methods

- (void)connectClient {
    
    _resGroup = [GCDGroup group];
    [_resGroup enter];
    
    [_testClient connectWithSuccessBlock:^(NSString *origin) {
        
        [_resGroup leave];
    } errorBlock:^(PNError *error) {
        
        XCTFail(@"Error occurs during connection, %@", error);
        [_resGroup leave];
    }];
     
    if ([GCDWrapper isGCDGroup:_resGroup timeoutFiredValue:kTestTestTimout]) {
        
        XCTFail(@"Timeout is fired. Didn't connect client to PubNub");
    }
    _resGroup = nil;
}

- (void)changeApplicationAccessRightsTo:(PNAccessRights)accessRights onPeriod:(NSInteger)accessPeriodDuration {
    
    _resGroup = [GCDGroup group];
    [_resGroup enter];
    
    [_testClient changeApplicationAccessRightsTo:accessRights onPeriod:accessPeriodDuration andCompletionHandlingBlock:^(PNAccessRightsCollection *accessRightsCollection, PNError *error) {
        
        if (!error) {
            
            [_resGroup leave];
        }
    }];
    
    if ([GCDWrapper isGCDGroup:_resGroup timeoutFiredValue:kTestTestTimout]) {
        
        XCTFail(@"Timeout fired during changeApplicationAccessRights");
    }
    _resGroup = nil;
    [GCDWrapper sleepForSeconds:5];
}

- (void)changeAccessRightsFor:(NSArray *)channelObjects
                             accessRights:(PNAccessRights)accessRights
                                 onPeriod:(NSInteger)accessPeriodDuration {
     
     _resGroup = [GCDGroup group];
     [_resGroup enter];
     
     [_testClient changeAccessRightsFor:channelObjects to:accessRights onPeriod:accessPeriodDuration withCompletionHandlingBlock:^(PNAccessRightsCollection *accessRightsCollection, PNError *error) {
         
         if (!error) {
             
             [_resGroup leave];
         }
     }];
     
     if ([GCDWrapper isGCDGroup:_resGroup timeoutFiredValue:kTestTestTimout]) {
         
         XCTFail(@"Timeout fired during changeApplicationAccessRights");
     }
     _resGroup = nil;
     [GCDWrapper sleepForSeconds:5];
}

- (PNAccessRightsInformation *)auditAccessRightsForApplication {
    
    _resGroup = [GCDGroup group];
    [_resGroup enter];
    
     __block PNAccessRightsCollection *_accessRightsCollection = nil;
    
    [_testClient auditAccessRightsForApplicationWithCompletionHandlingBlock:^(PNAccessRightsCollection *accessRightsCollection, PNError *error) {
        
        if (error) {
            
            XCTFail(@"Did fail to change access rights: %@", error);
        } else {
            
            _accessRightsCollection = accessRightsCollection;
        }
        
        [_resGroup leave];
    }];
    
    if ([GCDWrapper isGCDGroup:_resGroup timeoutFiredValue:kTestTestTimout]) {
        
        XCTFail(@"Timeout fired during changeApplicationAccessRights");
    }
    _resGroup = nil;
    
    PNAccessRightsInformation *accessRightsInformation = [_accessRightsCollection accessRightsInformationForApplication];
    return accessRightsInformation;
}

- (PNAccessRightsInformation *)auditAccessRightsFor:(NSArray *)channelObjects {
    
    _resGroup = [GCDGroup group];
    [_resGroup enter];
    
    __block PNAccessRightsCollection *_accessRightsCollection = nil;
    
    [_testClient auditAccessRightsFor:channelObjects withCompletionHandlingBlock:^(PNAccessRightsCollection *accessRightsCollection, PNError *error) {
        
        if (error) {
            
            XCTFail(@"Did fail to change access rights: %@", error);
        } else {
            
            _accessRightsCollection = accessRightsCollection;
        }
        
        [_resGroup leave];
    }];
    
    if ([GCDWrapper isGCDGroup:_resGroup timeoutFiredValue:kTestTestTimout]) {
        
        XCTFail(@"Timeout fired during changeApplicationAccessRights");
    }
    _resGroup = nil;
    
    PNAccessRightsInformation *accessRightsInformation = [_accessRightsCollection accessRightsInformationFor:channelObjects[0]];
    return accessRightsInformation;
}

- (BOOL)sendMessage:(NSString *)message toChannel:(PNChannel *)channel {
    
    GCDGroup *resGroup = [GCDGroup group];
    [resGroup enter];
    
    __block BOOL result = NO;
    
    [_testClient sendMessage:message toChannel:channel withCompletionBlock:^(PNMessageState state, id data) {
        
        if (state == PNMessageSent) {
            
            result = YES;
            [resGroup leave];
        }
        if (state == PNMessageSendingError) {

            [resGroup leave];
        }
    }];
    
    if ([GCDWrapper isGCDGroup:resGroup timeoutFiredValue:kTestTestTimout]) {
        
        XCTFail(@"Timeout is fired. Didn't subscribe on channels");
    }
    resGroup = nil;
    return result;
}

- (BOOL)getHistoryForChannel:(PNChannel *)channel {
    
    _resGroup = [GCDGroup group];
    [_resGroup enter];
    
    __block BOOL result = NO;
    
    [_testClient requestFullHistoryForChannel:channel withCompletionBlock:^(NSArray *messages, PNChannel *channel, PNDate *startDate, PNDate *endDate, PNError *error) {
        
        if (error) {
            
            XCTFail(@"Error request history");
        } else {
            
            result = YES;
        }
        
        [_resGroup leave];
    }];
    
    if ([GCDWrapper isGCDGroup:_resGroup timeoutFiredValue:10]) {
        
        XCTFail(@"Timeout is fired. Didn't receive size of message");
    }
    _resGroup = nil;
    return result;
}


- (BOOL)subscribeOn:(NSArray *)channelObjects {
    
    _resGroup = [GCDGroup group];
    [_resGroup enter];

    __block BOOL result = NO;
    
    [_testClient subscribeOn:channelObjects withClientState:nil andCompletionHandlingBlock:^(PNSubscriptionProcessState state, NSArray *channels, PNError *error) {
        
        if (!error | (state == PNSubscriptionProcessSubscribedState)) {
            
            result = YES;
        }
        [_resGroup leave];
    }];
    
    if ([GCDWrapper isGCDGroup:_resGroup timeoutFiredValue:kTestTestTimout - 10]) {
        
        XCTFail(@"Timeout is fired. Didn't subscribe on channels");
    }
    _resGroup = nil;
    return result;
}

- (BOOL)unsubscribeFrom:(NSArray *)channelObjects {
    
    _resGroup = [GCDGroup group];
    [_resGroup enter];
    
    __block BOOL result = NO;
    
    [_testClient unsubscribeFrom:channelObjects withCompletionHandlingBlock:^(NSArray *channels, PNError *error) {
    
        if (!error) {
 
            result = YES;
        }
        [_resGroup leave];
    }];
    
    if ([GCDWrapper isGCDGroup:_resGroup timeoutFiredValue:kTestTestTimout - 10]) {
        
        XCTFail(@"Timeout is fired. Didn't unsubscribe on channels");
    }
    _resGroup = nil;
    return result;
}


- (BOOL)getParticipantsListFor:(NSArray *)channelObjects {
    
    _resGroup = [GCDGroup group];
    [_resGroup enter];
    
    __block BOOL result = NO;
    
    [_testClient requestParticipantsListFor:channelObjects withCompletionBlock:^(PNHereNow *presenceInformation, NSArray *channels, PNError *error) {
 
        if (!error) {
            
            result = YES;
        }
        [_resGroup leave];
    }];
    
    if ([GCDWrapper isGCDGroup:_resGroup timeoutFiredValue:20]) {
        
        XCTFail(@"Timeout is fired. Didn't subscribe on channels");
    }
    _resGroup = nil;
    return result;
}

- (BOOL)disablePresenceObservationFor:(NSArray *)channelObjects {
    
    _resGroup = [GCDGroup group];
    [_resGroup enter];
    
    __block BOOL result = NO;
    
    [_testClient disablePresenceObservationFor:channelObjects withCompletionHandlingBlock:^(NSArray *channels, PNError *error) {
        
        if (error) {
            
            result = YES;
        }
        [_resGroup leave];
    }];
    
    if ([GCDWrapper isGCDGroup:_resGroup timeoutFiredValue:20]) {
        
        XCTFail(@"Timeout is fired. Didn't subscribe on channels");
    }
    _resGroup = nil;
    return result;
}

- (BOOL)addChannel:(NSArray *)channelObjects toGroup:(PNChannelGroup *)group {
    
    _resGroup = [GCDGroup group];
    [_resGroup enter];
    
    __block BOOL result = NO;
    __typeof(self) __weak weakSelf = self;
    [_testClient addChannels:channelObjects toGroup:group
                    withCompletionHandlingBlock:^(PNChannelGroup *channelGroup, NSArray *channels, PNError *error) {
    
        if (!error) {
            
            result = YES;
        }
        __typeof(weakSelf) __strong strongSelf = weakSelf;
        [strongSelf -> _resGroup leave];
    }];
    
    if ([GCDWrapper isGCDGroup:_resGroup timeoutFiredValue:20]) {
        
        XCTFail(@"Timeout is fired. Didn't subscribe on channels");
    }
    _resGroup = nil;
    return result;
}

- (BOOL)requestChannelsForGroup:(PNChannelGroup *)group {
    
    _resGroup = [GCDGroup group];
    [_resGroup enter];
    
    __block BOOL result = NO;
    
    [_testClient  requestChannelsForGroup:group withCompletionHandlingBlock:^(PNChannelGroup *channelGroup, PNError *error) {
        
        if (!error) {
            
             result = YES;
        }
        [_resGroup leave];
    }];
    
    if ([GCDWrapper isGCDGroup:_resGroup timeoutFiredValue:20]) {
        
        XCTFail(@"Timeout is fired. Didn't subscribe on channels");
    }
    
    _resGroup = nil;
    return result;
}

- (BOOL)requestGroupsForNamespace:(NSString *)space {
    
    _resGroup = [GCDGroup group];
    [_resGroup enter];
    
    __block BOOL result = NO;
    
    [_testClient requestChannelGroupsForNamespace:space withCompletionHandlingBlock:^(NSString *namespaceName, NSArray *channelGroups, PNError *error) {
        
        if (!error) {
            
            result = YES;
        }
        [_resGroup leave];
    }];
    
    if ([GCDWrapper isGCDGroup:_resGroup timeoutFiredValue:15]) {
        
        XCTFail(@"PubNub client didn't receive list of channels for group");
    }
    _resGroup = nil;
    return result;
}

- (BOOL)requestNamespaces {
    
    _resGroup = [GCDGroup group];
    [_resGroup enter];
    
    __block BOOL result = NO;
    
    [_testClient requestChannelGroupNamespacesWithCompletionHandlingBlock:^(NSArray *namespaces, PNError *error) {
        
        if (!error) {
            
            result = YES;
        }
        [_resGroup leave];
    }];
    
    if ([GCDWrapper isGCDGroup:_resGroup timeoutFiredValue:15]) {
        
        XCTFail(@"PubNub client didn't receive list of channels for group");
    }
    _resGroup = nil;
    return result;
}

- (BOOL)removeChannels:(NSArray *)channels fromGroup:(PNChannelGroup *)group {
    
    _resGroup = [GCDGroup group];
    [_resGroup enter];
    
    __block BOOL result = NO;
    
    [_testClient removeChannels:channels
                 fromGroup:group withCompletionHandlingBlock:^(PNChannelGroup *channelGroup, NSArray *channels, PNError *error) {
                     
                     if (!error) {
                         
                         result = YES;
                     }
                     [_resGroup leave];
                 }];
    
    if ([GCDWrapper isGCDGroup:_resGroup timeoutFiredValue:15]) {
        
        XCTFail(@"PubNub client did fail to remove channels from the group");
    }
    _resGroup = nil;
    return result;
}

- (BOOL)removeGroup:(PNChannelGroup *)group {
    
    _resGroup = [GCDGroup group];
    [_resGroup enter];
    
    __block BOOL result = NO;
    
    [_testClient removeChannelGroup:group withCompletionHandlingBlock:^(PNChannelGroup *channelGroup, PNError *error) {
        
        if (!error) {
            
            result = YES;
        }
        [_resGroup leave];
    }];
    
    if ([GCDWrapper isGCDGroup:_resGroup timeoutFiredValue:15]) {
        
        XCTFail(@"PubNub client did fail to remove group");
    }
    _resGroup = nil;
    return result;
}

@end

