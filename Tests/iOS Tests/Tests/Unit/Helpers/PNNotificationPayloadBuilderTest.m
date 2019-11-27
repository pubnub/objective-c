/**
* @author Serhii Mamontov
* @copyright © 2010-2019 PubNub, Inc.
*/
#import <XCTest/XCTest.h>
#import <PubNub/PNAPNSNotificationConfiguration+Private.h>
#import <PubNub/PNBaseNotificationPayload+Private.h>
#import <PubNub/PNAPNSNotificationPayload+Private.h>
#import <PubNub/PNAPNSNotificationTarget+Private.h>
#import <PubNub/PNHelpers.h>
#import <PubNub/PubNub.h>


NS_ASSUME_NONNULL_BEGIN

#pragma mark Test interface declaration

@interface PNNotificationPayloadBuilderTest : XCTestCase


# pragma mark - Information

/**
 * @brief Object to store keys created by platform-specific builder.
 */
@property (nonatomic, strong) NSMutableDictionary *platformPayloadStorage;

#pragma mark -


@end

NS_ASSUME_NONNULL_END


#pragma mark - Interface implementation

@implementation PNNotificationPayloadBuilderTest


#pragma mark - Setup / Tear down

- (void)setUp {
    [super setUp];
    
    
    self.platformPayloadStorage = [NSMutableDictionary new];
}


#pragma mark - Tests :: Notifications builder

- (void)testNotificationBuilderConstructor_ShouldPreparePlatformSpecificBuilders_WhenCalled {
    NSString *expectedTitle = [NSUUID UUID].UUIDString;
    NSString *expectedBody = [NSUUID UUID].UUIDString;
    
    
    PNNotificationsPayload *builder = [PNNotificationsPayload payloadsWithNotificationTitle:expectedTitle
                                                                                       body:expectedBody];
    
    XCTAssertNotNil(builder.apns);
    XCTAssertNotNil(builder.mpns);
    XCTAssertNotNil(builder.fcm);
}

- (void)testNotificationBuilderConstructor_ShouldPassTitleAndBodyToBuilders_WhenValuesPassed {
    NSString *expectedTitle = [NSUUID UUID].UUIDString;
    NSString *expectedBody = [NSUUID UUID].UUIDString;
    
    
    PNNotificationsPayload *builder = [PNNotificationsPayload payloadsWithNotificationTitle:expectedTitle
                                                                                       body:expectedBody];
    
    XCTAssertEqualObjects([[builder.apns dictionaryRepresentation] valueForKeyPath:@"aps.alert.title"], expectedTitle);
    XCTAssertEqualObjects([[builder.apns dictionaryRepresentation] valueForKeyPath:@"aps.alert.body"], expectedBody);
    XCTAssertEqualObjects([[builder.mpns dictionaryRepresentation] valueForKeyPath:@"title"], expectedTitle);
    XCTAssertEqualObjects([[builder.mpns dictionaryRepresentation] valueForKeyPath:@"back_content"], expectedBody);
    XCTAssertEqualObjects([[builder.fcm dictionaryRepresentation] valueForKeyPath:@"notification.title"], expectedTitle);
    XCTAssertEqualObjects([[builder.fcm dictionaryRepresentation] valueForKeyPath:@"notification.body"], expectedBody);
}

- (void)testNotificationSubtitle_ShouldPassToBuilders_WhenValueIsSet {
    NSString *expectedSubtitle = [NSUUID UUID].UUIDString;
    
    
    PNNotificationsPayload *builder = [PNNotificationsPayload payloadsWithNotificationTitle:[NSUUID UUID].UUIDString
                                                                                       body:[NSUUID UUID].UUIDString];
    builder.subtitle = expectedSubtitle;
    
    XCTAssertEqualObjects([[builder.apns dictionaryRepresentation] valueForKeyPath:@"aps.alert.subtitle"], expectedSubtitle);
    XCTAssertEqualObjects([[builder.mpns dictionaryRepresentation] valueForKeyPath:@"back_title"], expectedSubtitle);
    XCTAssertEqual(builder.fcm.notification.count, 2);
}

- (void)testNotificationBadge_ShouldPassToBuilders_WhenValueIsSet {
    NSNumber *expectedBadge = @11;
    
    
    PNNotificationsPayload *builder = [PNNotificationsPayload payloadsWithNotificationTitle:[NSUUID UUID].UUIDString
                                                                                       body:[NSUUID UUID].UUIDString];
    builder.badge = expectedBadge;
    
    XCTAssertEqualObjects([[builder.apns dictionaryRepresentation] valueForKeyPath:@"aps.badge"], expectedBadge);
    XCTAssertEqualObjects([[builder.mpns dictionaryRepresentation] valueForKeyPath:@"count"], expectedBadge);
    XCTAssertEqual(builder.fcm.notification.count, 2);
}

