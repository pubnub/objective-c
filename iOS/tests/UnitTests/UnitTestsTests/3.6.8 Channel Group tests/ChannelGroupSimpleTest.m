//
//  ChannelGroupSimpleTest.m
//  UnitTests
//
//  Created by Sergey Kazanskiy on 4/20/15.
//  Copyright (c) 2015 Vadim Osovets. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

static const NSUInteger kOnPeriod = 5;

@interface ChannelGroupSimpleTest : XCTestCase  <PNDelegate>
@end

@implementation ChannelGroupSimpleTest {
    
    GCDGroup *_resGroup;
    PubNub *_testClient;
    
    PNChannel *_testChannel;
    NSArray *_testChannels;
    
    PNChannelGroup *_testGroup;
    NSArray *_testGroups;
    
    NSString *_testNamespace;
    NSArray *_testNameSpaces;
    
    BOOL _isEventNotificationDid;
    BOOL _isEventNotificationFail;
    
    BOOL _isEventObserverDid;
    BOOL _isEventObserverFail;
    
    BOOL _isEventBlockDid;
    BOOL _isEventBlockFail;
    
    BOOL _isEventDelegateDid;
    BOOL _isEventDelegateFail;
    
    bool _isExtraEventCame;
    bool _isUnexpectedEventCame;
    bool _isExpectedEventMissing;
    
    int _eventsCounter;
    int _expectedEventsCount;
    
    BOOL _isFailTest;
    NSException *_stopTestException;
}

- (void)setUp {
    
    [super setUp];
    [PubNub disconnect];
    
    _testChannel = [PNChannel channelWithName:@"testChannel"];
    _testChannels = [PNChannel channelsWithNames:@[@"testChannel1", @"testChannel2"]];
    
    _testGroup = [PNChannelGroup channelGroupWithName:@"testGroup" inNamespace:@"testNamespace"];
    _testGroups = @[_testGroup];
    
    _testNamespace = @"testNamespace";
    _testNameSpaces = @[[PNChannelGroupNamespace namespaceWithName:_testNamespace]];
    
    _stopTestException = [NSException exceptionWithName:@"StopTestException"
                                                 reason:nil
                                               userInfo:nil];
    _isFailTest = NO;
}

- (void)tearDown {
    
    _testClient = nil;
    _testChannel = nil;
    _testGroup = nil;
    
    _testNamespace = nil;
    _testNameSpaces = nil;
    _stopTestException = nil;
    
    [PubNub disconnect];
    [super tearDown];
}


#pragma mark - Tests

- (void)testChannelGroupFunction {
    
    _testClient = [PubNub clientWithConfiguration:[PNConfiguration defaultTestConfiguration] andDelegate:self];
    [self connectClient];
    [self removeNamespace:_testNamespace];
    [self namespace:_testNamespace isExist:NO];
    
    // Add channels, also are added group and namespace
    [self addChannels:_testChannels toGroup:_testGroup];
    [self group:_testGroup contains:YES channels:_testChannels];
    [self namespace:_testNamespace contains:YES group:_testGroup];
    [self namespace:_testNamespace isExist:YES];

    // Subscribe on group and unsubscribe from group
    [self client:_testClient subscribeOn:_testGroups];
    [self client:_testClient isSubscribed:YES on:_testGroup];
    [self client:_testClient unsubscribeFrom:_testGroups];
    [self client:_testClient isSubscribed:NO on:_testGroup];
    
    // Remove channels, if group is empty then also are removed group but not namespace
    [self removeChannels:_testChannels fromGroup:_testGroup];
    [self group:_testGroup contains:NO channels:_testChannels];
    [self namespace:_testNamespace contains:NO group:_testGroup];
    [self namespace:_testNamespace isExist:YES];

    // Remove group, also are removed channels from the group (but not from PubNub); namespace isn't removed even if it is empty
    [self addChannels:_testChannels toGroup:_testGroup];
    [self removeGroup:_testGroup];
    [self group:_testGroup contains:NO channels:_testChannels];
    [self namespace:_testNamespace contains:NO group:_testGroup];
    [self namespace:_testNamespace isExist:YES];
    
    // Remove namespace, also are removed group and channels from the group (but not from PubNub)
    [self addChannels:_testChannels toGroup:_testGroup];
    [self removeNamespace:_testNamespace];
    [self group:_testGroup contains:NO channels:_testChannels];
    [self namespace:_testNamespace contains:NO group:_testGroup];
    [self namespace:_testNamespace isExist:NO];
}

- (void)testChannelGroupDuplicationMethods {
    
    _testClient = [PubNub clientWithConfiguration:[PNConfiguration defaultTestConfiguration] andDelegate:self];
    [self connectClient];
    [self removeNamespace:_testNamespace];
    [self namespace:_testNamespace isExist:NO];

    // Add channels twice
    [self addChannels:_testChannels toGroup:_testGroup];
    [self addChannels:_testChannels toGroup:_testGroup];
    [self group:_testGroup contains:YES channels:_testChannels];
    [self group:_testGroup contains:YES channels:_testChannels];

#warning Extra events come from observationCenter and kPNClientSubscriptionDidCompleteNotification when client subscribes twice
    
    // Subscribe on group twice
    [self client:_testClient subscribeOn:_testGroups];
//    [self client:_testClient subscribeOn:_testGroups];  // error, extra events came !!!
    [self client:_testClient isSubscribed:YES on:_testGroup];
    [self client:_testClient isSubscribed:YES on:_testGroup];

#warning Extra events come from observationCenter and kPNClientSubscriptionDidCompleteNotification when client unsubscribes twice
    
    // Unsubscribe from group twice
    [self client:_testClient unsubscribeFrom:_testGroups];
//    [self client:_testClient unsubscribeFrom:_testGroups];   // error, extra events came !!!
    [self client:_testClient isSubscribed:NO on:_testGroup];
    [self client:_testClient isSubscribed:NO on:_testGroup];
    
    // Remove channels twice
    [self removeChannels:_testChannels fromGroup:_testGroup];
    [self removeChannels:_testChannels fromGroup:_testGroup];
    [self group:_testGroup contains:NO channels:_testChannels];
    [self group:_testGroup contains:NO channels:_testChannels];
    
    // Remove group twice
    [self addChannels:_testChannels toGroup:_testGroup];
    [self removeGroup:_testGroup];
    [self removeGroup:_testGroup];
    [self namespace:_testNamespace contains:NO group:_testGroup];
    [self namespace:_testNamespace contains:NO group:_testGroup];
    
    // Remove namespace twice
    [self addChannels:_testChannels toGroup:_testGroup];
    [self removeNamespace:_testNamespace];
    [self removeNamespace:_testNamespace];
    [self namespace:_testNamespace isExist:NO];
    [self namespace:_testNamespace isExist:NO];
}

- (void)testChannelGroupCheckFinishedWithError {
    _isFailTest = YES;
    
    _testClient = [PubNub clientWithConfiguration:[PNConfiguration accessManagerTestConfiguration] andDelegate:self];
    [self connectClient];
    [self changeAccessRightsFor:_testNameSpaces accessRights:PNNoAccessRights onPeriod:kOnPeriod];
    
    // Add channels to the group
    [self didFailAddChannels:_testChannels toGroup:_testGroup];
    
    // Sibscribe on group
    [self didFailAddChannels:_testChannels toGroup:_testGroup];
    [self didFailSubscribeOnGroups:_testGroups];

#warning Expected event from delegate missing when client tries remove group with error
    
    // Remove channels from group, group, namespace
    [self didFailRemoveChannels:_testChannels fromGroup:_testGroup];
//    [self didFailRemoveGroup:_testGroup]; // error, expected event missing !!!
    [self didFailRemoveNamespace:_testNamespace];
    
    // Request channels for group, groups for namespace, namespaces
    [self didFailRequestChannelsFromGroup:_testGroup];
    [self didFailRequestGroupsFromNamespace:_testNamespace];
    [self didFailRequestNamespaces];
}


#pragma mark - < Private methods >
#pragma mark - Connect

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


#pragma mark - Add

- (void)addChannels:(NSArray *)channels toGroup:(PNChannelGroup *)group {
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(clientGroupChannelsAdditionCompleteNotification:)
                                                 name:kPNClientGroupChannelsAdditionCompleteNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(clientGroupChannelsAdditionDidFailWithErrorNotification:)
                                                 name:kPNClientGroupChannelsAdditionDidFailWithErrorNotification
                                               object:nil];
    [self clearTestFlags];
    _expectedEventsCount = 4;

    _resGroup = [GCDGroup group];
    [_resGroup enterTimes:_expectedEventsCount];
    
    // Execution of the method using observer
    __typeof(self) __weak weakSelf = self;
    
    [_testClient.observationCenter addChannelsAdditionToGroupObserver:self withCallbackBlock:^(PNChannelGroup *group, NSArray *channels, PNError *error) {
                                                      
            __typeof(weakSelf) __strong strongSelf = weakSelf;
            if (error) {
              
              _XCTPrimitiveFail(strongSelf, @"PubNub client did fail to add channels to the group: %@", error);
              strongSelf->_isEventObserverFail = YES;
            } else {
              
              strongSelf->_isEventObserverDid = YES;
            }

            if ([strongSelf->_resGroup isEntered]) {
                
                [strongSelf->_resGroup leave];
            }
            strongSelf->_eventsCounter++;
    }];
    
    // Execution of the method using block
    __block NSArray *addedChannelsToGroup = nil;
    
    [_testClient addChannels:channels toGroup:group withCompletionHandlingBlock:^(PNChannelGroup *channelGroup, NSArray *channels, PNError *error) {
    
        __typeof(weakSelf) __strong strongSelf = weakSelf;
        
        if (error) {
            
            _XCTPrimitiveFail(strongSelf, @"Error adding channels to the group %@", error);
            strongSelf->_isEventBlockFail = YES;
        } else {
            
            addedChannelsToGroup = channels;
            strongSelf->_isEventBlockDid = YES;
        }
        
        if ([strongSelf->_resGroup isEntered]) {
            
            [strongSelf->_resGroup leave];
        }
        strongSelf->_eventsCounter++;

    }];
    
    // Waiting group
    if ([GCDWrapper isGCDGroup:_resGroup timeoutFiredValue:kTestTestTimout]) {
        
        XCTAssertTrue(_isEventNotificationDid, @"Timeout fired, notification 'GroupChannelsAddition' wasn't called");
        XCTAssertTrue(_isEventObserverDid, @"Timeout fired, observer 'ChannelsAdditionToGroup' wasn't called");
        XCTAssertTrue(_isEventBlockDid, @"Timeout fired, method 'addChannelsToGroupWithSuccessBlock' wasn't called");
        XCTAssertTrue(_isEventDelegateDid, @"Timeout fired, delegate 'didAddChannels' wasn't called");
    }
    
    _resGroup = nil;
    
    // Removing observers
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kPNClientGroupChannelsAdditionCompleteNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kPNClientGroupChannelsAdditionDidFailWithErrorNotification object:nil];
    [_testClient.observationCenter removeChannelsAdditionToGroupObserver:self];
    
    // Checking events, showing how the method was completed
    if (![self checkCorrectReceivedEvents]) {
        
        XCTFail(@"Events with error or uncorrect amound of events came");
        @throw _stopTestException;
    }
    
    // Checking result
    NSSet *specifiedChannels = [[NSSet alloc] initWithArray:channels];
    NSSet *addedChannels = [[NSSet alloc] initWithArray:addedChannelsToGroup];

    if (![specifiedChannels isSubsetOfSet:addedChannels]) {
        
        XCTFail(@"Unrecognazed error, specified channels didn't added");
        @throw _stopTestException;
    }
}

