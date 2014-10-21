//
//  PNErrorTest.m
//  pubnub
//
//  Created by Valentin Tuller on 2/4/14.
//  Copyright (c) 2014 PubNub Inc. All rights reserved.
//

#import <XCTest/XCTest.h>

@interface PNError (test)

@property (nonatomic, copy) NSString *errorMessage;
- (void)setAssociatedObject:(id)associatedObject;
- (NSString *)domainForError:(NSInteger)errorCode;

@end

@interface PNErrorTest : XCTestCase

@end

@implementation PNErrorTest

-(void)tearDown {
	[NSThread sleepForTimeInterval:0.1];
    [super tearDown];
}

-(void)testErrorWithCode {
	PNError *error = [PNError errorWithCode: 123];
	XCTAssertTrue( error != nil, @"");
	XCTAssertTrue( error.code == 123, @"");
}

-(void)testErrorWithHTTPStatusCode {
	PNError *error = [PNError errorWithHTTPStatusCode: 123];
	XCTAssertTrue( error.code == kPNAPIUnauthorizedAccessError, @"");

	error = [PNError errorWithHTTPStatusCode: 403];
	XCTAssertTrue( error.code == kPNAPIAccessForbiddenError, @"");

	error = [PNError errorWithHTTPStatusCode: 402];
	XCTAssertTrue( error.code == kPNAPINotAvailableOrNotEnabledError, @"");
}

-(void)testErrorWithResponseErrorMessage {
	PNError *error = [PNError errorWithResponseErrorMessage: @""];
	XCTAssertTrue( error.code == kPNUnknownError, @"");

	error = [PNError errorWithResponseErrorMessage: @"Presence"];
	XCTAssertTrue( error.code == kPNPresenceAPINotAvailableError, @"");

	error = [PNError errorWithResponseErrorMessage: @"Invalid JSON"];
	XCTAssertTrue( error.code == kPNInvalidJSONError, @"");

	error = [PNError errorWithResponseErrorMessage: @"Invalid Character Channel"];
	XCTAssertTrue( error.code == kPNRestrictedCharacterInChannelNameError, @"");

	error = [PNError errorWithResponseErrorMessage: @"Invalid Key"];
	XCTAssertTrue( error.code == kPNInvalidSubscribeOrPublishKeyError, @"");

	error = [PNError errorWithResponseErrorMessage: @"Message Too Large"];
	XCTAssertTrue( error.code == kPNTooLongMessageError, @"");

	error = [PNError errorWithResponseErrorMessage: @"Push not enabled"];
	XCTAssertTrue( error.code == kPNPushNotificationsNotEnabledError, @"");
}

-(void)testErrorWithMessage {
	PNError *error = [PNError errorWithMessage: @"message" code: 123];
	XCTAssertTrue( error != nil, @"");
	XCTAssertTrue( error.code == 123, @"");
	XCTAssertTrue( [error.errorMessage isEqualToString: @"message"], @"");
}

-(void)testInitWithMessage {
	PNError *error = [[PNError alloc] initWithMessage: @"message" code: 123];
	XCTAssertTrue( error != nil, @"");
	XCTAssertTrue( error.code == 123, @"");
	XCTAssertTrue( [error.errorMessage isEqualToString: @"message"], @"");
}

-(void)testSetAssociatedObject {
	PNError *error = [[PNError alloc] initWithMessage: @"message" code: 123];
	id object = @"object";
	error.associatedObject = object;
	XCTAssertTrue( error.associatedObject == object, @"");
}

-(void)testDomainForError {
	PNError *error = [[PNError alloc] initWithMessage: @"message" code: 123];
	XCTAssertTrue( [[error domainForError:1] isEqualToString: kPNDefaultErrorDomain] == YES, @"");
	XCTAssertTrue( [[error domainForError:111] isEqualToString: kPNServiceErrorDomain] == YES, @"");
	XCTAssertTrue( [[error domainForError:112] isEqualToString: kPNServiceErrorDomain] == YES, @"");
	XCTAssertTrue( [[error domainForError:115] isEqualToString: kPNServiceErrorDomain] == YES, @"");
}

@end