- (void)testNotificationSound_ShouldPassToBuilders_WhenValueIsSet {
    NSString *expectedSound = [NSUUID UUID].UUIDString;
    
    
    PNNotificationsPayload *builder = [PNNotificationsPayload payloadsWithNotificationTitle:[NSUUID UUID].UUIDString
                                                                                       body:[NSUUID UUID].UUIDString];
    builder.sound = expectedSound;
    
    XCTAssertEqualObjects([[builder.apns dictionaryRepresentation] valueForKeyPath:@"aps.sound"], expectedSound);
    XCTAssertEqual(builder.mpns.payload.count, 2);
    XCTAssertEqualObjects([[builder.fcm dictionaryRepresentation] valueForKeyPath:@"notification.sound"], expectedSound);
}

- (void)testNotificationDebugging_ShouldSetDebugFlag_WhenDebuggingSetToYES {
    PNNotificationsPayload *builder = [PNNotificationsPayload payloadsWithNotificationTitle:[NSUUID UUID].UUIDString
                                                                                       body:[NSUUID UUID].UUIDString];
    builder.debugging = YES;
    
    XCTAssertEqualObjects([builder dictionaryRepresentationFor:PNAPNSPush][@"pn_debug"], @YES);
}

- (void)testNotificationDictionaryRepresentation_ShouldProvidePayloadForAPNSAndFCM_WhenCalledWithAPNSAndFCMPushTypes {
    NSString *expectedTitle = [NSUUID UUID].UUIDString;
    NSString *expectedBody = [NSUUID UUID].UUIDString;
    NSDictionary *expectedPayload = @{
        @"pn_apns": @{
            @"aps": @{
                @"alert": @{
                    @"title": expectedTitle,
                    @"body": expectedBody
                }
            }
        },
        @"pn_gcm": @{
            @"notification": @{
                @"title": expectedTitle,
                @"body": expectedBody
            }
        }
    };
    
    PNNotificationsPayload *builder = [PNNotificationsPayload payloadsWithNotificationTitle:expectedTitle
                                                                                       body:expectedBody];
    
    XCTAssertEqualObjects([builder dictionaryRepresentationFor:PNAPNSPush|PNFCMPush], expectedPayload);
}

- (void)testNotificationDictionaryRepresentation_ShouldProvidePayloadForAPNS2AndFCM_WhenCalledWithAPNSAndFCMPushTypes {
    NSString *expectedTitle = [NSUUID UUID].UUIDString;
    NSString *expectedBody = [NSUUID UUID].UUIDString;
    NSDictionary *expectedPayload = @{
        @"pn_apns": @{
            @"aps": @{
                @"alert": @{
                    @"title": expectedTitle,
                    @"body": expectedBody
                }
            },
            @"pn_push": @[
                @{
                    @"targets": @[
                        @{
                            @"environment": @"development",
                            @"topic": NSBundle.mainBundle.bundleIdentifier
                        }
                    ],
                    @"version": @"v2"
                }
            ]
        },
        @"pn_gcm": @{
            @"notification": @{
                @"title": expectedTitle,
                @"body": expectedBody
            }
        }
    };
    
    PNNotificationsPayload *builder = [PNNotificationsPayload payloadsWithNotificationTitle:expectedTitle
                                                                                       body:expectedBody];
    
    XCTAssertEqualObjects([builder dictionaryRepresentationFor:PNAPNS2Push|PNFCMPush], expectedPayload);
}


#pragma mark - Tests :: APNS builder

- (void)testAPNSConstructor_ShouldSetDefaultStructure_WhenCalledOnlyWithStorage {
    PNAPNSNotificationPayload *builder = [PNAPNSNotificationPayload payloadWithStorage:self.platformPayloadStorage
                                                                     notificationTitle:nil
                                                                                  body:nil];
    
    XCTAssertNotNil(builder);
    XCTAssertTrue([self.platformPayloadStorage[@"aps"] isKindOfClass:[NSMutableDictionary class]]);
    XCTAssertTrue([self.platformPayloadStorage[@"aps"][@"alert"] isKindOfClass:[NSMutableDictionary class]]);
    XCTAssertEqual(((NSDictionary *)self.platformPayloadStorage[@"aps"]).count, 1);
    XCTAssertEqual(((NSDictionary *)self.platformPayloadStorage[@"aps"][@"alert"]).count, 0);
}

