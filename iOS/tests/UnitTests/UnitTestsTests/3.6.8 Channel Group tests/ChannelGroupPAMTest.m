//
//  ChannelGroupPAMTest.m
//  UnitTests
//
//  Created by Vadim Osovets on 10/13/14.
//  Copyright (c) 2014 Vadim Osovets. All rights reserved.
//

#import <XCTest/XCTest.h>

@interface ChannelGroupPAMTest : XCTestCase <PNDelegate>

@end

@implementation ChannelGroupPAMTest {
    GCDGroup *_resGroup;
    NSString *_namespaceName;
    
    NSArray *_channels;
    PNChannelGroup *_group;
    PubNub *_pubNub;
}

- (void)setUp
{
    [super setUp];
    
    [PubNub disconnect];
    
    PNConfiguration *configuration = [PNConfiguration accessManagerTestConfiguration];
    
    configuration.authorizationKey = nil;
    
    [PubNub setupWithConfiguration:configuration andDelegate:self];
    [PubNub connect];
    
    _channels = [PNChannel channelsWithNames:@[@"test_ios_1", @"test_ios_2", @"test_ios_3"]];
    _group = [PNChannelGroup channelGroupWithName:@"test_channel_group" inNamespace:@"unit_test_ios_namespace" shouldObservePresence:NO];

 
    //Grant on group
    _resGroup = [GCDGroup group];
    [_resGroup enterTimes:1];

    [PubNub changeAccessRightsFor:@[_group]
                               to:PNAllAccessRights
                         onPeriod:10000
      withCompletionHandlingBlock:^(PNAccessRightsCollection *accessRightsCollection, PNError *error) {
                     
                     if (error) {
                         XCTFail(@"Error change access rights for group %@", error);
                     }
        
                     [_resGroup leave];
                  }];
    
    if ([GCDWrapper isGCDGroup:_resGroup timeoutFiredValue:10]) {
        XCTFail(@"Timeout is fired. Did fail change access rights for group");
    }
    
    _resGroup = nil;
 
    
    //Audit access rights for group
    _resGroup = [GCDGroup group];
    [_resGroup enterTimes:1];
    
    __block PNAccessRightsCollection *coll = nil;
    
    [PubNub auditAccessRightsFor:@[_group] withCompletionHandlingBlock:^(PNAccessRightsCollection *accessRightsCollection, PNError *error) {
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
    
    PNAccessRightsInformation *accessRights = [coll accessRightsInformationFor:_group];
    XCTAssertTrue(accessRights.rights == (PNAccessRights)PNAllAccessRights);
    
}

- (void)tearDown
{
    //Remove grant on group
    _resGroup = [GCDGroup group];
    [_resGroup enterTimes:1];
    
    __block PNAccessRightsCollection *coll = nil;
    
    [PubNub changeAccessRightsFor:@[_group]
                               to:PNNoAccessRights
                         onPeriod:0
      withCompletionHandlingBlock:^(PNAccessRightsCollection *accessRightsCollection, PNError *error) {
                     
                     if (error) {
                         XCTFail(@"Error adding channels to the group %@", error);
                     }
          
                     coll = accessRightsCollection;
                     [_resGroup leave];
                 }];
    
    if ([GCDWrapper isGCDGroup:_resGroup timeoutFiredValue:10]) {
        XCTFail(@"Timeout is fired. Did fail change access rights for group");
    }
    
    _resGroup = nil;

    PNAccessRightsInformation *accessRights = [coll accessRightsInformationFor:_group];
    XCTAssertTrue(accessRights.rights == (PNAccessRights)PNNoAccessRights);

    
    [PubNub disconnect];
    [super tearDown];
}

#pragma mark - Tests

- (void)testAuditAccessRightsForGroup {
    
    // check impossible to access groups without permissions
    
    _resGroup = [GCDGroup group];
    [_resGroup enter];
    
    [PubNub setClientIdentifier:@"Test Client"];
    
    // test to make sure we are using PAM access
    [[PubNub sharedInstance] requestDefaultChannelGroupsWithCompletionHandlingBlock:^(NSString *nspace, NSArray *groups, PNError *error) {
        if (!error) {
            XCTFail(@"We receive groups in PAM configuration without access rights");
        } else {
            
            if (error.code == kPNAPIAccessForbiddenError) { // I replace kPNChannelGroupNotEnabledError
                // expected error: permission is not given yet
            } else {
                XCTFail(@"Cannot receive default channel groups");
            }
        }
        
        [_resGroup leave];
    }];
    
    if ([GCDWrapper isGCDGroup:_resGroup timeoutFiredValue:5]) {
        XCTFail(@"Cannot receive group");
        [_resGroup leave];
    }
    
    _resGroup = nil;
}
    
- (void)testAddAccessRightsForGroup {
    
    _resGroup = [GCDGroup group];
    [_resGroup enter];

    
    [[PubNub sharedInstance] addChannels:_channels toGroup:_group withCompletionHandlingBlock:^(PNChannelGroup *group, NSArray *channels, PNError *error) {
        if (!error) {
            XCTFail(@"We receive groups in PAM configuration without access rights");
        } else {
            
            if (error.code == kPNAPIAccessForbiddenError) { // I replace kPNChannelGroupNotEnabledError
                // expected error: permission is    not given yet
            } else {
                XCTFail(@"Cannot receive default channel groups");
            }
        }
        
        [_resGroup leave];
    }];
    
    if ([GCDWrapper isGCDGroup:_resGroup timeoutFiredValue:5]) {
        XCTFail(@"Cannot receive group");
        [_resGroup leave];
    }
    
    _resGroup = nil;
}

- (void)testChangeAccessRightsFor {
    
    _resGroup = [GCDGroup group];
    [_resGroup enter];
    
    // give permission
    [[PubNub sharedInstance] changeAccessRightsFor:@[_group]
                                                to:PNAllAccessRights onPeriod:10 withCompletionHandlingBlock:^(PNAccessRightsCollection *rights, PNError *error) {
                                                     if (error) {
                                                        XCTFail(@"During change access rights %@", error);
                                                    }
                                                    
                                                    [_resGroup leave];
                                                }];
    
    if ([GCDWrapper isGCDGroup:_resGroup timeoutFiredValue:5]) {
        XCTFail(@"Cannot change access rights for group.");
        [_resGroup leave];
    }
    
    _resGroup = nil;
}

    
    
- (void)t1estChangeAccessRightsForGroup
{
    XCTFail(@"No implementation for \"%s\"", __PRETTY_FUNCTION__);
}

- (void)t1estRevokeAccessRightsForGroup
{
    XCTFail(@"No implementation for \"%s\"", __PRETTY_FUNCTION__);
}

@end
