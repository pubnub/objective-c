//
//  PAM_Test.m
//  UnitTests
//
//  Created by Sergey Kazanskiy on 3/27/15.
//  Copyright (c) 2015 PubNub Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "PNBaseTestCase.h"

static const NSUInteger kOnPeriod = 5;

@interface PAMSimpleTest : XCTestCase  <PNDelegate>

@end

@implementation PAMSimpleTest {
    
    GCDGroup *_resGroup;
    PubNub *_testClient;
    PNChannel *_testChannel;
    PNChannelGroup *_testGroup;
    PNChannelGroupNamespace *_testNameSpace;
    PNAccessRightsInformation *_accessRightsForApplication;
    
    BOOL _isEventNotificationWill;
    BOOL _isEventNotificationDid;
    BOOL _isEventNotificationFail;
    
    BOOL _isEventObserverDid;
    BOOL _isEventObserverFail;
    
    BOOL _isEventBlockDid;
    BOOL _isEventBlockFail;

    BOOL _isEventDelegateWill;
    BOOL _isEventDelegateDid;
    BOOL _isEventDelegateFail;
    
    NSException *_stopTestException;
}

- (void)setUp {
    
    [super setUp];
    [PubNub disconnect];
    
    _testChannel = [PNChannel channelWithName:@"testChannel"];
    _testGroup = [PNChannelGroup channelGroupWithName:@"testGroup" inNamespace:@"testNameSpace"];
    _testNameSpace = [PNChannelGroupNamespace namespaceWithName:@"testNameSpace"];
    _stopTestException = [NSException exceptionWithName:@"StopTestException"
                                             reason:nil
                                           userInfo:nil];
}

- (void)tearDown {
    
    _testClient = nil;
    _testChannel = nil;
    _testGroup = nil;
    _testNameSpace = nil;
    _stopTestException = nil;
    
    [PubNub disconnect];

    [super tearDown];
}


#pragma mark - Tests

- (void)testApplicationAccessRights {
    
    _testClient = [PubNub clientWithConfiguration:[PNConfiguration accessManagerTestConfiguration] andDelegate:self];
    [self connectClient];
    
    [self changeApplicationAccessRightsTo:PNReadAccessRight onPeriod:kOnPeriod];
    XCTAssertTrue([self auditAccessRightsForApplication].rights == PNReadAccessRight);
    
    [self changeApplicationAccessRightsTo:PNWriteAccessRight onPeriod:kOnPeriod];
    XCTAssertTrue([self auditAccessRightsForApplication].rights == PNWriteAccessRight);
    
    [self changeApplicationAccessRightsTo:PNAllAccessRights onPeriod:kOnPeriod];
    XCTAssertTrue([self auditAccessRightsForApplication].rights == PNAllAccessRights);
    
    [self changeApplicationAccessRightsTo:PNNoAccessRights onPeriod:kOnPeriod];
    XCTAssertTrue([self auditAccessRightsForApplication].rights == PNNoAccessRights);
    
    [self disconnectClient];
}

- (void)testChannelAccessRights {
    
    _testClient = [PubNub clientWithConfiguration:[PNConfiguration accessManagerTestConfiguration] andDelegate:self];
    [self connectClient];
    
    NSArray *channels = @[_testChannel];
    
    [self changeAccessRightsFor:channels accessRights:PNReadAccessRight onPeriod:kOnPeriod];
    XCTAssertTrue([self auditAccessRightsFor:channels].rights == PNReadAccessRight);
    
    [self changeAccessRightsFor:channels accessRights:PNWriteAccessRight onPeriod:kOnPeriod];
    XCTAssertTrue([self auditAccessRightsFor:channels].rights == PNWriteAccessRight);
    
    [self changeAccessRightsFor:channels accessRights:PNAllAccessRights onPeriod:kOnPeriod];
    XCTAssertTrue([self auditAccessRightsFor:channels].rights == PNAllAccessRights);
    
    [self changeAccessRightsFor:channels accessRights:PNNoAccessRights onPeriod:kOnPeriod];
    XCTAssertTrue([self auditAccessRightsFor:channels].rights == PNNoAccessRights);
    
    [self disconnectClient];
}

