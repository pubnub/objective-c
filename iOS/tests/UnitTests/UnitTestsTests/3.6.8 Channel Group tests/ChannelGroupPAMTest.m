//
//  ChannelGroupPAMTest.m
//  UnitTests
//
//  Created by Vadim Osovets on 10/13/14.
//  Copyright (c) 2014 Vadim Osovets. All rights reserved.
//

#import <XCTest/XCTest.h>

static NSString *kOriginPath = @"dara24.devbuild.pubnub.com";
static NSString *kPublishKey = @"pam";
static NSString *kSubscribeKey = @"pam";
static NSString *kSecretKey = @"pam";
static NSString *kAuthKey = @"pam";

@interface ChannelGroupPAMTest : XCTestCase

<
PNDelegate
>

@end

@implementation ChannelGroupPAMTest {
    dispatch_group_t _resGroup1;
    dispatch_group_t _resGroup2;
    dispatch_group_t _resGroup3;
    dispatch_group_t _resGroup4;
    dispatch_group_t _resGroup5;
    dispatch_group_t _resGroup6;
    
    NSString *_namespaceName;
    
    NSArray *_channels;
    PNChannelGroup *_group;
    
    PubNub *_pubNub;
    
    id _testMessage;
}

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
    [PubNub disconnect];
    
    PNConfiguration *configuration = [PNConfiguration configurationForOrigin:kOriginPath
                                                                  publishKey:kPublishKey
                                                                subscribeKey:kSubscribeKey
                                                                   secretKey:kSecretKey];
    
    configuration.authorizationKey = kAuthKey;
    
    [PubNub setupWithConfiguration:configuration andDelegate:self];
    
    [PubNub connect];
    
    _channels = [PNChannel channelsWithNames:@[@"test_ios_1", @"test_ios_2", @"test_ios_3"]];
    _group = [PNChannelGroup channelGroupWithName:@"test_channel_group" inNamespace:@"unit_test_ios_namespace" shouldObservePresence:NO];
    
    _testMessage = @"Test message";
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [PubNub disconnect];
    
    [super tearDown];
}

- (void)testAuditAccessRightsForGroup
{
    _resGroup1 = dispatch_group_create();
    dispatch_group_enter(_resGroup1);
    
    [PubNub setClientIdentifier:@"Test Client"];
    
    // test to make sure we are using PAM access
    [[PubNub sharedInstance] requestDefaultChannelGroupsWithCompletionHandlingBlock:^(NSString *nspace, NSArray *groups, PNError *error) {
        if (!error) {
            XCTFail(@"We receive groups in PAM configuration without access rights");
        } else {
            
            if (error.code == 120) {
                // expected error: permission is not given yet
            } else {
                XCTFail(@"Cannot receive default channel groups");
            }
        }
        
        dispatch_group_leave(_resGroup1);
    }];
    
    if ([GCDWrapper isGroup:_resGroup1 timeoutFiredValue:10]) {
        XCTFail(@"Cannot receive group");
        dispatch_group_leave(_resGroup1);
        
        _resGroup1 = NULL;
        
        return;
    }
    
    // check add group
    dispatch_group_enter(_resGroup1);
    
    [[PubNub sharedInstance] addChannels:_channels toGroup:_group withCompletionHandlingBlock:^(PNChannelGroup *group, NSArray *channels, PNError *error) {
        if (!error) {
            XCTFail(@"We receive groups in PAM configuration without access rights");
        } else {
            
            if (error.code == 120) {
                // expected error: permission is not given yet
            } else {
                XCTFail(@"Cannot receive default channel groups");
            }
        }
        
        dispatch_group_leave(_resGroup1);
    }];
    
    if ([GCDWrapper isGroup:_resGroup1 timeoutFiredValue:10]) {
        XCTFail(@"Cannot receive group");
        dispatch_group_leave(_resGroup1);
        
        _resGroup1 = NULL;
        
        return;
    }
    
    dispatch_group_enter(_resGroup1);
    
    // give permission
    [[PubNub sharedInstance] changeAccessRightsFor:@[_group]
                                                to:PNAllAccessRights onPeriod:10 withCompletionHandlingBlock:^(PNAccessRightsCollection *rights, PNError *error) {
                                                    if (error) {
                                                        XCTFail(@"During change access rights %@", error);
                                                    }
                                                    
                                                    dispatch_group_leave(_resGroup1);
                                                }];
    
    if ([GCDWrapper isGroup:_resGroup1 timeoutFiredValue:10]) {
        XCTFail(@"Cannot change access rights for group.");
        dispatch_group_leave(_resGroup1);
        
        _resGroup1 = NULL;
        
        return;
    }
}

- (void)testChangeAccessRightsForGroup
{
    XCTFail(@"No implementation for \"%s\"", __PRETTY_FUNCTION__);
}

- (void)testRevokeAccessRightsForGroup
{
    XCTFail(@"No implementation for \"%s\"", __PRETTY_FUNCTION__);
}

@end