- (void)didFailAddChannels:(NSArray *)channels toGroup:(PNChannelGroup *)group {
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(clientGroupChannelsAdditionCompleteNotification:)
                                                 name:kPNClientGroupChannelsAdditionCompleteNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(clientGroupChannelsAdditionDidFailWithErrorNotification:)
                                                 name:kPNClientGroupChannelsAdditionDidFailWithErrorNotification
                                               object:nil];
    [self clearTestFlags];
    _expectedEventsCount = 4;
    
    _resGroup = [GCDGroup group];
    [_resGroup enterTimes:_expectedEventsCount];
    
    // Execution of the method using observer
    __typeof(self) __weak weakSelf = self;
    [_testClient.observationCenter addChannelsAdditionToGroupObserver:self withCallbackBlock:^(PNChannelGroup *group, NSArray *channels, PNError *error) {
        
        __typeof(weakSelf) __strong strongSelf = weakSelf;
        if (error) {
            
            strongSelf->_isEventObserverFail = YES;
        } else {
            
            _XCTPrimitiveFail(strongSelf, @"PubNub client didn't fail to add channels to the group");
            strongSelf->_isEventObserverDid = YES;
        }
        
        if ([strongSelf->_resGroup isEntered]) {
            
            [strongSelf->_resGroup leave];
        }
        strongSelf->_eventsCounter++;
    }];
    
    // Execution of the method using block
    [_testClient addChannels:channels toGroup:group withCompletionHandlingBlock:^(PNChannelGroup *channelGroup, NSArray *channels, PNError *error) {
        
        __typeof(weakSelf) __strong strongSelf = weakSelf;
        if (error) {
            
            strongSelf->_isEventBlockFail = YES;
        } else {

            _XCTPrimitiveFail(strongSelf, @"PubNub client didn't fail to add channels to the group");
            strongSelf->_isEventBlockDid = YES;
        }
        
        if ([strongSelf->_resGroup isEntered]) {
            
            [strongSelf->_resGroup leave];
        }
        strongSelf->_eventsCounter++;
    }];
    
    // Waiting group
    if ([GCDWrapper isGCDGroup:_resGroup timeoutFiredValue:kTestTestTimout]) {
        
        XCTAssertTrue(_isEventNotificationFail, @"Timeout fired, notification 'ChannelsAdditionDidFailWithError' wasn't called");
        XCTAssertTrue(_isEventObserverFail, @"Timeout fired, didn't error in observer 'ChannelsAdditionToGroup'");
        XCTAssertTrue(_isEventBlockFail, @"Timeout fired, didn't error in method 'addChannelsToGroupWithSuccessBlock'");
        XCTAssertTrue(_isEventDelegateFail, @"Timeout fired, delegate 'channelsAdditionToGroupDidFail' wasn't called");
    }
    
    _resGroup = nil;
    
    // Removing observers
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kPNClientGroupChannelsAdditionCompleteNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kPNClientGroupChannelsAdditionDidFailWithErrorNotification object:nil];
    [_testClient.observationCenter removeChannelsAdditionToGroupObserver:self];

    // Checking events, showing how the method was completed
    if (![self checkCorrectReceivedEvents]) {
        
        XCTFail(@"Events with error or uncorrect amound of events came");
        @throw _stopTestException;
    }
}


#pragma mark - Remove

- (void)removeChannels:(NSArray *)channels fromGroup:(PNChannelGroup *)group {
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(clientGroupChannelsRemovalCompleteNotification:)
                                                 name:kPNClientGroupChannelsRemovalCompleteNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(clientGroupChannelsRemovalDidFailWithErrorNotification:)
                                                 name:kPNClientGroupChannelsRemovalDidFailWithErrorNotification
                                               object:nil];
    [self clearTestFlags];
    _expectedEventsCount = 4;
    
    _resGroup = [GCDGroup group];
    [_resGroup enterTimes:_expectedEventsCount];
    
    // Execution of the method using observer
    __typeof(self) __weak weakSelf = self;
    [_testClient.observationCenter addChannelsRemovalFromGroupObserver:self withCallbackBlock:^(PNChannelGroup *channelGroup, NSArray *channels, PNError *error) {
        
        __typeof(weakSelf) __strong strongSelf = weakSelf;
        if (error) {
            
            _XCTPrimitiveFail(strongSelf, @"PubNub client did fail to remove channels from the group: %@", error);
            strongSelf->_isEventObserverFail = YES;
        } else {
            
            strongSelf->_isEventObserverDid = YES;
        }
        
        if ([strongSelf->_resGroup isEntered]) {
            
            [strongSelf->_resGroup leave];
        }
         strongSelf->_eventsCounter++;
    }];
    
    // Execution of the method using block
    __block NSArray *removedChannelsFromGroup = nil;
    
    [_testClient removeChannels:_testChannels fromGroup:_testGroup withCompletionHandlingBlock:^(PNChannelGroup *channelGroup, NSArray *channels, PNError *error) {
        
        __typeof(weakSelf) __strong strongSelf = weakSelf;
        if (error) {
            
            _XCTPrimitiveFail(strongSelf, @"Error removing channels from the group %@", error);
            strongSelf->_isEventBlockFail = YES;
        } else {
            
            removedChannelsFromGroup = channels;
            strongSelf->_isEventBlockDid = YES;
        }
        
        if ([strongSelf->_resGroup isEntered]) {
            
            [strongSelf->_resGroup leave];
        }
        strongSelf->_eventsCounter++;
    }];
    
    // Waiting group
    if ([GCDWrapper isGCDGroup:_resGroup timeoutFiredValue:kTestTestTimout]) {
        
        XCTAssertTrue(_isEventNotificationDid, @"Timeout fired, notification 'GroupChannelsRemoving' wasn't called");
        XCTAssertTrue(_isEventObserverDid, @"Timeout fired, observer 'ChannelsRemovingToGroup' wasn't called");
        XCTAssertTrue(_isEventBlockDid, @"Timeout fired, method 'removeChannelsFronGroupWithSuccessBlock' wasn't called");
        XCTAssertTrue(_isEventDelegateDid, @"Timeout fired, delegate 'didRemoveChannels' wasn't called");
    }
    
    _resGroup = nil;
    
    // Removing observers
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kPNClientGroupChannelsRemovalCompleteNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kPNClientGroupChannelsRemovalDidFailWithErrorNotification object:nil];
    [_testClient.observationCenter removeChannelsRemovalFromGroupObserver:self];
    
    // Checking events, showing how the method was completed
    if (![self checkCorrectReceivedEvents]) {
        
        XCTFail(@"Events with error or uncorrect amound of events came");
        @throw _stopTestException;
    }
    
    // Checking result
    NSSet *specifiedChannels = [[NSSet alloc] initWithArray:channels];
    NSSet *removedChannels = [[NSSet alloc] initWithArray:removedChannelsFromGroup];
    
    if (![specifiedChannels isSubsetOfSet:removedChannels]) {
        
        XCTFail(@"Client still isn't connected to PubNub");
        @throw _stopTestException;
    }
}

- (void)removeGroup:(PNChannelGroup *)group {
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(clientChannelGroupRemovalCompleteNotification:)
                                                 name:kPNClientChannelGroupRemovalCompleteNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(clientChannelGroupRemovalDidFailWithErrorNotification:)
                                                 name:kPNClientChannelGroupRemovalDidFailWithErrorNotification
                                               object:nil];
    [self clearTestFlags];
    _expectedEventsCount = 4;
    
    _resGroup = [GCDGroup group];
    [_resGroup enterTimes:_expectedEventsCount];
    
    // Execution of the method using observer
    __typeof(self) __weak weakSelf = self;
    
    [_testClient.observationCenter addChannelGroupRemovalObserver:self withCallbackBlock:^(PNChannelGroup *channelGroup, PNError *error) {
        
        __typeof(weakSelf) __strong strongSelf = weakSelf;
        if (error) {
            
            _XCTPrimitiveFail(strongSelf, @"PubNub client did fail to remove channels from the group: %@", error);
            strongSelf->_isEventObserverFail = YES;
        } else if (channelGroup == group) {
            
            strongSelf->_isEventObserverDid = YES;
        }
        
        if ([strongSelf->_resGroup isEntered]) {
            
            [strongSelf->_resGroup leave];
        }
        strongSelf->_eventsCounter++;
    }];
    
    // Execution of the method using block
    [_testClient removeChannelGroup:group withCompletionHandlingBlock:^(PNChannelGroup *channelGroup, PNError *error) {
        
        __typeof(weakSelf) __strong strongSelf = weakSelf;
        if (error) {
            
            _XCTPrimitiveFail(strongSelf, @"Error removing channels from the group %@", error);
            strongSelf->_isEventBlockFail = YES;
        } else if (channelGroup == group) {
            
            strongSelf->_isEventBlockDid = YES;
        }
        
        if ([strongSelf->_resGroup isEntered]) {
            
            [strongSelf->_resGroup leave];
        }
        strongSelf->_eventsCounter++;
    }];
    
    // Waiting group
    if ([GCDWrapper isGCDGroup:_resGroup timeoutFiredValue:kTestTestTimout]) {
        
        XCTAssertTrue(_isEventNotificationDid, @"Timeout fired, notification 'GroupRemoving' wasn't called");
        XCTAssertTrue(_isEventObserverDid, @"Timeout fired, observer 'GroupRemoving' wasn't called");
        XCTAssertTrue(_isEventBlockDid, @"Timeout fired, method 'removeGroupWithSuccessBlock' wasn't called");
        XCTAssertTrue(_isEventDelegateDid, @"Timeout fired, delegate 'didRemoveGroup' wasn't called");
    }
    
    _resGroup = nil;
    
    // Removing observers
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kPNClientChannelGroupRemovalCompleteNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kPNClientChannelGroupRemovalDidFailWithErrorNotification object:nil];
    [_testClient.observationCenter removeChannelGroupRemovalObserver:self];
    
    // Checking events, showing how the method was completed
    if (![self checkCorrectReceivedEvents]) {
        
        XCTFail(@"Events with error or uncorrect amound of events came");
        @throw _stopTestException;
    }
}