- (void)testGroupAccessRights {
    
    _testClient = [PubNub clientWithConfiguration:[PNConfiguration accessManagerTestConfiguration] andDelegate:self];
    [self connectClient];
    
    NSArray *groups = @[_testGroup];

    [self changeAccessRightsFor:groups accessRights:PNReadAccessRight onPeriod:kOnPeriod];
    XCTAssertTrue([self auditAccessRightsFor:groups].rights == PNReadAccessRight);
    
    [self changeAccessRightsFor:groups accessRights:PNManagementRight onPeriod:kOnPeriod];
    XCTAssertTrue([self auditAccessRightsFor:groups].rights == PNManagementRight);
    
    [self changeAccessRightsFor:groups accessRights:(PNReadAccessRight | PNManagementRight) onPeriod:kOnPeriod];
    XCTAssertTrue([self auditAccessRightsFor:groups].rights == (PNReadAccessRight | PNManagementRight));
    
    [self changeAccessRightsFor:groups accessRights:PNNoAccessRights onPeriod:kOnPeriod];
    XCTAssertTrue([self auditAccessRightsFor:groups].rights == PNNoAccessRights);
    
    [self disconnectClient];
}

- (void)testNamespaceAccessRights {
    
    _testClient = [PubNub clientWithConfiguration:[PNConfiguration accessManagerTestConfiguration] andDelegate:self];
    [self connectClient];
    
    NSArray *namespaces = @[_testNameSpace];
    
    [self changeAccessRightsFor:namespaces accessRights:PNReadAccessRight onPeriod:kOnPeriod];
    XCTAssertTrue([self auditAccessRightsFor:namespaces].rights == PNReadAccessRight);
    
    [self changeAccessRightsFor:namespaces accessRights:PNManagementRight onPeriod:kOnPeriod];
    XCTAssertTrue([self auditAccessRightsFor:namespaces].rights == PNManagementRight);
    
    [self changeAccessRightsFor:namespaces accessRights:(PNReadAccessRight | PNManagementRight) onPeriod:kOnPeriod];
    XCTAssertTrue([self auditAccessRightsFor:namespaces].rights == (PNReadAccessRight | PNManagementRight));
    
    [self changeAccessRightsFor:namespaces accessRights:PNNoAccessRights onPeriod:kOnPeriod];
    XCTAssertTrue([self auditAccessRightsFor:namespaces].rights == PNNoAccessRights);
    
    [self disconnectClient];
}


#pragma mark - Private methodes

- (void)connectClient {
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(clientWillConnectToOriginNotification:)
                                                 name:kPNClientDidConnectToOriginNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(clientDidConnectToOriginNotification:)
                                                 name:kPNClientWillConnectToOriginNotification
                                               object:nil];
    _isEventNotificationWill = NO;
    _isEventNotificationDid = NO;
    
    _isEventObserverDid = NO;
    _isEventObserverFail = NO;

    _isEventBlockDid = NO;
    _isEventBlockFail = NO;
    
    _isEventDelegateWill = NO;
    _isEventDelegateDid = NO;
    _isEventDelegateFail = NO;
    
    _resGroup = [GCDGroup group];
    [_resGroup enterTimes:6];
    
    // Execution of the method using observer
    
    __typeof(self) __weak weakSelf = self;
    [_testClient.observationCenter addClientConnectionStateObserver:self
                                                  withCallbackBlock:^(NSString *origin, BOOL isConnected, PNError *error) {
                                                      
                                                      __typeof(weakSelf) __strong strongSelf = weakSelf;
                                                      if (error) {

                                                          _XCTPrimitiveFail(strongSelf, @"Error occurs during connection: %@", error);
                                                          strongSelf ->_isEventObserverFail = YES;
                                                      } else if (!isConnected) {
                                                          
                                                           _XCTPrimitiveFail(strongSelf, @"Looks like there is no internet connection or PubNub client doesn't have enough time");
                                                          strongSelf ->_isEventObserverFail = YES;
                                                      }
                                                      
                                                       strongSelf ->_isEventObserverDid = YES;
                                                       [strongSelf ->_resGroup leave];
                                                  }];
    
    // Execution of the method using block
    [_testClient connectWithSuccessBlock:^(NSString *origin) {

        _isEventBlockDid = YES;
        
        [_resGroup leave];
    } errorBlock:^(PNError *connectionError) {
        
        if (connectionError == nil) {
            
            XCTFail(@"Looks like there is no internet connection or PubNub client doesn't have enough time");
            _isEventBlockFail = YES;
        } else {
            
            XCTFail(@"Error occurs during connection: %@", connectionError);
            _isEventBlockFail = YES;
        }
        
        _isEventBlockDid = YES;
        [_resGroup leave];
    }];
    
    // Waiting group
    if ([GCDWrapper isGCDGroup:_resGroup timeoutFiredValue:kTestTestTimout]) {
        
        XCTAssertTrue(_isEventNotificationWill, @"Timeout fired, notification 'willConnect' wasn't called");
        XCTAssertTrue(_isEventNotificationDid, @"Timeout fired, notification 'didConnect' wasn't called");
        
        XCTAssertTrue(_isEventObserverDid, @"Timeout fired, observer 'addClientConnection' wasn't called");
        XCTAssertTrue(_isEventBlockDid, @"Timeout fired, method 'connectWithSuccessBlock' wasn't called");
        
        XCTAssertTrue(_isEventDelegateWill, @"Timeout fired, delegate 'willConnect' wasn't called");
        XCTAssertTrue(_isEventDelegateDid, @"Timeout fired, delegate 'didConnect' wasn't called");

        _resGroup = nil;
        @throw _stopTestException;
    }
    
    _resGroup = nil;
    
    // Removing observers
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kPNClientWillConnectToOriginNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kPNClientDidConnectToOriginNotification object:nil];
    [_testClient.observationCenter removeClientConnectionStateObserver:self];
    
    // Checking events which was finished with error
    if (_isEventBlockFail || _isEventObserverFail || _isEventDelegateFail) {
        @throw _stopTestException;
    }
    
    // Checking result
    if (![_testClient  isConnected]) {
        
        XCTFail(@"Client still isn't connected to PubNub");
        @throw _stopTestException;
    }
}