- (void)testAPNSConstructor_ShouldSetNotificationTitleBody_WhenCalledWithAllFieldsSet {
    NSString *expectedTitle = [NSUUID UUID].UUIDString;
    NSString *expectedBody = [NSUUID UUID].UUIDString;
    
    
    [PNAPNSNotificationPayload payloadWithStorage:self.platformPayloadStorage
                                notificationTitle:expectedTitle
                                             body:expectedBody];
    
    XCTAssertEqualObjects(self.platformPayloadStorage[@"aps"][@"alert"][@"title"], expectedTitle);
    XCTAssertEqualObjects(self.platformPayloadStorage[@"aps"][@"alert"][@"body"], expectedBody);
}

- (void)testAPNSSubtitle_ShouldSet_WhenSubtitlePassedToBuilder {
    NSString *expectedSubtitle = [NSUUID UUID].UUIDString;
    
    
    PNAPNSNotificationPayload *builder = [PNAPNSNotificationPayload payloadWithStorage:self.platformPayloadStorage
                                                                     notificationTitle:nil
                                                                                  body:nil];
    builder.subtitle = expectedSubtitle;
    
    XCTAssertEqualObjects(self.platformPayloadStorage[@"aps"][@"alert"][@"subtitle"], expectedSubtitle);
}

- (void)testAPNSSubtitle_ShouldNotSet_WhenNilPassedToBuilder {
    PNAPNSNotificationPayload *builder = [PNAPNSNotificationPayload payloadWithStorage:self.platformPayloadStorage
                                                                     notificationTitle:nil
                                                                                  body:nil];
    builder.subtitle = nil;
    
    XCTAssertNil(self.platformPayloadStorage[@"aps"][@"alert"][@"subtitle"]);
}

- (void)testAPNSBody_ShouldSet_WhenBodyPassedToBuilder {
    NSString *expectedBody = [NSUUID UUID].UUIDString;
    
    
    PNAPNSNotificationPayload *builder = [PNAPNSNotificationPayload payloadWithStorage:self.platformPayloadStorage
                                                                     notificationTitle:nil
                                                                                  body:nil];
    builder.body = expectedBody;
    
    XCTAssertEqualObjects(self.platformPayloadStorage[@"aps"][@"alert"][@"body"], expectedBody);
}

- (void)testAPNSBody_ShouldNotSet_WhenNilPassedToBuilder {
    PNAPNSNotificationPayload *builder = [PNAPNSNotificationPayload payloadWithStorage:self.platformPayloadStorage
                                                                     notificationTitle:nil
                                                                                  body:nil];
    builder.body = nil;
    
    XCTAssertNil(self.platformPayloadStorage[@"aps"][@"alert"][@"body"]);
}

- (void)testAPNSBadge_ShouldSet_WhenBadgePassedToBuilder {
    NSNumber *expectedBadge = @26;
    
    
    PNAPNSNotificationPayload *builder = [PNAPNSNotificationPayload payloadWithStorage:self.platformPayloadStorage
                                                                     notificationTitle:nil
                                                                                  body:nil];
    builder.badge = expectedBadge;
    
    XCTAssertEqualObjects(self.platformPayloadStorage[@"aps"][@"badge"], expectedBadge);
}

- (void)testAPNSBadge_ShouldNotSet_WhenNilPassedToBuilder {
    PNAPNSNotificationPayload *builder = [PNAPNSNotificationPayload payloadWithStorage:self.platformPayloadStorage
                                                                     notificationTitle:nil
                                                                                  body:nil];
    builder.badge = nil;
    
    XCTAssertNil(self.platformPayloadStorage[@"aps"][@"badge"]);
}

- (void)testAPNSSound_ShouldSet_WhenSoundPassedToBuilder {
    NSString *expectedSound = [NSUUID UUID].UUIDString;
    
    
    PNAPNSNotificationPayload *builder = [PNAPNSNotificationPayload payloadWithStorage:self.platformPayloadStorage
                                                                     notificationTitle:nil
                                                                                  body:nil];
    builder.sound = expectedSound;
    
    XCTAssertEqualObjects(self.platformPayloadStorage[@"aps"][@"sound"], expectedSound);
}

- (void)testAPNSSound_ShouldNotSet_WhenNilPassedToBuilder {
    PNAPNSNotificationPayload *builder = [PNAPNSNotificationPayload payloadWithStorage:self.platformPayloadStorage
                                                                     notificationTitle:nil
                                                                                  body:nil];
    builder.sound = nil;
    
    XCTAssertNil(self.platformPayloadStorage[@"aps"][@"sound"]);
}