- (void)removeNamespace:(NSString *)namespace {
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(clientChannelGroupNamespaceRemovalCompleteNotification:)
                                                 name:kPNClientChannelGroupNamespaceRemovalCompleteNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(clientChannelGroupNamespaceRemovalDidFailWithErrorNotification:)
                                                 name:kPNClientChannelGroupNamespaceRemovalDidFailWithErrorNotification
                                               object:nil];
    [self clearTestFlags];
    _expectedEventsCount = 4;
    
    _resGroup = [GCDGroup group];
    [_resGroup enterTimes:_expectedEventsCount];
    
    // Execution of the method using observer
    __typeof(self) __weak weakSelf = self;
    
    [_testClient.observationCenter addChannelGroupNamespaceRemovalObserver:self withCallbackBlock:^(NSString *namespaceName, PNError *error) {
        
        __typeof(weakSelf) __strong strongSelf = weakSelf;
        if (error) {
            
            _XCTPrimitiveFail(strongSelf, @"PubNub client did fail to remove channels from the group: %@", error);
            strongSelf->_isEventObserverFail = YES;
        } else if (namespaceName == namespace) {
            
            strongSelf->_isEventObserverDid = YES;
        }
        
        if ([strongSelf->_resGroup isEntered]) {
            
            [strongSelf->_resGroup leave];
        }
        strongSelf->_eventsCounter++;
    }];
    
    // Execution of the method using block
    [_testClient removeChannelGroupNamespace:namespace withCompletionHandlingBlock:^(NSString *namespaceName, PNError *error) {
        
        __typeof(weakSelf) __strong strongSelf = weakSelf;
        if (error) {
            
            _XCTPrimitiveFail(strongSelf, @"Error removing channels from the group %@", error);
            strongSelf->_isEventBlockFail = YES;
        } else if (namespaceName == namespace) {
            
            strongSelf->_isEventBlockDid = YES;
        }
        
        if ([strongSelf->_resGroup isEntered]) {
            
            [strongSelf->_resGroup leave];
        }
        strongSelf->_eventsCounter++;
    }];
    
    // Waiting group
    if ([GCDWrapper isGCDGroup:_resGroup timeoutFiredValue:kTestTestTimout]) {
        
        XCTAssertTrue(_isEventNotificationDid, @"Timeout fired, notification 'NamespaceRemoving' wasn't called");
        XCTAssertTrue(_isEventObserverDid, @"Timeout fired, observer 'NamespaceRemoving' wasn't called");
        XCTAssertTrue(_isEventBlockDid, @"Timeout fired, method 'removeNamespaceWithSuccessBlock' wasn't called");
        XCTAssertTrue(_isEventDelegateDid, @"Timeout fired, delegate 'didRemoveNamespace' wasn't called");
    }
    
    _resGroup = nil;
    
    // Removing observers
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kPNClientChannelGroupNamespaceRemovalCompleteNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kPNClientChannelGroupNamespaceRemovalDidFailWithErrorNotification object:nil];
    [_testClient.observationCenter removeChannelGroupNamespaceRemovalObserver:self];
    
    // Checking events, showing how the method was completed
    if (![self checkCorrectReceivedEvents]) {
        
        XCTFail(@"Events with error or uncorrect amound of events came");
        @throw _stopTestException;
    }
}

- (void)didFailRemoveChannels:(NSArray *)channels fromGroup:(PNChannelGroup *)group {
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(clientGroupChannelsRemovalCompleteNotification:)
                                                 name:kPNClientGroupChannelsRemovalCompleteNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(clientGroupChannelsRemovalDidFailWithErrorNotification:)
                                                 name:kPNClientGroupChannelsRemovalDidFailWithErrorNotification
                                               object:nil];
    [self clearTestFlags];
    _expectedEventsCount = 4;
    
    _resGroup = [GCDGroup group];
    [_resGroup enterTimes:_expectedEventsCount];
    
    // Execution of the method using observer
    __typeof(self) __weak weakSelf = self;
    [_testClient.observationCenter addChannelsRemovalFromGroupObserver:self withCallbackBlock:^(PNChannelGroup *channelGroup, NSArray *channels, PNError *error) {
        
        __typeof(weakSelf) __strong strongSelf = weakSelf;
        if (error) {
            
            strongSelf->_isEventObserverFail = YES;
        } else {
            
            _XCTPrimitiveFail(strongSelf, @"PubNub client did fail to remove channels from the group: %@", error);
            strongSelf->_isEventObserverDid = YES;
        }
        
        if ([strongSelf->_resGroup isEntered]) {
            
            [strongSelf->_resGroup leave];
        }
        strongSelf->_eventsCounter++;
    }];
    
    // Execution of the method using block
    [_testClient removeChannels:_testChannels fromGroup:_testGroup withCompletionHandlingBlock:^(PNChannelGroup *channelGroup, NSArray *channels, PNError *error) {
        
        __typeof(weakSelf) __strong strongSelf = weakSelf;
        if (error) {
            
            strongSelf->_isEventBlockFail = YES;
        } else {
            
            _XCTPrimitiveFail(strongSelf, @"Error removing channels from the group %@", error);
            strongSelf->_isEventBlockDid = YES;
        }
        
        if ([strongSelf->_resGroup isEntered]) {
            
            [strongSelf->_resGroup leave];
        }
        strongSelf->_eventsCounter++;
    }];
    
    // Waiting group
    if ([GCDWrapper isGCDGroup:_resGroup timeoutFiredValue:kTestTestTimout]) {
        
        XCTAssertTrue(_isEventNotificationFail, @"Timeout fired, notification 'GroupChannelsRemovalDidFail' wasn't called");
        XCTAssertTrue(_isEventObserverFail, @"Timeout fired, didn't error in observer 'ChannelsRemovingToGroup'");
        XCTAssertTrue(_isEventBlockFail, @"Timeout fired, didn't error in method 'removeChannelsFronGroupWithSuccessBlock'");
        XCTAssertTrue(_isEventDelegateFail, @"Timeout fired, delegate 'channelsRemovalFromGroupDidFail' wasn't called");
    }
    
    _resGroup = nil;
    
    // Removing observers
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kPNClientGroupChannelsRemovalCompleteNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kPNClientGroupChannelsRemovalDidFailWithErrorNotification object:nil];
    [_testClient.observationCenter removeChannelsRemovalFromGroupObserver:self];
    
    // Checking events, showing how the method was completed
    if (![self checkCorrectReceivedEvents]) {
        
        XCTFail(@"Events with error or uncorrect amound of events came");
        @throw _stopTestException;
    }
}

- (void)didFailRemoveGroup:(PNChannelGroup *)group {
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(clientChannelGroupRemovalCompleteNotification:)
                                                 name:kPNClientChannelGroupRemovalCompleteNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(clientChannelGroupRemovalDidFailWithErrorNotification:)
                                                 name:kPNClientChannelGroupRemovalDidFailWithErrorNotification
                                               object:nil];
    [self clearTestFlags];
    _expectedEventsCount = 4;
    
    _resGroup = [GCDGroup group];
    [_resGroup enterTimes:_expectedEventsCount];
    
    // Execution of the method using observer
    __typeof(self) __weak weakSelf = self;
    
    [_testClient.observationCenter addChannelGroupRemovalObserver:self withCallbackBlock:^(PNChannelGroup *channelGroup, PNError *error) {
        
        __typeof(weakSelf) __strong strongSelf = weakSelf;
        if (error) {
            
            strongSelf->_isEventObserverFail = YES;
        } else if (channelGroup == group) {
            
            _XCTPrimitiveFail(strongSelf, @"PubNub client removed the group");
            strongSelf->_isEventObserverDid = YES;
        }
        
        if ([strongSelf->_resGroup isEntered]) {
            
            [strongSelf->_resGroup leave];
        }
        strongSelf->_eventsCounter++;
    }];
    
    // Execution of the method using block
    [_testClient removeChannelGroup:group withCompletionHandlingBlock:^(PNChannelGroup *channelGroup, PNError *error) {
        
        __typeof(weakSelf) __strong strongSelf = weakSelf;
        if (error) {
            
            strongSelf->_isEventBlockFail = YES;
        } else if (channelGroup == group) {
            
            _XCTPrimitiveFail(strongSelf, @"PubNub client removed the group");
            strongSelf->_isEventBlockDid = YES;
        }
        
        if ([strongSelf->_resGroup isEntered]) {
            
            [strongSelf->_resGroup leave];
        }
        strongSelf->_eventsCounter++;
    }];
    
    // Waiting group
    if ([GCDWrapper isGCDGroup:_resGroup timeoutFiredValue:kTestTestTimout]) {
        
        XCTAssertTrue(_isEventNotificationFail, @"Timeout fired, notification 'ChannelGroupRemovalDidFail' wasn't called");
        XCTAssertTrue(_isEventObserverFail, @"Timeout fired, didn't error in observer 'GroupRemoving' wasn't called");
        XCTAssertTrue(_isEventBlockFail, @"Timeout fired, didn't error in method 'removeGroupWithSuccessBlock' wasn't called");
        XCTAssertTrue(_isEventDelegateFail, @"Timeout fired, delegate 'groupRemovalDidFail' wasn't called");
    }
    
    _resGroup = nil;
    
    // Removing observers
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kPNClientChannelGroupRemovalCompleteNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kPNClientChannelGroupRemovalDidFailWithErrorNotification object:nil];
    [_testClient.observationCenter removeChannelGroupRemovalObserver:self];
    
    // Checking events, showing how the method was completed
    if (![self checkCorrectReceivedEvents]) {
        
        XCTFail(@"Events with error or uncorrect amound of events came");
        @throw _stopTestException;
    }
}

- (void)didFailRemoveNamespace:(NSString *)namespace {
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(clientChannelGroupNamespaceRemovalCompleteNotification:)
                                                 name:kPNClientChannelGroupNamespaceRemovalCompleteNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(clientChannelGroupNamespaceRemovalDidFailWithErrorNotification:)
                                                 name:kPNClientChannelGroupNamespaceRemovalDidFailWithErrorNotification
                                               object:nil];
    [self clearTestFlags];
    _expectedEventsCount = 4;
    
    _resGroup = [GCDGroup group];
    [_resGroup enterTimes:_expectedEventsCount];
    
    // Execution of the method using observer
    __typeof(self) __weak weakSelf = self;
    
    [_testClient.observationCenter addChannelGroupNamespaceRemovalObserver:self withCallbackBlock:^(NSString *namespaceName, PNError *error) {
        
        __typeof(weakSelf) __strong strongSelf = weakSelf;
        if (error) {
            
            strongSelf->_isEventObserverFail = YES;
        } else if (namespaceName == namespace) {
            
            _XCTPrimitiveFail(strongSelf, @"PubNub client removed the namespace");
            strongSelf->_isEventObserverDid = YES;
        }
        
        if ([strongSelf->_resGroup isEntered]) {
            
            [strongSelf->_resGroup leave];
        }
        strongSelf->_eventsCounter++;
    }];
    
    // Execution of the method using block
    [_testClient removeChannelGroupNamespace:namespace withCompletionHandlingBlock:^(NSString *namespaceName, PNError *error) {
        
        __typeof(weakSelf) __strong strongSelf = weakSelf;
        if (error) {
            
            strongSelf->_isEventBlockFail = YES;
        } else if (namespaceName == namespace) {
            
            _XCTPrimitiveFail(strongSelf, @"PubNub client removed the namespace");
            strongSelf->_isEventBlockDid = YES;
        }
        
        if ([strongSelf->_resGroup isEntered]) {
            
            [strongSelf->_resGroup leave];
        }
        strongSelf->_eventsCounter++;
    }];
    
    // Waiting group
    if ([GCDWrapper isGCDGroup:_resGroup timeoutFiredValue:kTestTestTimout]) {
        
        XCTAssertTrue(_isEventNotificationFail, @"Timeout fired, notification 'NamespaceRemovalDidFail' wasn't called");
        XCTAssertTrue(_isEventObserverFail, @"Timeout fired, didn't error in observer 'NamespaceRemoving'");
        XCTAssertTrue(_isEventBlockFail, @"Timeout fired, didn't error in method 'removeNamespaceWithSuccessBlock'");
        XCTAssertTrue(_isEventDelegateFail, @"Timeout fired, delegate 'namespaceRemovalDidFail' wasn't called");
    }
    
    _resGroup = nil;
    
    // Removing observers
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kPNClientChannelGroupNamespaceRemovalCompleteNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kPNClientChannelGroupNamespaceRemovalDidFailWithErrorNotification object:nil];
    [_testClient.observationCenter removeChannelGroupNamespaceRemovalObserver:self];
    
    // Checking events, showing how the method was completed
    if (![self checkCorrectReceivedEvents]) {
        
        XCTFail(@"Events with error or uncorrect amound of events came");
        @throw _stopTestException;
    }
}


