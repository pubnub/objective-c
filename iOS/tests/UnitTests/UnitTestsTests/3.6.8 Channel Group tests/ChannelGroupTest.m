//
//  TestChannelGroup.m
//  UnitTests
//
//  Created by Sergey on 10/6/14.
//  Copyright (c) 2014 Vadim Osovets. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

@interface ChannelGroupTest : XCTestCase <PNDelegate> {
    
    GCDGroup *_resGroup;
    PNConfiguration *_configuration1;
}
@end

@implementation ChannelGroupTest

- (void)setUp {
    
    [super setUp];
    [PubNub disconnect];
    
    _configuration1 = [PNConfiguration accessManagerTestConfiguration];
    _configuration1.authorizationKey = @"testios19740905";
}

- (void)tearDown {
    
    [PubNub disconnect];
    [super tearDown];
}


#pragma mark - Test

- (void)testManagementGroups {
    
    // Connect client
    PubNub *client;
    XCTAssertTrue([self connectClient:&client withConfiguration:_configuration1]);
    
    // Change access right for group
    XCTAssertTrue(([self grantAccessRightsClient:client forGroup:@"g1" inNamespace:@"s1"]));
    PNAccessRightsInformation *accessRightsForGroup = [self auditAccessRightsClient:client forGroup:@"g1" inNamespace:@"s1"];
    XCTAssertTrue(accessRightsForGroup.rights == (PNReadAccessRight | PNWriteAccessRight | PNManagementRight));
    
    // Add channels to group
    XCTAssertTrue(([self addClient:client channels:@[@"iostest1",@"iostest2",@"iostest3"] toGroup:@"g1" inNamespace:@"s1"]));
    XCTAssertEqual([self requestChannelsClient:client forGroup:@"g1" inNamespace:@"s1"].count, 3);
    XCTAssertEqual([self requestGroupsClient:client forNamespace:@"s1"].count, 1);
    
    // Subscribe to group
    XCTAssertTrue(([self subscribeClient:client toGroup:@"g1" inNamespace:@"s1"]));
    XCTAssertTrue(([self isSubscribedClient:client onGroup:@"g1" inNamespace:@"s1"]));
    
    // Unsubscribe from group
    XCTAssertTrue(([self unsubscribeClient:client fromGroup:@"g1" inNamespace:@"s1"]));
    XCTAssertFalse(([self isSubscribedClient:client onGroup:@"g1" inNamespace:@"s1"]));
    
    // Remove channels from group
    XCTAssertTrue(([self removeClient:client channels:@[@"iostest1",@"iostest2",@"iostest3"] fromGroup:@"g1" inNamespace:@"s1"]));
    XCTAssertEqual([self requestChannelsClient:client forGroup:@"g1" inNamespace:@"s1"].count, 0);
    
    // Remove group
    XCTAssertTrue(([self removeClient:client group:@"g1" fromNamespace:@"s1"]));
    XCTAssertEqual([self requestGroupsClient:client forNamespace:@"s1"].count, 0);
    
    // Remove namespace
    XCTAssertTrue(([self grantAccessRightsClient:client forNamespace:@"s1"]));
    XCTAssertTrue(([self removeClient:client namespace:@"s1"]));
    
    // Remove grant from group
    XCTAssertTrue(([self removeAccessRightsClient:client forGroup:@"g1" inNamespace:@"s1"]));
    accessRightsForGroup = [self auditAccessRightsClient:client forGroup:@"g1" inNamespace:@"s1"];
    XCTAssertTrue(accessRightsForGroup.rights == PNNoAccessRights);
    
    // Disconnect client
    XCTAssertTrue([self disconnectClient:client]);
}


#pragma mark - < Private methods >
#pragma mark - Connect

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


#pragma mark - Group add

- (BOOL)addClient:(PubNub *)client
         channels:(NSArray *)channelsNames
          toGroup:(NSString *)groupName
      inNamespace:(NSString *)namespace {
    
    _resGroup = [GCDGroup group];
    [_resGroup enterTimes:2];
    
    NSSet *uniqChannelsNames = [[NSSet alloc] initWithArray:[PNChannel channelsWithNames:channelsNames]];
    __block NSArray *addedChannelsToGroup = nil;
    
    PNChannelGroup *group = [PNChannelGroup channelGroupWithName:groupName
                                                     inNamespace:namespace
                                           shouldObservePresence:NO];
    
    [client addChannels:[PNChannel channelsWithNames:channelsNames]
                toGroup:group
withCompletionHandlingBlock:^(PNChannelGroup *channelGroup, NSArray *channels, PNError *error) {
    
    if (error) {
        
        XCTFail(@"Error adding channels to the group %@", error);
    } else {
        
        addedChannelsToGroup = channels;
    }
    [_resGroup leave];
}];
    
    if ([GCDWrapper isGCDGroup:_resGroup timeoutFiredValue:15]) {
        
        XCTFail(@"PubNub client did fail to add channels to the group");
        _resGroup = nil;
        return NO;
    }
    _resGroup = nil;
    
    NSSet *uniqAddedChannelsNames = [[NSSet alloc] initWithArray:addedChannelsToGroup];
    return [uniqChannelsNames isSubsetOfSet:uniqAddedChannelsNames];
}


#pragma mark - Group remove

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
                     }
                     [_resGroup leave];
                 }];
    
    BOOL rez;
    
    if ([GCDWrapper isGCDGroup:_resGroup timeoutFiredValue:15]) {
        
        XCTFail(@"PubNub client did fail to remove channels from the group");
        _resGroup = nil;
        return NO;
    }
    _resGroup = nil;
    
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
        }
        
        [_resGroup leave];
    }];
    
    if ([GCDWrapper isGCDGroup:_resGroup timeoutFiredValue:15]) {
        
        XCTFail(@"PubNub client did fail to remove namespace");
        _resGroup = nil;
        return NO;
    }
    
    _resGroup = nil;
    return YES;
}