- (void)testAPNSDictionaryRepresentation_ShouldBeNil_WhenNoInformationPassed {
    PNAPNSNotificationPayload *builder = [PNAPNSNotificationPayload payloadWithStorage:self.platformPayloadStorage
                                                                     notificationTitle:nil
                                                                                  body:nil];
    
    XCTAssertNil([builder dictionaryRepresentation]);
}

- (void)testAPNSDictionaryRepresentation_ShouldSetContentAvailable_WhenSilentSetToYES {
    PNAPNSNotificationPayload *builder = [PNAPNSNotificationPayload payloadWithStorage:self.platformPayloadStorage
                                                                     notificationTitle:[NSUUID UUID].UUIDString
                                                                                  body:[NSUUID UUID].UUIDString];
    builder.sound = [NSUUID UUID].UUIDString;
    builder.badge = @20;
    builder.silent = YES;
    
    XCTAssertEqualObjects([builder dictionaryRepresentation][@"aps"][@"content-available"], @1);
    XCTAssertNil([builder dictionaryRepresentation][@"aps"][@"badge"]);
    XCTAssertNil([builder dictionaryRepresentation][@"aps"][@"sound"]);
    XCTAssertNil([builder dictionaryRepresentation][@"aps"][@"alert"]);
}

- (void)testAPNSDictionaryRepresentation_ShouldBeValid_WhenAllInformationPassed {
    NSString *expectedSubtitle = [NSUUID UUID].UUIDString;
    NSString *expectedTitle = [NSUUID UUID].UUIDString;
    NSString *expectedSound = [NSUUID UUID].UUIDString;
    NSString *expectedBody = [NSUUID UUID].UUIDString;
    NSNumber *expectedBadge = @26;
    NSDictionary *expectedPayload = @{
        @"aps": @{
            @"alert": @{
                @"title": expectedTitle,
                @"subtitle": expectedSubtitle,
                @"body": expectedBody
            },
            @"badge": expectedBadge,
            @"sound": expectedSound
        }
    };
    
    
    PNAPNSNotificationPayload *builder = [PNAPNSNotificationPayload payloadWithStorage:self.platformPayloadStorage
                                                                     notificationTitle:expectedTitle
                                                                                  body:expectedBody];
    builder.subtitle = expectedSubtitle;
    builder.badge = expectedBadge;
    builder.sound = expectedSound;
    
    XCTAssertEqualObjects([builder dictionaryRepresentation], expectedPayload);
}


#pragma mark - Tests :: APNS over HTTP/2 builder

- (void)testAPNS2DictionaryRepresentation_ShouldSetDefaultConfiguration_WhenCalledForAPNS2PushTypeWithOutConfiguration {
    NSString *expectedSubtitle = [NSUUID UUID].UUIDString;
    NSString *expectedTitle = [NSUUID UUID].UUIDString;
    NSString *expectedSound = [NSUUID UUID].UUIDString;
    NSString *expectedBody = [NSUUID UUID].UUIDString;
    NSNumber *expectedBadge = @26;
    NSDictionary *expectedPayload = @{
        @"aps": @{
            @"alert": @{
                @"title": expectedTitle,
                @"subtitle": expectedSubtitle,
                @"body": expectedBody
            },
            @"badge": expectedBadge,
            @"sound": expectedSound
        },
        @"pn_push": @[
            @{
                @"version": @"v2",
                @"targets": @[
                    @{
                        @"environment": @"development",
                        @"topic": NSBundle.mainBundle.bundleIdentifier
                    }
                ]
            }
        ]
    };
    
    
    PNAPNSNotificationPayload *builder = [PNAPNSNotificationPayload payloadWithStorage:self.platformPayloadStorage
                                                                     notificationTitle:expectedTitle
                                                                                  body:expectedBody];
    builder.subtitle = expectedSubtitle;
    builder.badge = expectedBadge;
    builder.sound = expectedSound;
    builder.apnsPushType = PNAPNS2Push;
    
    XCTAssertEqualObjects([builder dictionaryRepresentation], expectedPayload);
}


#pragma mark - Tests :: APNS over HTTP/2 builder :: Configuration