#pragma mark - Request
- (void)group:(PNChannelGroup *)group contains:(bool)positive channels:(NSArray *)channels {
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(clientChannelsForGroupRequestCompleteNotification:)
                                                 name:kPNClientChannelsForGroupRequestCompleteNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(clientChannelsForGroupRequestDidFailWithErrorNotification:)
                                                 name:kPNClientChannelsForGroupRequestDidFailWithErrorNotification
                                               object:nil];
    [self clearTestFlags];
    _expectedEventsCount = 4;
    
    _resGroup = [GCDGroup group];
    [_resGroup enterTimes:_expectedEventsCount];
    
    // Execution of the method using observer
    __typeof(self) __weak weakSelf = self;
    
    [_testClient.observationCenter addChannelsForGroupRequestObserver:self withCallbackBlock:^(PNChannelGroup *channelGroup, PNError *error) {
        
        __typeof(weakSelf) __strong strongSelf = weakSelf;
        if (error) {
            
            _XCTPrimitiveFail(strongSelf, @"PubNub client did fail to request channels from the group: %@", error);
            strongSelf->_isEventObserverFail = YES;
        } else {
            
            strongSelf->_isEventObserverDid = YES;
        }
        
        if ([strongSelf->_resGroup isEntered]) {
            
            [strongSelf->_resGroup leave];
        }
        strongSelf->_eventsCounter++;
    }];
    
    // Execution of the method using block
    __block NSArray *groupsChannels;
    
    [_testClient requestChannelsForGroup:group withCompletionHandlingBlock:^(PNChannelGroup *channelGroup, PNError *error) {
        
        __typeof(weakSelf) __strong strongSelf = weakSelf;
        if (error) {
            
            _XCTPrimitiveFail(strongSelf, @"Error requesting channels from the group %@", error);
            strongSelf->_isEventBlockFail = YES;
        } else {
            
            groupsChannels = [NSArray arrayWithArray:channelGroup.channels];
            strongSelf->_isEventBlockDid = YES;
        }
        
        if ([strongSelf->_resGroup isEntered]) {
            
            [strongSelf->_resGroup leave];
        }
        strongSelf->_eventsCounter++;
    }];
    
    // Waiting group
    if ([GCDWrapper isGCDGroup:_resGroup timeoutFiredValue:kTestTestTimout]) {
        
        XCTAssertTrue(_isEventNotificationDid, @"Timeout fired, notification 'GroupChannelsRequesting' wasn't called");
        XCTAssertTrue(_isEventObserverDid, @"Timeout fired, observer 'ChannelsRequestingToGroup' wasn't called");
        XCTAssertTrue(_isEventBlockDid, @"Timeout fired, method 'requesrtChannelsFronGroupWithSuccessBlock' wasn't called");
        XCTAssertTrue(_isEventDelegateDid, @"Timeout fired, delegate 'didRequestChannels' wasn't called");
    }

    _resGroup = nil;
    
    // Removing observers
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kPNClientChannelsForGroupRequestCompleteNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kPNClientChannelsForGroupRequestDidFailWithErrorNotification object:nil];
    [_testClient.observationCenter removeChannelsForGroupRequestObserver:self];
    
    // Checking events, showing how the method was completed
    if (![self checkCorrectReceivedEvents]) {
        
        XCTFail(@"Events with error or uncorrect amound of events came");
        @throw _stopTestException;
    }

    // Checking result
    NSSet *specifiedChannels = [[NSSet alloc] initWithArray:[channels valueForKey:@"name"]];
    NSSet *requestedChannels = [[NSSet alloc] initWithArray:[groupsChannels valueForKey:@"name"]];
    BOOL isChannels = [specifiedChannels isSubsetOfSet:requestedChannels];
    
    if (positive & !isChannels) {
        
        XCTFail(@"The checking showed an error");
        @throw _stopTestException;
        
    } else if (!positive & isChannels) {
        
        XCTFail(@"The checking showed an error");
        @throw _stopTestException;
    }
}
- (void)namespace:(NSString *)space contains:(bool)positive group:(PNChannelGroup *)group {
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(clientChannelGroupsRequestCompleteNotification:)
                                                 name:kPNClientChannelGroupsRequestCompleteNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(clientChannelGroupsRequestDidFailWithErrorNotification:)
                                                 name:kPNClientChannelGroupsRequestDidFailWithErrorNotification
                                               object:nil];
    [self clearTestFlags];
    _expectedEventsCount = 4;
    
    _resGroup = [GCDGroup group];
    [_resGroup enterTimes:_expectedEventsCount];
    
    // Execution of the method using observer
    __typeof(self) __weak weakSelf = self;
    
    [_testClient.observationCenter addChannelGroupsRequestObserver:self withCallbackBlock:^(NSString *namespaceName, NSArray *channelGroups, PNError *error) {
                                                     
        __typeof(weakSelf) __strong strongSelf = weakSelf;
        if (error) {
            
            _XCTPrimitiveFail(strongSelf, @"PubNub client did fail to request channels from the group: %@", error);
            strongSelf->_isEventObserverFail = YES;
        } else {
            
            strongSelf->_isEventObserverDid = YES;
        }
        
        if ([strongSelf->_resGroup isEntered]) {
            
            [strongSelf->_resGroup leave];
        }
        strongSelf->_eventsCounter++;
    }];
    
    // Execution of the method using block
    __block NSArray *groupsOfNamespace;
    
    [_testClient requestChannelGroupsForNamespace:space withCompletionHandlingBlock:^(NSString *namespaceName, NSArray *channelGroups, PNError *error) {
        
        __typeof(weakSelf) __strong strongSelf = weakSelf;
        if (error) {
            
            _XCTPrimitiveFail(strongSelf, @"Error requesting channels from the group %@", error);
            strongSelf->_isEventBlockFail = YES;
        } else {
            
            groupsOfNamespace = channelGroups;
            strongSelf->_isEventBlockDid = YES;
        }
        
        if ([strongSelf->_resGroup isEntered]) {
            
            [strongSelf->_resGroup leave];
        }
        strongSelf->_eventsCounter++;
    }];
    
    // Waiting group
    if ([GCDWrapper isGCDGroup:_resGroup timeoutFiredValue:kTestTestTimout]) {
        
        XCTAssertTrue(_isEventNotificationDid, @"Timeout fired, notification 'GroupChannelsRequesting' wasn't called");
        XCTAssertTrue(_isEventObserverDid, @"Timeout fired, observer 'ChannelsRequestingToGroup' wasn't called");
        XCTAssertTrue(_isEventBlockDid, @"Timeout fired, method 'requesrtChannelsFronGroupWithSuccessBlock' wasn't called");
        XCTAssertTrue(_isEventDelegateDid, @"Timeout fired, delegate 'didRequestChannels' wasn't called");
    }
    
    _resGroup = nil;
    
    // Removing observers
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kPNClientChannelGroupsRequestCompleteNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kPNClientChannelGroupsRequestDidFailWithErrorNotification object:nil];
    [_testClient.observationCenter removeChannelGroupsRequestObserver:self];
    
    // Checking events, showing how the method was completed
    if (![self checkCorrectReceivedEvents]) {
        
        XCTFail(@"Events with error or uncorrect amound of events came");
        @throw _stopTestException;
    }

    // Checking result
    NSSet *specifiedGroup = [[NSSet alloc] initWithArray:@[group.groupName]];
    NSSet *requestedGroups = [[NSSet alloc] initWithArray:[groupsOfNamespace valueForKey:@"groupName"]];
    BOOL isGroup = [specifiedGroup isSubsetOfSet:requestedGroups];
    
    if (positive & !isGroup) {
        
        XCTFail(@"The checking showed an error");
        @throw _stopTestException;
        
    } else if (!positive & isGroup) {
        
        XCTFail(@"The checking showed an error");
        @throw _stopTestException;
    }
}

