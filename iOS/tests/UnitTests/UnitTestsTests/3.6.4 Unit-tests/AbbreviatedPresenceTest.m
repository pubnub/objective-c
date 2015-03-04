//
//  AbbreviatedPresenceTest.m
//  pubnub
//
//  Created by Valentin Tuller on 10/23/13.
//  Copyright (c) 2013 PubNub Inc. All rights reserved.
//
/* Test descripition:
 This test should work only when Presence and Access Manager features
 enabled for developer account.
 
 It should check following scenario:
  - connect to pubsub; For configuration we setup 20 sec as a presence heartbeat timeout;
  - grant all access rights;
  - subscribe to channes with observing events
  - check that we receive two Presence events: join and timeout
 */

// TODO: it should be moved to Functional test suite



#import <XCTest/XCTest.h>
#import "PNBaseRequest.h"
#import "PNBaseRequest+Protected.h"

#import "PubNub.h"
#import "PubNub+Protected.h"
#import "PNConfiguration.h"
#import "PNWriteBuffer.h"
#import "PNConstants.h"
#import "PNClient.h"
#import "PNPresenceEvent.h"
#import "GCDWrapper.h"


static NSString *kOriginPath = @"pubsub.pubnub.com";

static NSString * const kPNPublishKey = @"pub-c-c37b4f44-6eab-4827-9059-3b1c9a4085f6";
static NSString * const kPNSubscriptionKey = @"sub-c-fb5d8de4-3735-11e4-8736-02ee2ddab7fe";
static NSString * const kPNSecretKey = @"sec-c-NDA1YjYyYjktZTA0NS00YmIzLWJmYjQtZjI4MGZmOGY0MzIw";
static NSString * const kPNCipherKey = nil;
static NSString * const kPNAuthorizationKey = nil;


@interface AbbreviatedPresenceTest : XCTestCase <PNDelegate> {
	GCDGroup *_resGroup;
    PNConfiguration *_configuration;
    PNConfiguration *_configuration1;
}

@end

@implementation AbbreviatedPresenceTest

- (void)setUp {
    
    [super setUp];
    [PubNub disconnect];
    [PubNub setDelegate:self];
    
    _configuration = [PNConfiguration defaultTestConfiguration];
    _configuration1 = [PNConfiguration accessManagerTestConfiguration];
    _configuration1.authorizationKey = @"testios19740905";
    
	[[NSNotificationCenter defaultCenter] addObserver:self
						   selector:@selector(handleClientDidReceivePresenceEvent:)
							   name:kPNClientDidReceivePresenceEventNotification
							 object:nil];
}

- (void)tearDown {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    _resGroup = nil;
    [PubNub disconnect];
    
    [super tearDown];
}


#pragma mark - < Scenarios >

