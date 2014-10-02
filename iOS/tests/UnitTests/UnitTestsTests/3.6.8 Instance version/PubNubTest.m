//
//  PubNubTest.m
//  UnitTests
//
//  Created by Vadim Osovets on 9/30/14.
//  Copyright (c) 2014 Vadim Osovets. All rights reserved.
//

#import <XCTest/XCTest.h>

@interface PubNubTest : XCTestCase

<
PNDelegate
>

@end

@implementation PubNubTest {
    dispatch_group_t _resGroup;
    
    PubNub *_pubNub2;
    PubNub *_pubNub3;
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

#pragma mark - Test

/**
 Check that changes in clients identifiers doesn't affect any other instance of PubNub.
 */

- (void)testIdentifiers
{
    NSString *const kIdentifier1 = @"1";
    NSString *const kIdentifier2 = @"2";
    NSString *const kIdentifier3 = @"3";
    
    [PubNub setClientIdentifier:kIdentifier1];
    PubNub *pubNub2 = [PubNub clientWithConfiguration:[PNConfiguration defaultConfiguration] andDelegate:nil];
    [pubNub2 setClientIdentifier:kIdentifier2];
    
    PubNub *pubNub3 = [PubNub clientWithConfiguration:[PNConfiguration defaultConfiguration] andDelegate:self];
    [pubNub3 setClientIdentifier:kIdentifier3];
    
    // check different identifiers
    
    XCTAssertEqualObjects([PubNub clientIdentifier], kIdentifier1, @"Client identifiers inconsistent.");
    XCTAssertEqualObjects([pubNub2 clientIdentifier], kIdentifier2, @"Client identifiers inconsistent.");
    XCTAssertEqualObjects([pubNub3 clientIdentifier], kIdentifier3, @"Client identifiers inconsistent.");
}

/**
 Check that changes in clients configuration doesn't affect any other instance of PubNub.
 */

- (void)testConfigurations {
    
    NSString *const kStubConf2 = @"pubsub.com.origin2";
    NSString *const kStubConf3 = @"subkey3";
    
    PNConfiguration *configuration1 = [PNConfiguration defaultConfiguration];
    
    PNConfiguration *configuration2 = [PNConfiguration configurationForOrigin:kStubConf2
                                                                   publishKey:kStubConf2 subscribeKey:kStubConf2 secretKey:kStubConf2];
    
    PNConfiguration *configuration3 = [PNConfiguration configurationForOrigin:kStubConf3
                                                                   publishKey:kStubConf3 subscribeKey:kStubConf3 secretKey:kStubConf3];
;
    
    [PubNub setupWithConfiguration:configuration1
                       andDelegate:self];
    PubNub *pubNub2 = [PubNub clientWithConfiguration:configuration2
                                          andDelegate:nil];
    
    PubNub *pubNub3 = [PubNub clientWithConfiguration:configuration3
                                          andDelegate:self];
    
    // check different identifiers
    
    XCTAssertEqualObjects([PubNub configuration], configuration1, @"Client identifiers inconsistent.");
    XCTAssertEqualObjects([pubNub2 configuration], configuration2, @"Client identifiers inconsistent.");
    XCTAssertEqualObjects([pubNub3 configuration], configuration3, @"Client identifiers inconsistent.");
}

/**
 Check that connect/disconnect one client doesn't affect other clients.
 */

- (void)testConnects {
    
    PNConfiguration *configuration1 = [PNConfiguration defaultConfiguration];
    PNConfiguration *configuration2 = [PNConfiguration defaultConfiguration];
    PNConfiguration *configuration3 = [PNConfiguration defaultConfiguration];
    
    [PubNub setupWithConfiguration:configuration1
                       andDelegate:self];
    
    _pubNub2 = [PubNub clientWithConfiguration:configuration2
                                          andDelegate:self];
    
//    _pubNub2 = [[PubNub alloc] initWithConfiguration:configuration2 andDelegate:self];
    [_pubNub2 setupWithConfiguration:configuration2 andDelegate:self];
    
    _pubNub3 = [PubNub clientWithConfiguration:configuration3
                                          andDelegate:self];
    
    _resGroup = dispatch_group_create();
    
    dispatch_group_enter(_resGroup);
    dispatch_group_enter(_resGroup);
    dispatch_group_enter(_resGroup);
    
    // try to connect all of them
    [PubNub connectWithSuccessBlock:^(NSString *status) {
        dispatch_group_leave(_resGroup);
    } errorBlock:^(PNError *error) {
        dispatch_group_leave(_resGroup);
        
        XCTFail(@"Cannot connect service(singletone based): %@", error);
    }];
    
    [_pubNub2 connectWithSuccessBlock:^(NSString *status) {
        dispatch_group_leave(_resGroup);
    } errorBlock:^(PNError *error) {
        dispatch_group_leave(_resGroup);
        XCTFail(@"Cannot connect singletone instance.");
    }];
    
    [_pubNub3 connect];
    
    if([GCDWrapper isGroup:_resGroup timeoutFiredValue:kTestTestTimout]) {
        XCTFail(@"Timeout fired.");
    };
}

#pragma mark - PNDelegate

- (void)pubnubClient:(PubNub *)client didConnectToOrigin:(NSString *)origin {
    if ([client isEqual:_pubNub3]) {
        dispatch_group_leave(_resGroup);
    }
}

- (void)pubnubClient:(PubNub *)client connectionDidFailWithError:(PNError *)error {
    if ([client isEqual:_pubNub3]) {
        dispatch_group_leave(_resGroup);
        XCTFail(@"Cannot connect to origin with third instance.");
    }
}

@end