- (void)testAPNSConfigurationConstructor_ShouldCreateWithDefaultTarget_WhenCalledDefault {
    NSDictionary *expectedConfiguration = @{
        @"version": @"v2",
        @"targets": @[
            @{
                @"environment": @"development",
                @"topic": NSBundle.mainBundle.bundleIdentifier
            }
        ]
    };
    
    
    PNAPNSNotificationConfiguration *configuration = [PNAPNSNotificationConfiguration defaultConfiguration];
    
    XCTAssertEqualObjects([configuration dictionaryRepresentation], expectedConfiguration);
}

- (void)testAPNSConfigurationConstructor_ShouldCreateWithDefaultTarget_WhenCalledWithEmptyTargetsList {
    NSDictionary *expectedConfiguration = @{
        @"version": @"v2",
        @"targets": @[
            @{
                @"environment": @"development",
                @"topic": NSBundle.mainBundle.bundleIdentifier
            }
        ]
    };
    
    
    PNAPNSNotificationConfiguration *configuration = [PNAPNSNotificationConfiguration configurationWithCollapseID:nil
                                                                                                   expirationDate:nil
                                                                                                          targets:@[]];
    
    XCTAssertEqualObjects([configuration dictionaryRepresentation], expectedConfiguration);
}

- (void)testAPNSConfigurationConstructor_ShouldCreateForTarget_WhenCalledWithSpecificTarget {
    NSString *expectedTopic = [NSUUID UUID].UUIDString;
    PNAPNSNotificationTarget *target = [PNAPNSNotificationTarget targetForTopic:expectedTopic];
    NSDictionary *expectedConfiguration = @{
        @"version": @"v2",
        @"targets": @[
            @{
                @"environment": @"development",
                @"topic": expectedTopic
            }
        ]
    };
    
    
    PNAPNSNotificationConfiguration *configuration = [PNAPNSNotificationConfiguration configurationWithTargets:@[target]];
    
    XCTAssertEqualObjects([configuration dictionaryRepresentation], expectedConfiguration);
}

- (void)testAPNSConfigurationConstructor_ShouldCreateSpecific_WhenCalledCollapseIDExpirationAndTargets {
    PNAPNSNotificationTarget *target = [PNAPNSNotificationTarget defaultTarget];
    NSDate *expectedExpirationDate = [NSDate dateWithTimeIntervalSince1970:1574892507];
    NSString *expectedCollapseID = [NSUUID UUID].UUIDString;
    NSDictionary *expectedConfiguration = @{
        @"collapse_id": expectedCollapseID,
        @"expiration": @"2019-11-27T22:08:27Z",
        @"version": @"v2",
        @"targets": @[
            @{
                @"environment": @"development",
                @"topic": NSBundle.mainBundle.bundleIdentifier
            }
        ]
    };
    
    PNAPNSNotificationConfiguration *configuration = [PNAPNSNotificationConfiguration configurationWithCollapseID:expectedCollapseID
                                                                                                   expirationDate:expectedExpirationDate
                                                                                                          targets:@[target]];
    
    XCTAssertEqualObjects([configuration dictionaryRepresentation], expectedConfiguration);
}


#pragma mark - Tests :: APNS over HTTP/2 builder :: Target

- (void)testAPNSTarget_ShouldCreateForDevelopmentEnvironmentAndBundleIdentifier_WhenCalledDefault {
    NSDictionary *expectedTarget = @{
        @"environment": @"development",
        @"topic": NSBundle.mainBundle.bundleIdentifier
    };
    
    
    PNAPNSNotificationTarget *target = [PNAPNSNotificationTarget defaultTarget];
    
    XCTAssertEqualObjects([target dictionaryRepresentation], expectedTarget);
}

- (void)testAPNSTarget_ShouldCreateForDevelopmentEnvironment_WhenCalledWithTopic {
    NSString *expectedTopic = [NSUUID UUID].UUIDString;
    NSDictionary *expectedTarget = @{ @"environment": @"development", @"topic": expectedTopic };
    
    
    PNAPNSNotificationTarget *target = [PNAPNSNotificationTarget targetForTopic:expectedTopic];
    
    XCTAssertEqualObjects([target dictionaryRepresentation], expectedTarget);
}

- (void)testAPNSTarget_ShouldCreateSpecific_WhenCalledWithTopicAndEnvironment {
    NSData *excludedDevice = [@"000000000000000000000000000000" dataUsingEncoding:NSUTF8StringEncoding];
    NSString *expectedTopic = [NSUUID UUID].UUIDString;
    NSDictionary *expectedTarget = @{
        @"environment": @"production",
        @"topic": expectedTopic,
        @"excluded_devices": @[[PNData HEXFromDevicePushToken:excludedDevice]]
    };
    
    
    PNAPNSNotificationTarget *target = [PNAPNSNotificationTarget targetForTopic:expectedTopic
                                                                  inEnvironment:PNAPNSProduction
                                                            withExcludedDevices:@[excludedDevice]];
    
    XCTAssertEqualObjects([target dictionaryRepresentation], expectedTarget);
}