- (void)testScenario {
    
    // Connect client
    PubNub *pubNubClient1;
    XCTAssertTrue([self connectClient:&pubNubClient1 withConfiguration:_configuration1]);

    // Grant on application and group
    XCTAssertTrue(([self grantAccessRightsApplicationforClient:pubNubClient1]));
    XCTAssertTrue(([self grantAccessRightsClient:pubNubClient1 forGroup:@"g1" inNamespace:@"s1"]));
    
    // Audit access rights for application
    PNAccessRightsCollection *collection = [self auditAccessRightsForApplication:pubNubClient1];
    XCTAssertEqual(collection.accessRightsInformationForAllChannels.count, 0);
    
    // Test add, request, remove for group, namespase
    XCTAssertTrue(([self addClient:pubNubClient1 channels:@[@"iostest1",@"iostest2",@"iostest3"] toGroup:@"g1" inNamespace:@"s1"]));
    
    XCTAssertEqual([self requestChannelsClient:pubNubClient1 forGroup:@"g1" inNamespace:@"s1"].count, 3);
    
    XCTAssertTrue(([self removeClient:pubNubClient1 channels:@[@"iostest1",@"iostest2",@"iostest3"] fromGroup:@"g1" inNamespace:@"s1"]));
    XCTAssertEqual([self requestChannelsClient:pubNubClient1 forGroup:@"g1" inNamespace:@"s1"].count, 0);
    
    XCTAssertTrue(([self removeClient:pubNubClient1 group:@"g1" fromNamespace:@"s1"]));
    XCTAssertEqual([self requestGroupsClient:pubNubClient1 forNamespace:@"s1"].count, 0);

    XCTAssertTrue(([self removeClient:pubNubClient1 namespace:@"s1"]));
    XCTAssertEqual([self requestGroupsClient:pubNubClient1 forNamespace:@"s1"].count, 0);
    

    // Subscribe to channels
    XCTAssertTrue(([self subscribeClient:pubNubClient1 toChannelObjects:@[@"iostest1",@"iostest2"] withClientState: nil]));
    XCTAssertTrue(([self subscribeClient:pubNubClient1 toChannelObjects:@[@"iostest1"] withClientState: nil]));
    
    XCTAssertEqual([pubNubClient1 subscribedObjectsList].count, 2);
    NSLog(@"!!! %@", [pubNubClient1 subscribedObjectsList]);
    XCTAssertTrue(([self isSubscribedClient:pubNubClient1 onChannel:@"iostest1"]));
    
    // Subscribe to group
    XCTAssertTrue(([self addClient:pubNubClient1 channels:@[@"iostest1"] toGroup:@"g1" inNamespace:@"s1"]));
    XCTAssertFalse(([self isSubscribedClient:pubNubClient1 onGroup:@"g1" inNamespace:@"s1"]));
    
    XCTAssertTrue(([self subscribeClient:pubNubClient1 toGroup:@"g1" inNamespace:@"s1"]));
    XCTAssertTrue(([self isSubscribedClient:pubNubClient1 onGroup:@"g1" inNamespace:@"s1"]));
    
    
    // Unsubscribe from group
    XCTAssertTrue(([self unsubscribeClient:pubNubClient1 fromGroup:@"g1" inNamespace:@"s1"]));
     XCTAssertFalse(([self isSubscribedClient:pubNubClient1 onGroup:@"g1" inNamespace:@"s1"]));
    
    // Unsubscribe from channels
    XCTAssertTrue(([self unsubscribeClient:pubNubClient1 fromChannelObjects:@[@"iostest1",@"iostest2"]]));
    XCTAssertTrue(([self unsubscribeClient:pubNubClient1 fromChannelObjects:@[@"iostest1"]]));
    XCTAssertEqual([pubNubClient1 subscribedObjectsList].count, 0);


    // Remove grant on application and group
    XCTAssertTrue(([self removeAccessRightsClient:pubNubClient1 forGroup:@"g1" inNamespace:@"s1"]));
    XCTAssertTrue(([self removeAccessRightsApplicationforClient:pubNubClient1]));
    
    // Disconnect client
    XCTAssertTrue([self disconnectClient:pubNubClient1]);
}


#pragma mark - < Private methods >
#pragma mark - Connect

- (BOOL)connectPubNubWithConfiguration:(PNConfiguration *)configuration {
    
    _resGroup = [GCDGroup group];
    [_resGroup enterTimes:2];
    
    [PubNub setConfiguration:configuration];
    
    [PubNub connectWithSuccessBlock:^(NSString *origin) {
        [_resGroup leave];
    } errorBlock:^(PNError *connectionError) {
        XCTFail(@"Error when connection %@", connectionError);
        [_resGroup leave];
    }];
    
    if ([GCDWrapper isGCDGroup:_resGroup timeoutFiredValue:5]) {
        XCTFail(@"Timeout is fired. PubNub does't connected");
        _resGroup = nil;
        return NO;
    }
    
    _resGroup = nil;
    return [[PubNub sharedInstance] isConnected];
}

- (BOOL)connectClient:(PubNub **)pubNubClient
    withConfiguration:(PNConfiguration *)configuration {
    
    _resGroup = [GCDGroup group];
    [_resGroup enterTimes:2];
    
    *pubNubClient = [PubNub connectingClientWithConfiguration:configuration delegate:self andSuccessBlock:^(NSString *res) {
        [_resGroup leave];
    } errorBlock:^(PNError *error) {
        XCTFail(@"Error occurs during connection, %@", error);
        [_resGroup leave];
    }];
    
    if ([GCDWrapper isGCDGroup:_resGroup timeoutFiredValue:30]) {
        XCTFail(@"Timeout is fired. Didn't connect client to PubNub");
        _resGroup = nil;
        return NO;
    }
    
    _resGroup = nil;
    return [*pubNubClient isConnected];
}

- (BOOL)disconnectPubNub {
    
    _resGroup = [GCDGroup group];
    [_resGroup enterTimes:1];
    
    [PubNub disconnect];
    
    if ([GCDWrapper isGCDGroup:_resGroup timeoutFiredValue:5]) {
        XCTFail(@"Timeout is fired. Didn't disconnect from PubNub");
        _resGroup = nil;
        return NO;
    }
    
    _resGroup = nil;
    return YES;
}

- (BOOL)disconnectClient:(PubNub *)pubNubClient {
    
    _resGroup = [GCDGroup group];
    [_resGroup enterTimes:1];
    
    [pubNubClient disconnect];
    
    if ([GCDWrapper isGCDGroup:_resGroup timeoutFiredValue:5]) {
        XCTFail(@"Timeout is fired. Didn't disconnect from PubNub");
        _resGroup = nil;
        return NO;
    }
    
    _resGroup = nil;
    return ![pubNubClient isConnected];
}