- (void)disconnectClient {
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(clientDidDisconnectFromNotification:)
                                                 name:kPNClientDidDisconnectFromOriginNotification
                                               object:nil];
    _isEventNotificationDid = NO;
    _isEventDelegateDid = NO;
    _isEventDelegateFail = NO;
    
    _resGroup = [GCDGroup group];
    [_resGroup enterTimes:2];
    
    // Execution of the method using delegate
    [_testClient disconnect];
    
    // Waiting group
    if ([GCDWrapper isGCDGroup:_resGroup timeoutFiredValue:kTestTestTimout]) {
        
        XCTAssertTrue(_isEventNotificationDid, @"Timeout fired, notification 'didDisconnect' not called");
        XCTAssertTrue(_isEventDelegateDid, @"Timeout fired, delegate 'didDisconnect' not called");
        
        _resGroup = nil;
        @throw _stopTestException;
    }

    _resGroup = nil;
    
    // Removing observer
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kPNClientDidDisconnectFromOriginNotification object:nil];
    
    // Checking event which was finished with error
    if (_isEventDelegateFail) {
        @throw _stopTestException;
    }
    
    // Checking result
    if ([_testClient  isConnected]) {
        
        XCTFail(@"Client is still connected to PubNub");
        @throw _stopTestException;
    }
}