#pragma mark - Tests :: MPNS builder

- (void)testMPNSConstructor_ShouldSetNotificationTitleBody_WhenCalledWithAllFieldsSet {
    NSString *expectedTitle = [NSUUID UUID].UUIDString;
    NSString *expectedBody = [NSUUID UUID].UUIDString;
    
    
    [PNMPNSNotificationPayload payloadWithStorage:self.platformPayloadStorage
                                notificationTitle:expectedTitle
                                             body:expectedBody];
    
    XCTAssertEqualObjects(self.platformPayloadStorage[@"title"], expectedTitle);
    XCTAssertEqualObjects(self.platformPayloadStorage[@"back_content"], expectedBody);
}

- (void)testMPNSBackTitle_ShouldSet_WhenSubtitlePassedToBuilder {
    NSString *expectedSubtitle = [NSUUID UUID].UUIDString;
    
    
    PNMPNSNotificationPayload *builder = [PNMPNSNotificationPayload payloadWithStorage:self.platformPayloadStorage
                                                                     notificationTitle:nil
                                                                                  body:nil];
    builder.subtitle = expectedSubtitle;
    
    XCTAssertEqualObjects(self.platformPayloadStorage[@"back_title"], expectedSubtitle);
}

- (void)testMPNSBackTitle_ShouldSet_WhenBackTitlePassedToBuilder {
    NSString *expectedSubtitle = [NSUUID UUID].UUIDString;
    
    
    PNMPNSNotificationPayload *builder = [PNMPNSNotificationPayload payloadWithStorage:self.platformPayloadStorage
                                                                     notificationTitle:nil
                                                                                  body:nil];
    builder.backTitle = expectedSubtitle;
    
    XCTAssertEqualObjects(self.platformPayloadStorage[@"back_title"], expectedSubtitle);
}

- (void)testMPNSBackContent_ShouldSet_WhenBodyPassedToBuilder {
    NSString *expectedBody = [NSUUID UUID].UUIDString;
    
    
    PNMPNSNotificationPayload *builder = [PNMPNSNotificationPayload payloadWithStorage:self.platformPayloadStorage
                                                                     notificationTitle:nil
                                                                                  body:nil];
    builder.body = expectedBody;
    
    XCTAssertEqualObjects(self.platformPayloadStorage[@"back_content"], expectedBody);
}

- (void)testMPNSBackContent_ShouldSet_WhenBackContentPassedToBuilder {
    NSString *expectedBody = [NSUUID UUID].UUIDString;
    
    
    PNMPNSNotificationPayload *builder = [PNMPNSNotificationPayload payloadWithStorage:self.platformPayloadStorage
                                                                     notificationTitle:nil
                                                                                  body:nil];
    builder.backContent = expectedBody;
    
    XCTAssertEqualObjects(self.platformPayloadStorage[@"back_content"], expectedBody);
}

- (void)testMPNSCount_ShouldSet_WhenBadgePassedToBuilder {
    NSNumber *expectedBadge = @26;
    
    
    PNMPNSNotificationPayload *builder = [PNMPNSNotificationPayload payloadWithStorage:self.platformPayloadStorage
                                                                     notificationTitle:nil
                                                                                  body:nil];
    builder.badge = expectedBadge;
    
    XCTAssertEqualObjects(self.platformPayloadStorage[@"count"], expectedBadge);
}

- (void)testMPNSCount_ShouldSet_WhenCountPassedToBuilder {
    NSNumber *expectedBadge = @26;
    
    
    PNMPNSNotificationPayload *builder = [PNMPNSNotificationPayload payloadWithStorage:self.platformPayloadStorage
                                                                     notificationTitle:nil
                                                                                  body:nil];
    builder.count = expectedBadge;
    
    XCTAssertEqualObjects(self.platformPayloadStorage[@"count"], expectedBadge);
}

- (void)testMPNSDictionaryRepresentation_ShouldBeNil_WhenNoInformationPassed {
    PNMPNSNotificationPayload *builder = [PNMPNSNotificationPayload payloadWithStorage:self.platformPayloadStorage
                                                                     notificationTitle:nil
                                                                                  body:nil];
    
    XCTAssertNil([builder dictionaryRepresentation]);
}