#pragma mark - Group request

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
        }
        
        [_resGroup leave];
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
        }
        
        [_resGroup leave];
    }];
    
    if ([GCDWrapper isGCDGroup:_resGroup timeoutFiredValue:15]) {
        
        XCTFail(@"PubNub client didn't receive list of channels for group");
        _resGroup = nil;
        return nil;
    }
    
    _resGroup = nil;
    return groupsOfspace;
}


#pragma mark - Group subscribe

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
        
        if (error) {
            
            XCTFail(@"Error when subscribing on channels %@", error);
        } else if (state == PNSubscriptionProcessSubscribedState) {
            
            rez = YES;
        }
        
        [_resGroup leave];
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
    __block BOOL rez = NO;
    
    [client unsubscribeFrom:@[_group] withCompletionHandlingBlock:^(NSArray *channels, PNError *error) {
        
        if (error) {
            
            XCTFail(@"Error unsubscribing from channels %@", error);
        } else {
            
            rez = YES;
        }
        
        [_resGroup leave];
    }];
    
    if ([GCDWrapper isGCDGroup:_resGroup timeoutFiredValue:10]) {
        
        XCTFail(@"Timeout is fired. Didn't subscribe on channels");
        rez = NO;
    }
    
    _resGroup = nil;
    return rez;
}


- (BOOL)isSubscribedClient:(PubNub *)client
                   onGroup:(NSString *)group
               inNamespace:(NSString *)space {
    
    PNChannelGroup *_group = [PNChannelGroup channelGroupWithName:group
                                                      inNamespace:space
                                            shouldObservePresence:NO];
    
    return [client isSubscribedOn:_group];
}


#pragma mark - Group grant

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
                               to:(PNReadAccessRight | PNWriteAccessRight | PNManagementRight)
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
    return (accessRights.rights == (PNAccessRights)(PNReadAccessRight | PNWriteAccessRight | PNManagementRight));
}

- (BOOL)grantAccessRightsClient:(PubNub *)client
                   forNamespace:(NSString *)space {
    
    _resGroup = [GCDGroup group];
    [_resGroup enterTimes:1];
    
    PNChannelGroupNamespace *nameSpace = [PNChannelGroupNamespace namespaceWithName:space];
    __block PNAccessRightsCollection *collection = nil;
    
    [client changeAccessRightsFor:@[nameSpace]
                               to:(PNReadAccessRight | PNWriteAccessRight | PNManagementRight)
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
    PNAccessRightsInformation *accessRights = [collection accessRightsInformationFor:nameSpace];
    return (accessRights.rights == (PNAccessRights)(PNReadAccessRight | PNWriteAccessRight | PNManagementRight));
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
    PNAccessRightsInformation *accessRights = [coll accessRightsInformationFor:_group];
    return (accessRights.rights == (PNAccessRights)PNNoAccessRights);
}

- (PNAccessRightsInformation *)auditAccessRightsClient:(PubNub *)client
                                              forGroup:(NSString *)group
                                           inNamespace:(NSString *)space {
    
    _resGroup = [GCDGroup group];
    [_resGroup enterTimes:1];
    
    PNChannelGroup *_group = [PNChannelGroup channelGroupWithName:group
                                                      inNamespace:space
                                            shouldObservePresence:NO];
    __block PNAccessRightsCollection *coll = nil;
    
    [client auditAccessRightsFor:@[_group] withCompletionHandlingBlock:^(PNAccessRightsCollection *accessRightsCollection, PNError *error) {
        
        if (error) {
            
            XCTFail(@"Error audit access rights for group %@", error);
        } else {
            
            coll = accessRightsCollection;
        }
        
        [_resGroup leave];
    }];
    
    if ([GCDWrapper isGCDGroup:_resGroup timeoutFiredValue:10]) {
        
        XCTFail(@"Timeout is fired. Did fail change access rights for group");
        _resGroup = nil;
        return nil;
    }
    _resGroup = nil;
    
    if (!coll) {
        
        return nil;
    }
    
    PNAccessRightsInformation *accessRights = [coll accessRightsInformationFor:_group];
    return accessRights;
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


#pragma mark - Group subscribe

// Subscribe on did
- (void)pubnubClient:(PubNub *)client didSubscribeOn:(NSArray *)channelObjects {
    
    if (_resGroup) {
        
        [_resGroup leave];
    }
}

// Subscribe on fail
- (void)pubnubClient:(PubNub *)client subscriptionDidFailWithError:(NSError *)error {
    
    XCTFail(@"Did fail subscription: %@", error);
    
    if (_resGroup) {
        
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


#pragma mark - Group add

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


#pragma mark - Group remove
// Remove channels from group (did)
- (void)pubnubClient:(PubNub *)client didRemoveChannels:(NSArray *)channels fromGroup:(PNChannelGroup *)group {
    
    if (_resGroup) {
        
        [_resGroup leave];
    }
}
// Remove channels from group (fail)
- (void)pubnubClient:(PubNub *)client channelsRemovalFromGroupDidFailWithError:(PNError *)error {
    
    XCTFail(@" PubNub client did fail to remove channels from the group: %@", error);
    
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
    
    XCTFail(@" PubNub client did fail to remove group: %@", error);
    
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


#pragma mark - Group request

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
    
    XCTFail(@" PubNub client did fail to resive groups: %@", error);
    
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
    
    XCTFail(@" PubNub client did fail to resive namespaces: %@", error);
    
    if (_resGroup) {
        
        [_resGroup leave];
    }
}

@end