- (void)changeApplicationAccessRightsTo:(PNAccessRights)accessRights onPeriod:(NSInteger)accessPeriodDuration {

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(clientDidChangeAccessRightsNotification:)
                                                 name:kPNClientAccessRightsChangeDidCompleteNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(clientDidFailChangeAccessRightsNotification:)
                                                 name:kPNClientAccessRightsChangeDidFailNotification
                                               object:nil];
    _isEventNotificationDid = NO;
    _isEventNotificationFail = NO;
    
    _isEventObserverDid = NO;
    _isEventObserverFail = NO;
    
    _isEventBlockDid = NO;
    _isEventBlockFail = NO;
    
    _isEventDelegateDid = NO;
    _isEventDelegateFail = NO;
    
    _resGroup = [GCDGroup group];
    [_resGroup enterTimes:4];
    
    // Execution of the method using observer
    __typeof(self) __weak weakSelf = self;
    [_testClient.observationCenter addAccessRightsChangeObserver:self
                                                       withBlock:^(PNAccessRightsCollection *collection, PNError *error) {
                                                           
                                                           __typeof(weakSelf) __strong strongSelf = weakSelf;
                                                           if (error) {
                                                               
                                                               _XCTPrimitiveFail(strongSelf, @"Did fail to change access rights: %@", error);
                                                               strongSelf ->_isEventObserverFail = YES;
                                                           }
                                                           
                                                           strongSelf ->_isEventObserverDid = YES;
                                                           [strongSelf ->_resGroup leave];
    }];

    
    // Execution of the method using block
    __block PNAccessRightsCollection *accessRightsCollection = nil;
    
    [_testClient changeApplicationAccessRightsTo:accessRights
                                        onPeriod:accessPeriodDuration
                      andCompletionHandlingBlock:^(PNAccessRightsCollection *collection, PNError *error) {
                     
                     if (error) {
                         
                         XCTFail(@"Did fail to change access rights: %@", error);
                         _isEventBlockFail = YES;
                     } else {
                         
                         accessRightsCollection = collection;
                     }
                     
                     _isEventBlockDid = YES;
                     [_resGroup leave];
                 }];
    
    // Waiting group
    if ([GCDWrapper isGCDGroup:_resGroup timeoutFiredValue:kTestTestTimout]) {
        
        XCTAssertTrue(_isEventNotificationDid, @"Timeout fired, notification 'didChangeAccessRights' wasn't called");
        XCTAssertTrue(_isEventObserverDid, @"Timeout fired, observer 'addAccessRightsChange' wasn't called");
        XCTAssertTrue(_isEventBlockDid, @"Timeout fired, method 'changeAccessRightsWithBlock' wasn't called");
        XCTAssertTrue(_isEventDelegateDid, @"Timeout fired, delegate 'didChangeAccessRights' wasn't called");
        
        _resGroup = nil;
        @throw _stopTestException;
    }
    
    _resGroup = nil;
    
    // Removing observers
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kPNClientAccessRightsChangeDidCompleteNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kPNClientAccessRightsChangeDidFailNotification object:nil];
    [_testClient.observationCenter removeAccessRightsObserver:self];
    
    // Checking events which was finished with error
    if (_isEventNotificationFail || _isEventObserverFail || _isEventBlockFail || _isEventDelegateFail) {
        @throw _stopTestException;
    }
    
    // Checking result
    PNAccessRightsInformation *accessRightsInformation = [accessRightsCollection accessRightsInformationForApplication];

    if (accessRightsInformation.rights != (PNAccessRights)accessRights) {
        
        XCTFail(@"Access rights not true");
        @throw _stopTestException;
    }
}

- (PNAccessRightsInformation *)auditAccessRightsForApplication {
    
#warning Should be fixed on server-side. 5 seconds between give access rights and audit.
    [GCDWrapper sleepForSeconds:5];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(clientDidAuditAccessRightsNotification:)
                                                 name:kPNClientAccessRightsAuditDidCompleteNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(clientDidFailAuditAccessRightsNotification:)
                                                 name:kPNClientAccessRightsAuditDidFailNotification
                                               object:nil];
    _isEventNotificationDid = NO;
    _isEventNotificationFail = NO;
    
    _isEventObserverDid = NO;
    _isEventObserverFail = NO;
    
    _isEventBlockDid = NO;
    _isEventBlockFail = NO;
    
    _isEventDelegateDid = NO;
    _isEventDelegateFail = NO;
    
    _resGroup = [GCDGroup group];
    [_resGroup enterTimes:4];
    
    // Execution of the method using observer
    __typeof(self) __weak weakSelf = self;
    [_testClient.observationCenter addAccessRightsAuditObserver:self withBlock:^(PNAccessRightsCollection *accessRightsCollection, PNError *error) {
        
                                                            __typeof(weakSelf) __strong strongSelf = weakSelf;
                                                           if (error) {
                                                               
                                                               _XCTPrimitiveFail(strongSelf, @"Did fail to audit access rights: %@", error);
                                                               strongSelf -> _isEventObserverFail = YES;
                                                           }
                                                           
                                                           strongSelf -> _isEventObserverDid = YES;
                                                           [strongSelf -> _resGroup leave];
                                                       }];
    
    
    // Execution of the method using block
    __block PNAccessRightsCollection *_accessRightsCollection = nil;

    [_testClient auditAccessRightsForApplicationWithCompletionHandlingBlock:^(PNAccessRightsCollection *accessRightsCollection, PNError *error) {
        
                          if (error) {
                              
                              XCTFail(@"Did fail to change access rights: %@", error);
                              _isEventBlockFail = YES;
                          } else {
                              
                              _accessRightsCollection = accessRightsCollection;
                          }
                          
                          _isEventBlockDid = YES;
                          [_resGroup leave];
                      }];
    
    // Waiting group
    if ([GCDWrapper isGCDGroup:_resGroup timeoutFiredValue:kTestTestTimout]) {
        
        XCTAssertTrue(_isEventNotificationDid, @"Timeout fired, notification 'didAuditAccessRights' wasn't called");
        XCTAssertTrue(_isEventObserverDid, @"Timeout fired, observer 'addAccessRightsAudit' wasn't called");
        XCTAssertTrue(_isEventBlockDid, @"Timeout fired, method 'AuditAccessRightsWithBlock' wasn't called");
        XCTAssertTrue(_isEventDelegateDid, @"Timeout fired, delegate 'didAuditAccessRights' wasn't called");
        
        _resGroup = nil;
        @throw _stopTestException;
    }
    
    _resGroup = nil;
    
    // Removing observers
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kPNClientAccessRightsAuditDidCompleteNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kPNClientAccessRightsAuditDidFailNotification object:nil];
    [_testClient.observationCenter removeAccessRightsAuditObserver:self];
    
    // Checking events which was finished with error
    if (_isEventNotificationFail || _isEventObserverFail || _isEventBlockFail || _isEventDelegateFail) {
        @throw _stopTestException;
    }
    
    // Checking result
    PNAccessRightsInformation *accessRightsInformation = [_accessRightsCollection accessRightsInformationForApplication];
    
    if (accessRightsInformation == nil) {
        
        XCTFail(@"There no access rights information");
        @throw _stopTestException;
    }
    
    return accessRightsInformation;
}