- (void)testMPNSDictionaryRepresentation_ShouldBeValid_WhenAllInformationPassed {
    NSString *expectedSubtitle = [NSUUID UUID].UUIDString;
    NSString *expectedTitle = [NSUUID UUID].UUIDString;
    NSString *expectedBody = [NSUUID UUID].UUIDString;
    NSNumber *expectedCount = @26;
    NSDictionary *expectedPayload = @{
        @"type": @"flip",
        @"title": expectedTitle,
        @"back_title": expectedSubtitle,
        @"back_content": expectedBody,
        @"count": expectedCount
    };
    
    
    PNMPNSNotificationPayload *builder = [PNMPNSNotificationPayload payloadWithStorage:self.platformPayloadStorage
                                                                     notificationTitle:expectedTitle
                                                                                  body:expectedBody];
    builder.type = @"flip";
    builder.subtitle = expectedSubtitle;
    builder.count = expectedCount;
    
    XCTAssertEqualObjects([builder dictionaryRepresentation], expectedPayload);
}


#pragma mark - Tests :: FCM builder

- (void)testFCMConstructor_ShouldSetDefaultStructure_WhenCalledOnlyWithStorage {
    PNFCMNotificationPayload *builder = [PNFCMNotificationPayload payloadWithStorage:self.platformPayloadStorage
                                                                   notificationTitle:nil
                                                                                body:nil];
    
    XCTAssertNotNil(builder);
    XCTAssertTrue([self.platformPayloadStorage[@"notification"] isKindOfClass:[NSMutableDictionary class]]);
    XCTAssertTrue([self.platformPayloadStorage[@"data"] isKindOfClass:[NSMutableDictionary class]]);
}

- (void)testFCMSConstructor_ShouldSetNotificationTitleBody_WhenCalledWithAllFieldsSet {
    NSString *expectedTitle = [NSUUID UUID].UUIDString;
    NSString *expectedBody = [NSUUID UUID].UUIDString;
    
    
    [PNFCMNotificationPayload payloadWithStorage:self.platformPayloadStorage
                               notificationTitle:expectedTitle
                                            body:expectedBody];
    
    XCTAssertEqualObjects(self.platformPayloadStorage[@"notification"][@"title"], expectedTitle);
    XCTAssertEqualObjects(self.platformPayloadStorage[@"notification"][@"body"], expectedBody);
}

- (void)testFCMSubtitle_ShouldNotSet_WhenPassedToBuilderBecauseNotSupported {
    PNFCMNotificationPayload *builder = [PNFCMNotificationPayload payloadWithStorage:self.platformPayloadStorage
                                                                   notificationTitle:nil
                                                                                body:nil];
    builder.subtitle = [NSUUID UUID].UUIDString;
    
    XCTAssertEqual(builder.notification.count, 0);
}

- (void)testFCMBody_ShouldSet_WhenBodyPassedToBuilder {
    NSString *expectedBody = [NSUUID UUID].UUIDString;
    
    
    PNFCMNotificationPayload *builder = [PNFCMNotificationPayload payloadWithStorage:self.platformPayloadStorage
                                                                   notificationTitle:nil
                                                                                body:nil];
    builder.body = expectedBody;
    
    XCTAssertEqualObjects(self.platformPayloadStorage[@"notification"][@"body"], expectedBody);
}

- (void)testFCMBody_ShouldNotSet_WhenNilPassedToBuilder {
    PNFCMNotificationPayload *builder = [PNFCMNotificationPayload payloadWithStorage:self.platformPayloadStorage
                                                                   notificationTitle:nil
                                                                                body:nil];
    builder.body = nil;
    
    XCTAssertNil(self.platformPayloadStorage[@"notification"][@"body"]);
}

- (void)testFCMSBadge_ShouldNotSet_WhenPassedToBuilderBecauseNotSupported {
    PNFCMNotificationPayload *builder = [PNFCMNotificationPayload payloadWithStorage:self.platformPayloadStorage
                                                                   notificationTitle:nil
                                                                                body:nil];
    builder.badge = @30;
    
    XCTAssertEqual(builder.notification.count, 0);
}

- (void)testFCMSSound_ShouldSet_WhenSoundPassedToBuilder {
    NSString *expectedSound = [NSUUID UUID].UUIDString;
    
    
    PNFCMNotificationPayload *builder = [PNFCMNotificationPayload payloadWithStorage:self.platformPayloadStorage
                                                                   notificationTitle:nil
                                                                                body:nil];
    builder.sound = expectedSound;
    
    XCTAssertEqualObjects(self.platformPayloadStorage[@"notification"][@"sound"], expectedSound);
}