- (void)namespace:(NSString *)name isExist:(BOOL)positive {
        
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(clientChannelGroupNamespacesRequestCompleteNotification:)
                                                 name:kPNClientChannelGroupNamespacesRequestCompleteNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(clientChannelGroupNamespacesRequestDidFailWithErrorNotification:)
                                                 name:kPNClientChannelGroupNamespacesRequestDidFailWithErrorNotification
                                               object:nil];
    [self clearTestFlags];
    _expectedEventsCount = 4;
    
    _resGroup = [GCDGroup group];
    [_resGroup enterTimes:_expectedEventsCount];
    
    // Execution of the method using observer
    __typeof(self) __weak weakSelf = self;
    
    [_testClient.observationCenter addChannelGroupNamespacesRequestObserver:self withCallbackBlock:^(NSArray *namespaces, PNError *error) {

        __typeof(weakSelf) __strong strongSelf = weakSelf;
        if (error) {
            
            _XCTPrimitiveFail(strongSelf, @"PubNub client did fail to request namespaces: %@", error);
            strongSelf->_isEventObserverFail = YES;
        } else {
            
            strongSelf->_isEventObserverDid = YES;
        }
        
        if ([strongSelf->_resGroup isEntered]) {
            
            [strongSelf->_resGroup leave];
        }
        strongSelf->_eventsCounter++;
    }];
    
    // Execution of the method using block
    __block NSArray *_namespaces;
    
    [_testClient requestChannelGroupNamespacesWithCompletionHandlingBlock:^(NSArray *namespaces, PNError *error) {
     
        __typeof(weakSelf) __strong strongSelf = weakSelf;
        if (error) {
            
            _XCTPrimitiveFail(strongSelf, @"Error requesting namespaces %@", error);
            strongSelf->_isEventBlockFail = YES;
        } else {
            
            _namespaces = namespaces;
            strongSelf->_isEventBlockDid = YES;
        }
        
        if ([strongSelf->_resGroup isEntered]) {
            
            [strongSelf->_resGroup leave];
        }
        strongSelf->_eventsCounter++;;
    }];
    
    // Waiting group
    if ([GCDWrapper isGCDGroup:_resGroup timeoutFiredValue:kTestTestTimout]) {
        
        XCTAssertTrue(_isEventNotificationDid, @"Timeout fired, notification 'NamespacesRequesting' wasn't called");
        XCTAssertTrue(_isEventObserverDid, @"Timeout fired, observer 'NamespacesRequest' wasn't called");
        XCTAssertTrue(_isEventBlockDid, @"Timeout fired, method 'requesrtNamespacesWithSuccessBlock' wasn't called");
        XCTAssertTrue(_isEventDelegateDid, @"Timeout fired, delegate 'didRequestNamespaces' wasn't called");
    }
    
    _resGroup = nil;
    
    // Removing observers
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kPNClientChannelGroupNamespacesRequestCompleteNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kPNClientChannelGroupNamespacesRequestDidFailWithErrorNotification object:nil];
    [_testClient.observationCenter removeChannelGroupNamespacesRequestObserver:self];
    
    // Checking events, showing how the method was completed
    if (![self checkCorrectReceivedEvents]) {
        
        XCTFail(@"Events with error or uncorrect amound of events came");
        @throw _stopTestException;
    }

    // Checking result
    NSSet *specifiedNamespace = [[NSSet alloc] initWithArray:@[name]];
    NSSet *requestedNamespaces = [[NSSet alloc] initWithArray:_namespaces];
    BOOL isNamespace = [specifiedNamespace isSubsetOfSet:requestedNamespaces];
    
    if (positive & !isNamespace) {
        
        XCTFail(@"The checking showed an error");
        @throw _stopTestException;
        
    } else if (!positive & isNamespace) {
        
        XCTFail(@"The checking showed an error");
        @throw _stopTestException;
    }
}

- (BOOL)didFailRequestChannelsFromGroup:(PNChannelGroup *)group {
    
    BOOL result = YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(clientChannelsForGroupRequestCompleteNotification:)
                                                 name:kPNClientChannelsForGroupRequestCompleteNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(clientChannelsForGroupRequestDidFailWithErrorNotification:)
                                                 name:kPNClientChannelsForGroupRequestDidFailWithErrorNotification
                                               object:nil];
    [self clearTestFlags];
    _expectedEventsCount = 4;
    
    _resGroup = [GCDGroup group];
    [_resGroup enterTimes:_expectedEventsCount];
    
    // Execution of the method using observer
    __typeof(self) __weak weakSelf = self;
    
    [_testClient.observationCenter addChannelsForGroupRequestObserver:self withCallbackBlock:^(PNChannelGroup *channelGroup, PNError *error) {
        
        __typeof(weakSelf) __strong strongSelf = weakSelf;
        if (error) {
            
            strongSelf->_isEventObserverFail = YES;
        } else {
            
            _XCTPrimitiveFail(strongSelf, @"PubNub client requested channels from the group");
            strongSelf->_isEventObserverDid = YES;
        }
        
        if ([strongSelf->_resGroup isEntered]) {
            
            [strongSelf->_resGroup leave];
        }
        strongSelf->_eventsCounter++;
    }];
    
    // Execution of the method using block
    [_testClient requestChannelsForGroup:group withCompletionHandlingBlock:^(PNChannelGroup *channelGroup, PNError *error) {
        
        __typeof(weakSelf) __strong strongSelf = weakSelf;
        if (error) {
            
            strongSelf->_isEventBlockFail = YES;
        } else {
            
            _XCTPrimitiveFail(strongSelf, @"PubNub client requested channels from the group");
            strongSelf->_isEventBlockDid = YES;
        }
        
        if ([strongSelf->_resGroup isEntered]) {
            
            [strongSelf->_resGroup leave];
        }
        strongSelf->_eventsCounter++;
    }];
    
    // Waiting group
    if ([GCDWrapper isGCDGroup:_resGroup timeoutFiredValue:kTestTestTimout]) {
        
        XCTAssertTrue(_isEventNotificationFail, @"Timeout fired, notification 'ChannelsForGroupRequestDidFail' wasn't called");
        XCTAssertTrue(_isEventObserverFail, @"Timeout fired, didn't error in observer 'ChannelsRequestingToGroup'");
        XCTAssertTrue(_isEventBlockFail, @"Timeout fired, didn't error in method 'requesrtChannelsFronGroupWithSuccessBlock'");
        XCTAssertTrue(_isEventDelegateFail, @"Timeout fired, delegate 'channelsForGroupRequestDidFail' wasn't called");
    }
    
    _resGroup = nil;
    
    // Removing observers
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kPNClientChannelsForGroupRequestCompleteNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kPNClientChannelsForGroupRequestDidFailWithErrorNotification object:nil];
    [_testClient.observationCenter removeChannelsForGroupRequestObserver:self];
    
    // Checking events, showing how the method was completed
    if (![self checkCorrectReceivedEvents]) {
        
        XCTFail(@"Events with error or uncorrect amound of events came");
        result = NO;
    }
    
    return result;
}

- (BOOL)didFailRequestGroupsFromNamespace:(NSString *)space {
    
    BOOL result = YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(clientChannelGroupsRequestCompleteNotification:)
                                                 name:kPNClientChannelGroupsRequestCompleteNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(clientChannelGroupsRequestDidFailWithErrorNotification:)
                                                 name:kPNClientChannelGroupsRequestDidFailWithErrorNotification
                                               object:nil];
    [self clearTestFlags];
    _expectedEventsCount = 4;
    
    _resGroup = [GCDGroup group];
    [_resGroup enterTimes:_expectedEventsCount];
    
    // Execution of the method using observer
    __typeof(self) __weak weakSelf = self;
    
    [_testClient.observationCenter addChannelGroupsRequestObserver:self withCallbackBlock:^(NSString *namespaceName, NSArray *channelGroups, PNError *error) {
        
        __typeof(weakSelf) __strong strongSelf = weakSelf;
        if (error) {
            
            strongSelf->_isEventObserverFail = YES;
        } else {
            
            _XCTPrimitiveFail(strongSelf, @"PubNub client requested groups from the namespaces");
            strongSelf->_isEventObserverDid = YES;
        }
        
        if ([strongSelf->_resGroup isEntered]) {
            
            [strongSelf->_resGroup leave];
        }
        strongSelf->_eventsCounter++;
    }];
    
    // Execution of the method using block
    [_testClient requestChannelGroupsForNamespace:space withCompletionHandlingBlock:^(NSString *namespaceName, NSArray *channelGroups, PNError *error) {
        
        __typeof(weakSelf) __strong strongSelf = weakSelf;
        if (error) {
            
            strongSelf->_isEventBlockFail = YES;
        } else {
            
           _XCTPrimitiveFail(strongSelf, @"PubNub client requested groups from the namespaces");
            strongSelf->_isEventBlockDid = YES;
        }
        
        if ([strongSelf->_resGroup isEntered]) {
            
            [strongSelf->_resGroup leave];
        }
        strongSelf->_eventsCounter++;
    }];
    
    // Waiting group
    if ([GCDWrapper isGCDGroup:_resGroup timeoutFiredValue:kTestTestTimout]) {
        
        XCTAssertTrue(_isEventNotificationFail, @"Timeout fired, notification 'ChannelGroupsRequestDidFail' wasn't called");
        XCTAssertTrue(_isEventObserverFail, @"Timeout fired, didn't error in observer 'ChannelsRequestingToGroup'");
        XCTAssertTrue(_isEventBlockFail, @"Timeout fired, didn't error in method 'requesrtChannelsFronGroupWithSuccessBlock'");
        XCTAssertTrue(_isEventDelegateFail, @"Timeout fired, delegate 'channelGroupsRequestDidFail' wasn't called");
    }
    
    _resGroup = nil;
    
    // Removing observers
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kPNClientChannelGroupsRequestCompleteNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kPNClientChannelGroupsRequestDidFailWithErrorNotification object:nil];
    [_testClient.observationCenter removeChannelGroupsRequestObserver:self];
    
    // Checking events, showing how the method was completed
    if (![self checkCorrectReceivedEvents]) {
        
        XCTFail(@"Events with error or uncorrect amound of events came");
        result = NO;
    }
    
    return result;
}

- (BOOL)didFailRequestNamespaces {
    
    BOOL result = YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(clientChannelGroupNamespacesRequestCompleteNotification:)
                                                 name:kPNClientChannelGroupNamespacesRequestCompleteNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(clientChannelGroupNamespacesRequestDidFailWithErrorNotification:)
                                                 name:kPNClientChannelGroupNamespacesRequestDidFailWithErrorNotification
                                               object:nil];
    [self clearTestFlags];
    _expectedEventsCount = 4;
    
    _resGroup = [GCDGroup group];
    [_resGroup enterTimes:_expectedEventsCount];
    
    // Execution of the method using observer
    __typeof(self) __weak weakSelf = self;
    
    [_testClient.observationCenter addChannelGroupNamespacesRequestObserver:self withCallbackBlock:^(NSArray *namespaces, PNError *error) {
        
        __typeof(weakSelf) __strong strongSelf = weakSelf;
        if (error) {
            
            strongSelf->_isEventObserverFail = YES;
        } else {
            
            _XCTPrimitiveFail(strongSelf, @"PubNub client requested namespaces");
            strongSelf->_isEventObserverDid = YES;
        }
        
        if ([strongSelf->_resGroup isEntered]) {
            
            [strongSelf->_resGroup leave];
        }
        strongSelf->_eventsCounter++;
    }];
    
    // Execution of the method using block
    __block NSSet *_namespaces;
    
    [_testClient requestChannelGroupNamespacesWithCompletionHandlingBlock:^(NSArray *namespaces, PNError *error) {
        
        __typeof(weakSelf) __strong strongSelf = weakSelf;
        if (error) {
            
            strongSelf->_isEventBlockFail = YES;
        } else {
            
            _XCTPrimitiveFail(strongSelf, @"PubNub client requested namespaces");
            _namespaces = [NSSet setWithArray:namespaces];
            strongSelf->_isEventBlockDid = YES;
        }
        
        if ([strongSelf->_resGroup isEntered]) {
            
            [strongSelf->_resGroup leave];
        }
        strongSelf->_eventsCounter++;
    }];
    
    // Waiting group
    if ([GCDWrapper isGCDGroup:_resGroup timeoutFiredValue:kTestTestTimout]) {
        
        XCTAssertTrue(_isEventNotificationFail, @"Timeout fired, notification 'NamespacesRequestDidFail' wasn't called");
        XCTAssertTrue(_isEventObserverFail, @"Timeout fired, didn't error in observer 'NamespacesRequest'");
        XCTAssertTrue(_isEventBlockFail, @"Timeout fired, didn't error in method 'requesrtNamespacesWithSuccessBlock'");
        XCTAssertTrue(_isEventDelegateFail, @"Timeout fired, delegate 'NamespacesRequestDidFail' wasn't called");
    }
    
    _resGroup = nil;
    
    // Removing observers
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kPNClientChannelGroupNamespacesRequestCompleteNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kPNClientChannelGroupNamespacesRequestDidFailWithErrorNotification object:nil];
    [_testClient.observationCenter removeChannelGroupNamespacesRequestObserver:self];
    
    // Checking events, showing how the method was completed
    if (![self checkCorrectReceivedEvents]) {
        
        XCTFail(@"Events with error or uncorrect amound of events came");
        result = NO;
    }
    
    return result;
}


