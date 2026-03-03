#import <XCTest/XCTest.h>
#import <PubNub/PNPushNotificationManageRequest.h>
#import <PubNub/PNPushNotificationFetchRequest.h>
#import <PubNub/PNBasePushNotificationsRequest.h>
#import <PubNub/PNStructures.h>
#import "PNBaseRequest+Private.h"


#pragma mark Interface declaration

@interface PNPushRequestTest : XCTestCase

@end


#pragma mark - Tests

@implementation PNPushRequestTest


#pragma mark - Helper

- (NSData *)sampleDeviceToken {
    unsigned char bytes[] = {
        0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08,
        0x09, 0x0a, 0x0b, 0x0c, 0x0d, 0x0e, 0x0f, 0x10,
        0x11, 0x12, 0x13, 0x14, 0x15, 0x16, 0x17, 0x18,
        0x19, 0x1a, 0x1b, 0x1c, 0x1d, 0x1e, 0x1f, 0x20
    };
    return [NSData dataWithBytes:bytes length:sizeof(bytes)];
}


#pragma mark - PNPushNotificationManageRequest :: Add channels (APNS)

- (void)testItShouldCreateAddChannelsRequestWhenAPNSTokenProvided {
    NSData *token = [self sampleDeviceToken];
    PNPushNotificationManageRequest *request = [PNPushNotificationManageRequest requestToAddChannels:@[@"ch1", @"ch2"]
                                                                                   toDeviceWithToken:token
                                                                                            pushType:PNAPNSPush];

    XCTAssertNotNil(request);
    XCTAssertEqual(request.pushType, PNAPNSPush);
    XCTAssertEqualObjects(request.query[@"type"], @"apns");
}

- (void)testItShouldIncludeChannelsInAddQuery {
    NSData *token = [self sampleDeviceToken];
    PNPushNotificationManageRequest *request = [PNPushNotificationManageRequest requestToAddChannels:@[@"ch1", @"ch2"]
                                                                                   toDeviceWithToken:token
                                                                                            pushType:PNAPNSPush];

    NSString *addChannels = request.query[@"add"];

    XCTAssertNotNil(addChannels);
    XCTAssertTrue([addChannels containsString:@"ch1"]);
    XCTAssertTrue([addChannels containsString:@"ch2"]);
}

- (void)testItShouldRetainPushTokenWhenAPNSRequestCreated {
    NSData *token = [self sampleDeviceToken];
    PNPushNotificationManageRequest *request = [PNPushNotificationManageRequest requestToAddChannels:@[@"ch"]
                                                                                   toDeviceWithToken:token
                                                                                            pushType:PNAPNSPush];

    XCTAssertNotNil(request.pushToken);
    XCTAssertTrue([request.pushToken isKindOfClass:[NSData class]]);
}


#pragma mark - PNPushNotificationManageRequest :: Add channels (APNS2)

- (void)testItShouldCreateAddChannelsRequestWhenAPNS2TokenProvided {
    NSData *token = [self sampleDeviceToken];
    PNPushNotificationManageRequest *request = [PNPushNotificationManageRequest requestToAddChannels:@[@"ch1"]
                                                                                   toDeviceWithToken:token
                                                                                            pushType:PNAPNS2Push];

    XCTAssertNotNil(request);
    XCTAssertEqual(request.pushType, PNAPNS2Push);
}

- (void)testItShouldHaveDefaultEnvironmentInQueryWhenAPNS2RequestCreated {
    NSData *token = [self sampleDeviceToken];
    PNPushNotificationManageRequest *request = [PNPushNotificationManageRequest requestToAddChannels:@[@"ch"]
                                                                                   toDeviceWithToken:token
                                                                                            pushType:PNAPNS2Push];

    XCTAssertEqualObjects(request.query[@"environment"], @"development",
                          @"Default environment should be development");
}

- (void)testItShouldIncludeEnvironmentInQueryWhenAPNS2Configured {
    NSData *token = [self sampleDeviceToken];
    PNPushNotificationManageRequest *request = [PNPushNotificationManageRequest requestToAddChannels:@[@"ch"]
                                                                                   toDeviceWithToken:token
                                                                                            pushType:PNAPNS2Push];
    request.environment = PNAPNSProduction;

    XCTAssertEqualObjects(request.query[@"environment"], @"production");
}

- (void)testItShouldIncludeTopicInQueryWhenAPNS2Configured {
    NSData *token = [self sampleDeviceToken];
    PNPushNotificationManageRequest *request = [PNPushNotificationManageRequest requestToAddChannels:@[@"ch"]
                                                                                   toDeviceWithToken:token
                                                                                            pushType:PNAPNS2Push];
    request.topic = @"com.example.myapp";

    XCTAssertEqualObjects(request.query[@"topic"], @"com.example.myapp");
}


#pragma mark - PNPushNotificationManageRequest :: Add channels (FCM)

- (void)testItShouldCreateAddChannelsRequestWhenFCMTokenProvided {
    PNPushNotificationManageRequest *request = [PNPushNotificationManageRequest requestToAddChannels:@[@"ch1"]
                                                                                   toDeviceWithToken:@"fcm-device-token"
                                                                                            pushType:PNFCMPush];

    XCTAssertNotNil(request);
    XCTAssertEqualObjects(request.query[@"type"], @"gcm");
}