#pragma mark - Subscribe

- (BOOL)subscribeClient:(PubNub *)client
       toChannelObjects:(NSArray *)сhannels
        withClientState:(NSDictionary *)state {

    _resGroup = [GCDGroup group];
    [_resGroup enterTimes:2];
    
    NSArray *_channels = [PNChannel channelsWithNames:сhannels];
    
    NSSet *setChannels = [[NSSet alloc] initWithArray:[PNChannel channelsWithNames:сhannels]];
    __block NSSet *setSubscribedChannels;

    [client subscribeOn:_channels withClientState:nil andCompletionHandlingBlock:^(PNSubscriptionProcessState state, NSArray *channels, PNError *error) {
        XCTAssertNil(error,@"Error when subscribing on channels");
        switch (state) {
            case PNSubscriptionProcessSubscribedState: {
                [_resGroup leave];
                setSubscribedChannels = [[NSSet alloc] initWithArray:[client subscribedObjectsList]];
            }
                break;
            default:
                break;
        }
    }];
    
    if ([GCDWrapper isGCDGroup:_resGroup timeoutFiredValue:5]) {
        XCTFail(@"Timeout is fired. Didn't subscribe on channels");
        _resGroup = nil;
        return NO;
    }
            
    _resGroup = nil;
    return [setChannels isSubsetOfSet:setSubscribedChannels];
}

- (BOOL)unsubscribeClient:(PubNub *)client
       fromChannelObjects:(NSArray *)сhannels {
    
    _resGroup = [GCDGroup group];
    [_resGroup enterTimes:2];
    
    NSArray *_channels = [PNChannel channelsWithNames:сhannels];
    
    NSSet *setChannels = [[NSSet alloc] initWithArray:[PNChannel channelsWithNames:сhannels]];
    __block NSSet *setSubscribedChannels;

    [client unsubscribeFrom:_channels withCompletionHandlingBlock:^(NSArray *channels, PNError *error) {
        if (error) {
            XCTFail(@"Error unsubscribing from channels %@", error);
        } else {
            setSubscribedChannels = [[NSSet alloc] initWithArray:[client subscribedObjectsList]];
            [_resGroup leave];
        }
    }];
    
    if ([GCDWrapper isGCDGroup:_resGroup timeoutFiredValue:5]) {
        XCTFail(@"Timeout is fired. Didn't unsubscribing from channels");
        _resGroup = nil;
        return NO;
    }
    
    _resGroup = nil;
    return ![setChannels isSubsetOfSet:setSubscribedChannels];
}

- (BOOL)isSubscribedClient:(PubNub *)client
                 onChannel:(NSString *)channel {
    
    PNChannel *_channel = [PNChannel channelWithName:channel];
    
    return [client isSubscribedOn:_channel];
}

#pragma mark - Send message

- (BOOL)sendClient:(PubNub *)client
           message:(NSString *)message
         toChannel:(NSString  *)channel
        compressed:(BOOL)shouldCompressMessage
    storeInHistory:(BOOL)shouldStoreInHistory {
    
    PNChannel *_channel = [PNChannel channelWithName:channel];
    
    _resGroup = [GCDGroup group];
    [_resGroup enterTimes:2];
    
    [client sendMessage:message
              toChannel:_channel
             compressed:shouldCompressMessage
         storeInHistory:shouldStoreInHistory
    withCompletionBlock:^(PNMessageState state, id data) {

        switch (state) {
            case PNMessageSending:
                break;
            case PNMessageSendingError:
                XCTFail(@"Error during PNMessageSending occured: PNMessageSendingError");
                break;
            case PNMessageSent:
                [_resGroup leave];
                break;
        }
    }];
    
    if ([GCDWrapper isGCDGroup:_resGroup timeoutFiredValue:5]) {
        XCTFail(@"Timeout is fired. Not all messages were sent");
        _resGroup = nil;
        return NO;
    }
    
    _resGroup = nil;
    return  YES;
}


#pragma mark - Group