#pragma mark - Subscribe

- (void)client:(PubNub *)client subscribeOn:(NSArray *)groups {
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(clientSubscriptionDidCompleteNotification:)
                                                 name:kPNClientSubscriptionDidCompleteNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(clientSubscriptionDidFailNotification:)
                                                 name:kPNClientSubscriptionDidFailNotification
                                               object:nil];
    [self clearTestFlags];
    _expectedEventsCount = 4;
    
    _resGroup = [GCDGroup group];
    [_resGroup enterTimes:_expectedEventsCount];
    
    // Execution of the method using observer
    __typeof(self) __weak weakSelf = self;
    
    [client.observationCenter addClientChannelSubscriptionStateObserver:self withCallbackBlock:^(PNSubscriptionProcessState state, NSArray *channels, PNError *error) {
        
        __typeof(weakSelf) __strong strongSelf = weakSelf;
        if (error) {
            
            _XCTPrimitiveFail(strongSelf, @"PubNub client did fail to subscribe on the groups: %@", error);
            strongSelf->_isEventObserverFail = YES;
            
            if ([strongSelf->_resGroup isEntered]) {
                
                [strongSelf->_resGroup leave];
            }
            
            strongSelf->_eventsCounter++;
            
        } else if (state == PNSubscriptionProcessSubscribedState && [groups isEqual:channels]) {
            NSLog(@"!!! observational");
            strongSelf->_isEventObserverDid = YES;
            
            if ([strongSelf->_resGroup isEntered]) {
                
                [strongSelf->_resGroup leave];
            }
 
            strongSelf->_eventsCounter++;
        }
        
    }];
    
    // Execution of the method using block
    [client subscribeOn:groups withCompletionHandlingBlock:^(PNSubscriptionProcessState state, NSArray *channels, PNError *error) {
        
        __typeof(weakSelf) __strong strongSelf = weakSelf;
        if (error) {
            
            _XCTPrimitiveFail(strongSelf, @"PubNub client did fail to subscribe on the groups %@", error);
            strongSelf->_isEventBlockFail = YES;
            
            if ([strongSelf->_resGroup isEntered]) {
                
                [strongSelf->_resGroup leave];
            }
            
            strongSelf->_eventsCounter++;
            
        } else if (state == PNSubscriptionProcessSubscribedState && [groups isEqual:channels]) {
            
            strongSelf->_isEventBlockDid = YES;
            
            if ([strongSelf->_resGroup isEntered]) {
                
                [strongSelf->_resGroup leave];
            }
            
            strongSelf->_eventsCounter++;
        }
    }];
    
    // Waiting group
    if ([GCDWrapper isGCDGroup:_resGroup timeoutFiredValue:kTestTestTimout]) {
        
        XCTAssertTrue(_isEventNotificationDid, @"Timeout fired, notification 'SubscriptionDidComplete' wasn't called");
        XCTAssertTrue(_isEventObserverDid, @"Timeout fired, observer 'ChannelSubscription' wasn't called");
        XCTAssertTrue(_isEventBlockDid, @"Timeout fired, method 'subscribeOnWithSuccessBlock' wasn't called");
        XCTAssertTrue(_isEventDelegateDid, @"Timeout fired, delegate 'didSubscribeOn' wasn't called");
    }
    
    _resGroup = nil;
    
    // Removing observers
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kPNClientChannelGroupRemovalCompleteNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kPNClientChannelGroupRemovalDidFailWithErrorNotification object:nil];
    [_testClient.observationCenter removeChannelGroupRemovalObserver:self];
    
    // Checking events, showing how the method was completed
    if (![self checkCorrectReceivedEvents]) {
        
        XCTFail(@"Events with error or uncorrect amound of events came");
        @throw _stopTestException;
    }
}

- (void)client:(PubNub *)client unsubscribeFrom:(NSArray *)groups {
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(clientUnsubscriptionDidCompleteNotification:)
                                                 name:kPNClientUnsubscriptionDidCompleteNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(clientUnsubscriptionDidFailNotification:)
                                                 name:kPNClientUnsubscriptionDidFailNotification
                                               object:nil];
    [self clearTestFlags];
    _expectedEventsCount = 4;
    
    _resGroup = [GCDGroup group];
    [_resGroup enterTimes:_expectedEventsCount];
    
    // Execution of the method using observer
    __typeof(self) __weak weakSelf = self;
    
    [client.observationCenter addClientChannelUnsubscriptionObserver:self withCallbackBlock:^(NSArray *channels, PNError *error) {
        
        __typeof(weakSelf) __strong strongSelf = weakSelf;
        if (error) {
            
            _XCTPrimitiveFail(strongSelf, @"PubNub client did fail to unsubscribe on the groups: %@", error);
            strongSelf->_isEventObserverFail = YES;
        } else if ([groups isEqual:channels]) {
            
            strongSelf->_isEventObserverDid = YES;
        }
        
        if ([strongSelf->_resGroup isEntered]) {
            
            [strongSelf->_resGroup leave];
        }
        strongSelf->_eventsCounter++;
    }];
    
    // Execution of the method using block
    [client unsubscribeFrom:groups withCompletionHandlingBlock:^(NSArray *channels, PNError *error) {
        
        __typeof(weakSelf) __strong strongSelf = weakSelf;
        if (error) {
            
            _XCTPrimitiveFail(strongSelf, @"PubNub client did fail to unsubscribe on the groups %@", error);
            strongSelf->_isEventBlockFail = YES;
        } else if ([groups isEqual:channels]) {
            
            strongSelf->_isEventBlockDid = YES;
        }
        
        if ([strongSelf->_resGroup isEntered]) {
            
            [strongSelf->_resGroup leave];
        }
        strongSelf->_eventsCounter++;
    }];
    
    // Waiting group
    if ([GCDWrapper isGCDGroup:_resGroup timeoutFiredValue:kTestTestTimout]) {
        
        XCTAssertTrue(_isEventNotificationDid, @"Timeout fired, notification 'UnsubscriptionDidComplete' wasn't called");
        XCTAssertTrue(_isEventObserverDid, @"Timeout fired, observer 'ChannelUnsubscription' wasn't called");
        XCTAssertTrue(_isEventBlockDid, @"Timeout fired, method 'unsubscribeFromWithSuccessBlock' wasn't called");
        XCTAssertTrue(_isEventDelegateDid, @"Timeout fired, delegate 'didUnsubscribeFrom' wasn't called");
    }
    
    _resGroup = nil;
    
    // Removing observers
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kPNClientChannelGroupRemovalCompleteNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kPNClientChannelGroupRemovalDidFailWithErrorNotification object:nil];
    [_testClient.observationCenter removeChannelGroupRemovalObserver:self];
    
    // Checking events, showing how the method was completed
    if (![self checkCorrectReceivedEvents]) {
        
        XCTFail(@"Events with error or uncorrect amound of events came");
        @throw _stopTestException;
    }
}
-(void)client:(PubNub *)client isSubscribed:(BOOL)positive on:(PNChannelGroup *)group {
    
    if (positive & ![client isSubscribedOn:group]) {
        
        XCTFail(@"The checking showed an error");
        @throw _stopTestException;
        
    } else if (!positive & [client isSubscribedOn:group]) {
        
        XCTFail(@"The checking showed an error");
        @throw _stopTestException;
    }
}

- (void)didFailSubscribeOnGroups:(NSArray *)groups {
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(clientSubscriptionDidCompleteNotification:)
                                                 name:kPNClientSubscriptionDidCompleteNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(clientSubscriptionDidFailNotification:)
                                                 name:kPNClientSubscriptionDidFailNotification
                                               object:nil];
    [self clearTestFlags];
    _expectedEventsCount = 4;
    
    _resGroup = [GCDGroup group];
    [_resGroup enterTimes:_expectedEventsCount];
    
    // Execution of the method using observer
    __typeof(self) __weak weakSelf = self;
    
    [_testClient.observationCenter addClientChannelSubscriptionStateObserver:self withCallbackBlock:^(PNSubscriptionProcessState state, NSArray *channels, PNError *error) {
        
        __typeof(weakSelf) __strong strongSelf = weakSelf;
        if (error) {
            
            strongSelf->_isEventObserverFail = YES;
        } else if (state == PNSubscriptionProcessSubscribedState && [groups isEqual:channels]) {
            
            _XCTPrimitiveFail(strongSelf, @"PubNub client subscribed on the groups");
            strongSelf->_isEventObserverDid = YES;
        }
        
        if ([strongSelf->_resGroup isEntered]) {
            
            [strongSelf->_resGroup leave];
        }
        strongSelf->_eventsCounter++;
    }];
    
    // Execution of the method using block
    [_testClient subscribeOn:groups withCompletionHandlingBlock:^(PNSubscriptionProcessState state, NSArray *channels, PNError *error) {
        
        __typeof(weakSelf) __strong strongSelf = weakSelf;
        if (error) {
            
            strongSelf->_isEventBlockFail = YES;
        } else if (state == PNSubscriptionProcessSubscribedState && [groups isEqual:channels]) {
            
            _XCTPrimitiveFail(strongSelf, @"PubNub client subscribed on the groups");
            strongSelf->_isEventBlockDid = YES;
        }
        
        if ([strongSelf->_resGroup isEntered]) {
            
            [strongSelf->_resGroup leave];
        }
        strongSelf->_eventsCounter++;
    }];
    
    // Waiting group
    if ([GCDWrapper isGCDGroup:_resGroup timeoutFiredValue:kTestTestTimout]) {
        
        XCTAssertTrue(_isEventNotificationFail, @"Timeout fired, notification 'SubscriptionDidFail' wasn't called");
        XCTAssertTrue(_isEventObserverFail, @"Timeout fired, didn't error in observer 'ChannelSubscription'");
        XCTAssertTrue(_isEventBlockFail, @"Timeout fired, didn't error in method 'subscribeOnWithSuccessBlock'");
        XCTAssertTrue(_isEventDelegateFail, @"Timeout fired, delegate 'subscriptionDidFail' wasn't called");
    }
    
    _resGroup = nil;
    
    // Removing observers
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kPNClientChannelGroupRemovalCompleteNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kPNClientChannelGroupRemovalDidFailWithErrorNotification object:nil];
    [_testClient.observationCenter removeChannelGroupRemovalObserver:self];
    
    // Checking events, showing how the method was completed
    if (![self checkCorrectReceivedEvents]) {
        
        XCTFail(@"Events with error or uncorrect amound of events came");
        @throw _stopTestException;
    }
}


#pragma mark - Access rights