- (void)changeAccessRightsFor:(NSArray *)channelObjects
                 accessRights:(PNAccessRights)accessRights
                     onPeriod:(NSInteger)accessPeriodDuration {
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(clientDidChangeAccessRightsNotification:)
                                                 name:kPNClientAccessRightsChangeDidCompleteNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(clientDidFailChangeAccessRightsNotification:)
                                                 name:kPNClientAccessRightsChangeDidFailNotification
                                               object:nil];
    _isEventNotificationDid = NO;
    _isEventNotificationFail = NO;
    
    _isEventObserverDid = NO;
    _isEventObserverFail = NO;
    
    _isEventBlockDid = NO;
    _isEventBlockFail = NO;
    
    _isEventDelegateDid = NO;
    _isEventDelegateFail = NO;
    
    _resGroup = [GCDGroup group];
    [_resGroup enterTimes:4];
    
    // Execution of the method using observer
    __typeof(self) __weak weakSelf = self;
    [_testClient.observationCenter addAccessRightsChangeObserver:self
                                                       withBlock:^(PNAccessRightsCollection *collection, PNError *error) {
                                                           
                                                           __typeof(weakSelf) __strong strongSelf = weakSelf;
                                                           if (error) {
                                                               
                                                               _XCTPrimitiveFail(strongSelf, @"Did fail to change access rights: %@", error);
                                                               strongSelf -> _isEventObserverFail = YES;
                                                           }
                                                           
                                                           strongSelf -> _isEventObserverDid = YES;
                                                           [strongSelf -> _resGroup leave];
                                                       }];
    
    
    // Execution of the method using block
    __block PNAccessRightsCollection *_accessRightsCollection = nil;
    
    [_testClient changeAccessRightsFor:channelObjects to:accessRights onPeriod:accessPeriodDuration withCompletionHandlingBlock:^(PNAccessRightsCollection *accessRightsCollection, PNError *error) {
        
                          if (error) {
                              
                              XCTFail(@"Did fail to change access rights: %@", error);
                              _isEventBlockFail = YES;
                          } else {
                              
                              _accessRightsCollection = accessRightsCollection;
                          }
                          
                          _isEventBlockDid = YES;
                          [_resGroup leave];
                      }];
    
    // Waiting group
    if ([GCDWrapper isGCDGroup:_resGroup timeoutFiredValue:kTestTestTimout]) {
        
        XCTAssertTrue(_isEventNotificationDid, @"Timeout fired, notification 'didChangeAccessRights' wasn't called");
        XCTAssertTrue(_isEventObserverDid, @"Timeout fired, observer 'addAccessRightsChange' wasn't called");
        XCTAssertTrue(_isEventBlockDid, @"Timeout fired, method 'changeAccessRightsWithBlock' wasn't called");
        XCTAssertTrue(_isEventDelegateDid, @"Timeout fired, delegate 'didChangeAccessRights' wasn't called");
        
        _resGroup = nil;
        @throw _stopTestException;
    }
    
    _resGroup = nil;
    
    // Removing observers
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kPNClientAccessRightsChangeDidCompleteNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kPNClientAccessRightsChangeDidFailNotification object:nil];
    [_testClient.observationCenter removeAccessRightsObserver:self];
    
    // Checking events which was finished with error
    if (_isEventNotificationFail || _isEventObserverFail || _isEventBlockFail || _isEventDelegateFail) {
        @throw _stopTestException;
    }
    
    // Checking result
    PNAccessRightsInformation *accessRightsInformation = [_accessRightsCollection accessRightsInformationFor:channelObjects[0]];
    
    if (accessRightsInformation.rights != (PNAccessRights)accessRights) {
        
        XCTFail(@"Access rights not true");
        @throw _stopTestException;
    }
}

