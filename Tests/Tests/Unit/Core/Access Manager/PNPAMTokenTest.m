/**
 * @author Serhii Mamontov
 * @copyright © 2010-2019 PubNub, Inc.
 */
#import <PubNub/PubNub+CorePrivate.h>
#import "PNRecordableTestCase.h"
#import <PubNub/PubNub.h>
#import <OCMock/OCMock.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Interface declaration

@interface PNPAMTokenTest : PNRecordableTestCase

#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark - Tests

@implementation PNPAMTokenTest


#pragma mark - VCR configuration

- (BOOL)shouldSetupVCR {
    return NO;
}


#pragma mark - Tests :: Builder

- (void)testItShouldParseToken {
    NSString *base64Token = @"qEF2AkF0GmEI03xDdHRsGDxDcmVzpURjaGFuoWljaGFubmVsLTEY70NncnChb2NoYW5uZWxfZ3JvdXAtMQVDdXNyoENzcGOgRHV1aWShZnV1aWQtMRhoQ3BhdKVEY2hhbqFtXmNoYW5uZWwtXFMqJBjvQ2dycKF0XjpjaGFubmVsX2dyb3VwLVxTKiQFQ3VzcqBDc3BjoER1dWlkoWpedXVpZC1cUyokGGhEbWV0YaBEdXVpZHR0ZXN0LWF1dGhvcml6ZWQtdXVpZENzaWdYIPpU-vCe9rkpYs87YUrFNWkyNq8CVvmKwEjVinnDrJJc";
    
    PNPAMToken *token = [self.client parseAuthToken:base64Token];
    
    XCTAssertNotNil(token.resources, @"'resources' is missing");
    XCTAssertNotNil(token.patterns, @"'patterns' is missing");
    
    XCTAssertNotNil(token.error);
    XCTAssertEqual(token.error.code, PNAuthErrorPAMTokenWrongUUID);

    XCTAssertEqualObjects(token.authorizedUUID, @"test-authorized-uuid");
    XCTAssertEqual(token.resources.channels.count, 1);
    XCTAssertEqual(token.resources.groups.count, 1);
    XCTAssertEqual(token.resources.uuids.count, 1);
    XCTAssertEqual(token.patterns.channels.count, 1);
    XCTAssertEqual(token.patterns.groups.count, 1);
    XCTAssertEqual(token.patterns.uuids.count, 1);
    
    XCTAssertEqual(token.resources.channels[@"channel-1"].value, PNPAMPermissionAll);
    XCTAssertEqual(token.resources.groups[@"channel_group-1"].value, PNPAMPermissionRead | PNPAMPermissionManage);
    XCTAssertEqual(token.resources.uuids[@"uuid-1"].value, PNPAMPermissionDelete | PNPAMPermissionGet | PNPAMPermissionUpdate);
    XCTAssertEqual(token.patterns.channels[@"^channel-\\S*$"].value, PNPAMPermissionAll);
    XCTAssertEqual(token.patterns.groups[@"^:channel_group-\\S*$"].value, PNPAMPermissionRead | PNPAMPermissionManage);
    XCTAssertEqual(token.patterns.uuids[@"^uuid-\\S*$"].value, PNPAMPermissionDelete | PNPAMPermissionGet | PNPAMPermissionUpdate);
    XCTAssertNil(token.categories.channels);
    XCTAssertNil(token.categories.uuids);
}

- (void)testItShouldParseTokenWithCategoryAndReturnsCategoryAndResourcePermissions {
    NSString *base64Token = @"qWF2AmF0GmEJDXxjdHRsGDxjcmVzomRjaGFuoWljaGFubmVsLTEYIGR1dWlkoWZ1dWlkLTEYIGNwYXShZGNoYW6hbV5jaGFubmVsLVxTKiQYIGNjYXSiZGNoYW4YIGR1dWlkGCBkbWV0YaBkdXVpZHR0ZXN0LWF1dGhvcml6ZWQtdXVpZGNzaWdE-lT68A==";
    
    PNPAMToken *token = [self.client parseAuthToken:base64Token];
    
    XCTAssertNotNil(token.categories, @"'categories' is missing");
    XCTAssertNotNil(token.resources, @"'resources' is missing");
    XCTAssertNotNil(token.patterns, @"'patterns' is missing");
    XCTAssertEqualObjects(token.authorizedUUID, @"test-authorized-uuid");
    XCTAssertEqual(token.categories.channels.value, PNPAMPermissionGet);
    XCTAssertEqual(token.categories.uuids.value, PNPAMPermissionGet);
    
    XCTAssertEqual(token.resources.channels[@"channel-1"].value, PNPAMPermissionGet);
    XCTAssertEqual(token.resources.uuids[@"uuid-1"].value, PNPAMPermissionGet);
    XCTAssertEqual(token.patterns.channels[@"^channel-\\S*$"].value, PNPAMPermissionGet);
}

- (void)testItShouldParseTokenOnlyWithCategoryAndReturnsCategoryOnlyPermissions {
    NSString *base64Token = @"pmF2AmF0GmEJDXxjdHRsGDxjY2F0oWR1dWlkGCBkdXVpZHR0ZXN0LWF1dGhvcml6ZWQtdXVpZGNzaWdE-lT68A==";
    
    PNPAMToken *token = [self.client parseAuthToken:base64Token];
    
    XCTAssertNotNil(token.categories, @"'categories' is missing");
    XCTAssertNotNil(token.resources, @"'resources' is missing");
    XCTAssertNotNil(token.patterns, @"'patterns' is missing");
    
    XCTAssertEqualObjects(token.authorizedUUID, @"test-authorized-uuid");
    XCTAssertEqual(token.categories.uuids.value, PNPAMPermissionGet);
    XCTAssertNil(token.categories.channels);
    
    XCTAssertEqual(token.resources.channels.count, 0);
    XCTAssertEqual(token.resources.groups.count, 0);
    XCTAssertEqual(token.resources.uuids.count, 0);
    XCTAssertEqual(token.patterns.channels.count, 0);
    XCTAssertEqual(token.patterns.groups.count, 0);
    XCTAssertEqual(token.patterns.uuids.count, 0);
    XCTAssertNil(token.meta);
}

- (void)testItShouldSetToken {
    [self.client setAuthToken:@"access-token"];
    
    [self waitTask:@"auth-token-set" completionFor:2.f];
    XCTAssertEqualObjects([self.client.currentConfiguration valueForKey:@"authToken"], @"access-token");
}

@end
