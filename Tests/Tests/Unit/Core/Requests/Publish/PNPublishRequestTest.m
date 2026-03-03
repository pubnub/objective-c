#import <XCTest/XCTest.h>
#import <PubNub/PNPublishRequest.h>
#import <PubNub/PNPublishFileMessageRequest.h>
#import <PubNub/PNSignalRequest.h>
#import <PubNub/PNBasePublishRequest.h>
#import "PNBaseRequest+Private.h"


#pragma mark Interface declaration

@interface PNPublishRequestTest : XCTestCase

@end


#pragma mark - Tests

@implementation PNPublishRequestTest


#pragma mark - PNPublishRequest :: Construction

- (void)testItShouldCreatePublishRequestWhenChannelProvided {
    PNPublishRequest *request = [PNPublishRequest requestWithChannel:@"test-channel"];

    XCTAssertNotNil(request);
    XCTAssertEqualObjects(request.channel, @"test-channel");
}

- (void)testItShouldHaveDefaultValuesWhenPublishRequestCreated {
    PNPublishRequest *request = [PNPublishRequest requestWithChannel:@"test-channel"];

    XCTAssertTrue(request.shouldReplicate, @"Replicate should default to YES");
    XCTAssertTrue(request.shouldStore, @"Store should default to YES");
    XCTAssertFalse(request.shouldCompress, @"Compress should default to NO");
    XCTAssertEqual(request.ttl, 0, @"TTL should default to 0");
    XCTAssertNil(request.metadata, @"Metadata should default to nil");
    XCTAssertNil(request.message, @"Message should default to nil");
    XCTAssertNil(request.payloads, @"Payloads should default to nil");
    XCTAssertNil(request.customMessageType, @"customMessageType should default to nil");
}


#pragma mark - PNPublishRequest :: Query parameters

- (void)testItShouldIncludeStoreDisabledInQuery {
    PNPublishRequest *request = [PNPublishRequest requestWithChannel:@"ch"];
    request.store = NO;

    XCTAssertEqualObjects(request.query[@"store"], @"0");
}

- (void)testItShouldIncludeReplicateDisabledInQuery {
    PNPublishRequest *request = [PNPublishRequest requestWithChannel:@"ch"];
    request.replicate = NO;

    XCTAssertEqualObjects(request.query[@"norep"], @"true");
}

- (void)testItShouldIncludeTTLInQueryWhenStoredWithTTL {
    PNPublishRequest *request = [PNPublishRequest requestWithChannel:@"ch"];
    request.store = YES;
    request.ttl = 300;

    XCTAssertEqualObjects(request.query[@"ttl"], @(300).stringValue);
}

- (void)testItShouldNotIncludeTTLInQueryWhenStoreDisabled {
    PNPublishRequest *request = [PNPublishRequest requestWithChannel:@"ch"];
    request.store = NO;
    request.ttl = 300;

    XCTAssertNil(request.query[@"ttl"], @"TTL should not appear when store is disabled");
}

- (void)testItShouldIncludeCustomMessageTypeInQuery {
    PNPublishRequest *request = [PNPublishRequest requestWithChannel:@"ch"];
    request.customMessageType = @"text-message";

    XCTAssertEqualObjects(request.query[@"custom_message_type"], @"text-message");
}

- (void)testItShouldIncludeArbitraryParametersInPublishQuery {
    PNPublishRequest *request = [PNPublishRequest requestWithChannel:@"ch"];
    request.arbitraryQueryParameters = @{ @"key1": @"value1" };

    XCTAssertEqualObjects(request.query[@"key1"], @"value1");
}


#pragma mark - PNSignalRequest :: Construction

- (void)testItShouldCreateSignalRequestWhenChannelAndDataProvided {
    PNSignalRequest *request = [PNSignalRequest requestWithChannel:@"signal-ch" signal:@"status-update"];

    XCTAssertNotNil(request);
    XCTAssertEqualObjects(request.channel, @"signal-ch");
}

- (void)testItShouldAcceptDictionarySignalDataWhenCreated {
    NSDictionary *signalData = @{ @"temperature": @72.5 };
    PNSignalRequest *request = [PNSignalRequest requestWithChannel:@"sensors" signal:signalData];

    XCTAssertNotNil(request);
    XCTAssertEqualObjects(request.channel, @"sensors");
}


#pragma mark - PNSignalRequest :: Query parameters

- (void)testItShouldIncludeCustomMessageTypeInSignalQuery {
    PNSignalRequest *request = [PNSignalRequest requestWithChannel:@"ch" signal:@"data"];
    request.customMessageType = @"sensor-update";

    XCTAssertEqualObjects(request.query[@"custom_message_type"], @"sensor-update");
}


#pragma mark - PNPublishFileMessageRequest :: Construction

- (void)testItShouldCreateFileMessageRequestWhenAllRequiredParamsProvided {
    PNPublishFileMessageRequest *request = [PNPublishFileMessageRequest requestWithChannel:@"file-ch"
                                                                            fileIdentifier:@"file-id-123"
                                                                                      name:@"photo.jpg"];

    XCTAssertNotNil(request);
    XCTAssertEqualObjects(request.channel, @"file-ch");
    XCTAssertEqualObjects(request.identifier, @"file-id-123");
    XCTAssertEqualObjects(request.filename, @"photo.jpg");
}

- (void)testItShouldInheritBasePublishDefaultsWhenFileMessageRequestCreated {
    PNPublishFileMessageRequest *request = [PNPublishFileMessageRequest requestWithChannel:@"ch"
                                                                            fileIdentifier:@"id"
                                                                                      name:@"file.txt"];

    XCTAssertTrue(request.shouldReplicate, @"Replicate should default to YES from base");
    XCTAssertTrue(request.shouldStore, @"Store should default to YES from base");
    XCTAssertEqual(request.ttl, 0, @"TTL should default to 0 from base");
}

- (void)testItShouldIncludeStoreDisabledInFileMessageQuery {
    PNPublishFileMessageRequest *request = [PNPublishFileMessageRequest requestWithChannel:@"ch"
                                                                            fileIdentifier:@"id"
                                                                                      name:@"file.txt"];
    request.store = NO;

    XCTAssertEqualObjects(request.query[@"store"], @"0");
}

- (void)testItShouldIncludeCustomMessageTypeInFileMessageQuery {
    PNPublishFileMessageRequest *request = [PNPublishFileMessageRequest requestWithChannel:@"ch"
                                                                            fileIdentifier:@"id"
                                                                                      name:@"file.txt"];
    request.customMessageType = @"file-share";

    XCTAssertEqualObjects(request.query[@"custom_message_type"], @"file-share");
}


#pragma mark -

@end