- (BOOL)addClient:(PubNub *)client
         channels:(NSArray *)channelsNames
          toGroup:(NSString *)groupName
      inNamespace:(NSString *)namespace {
    
    _resGroup = [GCDGroup group];
    [_resGroup enterTimes:2];
    
//    NSSet *setChannels = [[NSSet alloc] initWithArray:[PNChannel channelsWithNames:channels]];
    __block NSArray *resultChannels = nil;
//    NSSet *setSubscribedChannels1;

    PNChannelGroup *group = [PNChannelGroup channelGroupWithName:groupName
                                                      inNamespace:namespace
                                            shouldObservePresence:NO];
    
    [client addChannels:[PNChannel channelsWithNames:channelsNames]
                toGroup:group
withCompletionHandlingBlock:^(PNChannelGroup *channelGroup, NSArray *channels, PNError *error) {
        if (error) {
            XCTFail(@"Error adding channels to the group %@", error);
        } else {
            resultChannels = channels;
        }
    
        [_resGroup leave];
    }];
    
    if ([GCDWrapper isGCDGroup:_resGroup timeoutFiredValue:15]) {
        XCTFail(@"PubNub client did fail to add channels to the group");
         _resGroup = nil;
        return NO;
    }
    
    _resGroup = nil;
    
//    setSubscribedChannels1 = [[NSSet alloc] initWithArray:[client subscribedObjectsList]];
//    return [setChannels isSubsetOfSet:setSubscribedChannels];
    return YES;
}

- (BOOL)removeClient:(PubNub *)client
            channels:(NSArray *)channels
           fromGroup:(NSString *)group
         inNamespace:(NSString *)space {
    
    _resGroup = [GCDGroup group];
    [_resGroup enterTimes:2];
    
    NSSet *setChannels = [[NSSet alloc] initWithArray:[PNChannel channelsWithNames:channels]];
    __block NSSet *setSubscribedChannels;
    
    PNChannelGroup *_group = [PNChannelGroup channelGroupWithName:group
                                                      inNamespace:space
                                            shouldObservePresence:NO];
    NSArray *_channels = [PNChannel channelsWithNames:channels];
    
    [client removeChannels:_channels
                  fromGroup:_group withCompletionHandlingBlock:^(PNChannelGroup *channelGroup, NSArray *channels, PNError *error) {
                      if (error) {
                          XCTFail(@"Error adding channels to the group %@", error);
                      } else {
                          setSubscribedChannels = [[NSSet alloc] initWithArray:channels];
                          [_resGroup leave];
                      }
                  }];
    
    BOOL rez;
    
    if ([GCDWrapper isGCDGroup:_resGroup timeoutFiredValue:15]) {
        XCTFail(@"PubNub client did fail to remove channels from the group");
        _resGroup = nil;
        return NO;
    }
    
    _resGroup = nil;
//   setSubscribedChannels = [[NSSet alloc] initWithArray:[client subscribedObjectsList]];
    return rez = [setChannels isSubsetOfSet:setSubscribedChannels];
}

- (BOOL)removeClient:(PubNub *)client
               group:(NSString *)group
       fromNamespace:(NSString *)space {
    
    _resGroup = [GCDGroup group];
    [_resGroup enterTimes:2];
    
    PNChannelGroup *_group = [PNChannelGroup channelGroupWithName:group
                                                      inNamespace:space
                                            shouldObservePresence:NO];
    
    [client removeChannelGroup:_group withCompletionHandlingBlock:^(PNChannelGroup *channelGroup, PNError *error) {
                 if (error) {
                     XCTFail(@"Error adding channels to the group %@", error);
                 } else {
                     [_resGroup leave];
                 }
             }];
    
    if ([GCDWrapper isGCDGroup:_resGroup timeoutFiredValue:15]) {
        XCTFail(@"PubNub client did fail to remove group");
        _resGroup = nil;
        return NO;
    }
    
    _resGroup = nil;
    return YES;
}

- (BOOL)removeClient:(PubNub *)client
           namespace:(NSString *)space {
    
    _resGroup = [GCDGroup group];
    [_resGroup enterTimes:2];

    [client removeChannelGroupNamespace:space withCompletionHandlingBlock:^(NSString *namespaceName, PNError *error) {
    
        if (error) {
            XCTFail(@"Error adding channels to the group %@", error);
        } else {
            [_resGroup leave];
        }
    }];
    
    if ([GCDWrapper isGCDGroup:_resGroup timeoutFiredValue:15]) {
        XCTFail(@"PubNub client did fail to remove namespace");
        _resGroup = nil;
        return NO;
    }
    
    _resGroup = nil;
    return YES;
}

