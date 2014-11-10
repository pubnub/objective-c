//
//  PNChannelGroupTest.m
//  UnitTests
//
//  Created by Vadim Osovets on 11/4/14.
//  Copyright (c) 2014 Vadim Osovets. All rights reserved.
//

#import <XCTest/XCTest.h>

static NSString *kNamespaceSeparatorSymbol = @":";

@interface PNChannelGroupTest : XCTestCase

@end

@implementation PNChannelGroupTest {
    PubNub *_pubNub;
    
    dispatch_group_t _resGroup;
}

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

#pragma mark - Tests

- (void)testCreateGroup
{
    NSArray *names = @[@"test", @"group_name_test", @"test:test", @"test_test:test", @"test_test:test:test"];
    
    PNConfiguration *configuration = [PNConfiguration configurationForOrigin:kTestPNOriginHost publishKey:kTestPNPublishKey subscribeKey:kTestPNSubscriptionKey secretKey:nil];
    
    _pubNub = [PubNub clientWithConfiguration:configuration];
    
    [_pubNub connect];
    
    for (NSString *groupName in names) {
        PNChannelGroup *group = [PNChannelGroup channelGroupWithName:groupName];
        
        XCTAssertNotNil(group, @"Group cannot be created: %@", groupName);
        
        dispatch_group_t testResGroup = dispatch_group_create();
        
        NSString *channelName = [NSString stringWithFormat:@"test_%lu", (unsigned long)[names indexOfObject:groupName]];
        
        NSRange range = [groupName rangeOfString:kNamespaceSeparatorSymbol];
        
        // we try to subscribe to group in default namespace
        if (range.location == NSNotFound) {
            
            dispatch_group_enter(testResGroup);
            
            [_pubNub addChannels:@[[PNChannel channelWithName:channelName]] toGroup:group withCompletionHandlingBlock:^(PNChannelGroup *channelGroup, NSArray *channels, PNError *error) {
                
                if (!error) {
                    // TODO: check if we really subscribed to it?
                } else {
                    XCTFail(@"Cannot add channel to group: %@ %@", channelName, groupName);
                }
                
                dispatch_group_leave(testResGroup);
            }];
            
            if ([GCDWrapper isGroup:testResGroup timeoutFiredValue:10]) {
                XCTFail(@"Timeout is fired. Cannot add channel to group: %@ %@", channelName, groupName);
                dispatch_group_leave(testResGroup);
            }
            
            // check if group is created on server-side
            
            dispatch_group_t testResGroup2 = dispatch_group_create();
            
            dispatch_group_enter(testResGroup2);
            
            [_pubNub requestDefaultChannelGroupsWithCompletionHandlingBlock:^(NSString *namespaceName, NSArray *channelGroups, PNError *error) {
                if (!error) {
                    BOOL isGroupFound = NO;
                    
                    for (PNChannelGroup *group in channelGroups) {
                        if ([groupName isEqualToString:group.groupName]) {
                            isGroupFound = YES;
                            break;
                        }
                    }
                    
                    if (!isGroupFound) {
                        XCTFail(@"Cannot find group in default namespace: %@ group: %@", namespaceName, groupName);
                    }
                    
                } else {
                    XCTFail(@"Cannot request channel groups in default namespace: %@", namespaceName);
                }
                
                dispatch_group_leave(testResGroup2);
            }];
            
            if ([GCDWrapper isGroup:testResGroup2 timeoutFiredValue:5]) {
                XCTFail(@"Timeout is fired. Cannot add channel to group: %@ %@", channelName, groupName);
                dispatch_group_leave(testResGroup2);
            }
            
        } else {
            // try to determine group and namespace:
            NSString *testNamespace = [groupName substringToIndex:range.location];
            NSString *testGroupName = [groupName substringFromIndex:range.location + 1];
            
            // we try to subscribe to group in a namespace
            
            dispatch_group_enter(testResGroup);
            
            [_pubNub addChannels:@[[PNChannel channelWithName:channelName]] toGroup:group withCompletionHandlingBlock:^(PNChannelGroup *channelGroup, NSArray *channels, PNError *error) {
                
                if (!error) {
                    // TODO: check if we really subscribed to it?
                } else {
                    XCTFail(@"Cannot add channel to group: %@ %@", channelName, groupName);
                }
                
                if ([testNamespace isEqualToString:@"test_test"]) {
                    NSLog(@"");
                }
                
                dispatch_group_leave(testResGroup);
            }];
            
            if ([GCDWrapper isGroup:testResGroup timeoutFiredValue:10]) {
                XCTFail(@"Timeout is fired. Cannot add channel to group: %@ %@", channelName, groupName);
                dispatch_group_leave(testResGroup);
            }
            
            // check if group is created on server-side
            
            dispatch_group_t testResGroup2 = dispatch_group_create();
            
            dispatch_group_enter(testResGroup2);
            
            [_pubNub requestChannelGroupsForNamespace:testNamespace
                          withCompletionHandlingBlock:^(NSString *namespaceName, NSArray *channelGroups, PNError *error) {
                if (!error) {
                    BOOL isGroupFound = NO;
                    
                    for (PNChannelGroup *group in channelGroups) {
                        if ([testGroupName isEqualToString:group.groupName]) {
                            isGroupFound = YES;
                            break;
                        }
                    }
                    
                    if (!isGroupFound) {
                        XCTFail(@"Cannot find group in namespace: %@ group: %@", namespaceName, groupName);
                    }
                    
                } else {
                    XCTFail(@"Cannot request channel groups in namespace: %@", namespaceName);
                }
                
                dispatch_group_leave(testResGroup2);
            }];
            
            if ([GCDWrapper isGroup:testResGroup2 timeoutFiredValue:5]) {
                XCTFail(@"Timeout is fired. Cannot add channel to group: %@ %@", channelName, groupName);
                dispatch_group_leave(testResGroup2);
            }
        }
    }
}

@end