- (PNAccessRightsInformation *)auditAccessRightsFor:(NSArray *)channelObjects {
    
#warning Should be fixed on server-side. 5 seconds between give access rights and audit.    
    [GCDWrapper sleepForSeconds:5];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(clientDidAuditAccessRightsNotification:)
                                                 name:kPNClientAccessRightsAuditDidCompleteNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(clientDidFailAuditAccessRightsNotification:)
                                                 name:kPNClientAccessRightsAuditDidFailNotification
                                               object:nil];
    _isEventNotificationDid = NO;
    _isEventNotificationFail = NO;
    
    _isEventObserverDid = NO;
    _isEventObserverFail = NO;
    
    _isEventBlockDid = NO;
    _isEventBlockFail = NO;
    
    _isEventDelegateDid = NO;
    _isEventDelegateFail = NO;
    
    _resGroup = [GCDGroup group];
    [_resGroup enterTimes:4];
    
    // Execution of the method using observer
    __typeof(self) __weak weakSelf = self;
    
    [_testClient.observationCenter addAccessRightsAuditObserver:self withBlock:^(PNAccessRightsCollection *accessRightsCollection, PNError *error) {
        
        __typeof(weakSelf) __strong strongSelf = weakSelf;
        if (error) {
            
            _XCTPrimitiveFail(strongSelf, @"Did fail to audit access rights: %@", error);
            strongSelf -> _isEventObserverFail = YES;
        }
        
        strongSelf -> _isEventObserverDid = YES;
        [strongSelf -> _resGroup leave];
    }];
    
    
    // Execution of the method using block
    __block PNAccessRightsCollection *_accessRightsCollection = nil;
    
    [_testClient auditAccessRightsFor:channelObjects withCompletionHandlingBlock:^(PNAccessRightsCollection *accessRightsCollection, PNError *error) {
        
        if (error) {
            
            XCTFail(@"Did fail to change access rights: %@", error);
            _isEventBlockFail = YES;
        } else {
            
            _accessRightsCollection = accessRightsCollection;
        }
        
        _isEventBlockDid = YES;
        [_resGroup leave];
    }];
    
    // Waiting group
    if ([GCDWrapper isGCDGroup:_resGroup timeoutFiredValue:kTestTestTimout]) {
        
        XCTAssertTrue(_isEventNotificationDid, @"Timeout fired, notification 'didAuditAccessRights' wasn't called");
        XCTAssertTrue(_isEventObserverDid, @"Timeout fired, observer 'addAccessRightsAudit' wasn't called");
        XCTAssertTrue(_isEventBlockDid, @"Timeout fired, method 'AuditAccessRightsWithBlock' wasn't called");
        XCTAssertTrue(_isEventDelegateDid, @"Timeout fired, delegate 'didAuditAccessRights' wasn't called");
        
        _resGroup = nil;
        @throw _stopTestException;
    }
    
    _resGroup = nil;
    
    // Removing observers
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kPNClientAccessRightsAuditDidCompleteNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kPNClientAccessRightsAuditDidFailNotification object:nil];
    [_testClient.observationCenter removeAccessRightsAuditObserver:self];
    
    // Checking events which was finished with error
    if (_isEventNotificationFail || _isEventObserverFail || _isEventBlockFail || _isEventDelegateFail) {
        @throw _stopTestException;
    }
    
    // Checking result
    PNAccessRightsInformation *accessRightsInformation = [_accessRightsCollection accessRightsInformationFor:channelObjects[0]];
    
    if (accessRightsInformation == nil) {
        
        XCTFail(@"There no access rights information");
        @throw _stopTestException;
    }
    
    return accessRightsInformation;
}