- (NSArray *)requestChannelsClient:(PubNub *)client
                           forGroup:(NSString *)group
                        inNamespace:(NSString *)space {
    
    _resGroup = [GCDGroup group];
    [_resGroup enterTimes:2];

    PNChannelGroup *_group = [PNChannelGroup channelGroupWithName:group
                                                      inNamespace:space
                                            shouldObservePresence:NO];

    __block NSArray *groupsChannels;
    
    [client requestChannelsForGroup:_group withCompletionHandlingBlock:^(PNChannelGroup *channelGroup, PNError *error) {
        if (error) {
            XCTFail(@"Error receiving list of channels for group %@", error);
        } else {
            groupsChannels = [NSArray arrayWithArray:channelGroup.channels];
            [_resGroup leave];
        }
    }];
    
    if ([GCDWrapper isGCDGroup:_resGroup timeoutFiredValue:15]) {
        XCTFail(@"PubNub client didn't receive list of channels for group");
        _resGroup = nil;
        return nil;
    }
    
    _resGroup = nil;
   return groupsChannels;
}

- (NSArray *)requestGroupsClient:(PubNub *)client
                      forNamespace:(NSString *)space {
    
    _resGroup = [GCDGroup group];
    [_resGroup enterTimes:2];
    
    __block NSArray *groupsOfspace;
    
    
    [client requestChannelGroupsForNamespace:space withCompletionHandlingBlock:^(NSString *namespaceName, NSArray *channelGroups, PNError *error) {
        if (error) {
            XCTFail(@"Error receiving list of channels for group %@", error);
        } else {
            groupsOfspace = [NSArray arrayWithArray:channelGroups];
            [_resGroup leave];
        }
    }];

    if ([GCDWrapper isGCDGroup:_resGroup timeoutFiredValue:15]) {
        XCTFail(@"PubNub client didn't receive list of channels for group");
        _resGroup = nil;
        return nil;
    }
    
    _resGroup = nil;
    return groupsOfspace;
}


#pragma mark - Group

- (BOOL)grantAccessRightsApplicationforClient:(PubNub *)client {
    
    _resGroup = [GCDGroup group];
    // we disconnect first
    [_resGroup enterTimes:1];
    
    [client changeApplicationAccessRightsTo:PNAllAccessRights
                                   onPeriod:10000
                 andCompletionHandlingBlock:^(PNAccessRightsCollection *accessRightsCollection, PNError *error) {
    
        if (error) {
            XCTFail(@"Error adding channels to the group %@", error);
            [_resGroup leave];
        } else {
            [_resGroup leave];
        }
    }];
    
    if ([GCDWrapper isGCDGroup:_resGroup timeoutFiredValue:30]) {
        XCTFail(@"PubNub client did fail to remove namespace");
        _resGroup = nil;
        return NO;
    }
    
    _resGroup = nil;
    return YES;
}

- (BOOL)removeAccessRightsApplicationforClient:(PubNub *)client {
    
    _resGroup = [GCDGroup group];
    [_resGroup enterTimes:1];
    
    [client changeApplicationAccessRightsTo:PNNoAccessRights
                                   onPeriod:0
                 andCompletionHandlingBlock:^(PNAccessRightsCollection *accessRightsCollection, PNError *error) {
                     
                     if (error) {
                         XCTFail(@"Error adding channels to the group %@", error);
                     } else {
                         [_resGroup leave];
                     }
                 }];
    
    if ([GCDWrapper isGCDGroup:_resGroup timeoutFiredValue:10]) {
        XCTFail(@"PubNub client did fail to remove namespace");
        _resGroup = nil;
        return NO;
    }
    
    _resGroup = nil;
    return YES;
}


- (BOOL)subscribeClient:(PubNub *)client
                toGroup:(NSString *)group
            inNamespace:(NSString *)space {
    
    _resGroup = [GCDGroup group];
    [_resGroup enterTimes:2];
    
    PNChannelGroup *_group = [PNChannelGroup channelGroupWithName:group
                                                      inNamespace:space
                                            shouldObservePresence:NO];

    __block BOOL rez = NO;
    
    [client subscribeOn:@[_group] withClientState:nil andCompletionHandlingBlock:^(PNSubscriptionProcessState state, NSArray *channels, PNError *error) {
        XCTAssertNil(error,@"Error when subscribing on channels");
        [_resGroup leave];
        rez = NO;
        switch (state) {
            case PNSubscriptionProcessSubscribedState: {
                [_resGroup leave];
                rez = YES;
             }
                break;
            default:
                break;
        }
    }];
    
    if ([GCDWrapper isGCDGroup:_resGroup timeoutFiredValue:20]) {
        XCTFail(@"Timeout is fired. Didn't subscribe on channels");
        rez = NO;
    }
    
    _resGroup = nil;
    return rez;
}


