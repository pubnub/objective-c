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
    NSArray *names = @[@"test", @"test:test", @"test_test:test", @"test_test:test:test"];
    
    PNConfiguration *configuration = [PNConfiguration configurationForOrigin:kTestPNOriginHost publishKey:kTestPNPublishKey subscribeKey:kTestPNSubscriptionKey secretKey:nil];
    
    _pubNub = [PubNub clientWithConfiguration:configuration];
    
    [_pubNub connect];
    
    for (NSString *groupName in names) {
        PNChannelGroup *group = [PNChannelGroup channelGroupWithName:groupName];
        
        XCTAssertNotNil(group, @"Group cannot be created: %@", groupName);
        
        dispatch_group_t testResGroup = dispatch_group_create();
        
        dispatch_group_enter(testResGroup);
        
        NSString *channelName = [NSString stringWithFormat:@"test_%lu", (unsigned long)[names indexOfObject:groupName]];
        
        // it means we subscribe to group in default namespace
        if ([groupName rangeOfString:kNamespaceSeparatorSymbol].location == NSNotFound) {
            
//            [_pubNub addChannels:@[[PNChannel channelWithName:channelName]] toGroup:group withCompletionHandlingBlock:^(PNChannelGroup *channelGroup, NSArray *channels, PNError *error) {
//                
//                if (!error) {
//                    // TODO: check if we really subscribed to it?
//                } else {
//                    XCTFail(@"Cannot add channel to group: %@ %@", channelName, groupName);
//                }
//                
//                dispatch_group_leave(testResGroup);
//            }];
//            
            if ([GCDWrapper isGroup:testResGroup timeoutFiredValue:10]) {
                XCTFail(@"Timeout is fired. Cannot add channel to group: %@ %@", channelName, groupName);
//                dispatch_group_leave(testResGroup);
            }
//
//            testResGroup = NULL;
//            
//            NSLog(@"Wait stop.");
        }
    }
}

@end