- (void)testFCMSSound_ShouldNotSet_WhenNilPassedToBuilder {
    PNFCMNotificationPayload *builder = [PNFCMNotificationPayload payloadWithStorage:self.platformPayloadStorage
                                                                   notificationTitle:nil
                                                                                body:nil];
    builder.sound = nil;
    
    XCTAssertNil(self.platformPayloadStorage[@"notification"][@"sound"]);
}

- (void)testFCMSIcon_ShouldSet_WhenSoundPassedToBuilder {
    NSString *expectedIcon = [NSUUID UUID].UUIDString;
    
    
    PNFCMNotificationPayload *builder = [PNFCMNotificationPayload payloadWithStorage:self.platformPayloadStorage
                                                                   notificationTitle:nil
                                                                                body:nil];
    builder.icon = expectedIcon;
    
    XCTAssertEqualObjects(self.platformPayloadStorage[@"notification"][@"icon"], expectedIcon);
}

- (void)testFCMSIcon_ShouldNotSet_WhenNilPassedToBuilder {
    PNFCMNotificationPayload *builder = [PNFCMNotificationPayload payloadWithStorage:self.platformPayloadStorage
                                                                   notificationTitle:nil
                                                                                body:nil];
    builder.icon = nil;
    
    XCTAssertNil(self.platformPayloadStorage[@"notification"][@"icon"]);
}

- (void)testFCMSTag_ShouldSet_WhenSoundPassedToBuilder {
    NSString *expectedTag = [NSUUID UUID].UUIDString;
    
    
    PNFCMNotificationPayload *builder = [PNFCMNotificationPayload payloadWithStorage:self.platformPayloadStorage
                                                                   notificationTitle:nil
                                                                                body:nil];
    builder.tag = expectedTag;
    
    XCTAssertEqualObjects(self.platformPayloadStorage[@"notification"][@"tag"], expectedTag);
}

- (void)testFCMSTag_ShouldNotSet_WhenNilPassedToBuilder {
    PNFCMNotificationPayload *builder = [PNFCMNotificationPayload payloadWithStorage:self.platformPayloadStorage
                                                                   notificationTitle:nil
                                                                                body:nil];
    builder.tag = nil;
    
    XCTAssertNil(self.platformPayloadStorage[@"notification"][@"tag"]);
}

- (void)testFCMDictionaryRepresentation_ShouldBeNil_WhenNoInformationPassed {
    PNFCMNotificationPayload *builder = [PNFCMNotificationPayload payloadWithStorage:self.platformPayloadStorage
                                                                   notificationTitle:nil
                                                                                body:nil];
    
    XCTAssertNil([builder dictionaryRepresentation]);
}

- (void)testFCMDictionaryRepresentation_ShouldMoveNotificationToData_WhenSilentSetToYES {
    NSString *expectedSound = [NSUUID UUID].UUIDString;
    NSString *expectedTitle = [NSUUID UUID].UUIDString;
    NSString *expectedBody = [NSUUID UUID].UUIDString;
    NSDictionary *expectedNotification = @{
        @"title": expectedTitle,
        @"body": expectedBody,
        @"sound": expectedSound
    };
    
    PNFCMNotificationPayload *builder = [PNFCMNotificationPayload payloadWithStorage:self.platformPayloadStorage
                                                                   notificationTitle:expectedTitle
                                                                                body:expectedBody];
    builder.sound = expectedSound;
    builder.silent = YES;
    
    XCTAssertNil([builder dictionaryRepresentation][@"notification"]);
    XCTAssertEqualObjects([builder dictionaryRepresentation][@"data"][@"notification"], expectedNotification);
}

- (void)testFCMDictionaryRepresentation_ShouldBeValid_WhenAllInformationPassed {
    NSString *expectedSound = [NSUUID UUID].UUIDString;
    NSString *expectedTitle = [NSUUID UUID].UUIDString;
    NSString *expectedBody = [NSUUID UUID].UUIDString;
    NSDictionary *expectedPayload = @{
        @"notification": @{
            @"title": expectedTitle,
            @"body": expectedBody,
            @"sound": expectedSound
        }
    };
    
    
    PNFCMNotificationPayload *builder = [PNFCMNotificationPayload payloadWithStorage:self.platformPayloadStorage
                                                                   notificationTitle:expectedTitle
                                                                                body:expectedBody];
    builder.sound = expectedSound;
    
    XCTAssertEqualObjects([builder dictionaryRepresentation], expectedPayload);
}

#pragma mark -


@end