- (BOOL)unsubscribeClient:(PubNub *)client
                fromGroup:(NSString *)group
              inNamespace:(NSString *)space {
    
    _resGroup = [GCDGroup group];
    [_resGroup enterTimes:2];
    
    PNChannelGroup *_group = [PNChannelGroup channelGroupWithName:group
                                                      inNamespace:space
                                            shouldObservePresence:NO];
    
    [client unsubscribeFrom:@[_group] withCompletionHandlingBlock:^(NSArray *channels, PNError *error) {
        if (error) {
            XCTFail(@"Error unsubscribing from channels %@", error);
        }
        
        [_resGroup leave];
    }];
    
    if ([GCDWrapper isGCDGroup:_resGroup timeoutFiredValue:10]) {
        XCTFail(@"Timeout is fired. Didn't subscribe on channels");
        _resGroup = nil;
        return NO;
    }
    
    _resGroup = nil;
    return YES;
}


- (BOOL)isSubscribedClient:(PubNub *)client
                   onGroup:(NSString *)group
               inNamespace:(NSString *)space {

PNChannelGroup *_group = [PNChannelGroup channelGroupWithName:group
                                                  inNamespace:space
                                        shouldObservePresence:NO];

    return [client isSubscribedOn:_group];
}


- (PNAccessRightsCollection *)auditAccessRightsForApplication:(PubNub *)client {
    
    _resGroup = [GCDGroup group];
    [_resGroup enterTimes:1];
    
    __block PNAccessRightsCollection *coll = nil;
    
    [client auditAccessRightsForApplicationWithCompletionHandlingBlock:^(PNAccessRightsCollection *accessRightsCollection, PNError *error) {
        if (error) {
            XCTFail(@"Error audit access rights for application %@", error);
        } else {
            coll = accessRightsCollection;
            [_resGroup leave];
        }
    }];
    
    if ([GCDWrapper isGCDGroup:_resGroup timeoutFiredValue:10]) {
        XCTFail(@"PubNub client didn't receive list of channels for group");
        _resGroup = nil;
        return nil;
    }
    
    _resGroup = nil;
    return coll;
}


- (BOOL)grantAccessRightsClient:(PubNub *)client
                       forGroup:(NSString *)groupName
                    inNamespace:(NSString *)space {
    
    _resGroup = [GCDGroup group];
    [_resGroup enterTimes:1];
    
    PNChannelGroup *group = [PNChannelGroup channelGroupWithName:groupName
                                                      inNamespace:space
                                            shouldObservePresence:NO];
    __block PNAccessRightsCollection *collection = nil;
    PNAccessRightsInformation *accessRights = nil;
    
    [client changeAccessRightsFor:@[group]
                               to:PNAllAccessRights
                         onPeriod:10000
      withCompletionHandlingBlock:^(PNAccessRightsCollection *accessRightsCollection, PNError *error) {
          if (error) {
              XCTFail(@"Error change access rights for group %@", error);
          } else {
              collection = accessRightsCollection;
          }
          
          [_resGroup leave];
      }];

    if ([GCDWrapper isGCDGroup:_resGroup timeoutFiredValue:10]) {
        XCTFail(@"Timeout is fired. Did fail change access rights for group");
        _resGroup = nil;
        return NO;
    }

    _resGroup = nil;
    accessRights = [collection accessRightsInformationFor:group];
    
    return (accessRights.rights == (PNAccessRights)PNAllAccessRights);
}

- (BOOL)removeAccessRightsClient:(PubNub *)client
                       forGroup:(NSString *)group
                    inNamespace:(NSString *)space {
    
    _resGroup = [GCDGroup group];
    [_resGroup enterTimes:1];
    
    PNChannelGroup *_group = [PNChannelGroup channelGroupWithName:group
                                                      inNamespace:space
                                            shouldObservePresence:NO];
    __block PNAccessRightsCollection *coll = nil;
    PNAccessRightsInformation *accessRights = nil;
    
    [client changeAccessRightsFor:@[_group]
                               to:PNNoAccessRights
                         onPeriod:0
      withCompletionHandlingBlock:^(PNAccessRightsCollection *accessRightsCollection, PNError *error) {
          if (error) {
              XCTFail(@"Error change access rights for group %@", error);
          } else {
              coll = accessRightsCollection;
          }
          
          [_resGroup leave];
      }];
    
    if ([GCDWrapper isGCDGroup:_resGroup timeoutFiredValue:10]) {
        XCTFail(@"Timeout is fired. Did fail change access rights for group");
        _resGroup = nil;
        return NO;
    }
    
    _resGroup = nil;
    accessRights = [coll accessRightsInformationFor:_group];
    
    return (accessRights.rights == (PNAccessRights)PNNoAccessRights);
}