#pragma mark - PubNub Notificatons

// Connect
- (void)clientWillConnectToOriginNotification:(NSNotification *)notification {
    
    if (_resGroup) {
        
        _isEventNotificationWill = YES;
        [_resGroup leave];
    }
}

- (void)clientDidConnectToOriginNotification:(NSNotification *)notification {
    
    if (_resGroup) {
        
        _isEventNotificationDid = YES;
        [_resGroup leave];
    }
}

// Disconnect
- (void)clientDidDisconnectFromNotification:(NSNotification *)notification {
    
    if (_resGroup) {
        
        _isEventNotificationDid = YES;
        [_resGroup leave];
    }
}

// Change access rights
- (void)clientDidChangeAccessRightsNotification:(NSNotification *)notification {
    
    if (_resGroup) {
        
        _isEventNotificationDid = YES;
        [_resGroup leave];
    }
}

- (void)clientDidFailChangeAccessRightsNotification:(NSNotification *)notification {
    
    if (_resGroup) {
        
        XCTFail(@"Notification: did fail to change access rights");
        _isEventNotificationFail = YES;
        [_resGroup leave];
    }
}

// Audit access rights
- (void)clientDidAuditAccessRightsNotification:(NSNotification *)notification {
    
    if (_resGroup) {
        
        _isEventNotificationDid = YES;
        [_resGroup leave];
    }
 }

- (void)clientDidFailAuditAccessRightsNotification:(NSNotification *)notification {
    
    if (_resGroup) {
        
        XCTFail(@"Notification: did fail to audit access rights");
        _isEventNotificationFail = YES;
        [_resGroup leave];
    }
}


#pragma mark - PubNub Delegates

// Connect
- (void)pubnubClient:(PubNub *)client willConnectToOrigin:(NSString *)origin {
    
    if (_resGroup) {
        
        _isEventDelegateWill = YES;
        [_resGroup leave];
    }
}

- (void)pubnubClient:(PubNub *)client didConnectToOrigin:(NSString *)origin {

    if (_resGroup) {
        
        _isEventDelegateDid = YES;
        [_resGroup leave];
    }
}

- (void)pubnubClient:(PubNub *)client connectionDidFailWithError:(PNError *)error {
    
    if (_resGroup) {
        
        XCTFail(@"Delegate: connection did fail with error: %@", error);
        _isEventDelegateFail = YES;
        [_resGroup leave];
    }
}

// Disconnect
- (void)pubnubClient:(PubNub *)client didDisconnectFromOrigin:(NSString *)origin {
    
    if (_resGroup) {
        
        _isEventDelegateDid = YES;
        [_resGroup leave];
    }
}

- (void)pubnubClient:(PubNub *)client didDisconnectFromOrigin:(NSString *)origin withError:(PNError *)error {
    
    if (_resGroup) {
        
        XCTFail(@"Delegate: disconnection did fail with error: %@", error);
        _isEventDelegateFail = YES;
        [_resGroup leave];
    }
}

// Change access rights
- (void)pubnubClient:(PubNub *)client didChangeAccessRights:(PNAccessRightsCollection *)accessRightsCollection {
    
    if (_resGroup) {
        
        _isEventDelegateDid = YES;
        [_resGroup leave];
    }
}

- (void)pubnubClient:(PubNub *)client accessRightsChangeDidFailWithError:(PNError *)error {
    
    if (_resGroup) {
        
        XCTFail(@"Delegate: did fail to change access rights with error: %@", error);
        _isEventDelegateFail = YES;
        [_resGroup leave];
    }
}

// Audit access rights
- (void)pubnubClient:(PubNub *)client didAuditAccessRights:(PNAccessRightsCollection *)accessRightsCollection {
    
    if (_resGroup) {
        
        _isEventDelegateDid = YES;
        [_resGroup leave];
    }
}

- (void)pubnubClient:(PubNub *)client accessRightsAuditDidFailWithError:(PNError *)error {
    
    if (_resGroup) {
        
        XCTFail(@"Delegate: did fail to pull out access rights information with error: %@", error);
        _isEventDelegateFail = YES;
        [_resGroup leave];
    }
}

@end