- (void)testItShouldRetainStringTokenWhenFCMRequestCreated {
    PNPushNotificationManageRequest *request = [PNPushNotificationManageRequest requestToAddChannels:@[@"ch"]
                                                                                   toDeviceWithToken:@"fcm-token-123"
                                                                                            pushType:PNFCMPush];

    XCTAssertNotNil(request.pushToken);
    XCTAssertTrue([request.pushToken isKindOfClass:[NSString class]]);
}


#pragma mark - PNPushNotificationManageRequest :: Remove channels

- (void)testItShouldIncludeChannelsInRemoveQuery {
    NSData *token = [self sampleDeviceToken];
    PNPushNotificationManageRequest *request = [PNPushNotificationManageRequest requestToRemoveChannels:@[@"ch1"]
                                                                                    fromDeviceWithToken:token
                                                                                               pushType:PNAPNSPush];

    XCTAssertNotNil(request);
    XCTAssertEqualObjects(request.query[@"remove"], @"ch1");
}


#pragma mark - PNPushNotificationManageRequest :: Remove all (device)

- (void)testItShouldCreateRemoveDeviceRequestWhenTokenProvided {
    NSData *token = [self sampleDeviceToken];
    PNPushNotificationManageRequest *request = [PNPushNotificationManageRequest requestToRemoveDeviceWithToken:token
                                                                                                     pushType:PNAPNSPush];

    XCTAssertNotNil(request);
    XCTAssertNil(request.channels, @"channels should be nil for remove device request");
}


#pragma mark - PNPushNotificationManageRequest :: Arbitrary query params

- (void)testItShouldIncludeArbitraryParametersInManageQuery {
    NSData *token = [self sampleDeviceToken];
    PNPushNotificationManageRequest *request = [PNPushNotificationManageRequest requestToAddChannels:@[@"ch"]
                                                                                   toDeviceWithToken:token
                                                                                            pushType:PNAPNSPush];
    request.arbitraryQueryParameters = @{ @"key": @"value" };

    XCTAssertEqualObjects(request.query[@"key"], @"value");
}


#pragma mark - PNPushNotificationManageRequest :: Validation

- (void)testItShouldPassValidationWhenAddChannelsWithAPNSToken {
    NSData *token = [self sampleDeviceToken];
    PNPushNotificationManageRequest *request = [PNPushNotificationManageRequest requestToAddChannels:@[@"ch"]
                                                                                   toDeviceWithToken:token
                                                                                            pushType:PNAPNSPush];

    XCTAssertNil([request validate]);
}

- (void)testItShouldPassValidationWhenAddChannelsWithFCMToken {
    PNPushNotificationManageRequest *request = [PNPushNotificationManageRequest requestToAddChannels:@[@"ch"]
                                                                                   toDeviceWithToken:@"fcm-token"
                                                                                            pushType:PNFCMPush];

    XCTAssertNil([request validate]);
}

- (void)testItShouldPassValidationWhenRemoveDeviceWithToken {
    NSData *token = [self sampleDeviceToken];
    PNPushNotificationManageRequest *request = [PNPushNotificationManageRequest requestToRemoveDeviceWithToken:token
                                                                                                     pushType:PNAPNSPush];

    XCTAssertNil([request validate]);
}

- (void)testItShouldFailValidationWhenAPNSTokenIsNotNSData {
    PNPushNotificationManageRequest *request = [PNPushNotificationManageRequest requestToAddChannels:@[@"ch"]
                                                                                   toDeviceWithToken:@"wrong-type"
                                                                                            pushType:PNAPNSPush];

    XCTAssertNotNil([request validate], @"Validation should fail when APNS token is not NSData");
}

- (void)testItShouldFailValidationWhenFCMTokenIsNotNSString {
    NSData *token = [self sampleDeviceToken];
    PNPushNotificationManageRequest *request = [PNPushNotificationManageRequest requestToAddChannels:@[@"ch"]
                                                                                   toDeviceWithToken:token
                                                                                            pushType:PNFCMPush];

    XCTAssertNotNil([request validate], @"Validation should fail when FCM token is not NSString");
}

- (void)testItShouldFailValidationWhenAddChannelsListIsEmpty {
    NSData *token = [self sampleDeviceToken];
    PNPushNotificationManageRequest *request = [PNPushNotificationManageRequest requestToAddChannels:@[]
                                                                                   toDeviceWithToken:token
                                                                                            pushType:PNAPNSPush];

    XCTAssertNotNil([request validate], @"Validation should fail with empty channels list for add");
}

- (void)testItShouldFailValidationWhenAPNS2TopicIsEmptyAndBundleIdNil {
    NSData *token = [self sampleDeviceToken];
    PNPushNotificationManageRequest *request = [PNPushNotificationManageRequest requestToAddChannels:@[@"ch"]
                                                                                   toDeviceWithToken:token
                                                                                            pushType:PNAPNS2Push];
    request.topic = @"";

    // Validate returns an error when topic is empty (even though query falls back to bundle ID).
    PNError *error = [request validate];
    XCTAssertNotNil(error, @"Validation should fail when APNS2 topic is empty");
}