- (BOOL)auditAccessRightsClient:(PubNub *)client
                       forGroup:(NSString *)group
                    inNamespace:(NSString *)space {

    _resGroup = [GCDGroup group];
    [_resGroup enterTimes:1];
    
    PNChannelGroup *_group = [PNChannelGroup channelGroupWithName:group
                                                      inNamespace:space
                                            shouldObservePresence:NO];
    
    __block PNAccessRightsCollection *coll = nil;
    PNAccessRightsInformation *accessRights = nil;

    [client auditAccessRightsFor:@[_group] withCompletionHandlingBlock:^(PNAccessRightsCollection *accessRightsCollection, PNError *error) {
        if (error) {
            XCTFail(@"Error audit access rights for group %@", error);
        }
        
        coll = accessRightsCollection;
        [_resGroup leave];
    }];

    if ([GCDWrapper isGCDGroup:_resGroup timeoutFiredValue:10]) {
        XCTFail(@"Timeout is fired. Did fail change access rights for group");
    }

    _resGroup = nil;

    accessRights = [coll accessRightsInformationFor:_group];
    XCTAssertTrue(accessRights.rights == (PNAccessRights)PNAllAccessRights);
    return (accessRights.rights == (PNAccessRights)PNNoAccessRights);
}

#warning It seems should be removed

- (void)t1estAbbreviatedPresence
{
	[PubNub disconnect];
	[PubNub setDelegate:self];
    
    // Vadim's keys
    
	PNConfiguration *configuration = [PNConfiguration configurationForOrigin:kOriginPath
                                                                  publishKey:kPNPublishKey
                                                                subscribeKey:kPNSubscriptionKey
                                                                   secretKey:kPNCipherKey
                                                                   cipherKey: nil];
    
    configuration.presenceHeartbeatTimeout = 20;
	[PubNub setConfiguration:configuration];
    
    _resGroup = [GCDGroup group];
    [_resGroup enterTimes:3];

	[PubNub connectWithSuccessBlock:^(NSString *origin) {
  
		NSLog(@"\n\n\n\n\n\n\n{BLOCK} PubNub client connected to: %@", origin);
        
        [_resGroup leave];
	} errorBlock:^(PNError *connectionError) {
							 XCTFail(@"connectionError %@", connectionError);
     }];

    if ([GCDWrapper isGCDGroup:_resGroup timeoutFiredValue:10]) {
        XCTFail(@"Timeout received");
        _resGroup = nil;
    }
 
    _resGroup = nil;
    
	BOOL isConnect = [[PubNub sharedInstance] isConnected];
	XCTAssertTrue( isConnect, @"not connected");
    
    // we are expecting two presence events: join and timeout
    [_resGroup enterTimes:2];
    
	[PubNub subscribeOn: @[[PNChannel channelWithName: @"zzz" shouldObservePresence: YES shouldUpdatePresenceObservingFlag: YES]]
		withCompletionHandlingBlock:^(PNSubscriptionProcessState state, NSArray *channels, PNError *subscriptionError) {
            
            NSLog(@"channels: %@", channels);
            [_resGroup leave];
	 }];

    if ([GCDWrapper isGCDGroup:_resGroup timeoutFiredValue:10]) {
        XCTFail(@"Timeout received");
        _resGroup = nil;
    }
    
    _resGroup = nil;
}





- (void)handleClientDidReceivePresenceEvent:(NSNotification *)notification {
    // Retrieve reference on presence event which was received
	NSLog(@"clientDidReceivePresenceEvent %@", notification);
    
    PNPresenceEvent *event = (PNPresenceEvent *)notification.userInfo;
    
        if (event.type == PNPresenceEventJoin) {
            [_resGroup leave];
        } else if (event.type == PNPresenceEventTimeout) {
            [_resGroup leave];
        }
}


#pragma mark - < Delegate methods >
#pragma mark - Connect

// Connect did
- (void)pubnubClient:(PubNub *)client didConnectToOrigin:(NSString *)origin {
    
    if (_resGroup) {
        [_resGroup leave];
    }
}

// Connect fail
- (void)pubnubClient:(PubNub *)client connectionDidFailWithError:(PNError *)error {
    XCTFail(@"Did fail connection: %@", error);
    
    if (_resGroup) {
        [_resGroup leave];
    }
}

// Disconnected did
- (void)pubnubClient:(PubNub *)client didDisconnectFromOrigin:(NSString *)origin {
    if (_resGroup) {
        [_resGroup leave];
    }
}

#pragma mark - Subscribe

// Subscribe on did
- (void)pubnubClient:(PubNub *)client didSubscribeOn:(NSArray *)channelObjects {
    if (_resGroup) {
        [_resGroup leave];
    }
}

// Subscribe on fail
- (void)pubnubClient:(PubNub *)client subscriptionDidFailWithError:(NSError *)error {
    if (_resGroup) {
        XCTFail(@"Did fail subscription: %@", error);
        [_resGroup leave];
    }
}