- (void)changeAccessRightsFor:(NSArray *)channelObjects accessRights:(PNAccessRights)accessRights onPeriod:(NSInteger)accessPeriodDuration {
    
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


#pragma mark - Service-methods

- (void)clearTestFlags {
    
    _isEventNotificationDid = NO;
    _isEventNotificationFail = NO;
    
    _isEventObserverDid = NO;
    _isEventObserverFail = NO;
    
    _isEventBlockDid = NO;
    _isEventBlockFail = NO;
    
    _isEventDelegateDid = NO;
    _isEventDelegateFail = NO;
    
    _isExtraEventCame = NO;
    _isUnexpectedEventCame = NO;
    _isExpectedEventMissing = NO;
    
    _eventsCounter = 0;
    _expectedEventsCount = 0;
}

-(BOOL)checkCorrectReceivedEvents {
    
    BOOL incorrectResult = YES;
    
    if (!_isFailTest) {
        
        _isExpectedEventMissing = !_isEventNotificationDid || !_isEventObserverDid || !_isEventBlockDid || !_isEventDelegateDid;
        _isUnexpectedEventCame = _isEventNotificationFail || _isEventObserverFail || _isEventDelegateFail || _isEventBlockFail;
        _isExtraEventCame = _eventsCounter > _expectedEventsCount;
        
        XCTAssertTrue(_isEventNotificationDid);
        XCTAssertTrue(_isEventObserverDid);
        XCTAssertTrue(_isEventBlockDid);
        XCTAssertTrue(_isEventDelegateDid);
        XCTAssertFalse(_isEventNotificationFail);
        XCTAssertFalse(_isEventObserverFail);
        XCTAssertFalse(_isEventBlockFail);
        XCTAssertFalse(_isEventDelegateFail);
        
    } else {
        
        _isExpectedEventMissing = !_isEventNotificationFail || !_isEventObserverFail || !_isEventDelegateFail || !_isEventBlockFail;
        _isUnexpectedEventCame = _isEventNotificationDid || _isEventObserverDid || _isEventDelegateDid || _isEventBlockDid;
        _isExtraEventCame = _eventsCounter > _expectedEventsCount;
        
        XCTAssertFalse(_isEventNotificationDid);
        XCTAssertFalse(_isEventObserverDid);
        XCTAssertFalse(_isEventBlockDid);
        XCTAssertFalse(_isEventDelegateDid);
        XCTAssertTrue(_isEventNotificationFail);
        XCTAssertTrue(_isEventObserverFail);
        XCTAssertTrue(_isEventBlockFail);
        XCTAssertTrue(_isEventDelegateFail);
    }
    
    XCTAssertFalse(_isExpectedEventMissing);
    XCTAssertFalse(_isUnexpectedEventCame);
    XCTAssertFalse(_isExtraEventCame);
    
    incorrectResult = _isExpectedEventMissing || _isUnexpectedEventCame || _isExtraEventCame;
    return !incorrectResult;
}

#pragma mark - < Notificatons >
#pragma mark - Add

// Add channels to group (did)
- (void)clientGroupChannelsAdditionCompleteNotification:(NSNotification *)notification {
    
    if ([_resGroup isEntered]) {
        
        if (_isFailTest) {
            
            XCTFail(@"PubNub client added channels to the group");
        }
        _isEventNotificationDid = YES;
        [_resGroup leave];
    }
    _eventsCounter++;
}

// Add channels to group (fail)
- (void)clientGroupChannelsAdditionDidFailWithErrorNotification:(NSNotification *)notification {
    
    if ([_resGroup isEntered]) {
        
        if (!_isFailTest) {
            
            XCTFail(@"PubNub client did fail to add channels to the group");
        }
        _isEventNotificationFail = YES;
        [_resGroup leave];
    }
    _eventsCounter++;
}


#pragma mark - Remove

// Remove channels from group (did)
- (void)clientGroupChannelsRemovalCompleteNotification:(NSNotification *)notification {
    
    if ([_resGroup isEntered]) {
        
        if (_isFailTest) {
            
            XCTFail(@"PubNub client removed channels from the group");
        }
        _isEventNotificationDid = YES;
        [_resGroup leave];
    }
    _eventsCounter++;
}

// Remove channels from group (fail)
- (void)clientGroupChannelsRemovalDidFailWithErrorNotification:(NSNotification *)notification {
    
    if ([_resGroup isEntered]) {
        
        if (!_isFailTest) {
            
            XCTFail(@"PubNub client did fail to remove channels from the group");
        }
        _isEventNotificationFail = YES;
        [_resGroup leave];
    }
    _eventsCounter++;
}

// Remove group (did)
- (void)clientChannelGroupRemovalCompleteNotification:(NSNotification *)notification {
    
    if ([_resGroup isEntered]) {
        
        if (_isFailTest) {
            
            XCTFail(@"PubNub client removed the group");
        }
        _isEventNotificationDid = YES;
        [_resGroup leave];
    }
    _eventsCounter++;
}

// Remove group (fail)
- (void)clientChannelGroupRemovalDidFailWithErrorNotification:(NSNotification *)notification {
    
    if ([_resGroup isEntered]) {
        
        if (!_isFailTest) {
            
            XCTFail(@"PubNub client did fail to remove group");
        }
        _isEventNotificationFail = YES;
        [_resGroup leave];
    }
    _eventsCounter++;
}


// Remove namespace (did)
- (void)clientChannelGroupNamespaceRemovalCompleteNotification:(NSNotification *)notification {
    
    if ([_resGroup isEntered]) {
        
        if (_isFailTest) {
            
            XCTFail(@"PubNub client removed namespace");
        }
        _isEventNotificationDid = YES;
        [_resGroup leave];
    }
    _eventsCounter++;
}

// Remove namespace (fail)
- (void)clientChannelGroupNamespaceRemovalDidFailWithErrorNotification:(NSNotification *)notification {
    
    if ([_resGroup isEntered]) {
        
        if (!_isFailTest) {
            
            XCTFail(@"PubNub client did fail to remove namespace");
        }
        _isEventNotificationFail = YES;
        [_resGroup leave];
    }
    _eventsCounter++;
}


#pragma mark - Request

// Request challels (did)
- (void)clientChannelsForGroupRequestCompleteNotification:(NSNotification *)notification {
    
    if ([_resGroup isEntered]) {
        
        if (_isFailTest) {
            
            XCTFail(@"PubNub client requested channels from the group");
        }
        _isEventNotificationDid = YES;
        [_resGroup leave];
    }
    _eventsCounter++;
}

// Request channels (fail)
- (void)clientChannelsForGroupRequestDidFailWithErrorNotification:(NSNotification *)notification {
    
    if ([_resGroup isEntered]) {
        
        if (!_isFailTest) {
            
            XCTFail(@"PubNub client did fail to request channels from the group");
        }
        _isEventNotificationFail = YES;
        [_resGroup leave];
    }
    _eventsCounter++;
}

// Request groups (did)
- (void)clientChannelGroupsRequestCompleteNotification:(NSNotification *)notification {
    
    if ([_resGroup isEntered]) {
        
        if (_isFailTest) {
            
            XCTFail(@"PubNub client requested groups from the namespace");
        }
        _isEventNotificationDid = YES;
        [_resGroup leave];
    }
    _eventsCounter++;
}

// Request groups (fail)
- (void)clientChannelGroupsRequestDidFailWithErrorNotification:(NSNotification *)notification {
    
    if ([_resGroup isEntered]) {
        
        if (!_isFailTest) {
            
            XCTFail(@"PubNub client did fail to request groups from the namespace");
        }
        _isEventNotificationFail = YES;
        [_resGroup leave];
    }
    _eventsCounter++;
}

// Request namespaces (did)
- (void)clientChannelGroupNamespacesRequestCompleteNotification:(NSNotification *)notification {
    
    if ([_resGroup isEntered]) {
        
        if (_isFailTest) {
            
            XCTFail(@"PubNub client requested namespaces");
        }
        _isEventNotificationDid = YES;
        [_resGroup leave];
    }
    _eventsCounter++;
}

// Request namespaces (fail)
- (void)clientChannelGroupNamespacesRequestDidFailWithErrorNotification:(NSNotification *)notification {
    
    if (!_isFailTest) {
        
        XCTFail(@"PubNub client did fail to request namespaces");
    }
    if ([_resGroup isEntered]) {
        
        _isEventNotificationFail = YES;
        [_resGroup leave];
    }
    _eventsCounter++;
}


#pragma mark - Subscribe

// Subscribe on groups (did)
- (void)clientSubscriptionDidCompleteNotification:(NSNotification *)notification {
    
    if ([_resGroup isEntered]) {
        
        if (_isFailTest) {
            
            XCTFail(@"PubNub client subscribed on the group");
        }
        _isEventNotificationDid = YES;
        [_resGroup leave];
    }
    _eventsCounter++;
}

// Subscribe on groups (fail)
- (void)clientSubscriptionDidFailNotification:(NSNotification *)notification {
    
    if ([_resGroup isEntered]) {
        
        if (!_isFailTest) {
            
            XCTFail(@"PubNub client did fail to subscribe on the group");
        }
        _isEventNotificationFail = YES;
        [_resGroup leave];
    }
    _eventsCounter++;
}

// Unsubscribe from groups (did)
- (void)clientUnsubscriptionDidCompleteNotification:(NSNotification *)notification {
    
    if ([_resGroup isEntered]) {
        
        if (_isFailTest) {
            
            XCTFail(@"PubNub client unsubscribed from the group");
        }
        _isEventNotificationDid = YES;
        [_resGroup leave];
    }
    _eventsCounter++;
}

// Unsubscribe from groups (fail)
- (void)clientUnsubscriptionDidFailNotification:(NSNotification *)notification {
    
    if ([_resGroup isEntered]) {
        
        if (!_isFailTest) {
            
            XCTFail(@"PubNub client did fail to unsubscribe from the group");
        }
        _isEventNotificationFail = YES;
        [_resGroup leave];
    }
    _eventsCounter++;
}


#pragma mark - < Delegate methods >
#pragma mark - Add

// Add channels to group (did)
- (void)pubnubClient:(PubNub *)client didAddChannels:(NSArray *)channels toGroup:(PNChannelGroup *)group {
    
    if ([_resGroup isEntered]) {
        
        if (_isFailTest) {
            
            XCTFail(@"PubNub client added channels to the group");
        }
        _isEventDelegateDid = YES;
        [_resGroup leave];
    }
    _eventsCounter++;
}

// Add channels to group (fail)
- (void)pubnubClient:(PubNub *)client channelsAdditionToGroupDidFailWithError:(PNError *)error {
    
    if ([_resGroup isEntered]) {
        
        if (!_isFailTest) {
            
            XCTFail(@"PubNub client did fail to add channels to the group: %@", error);
        }
        _isEventDelegateFail = YES;
        [_resGroup leave];
    }
    _eventsCounter++;
}


#pragma mark - Remove

// Remove channels from group (did)
- (void)pubnubClient:(PubNub *)client didRemoveChannels:(NSArray *)channels fromGroup:(PNChannelGroup *)group {
    
    if ([_resGroup isEntered]) {
        
        if (_isFailTest) {
            
            XCTFail(@"PubNub client removed channels from the group");
        }
        _isEventDelegateDid = YES;
        [_resGroup leave];
    }
    _eventsCounter++;
}
// Remove channels from group (fail)
- (void)pubnubClient:(PubNub *)client channelsRemovalFromGroupDidFailWithError:(PNError *)error {
    
    if ([_resGroup isEntered]) {
        
        if (!_isFailTest) {
            
            XCTFail(@"PubNub client did fail to remove channels from the group: %@", error);
        }
        _isEventDelegateFail = YES;
        [_resGroup leave];
    }
    _eventsCounter++;
}

// Remove group (did)
- (void)pubnubClient:(PubNub *)client didRemoveChannelGroup:(PNChannelGroup *)group {
    
    if ([_resGroup isEntered]) {
        
        if (_isFailTest) {
            
            XCTFail(@"PubNub client removed the group");
        }
        _isEventDelegateDid = YES;
        [_resGroup leave];
    }
    _eventsCounter++;
}
// Remove group (fail)
- (void)pubnubClient:(PubNub *)client groupRemovalDidFailWithError:(PNError *)error {
    
    if ([_resGroup isEntered]) {
        
        if (!_isFailTest) {
            
            XCTFail(@"PubNub client did fail to remove the group: %@", error);
        }
        _isEventDelegateFail = YES;
        [_resGroup leave];
    }
    _eventsCounter++;
}

// Remove namespace (did)
- (void)pubnubClient:(PubNub *)client didRemoveNamespace:(NSString *)nspace {
    
    if ([_resGroup isEntered]) {
        
        if (_isFailTest) {
            
            XCTFail(@"PubNub client removed the namespace");
        }
        _isEventDelegateDid = YES;
        [_resGroup leave];
    }
    _eventsCounter++;
}

// Remove namespace (fail)
- (void)pubnubClient:(PubNub *)client namespaceRemovalDidFailWithError:(PNError *)error {
    
    if ([_resGroup isEntered]) {
        
        if (!_isFailTest) {
            
            XCTFail(@"PubNub client did fail to remove the namespace: %@", error);
        }
        _isEventDelegateFail = YES;
        [_resGroup leave];
    }
    _eventsCounter++;
}


#pragma mark - Request

// Request channels for group (did) ???
- (void)pubnubClient:(PubNub *)client didReceiveChannelsForGroup:(PNChannelGroup *)group {
    
    if ([_resGroup isEntered]) {
        
        if (_isFailTest) {
            
            XCTFail(@"PubNub client received channels for group");
        }
        _isEventDelegateDid = YES;
        [_resGroup leave];
    }
    _eventsCounter++;
}

// Request channels for group (fail)
- (void)pubnubClient:(PubNub *)client channelsForGroupRequestDidFailWithError:(PNError *)error {

    if ([_resGroup isEntered]) {
        
        if (!_isFailTest) {
            
            XCTFail(@"PubNub client did fail to receive channels for group: %@", error);
        }
        _isEventDelegateFail = YES;
        [_resGroup leave];
    }
    _eventsCounter++;
}

// Request groups (did)
- (void)pubnubClient:(PubNub *)client didReceiveChannelGroups:(NSArray *)groups forNamespace:(NSString *)nspace {
    
    if ([_resGroup isEntered]) {
        
        if (_isFailTest) {
            

            XCTFail(@"PubNub client received groups for namespace");
        }
        _isEventDelegateDid = YES;
        [_resGroup leave];
    }
    _eventsCounter++;
}
// Request groups (fail)
- (void)pubnubClient:(PubNub *)client channelGroupsRequestDidFailWithError:(PNError *)error {
    
    if ([_resGroup isEntered]) {
        
        if (!_isFailTest) {
            

            XCTFail(@"PubNub client did fail to resive groups for namespace: %@", error);
        }
        _isEventDelegateFail = YES;
        [_resGroup leave];
    }
    _eventsCounter++;
}

// Request namespaces (did)
- (void)pubnubClient:(PubNub *)client didReceiveChannelGroupNamespaces:(NSArray *)namespaces {
    
    if ([_resGroup isEntered]) {
        
        if (_isFailTest) {
            
            XCTFail(@"PubNub client received namespaces");
        }
        _isEventDelegateDid = YES;
        [_resGroup leave];
    }
    _eventsCounter++;
}

// Request namespaces (fail)
- (void)pubnubClient:(PubNub *)client channelGroupNamespacesRequestDidFailWithError:(PNError *)error {
    
    if ([_resGroup isEntered]) {
        
        if (!_isFailTest) {
            
            XCTFail(@"PubNub client did fail to resive namespaces: %@", error);
        }
        _isEventDelegateFail = YES;
        [_resGroup leave];
    }
    _eventsCounter++;
}


#pragma mark - Subscribe


// Subscribe on (did)
- (void)pubnubClient:(PubNub *)client didSubscribeOn:(NSArray *)channelObjects {
    
    if ([_resGroup isEntered]) {
        
        if (_isFailTest) {
            
            XCTFail(@"PubNub client subscribed on group");
        }
        _isEventDelegateDid = YES;
        [_resGroup leave];
    }
    _eventsCounter++;
}

// Subscribe on (fail)
- (void)pubnubClient:(PubNub *)client subscriptionDidFailWithError:(NSError *)error {
    
    if ([_resGroup isEntered]) {
        
        if (!_isFailTest) {
            
            XCTFail(@"Did fail to subscribe on group: %@", error);
        }
        _isEventDelegateFail = YES;
        [_resGroup leave];
    }
    _eventsCounter++;
}

// Unsubscribe from (did)
- (void)pubnubClient:(PubNub *)client didUnsubscribeFrom:(NSArray *)channelObjects {
    
    if ([_resGroup isEntered]) {
        
        if (_isFailTest) {
            
            XCTFail(@"PubNub client unsubscribed on group");
        }
        _isEventDelegateDid = YES;
        [_resGroup leave];
    }
    _eventsCounter++;
}

// Unsubscribe from (fail)
- (void)pubnubClient:(PubNub *)client unsubscriptionDidFailWithError:(PNError *)error {
    
    if ([_resGroup isEntered]) {
        
        if (!_isFailTest) {
            
            XCTFail(@"Did fail to unsubscribe from: %@", error);
        }
        _isEventDelegateFail = YES;
        [_resGroup leave];
    }
    _eventsCounter++;
}

@end


//[_resGroup enterWithWaitingNotificationDid:(int)amoungOfNotificationDid
//                          notificationFail:(int)amoungOfNotificationFail
//                               observerDid:(int)amoungOfObserverDid
//                              observerFail:(int)amoungOfObserverFail
//                                  blockDid:(int)amoungOfBlockDid
//                                 blockFail:(int)amoungOfBlockFail
//                               delegateDid:(int)amoungOfDelegateDid
//                              delegateFail:(int)amoungOfDelegateFail

//[_resGroup leaveNotificationDid];






//#define PNTestFail(weakSelf, ...) \
//({ typeof(weakSelf) strong strongSelf = weakSelf;\
//XCTPrimitiveFail(strongSelf, _VA_ARGS__);\
//})

//[_resGroup enterWithWaitingNotificationDid:1
//                          notificationFail:0
//                               observerDid:1
//                              observerFail:0
//                                  blockDid:1
//                                 blockFail:0
//                               delegateDid:1
//                              delegateFail:0];


//- (void)add1Channels:(NSArray *)channels toGroup:(PNChannelGroup *)group {
//
///*    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(clientGroupChannelsAdditionCompleteNotification:)
//                                                 name:kPNClientGroupChannelsAdditionCompleteNotification
//                                               object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(clientGroupChannelsAdditionDidFailWithErrorNotification:)
//                                                 name:kPNClientGroupChannelsAdditionDidFailWithErrorNotification
//                                               object:nil];
// */
//
////   PNBaseTestCase testCase = [[PNBaseTestCase new] expectNotifications:@[kPNClientAccessRightsAuditDidCompleteNotification, kPNClientAccessRightsAuditDidCompleteNotification]];
//
//    // Enter group
//    _resGroup = [GCDGroup group];
//
//
//
//    [_resGroup enterNotificationDid:1];
//    [_resGroup enterNotificationDid:0];
//
//    [_resGroup enterObserverDid:1];
//    [_resGroup enterObserverDid:0];
//
//    [_resGroup enterBlockDid:1];
//    [_resGroup enterBlockDid:0];
//
//    [_resGroup enterDelegateDid:1];
//    [_resGroup enterDelegateDid:0];
//
//    [_resGroup enterTimes:4];
//
//     // Execution of the method using observer
//    __typeof(self) __weak weakSelf = self;
//
//    [_testClient.observationCenter addChannelsAdditionToGroupObserver:self withCallbackBlock:^(PNChannelGroup *group, NSArray *channels, PNError *error) {
//
//        __typeof(weakSelf) __strong strongSelf = weakSelf;
//
//        if (error) {
//
//            [strongSelf->_resGroup leaveObserverFail];
//        } else {
//
//            [strongSelf->_resGroup leaveObserverDid];
//        }
//    }];
//
//    // Execution of the method using block
//    [_testClient addChannels:channels toGroup:group withCompletionHandlingBlock:^(PNChannelGroup *channelGroup, NSArray *channels, PNError *error) {
//
//        __typeof(weakSelf) __strong strongSelf = weakSelf;
//
//        if (error) {
//
//            [strongSelf->_resGroup leaveBlockFail];
//        } else {
//
//            [strongSelf->_resGroup leaveBlockDid];
//        }
//    }];
//
//    // Waiting group
//    if ([GCDWrapper isGCDGroup:_resGroup timeoutFiredValue:kTestTestTimout]) {
//
////        XCTFail(@"Events with error or uncorrect amound of events came %@", eventsError);
//    }
//
//    // Removing observers
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:kPNClientGroupChannelsAdditionCompleteNotification object:nil];
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:kPNClientGroupChannelsAdditionDidFailWithErrorNotification object:nil];
//    [_testClient.observationCenter removeChannelsAdditionToGroupObserver:self];
//
//    // Checking events, showing how the method was completed
//    if (![self checkCorrectReceivedEvents]) {
//
//        XCTFail(@"Events with error or uncorrect amound of events came");
//        @throw _stopTestException;
//    }
//
//    // Checking result
//    NSSet *specifiedChannels = [[NSSet alloc] initWithArray:channels];
////    NSSet *addedChannels = [[NSSet alloc] initWithArray:addedChannelsToGroup];
//
//    if (![specifiedChannels isSubsetOfSet:addedChannels]) {
//
//        XCTFail(@"Unrecognazed error, specified channels didn't added");
//        @throw _stopTestException;
//    }
//}

//- (void)test1ChannelGroupFunction {
//
//    _testClient = [PubNub clientWithConfiguration:[PNConfiguration defaultConfiguration] andDelegate:self];
//    [self connectClient];
//
//    // Add channels, also are added group and namespace
//    [self add1Channels:_testChannels toGroup:_testGroup];
//}