#pragma mark - PNPushNotificationFetchRequest :: Construction

- (void)testItShouldCreateFetchRequestWhenAPNSTokenProvided {
    NSData *token = [self sampleDeviceToken];
    PNPushNotificationFetchRequest *request = [PNPushNotificationFetchRequest requestWithDevicePushToken:token
                                                                                               pushType:PNAPNSPush];

    XCTAssertNotNil(request);
    XCTAssertEqualObjects(request.query[@"type"], @"apns");
}

- (void)testItShouldCreateFetchRequestWhenAPNS2TokenProvided {
    NSData *token = [self sampleDeviceToken];
    PNPushNotificationFetchRequest *request = [PNPushNotificationFetchRequest requestWithDevicePushToken:token
                                                                                               pushType:PNAPNS2Push];

    XCTAssertNotNil(request);
    XCTAssertEqual(request.pushType, PNAPNS2Push);
}

- (void)testItShouldCreateFetchRequestWhenFCMTokenProvided {
    PNPushNotificationFetchRequest *request = [PNPushNotificationFetchRequest requestWithDevicePushToken:@"fcm-token"
                                                                                               pushType:PNFCMPush];

    XCTAssertNotNil(request);
    XCTAssertEqualObjects(request.query[@"type"], @"gcm");
}

- (void)testItShouldHaveDefaultEnvironmentInQueryWhenFetchPushCreated {
    NSData *token = [self sampleDeviceToken];
    PNPushNotificationFetchRequest *request = [PNPushNotificationFetchRequest requestWithDevicePushToken:token
                                                                                               pushType:PNAPNS2Push];

    XCTAssertEqualObjects(request.query[@"environment"], @"development",
                          @"Default environment should be development");
}

- (void)testItShouldIncludeArbitraryParametersInFetchPushQuery {
    NSData *token = [self sampleDeviceToken];
    PNPushNotificationFetchRequest *request = [PNPushNotificationFetchRequest requestWithDevicePushToken:token
                                                                                               pushType:PNAPNSPush];
    request.arbitraryQueryParameters = @{ @"custom": @"param" };

    XCTAssertEqualObjects(request.query[@"custom"], @"param");
}

- (void)testItShouldIncludeEnvironmentAndTopicInQueryWhenFetchAPNS2Configured {
    NSData *token = [self sampleDeviceToken];
    PNPushNotificationFetchRequest *request = [PNPushNotificationFetchRequest requestWithDevicePushToken:token
                                                                                               pushType:PNAPNS2Push];
    request.environment = PNAPNSProduction;
    request.topic = @"com.example.app";

    XCTAssertEqualObjects(request.query[@"environment"], @"production");
    XCTAssertEqualObjects(request.query[@"topic"], @"com.example.app");
}


#pragma mark - PNPushNotificationFetchRequest :: Validation

- (void)testItShouldPassValidationWhenFetchWithAPNSToken {
    NSData *token = [self sampleDeviceToken];
    PNPushNotificationFetchRequest *request = [PNPushNotificationFetchRequest requestWithDevicePushToken:token
                                                                                               pushType:PNAPNSPush];

    XCTAssertNil([request validate]);
}

- (void)testItShouldPassValidationWhenFetchWithFCMToken {
    PNPushNotificationFetchRequest *request = [PNPushNotificationFetchRequest requestWithDevicePushToken:@"fcm-token"
                                                                                               pushType:PNFCMPush];

    XCTAssertNil([request validate]);
}

- (void)testItShouldFailValidationWhenFetchAPNSTokenIsNotNSData {
    PNPushNotificationFetchRequest *request = [PNPushNotificationFetchRequest requestWithDevicePushToken:@"wrong-type"
                                                                                               pushType:PNAPNSPush];

    XCTAssertNotNil([request validate], @"Validation should fail when APNS token is not NSData");
}

- (void)testItShouldFailValidationWhenFetchFCMTokenIsNotNSString {
    NSData *token = [self sampleDeviceToken];
    PNPushNotificationFetchRequest *request = [PNPushNotificationFetchRequest requestWithDevicePushToken:token
                                                                                               pushType:PNFCMPush];

    XCTAssertNotNil([request validate], @"Validation should fail when FCM token is not NSString");
}

- (void)testItShouldFailValidationWhenFetchTokenIsEmptyData {
    NSData *emptyToken = [NSData data];
    PNPushNotificationFetchRequest *request = [PNPushNotificationFetchRequest requestWithDevicePushToken:emptyToken
                                                                                               pushType:PNAPNSPush];

    XCTAssertNotNil([request validate], @"Validation should fail with empty NSData token");
}

- (void)testItShouldFailValidationWhenFetchTokenIsEmptyString {
    PNPushNotificationFetchRequest *request = [PNPushNotificationFetchRequest requestWithDevicePushToken:@""
                                                                                               pushType:PNFCMPush];

    XCTAssertNotNil([request validate], @"Validation should fail with empty string token");
}


#pragma mark -

@end