// Unsubscribe from did
- (void)pubnubClient:(PubNub *)client didUnsubscribeFrom:(NSArray *)channelObjects {
    if (_resGroup) {
        [_resGroup leave];
    }
}

// Unsubscribe from fail
- (void)pubnubClient:(PubNub *)client unsubscriptionDidFailWithError:(PNError *)error {
    XCTFail(@"Did fail unsubscription: %@", error);
    
    if (_resGroup) {
        [_resGroup leave];
    }
}


#pragma mark - Send message

// Send message did
- (void)pubnubClient:(PubNub *)client didFailMessageSend:(PNMessage *)encryptedMessage withError:(PNError *)error {
    XCTFail(@"Did fail send message: %@", error);
    
    if (_resGroup) {
        [_resGroup leave];
    }
}

// Send message fail
- (void)pubnubClient:(PubNub *)client didSendMessage:(PNMessage *)encryptedMessage {
    if (_resGroup) {
        [_resGroup leave];
    }
}


#pragma mark - Group

// Add channels in group (did)
- (void)pubnubClient:(PubNub *)client didAddChannels:(NSArray *)channels toGroup:(PNChannelGroup *)group {
    if (_resGroup) {
        [_resGroup leave];
    }
}
// Add channels to group (fail)
- (void)pubnubClient:(PubNub *)client channelsAdditionToGroupDidFailWithError:(PNError *)error {
        XCTFail(@"PubNub client did fail to add channels from the group: %@", error);
    
    if (_resGroup) {
        [_resGroup leave];
    }
}

// Remove channels from group (did)
- (void)pubnubClient:(PubNub *)client didRemoveChannels:(NSArray *)channels fromGroup:(PNChannelGroup *)group {
    if (_resGroup) {
        [_resGroup leave];
    }
}
// Remove channels from group (fail)
- (void)pubnubClient:(PubNub *)client channelsRemovalFromGroupDidFailWithError:(PNError *)error {
        XCTFail(@"!!! PubNub client did fail to remove channels from the group: %@", error);
    
    if (_resGroup) {
        [_resGroup leave];
    }
}

// Remove group (did)
- (void)pubnubClient:(PubNub *)client didRemoveChannelGroup:(PNChannelGroup *)group {
    if (_resGroup) {
        [_resGroup leave];
    }
}
// Remove group (fail)
- (void)pubnubClient:(PubNub *)client groupRemovalDidFailWithError:(PNError *)error {
        XCTFail(@"!!! PubNub client did fail to remove group: %@", error);
    
    if (_resGroup) {
        [_resGroup leave];
    }
}

// Remove namespace (did)
- (void)pubnubClient:(PubNub *)client didRemoveNamespace:(NSString *)nspace {
    if (_resGroup) {
        [_resGroup leave];
    }
}
// Remove namespace (fail)
- (void)pubnubClient:(PubNub *)client namespaceRemovalDidFailWithError:(PNError *)error {
    XCTFail(@"PubNub client did fail to remove namespace: %@", error);
    
    if (_resGroup) {
        [_resGroup leave];
    }
}

// Request channels for group (did) ???
- (void)pubnubClient:(PubNub *)client didReceiveChannelsForGroup:(PNChannelGroup *)group {
    if (_resGroup) {
        [_resGroup leave];
    }
}
// Request channels for group (fail)
- (void)pubnubClient:(PubNub *)client channelsForGroupRequestDidFailWithError:(PNError *)error {
        XCTFail(@"PubNub client did fail to receive channels for group: %@", error);
    
    if (_resGroup) {
        [_resGroup leave];
    }
}

// Request groups (did)
- (void)pubnubClient:(PubNub *)client didReceiveChannelGroups:(NSArray *)groups forNamespace:(NSString *)nspace {
    if (_resGroup) {
        [_resGroup leave];
    }
}
// Request groups (fail)
- (void)pubnubClient:(PubNub *)client channelGroupsRequestDidFailWithError:(PNError *)error {
        XCTFail(@"!!! PubNub client did fail to resive groups: %@", error);
    
    if (_resGroup) {
        [_resGroup leave];
    }
}

// Request namespaces (did)
- (void)pubnubClient:(PubNub *)client didReceiveChannelGroupNamespaces:(NSArray *)namespaces {
    if (_resGroup) {
        [_resGroup leave];
    }
}

// Request namespaces (fail)
- (void)pubnubClient:(PubNub *)client channelGroupNamespacesRequestDidFailWithError:(PNError *)error {
        XCTFail(@"!!! PubNub client did fail to resive namespaces: %@", error);
    
    if (_resGroup) {
        [_resGroup leave];
    }
}


@end
