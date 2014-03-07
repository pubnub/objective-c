//
//  PNErrorTest.m
//  pubnub
//
//  Created by Valentin Tuller on 2/4/14.
//  Copyright (c) 2014 PubNub Inc. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>

@interface PNError (test)

@property (nonatomic, copy) NSString *errorMessage;
- (void)setAssociatedObject:(id)associatedObject;
- (NSString *)domainForError:(NSInteger)errorCode;

@end

@interface PNErrorTest : SenTestCase

@end

@implementation PNErrorTest

-(void)tearDown {
    [super tearDown];
	[NSThread sleepForTimeInterval:0.1];
}

-(void)testErrorWithCode {
	PNError *error = [PNError errorWithCode: 123];
	STAssertTrue( error != nil, @"");
	STAssertTrue( error.code == 123, @"");
}

-(void)testErrorWithHTTPStatusCode {
	PNError *error = [PNError errorWithHTTPStatusCode: 123];
	STAssertTrue( error.code == kPNAPIUnauthorizedAccessError, @"");

	error = [PNError errorWithHTTPStatusCode: 403];
	STAssertTrue( error.code == kPNAPIAccessForbiddenError, @"");

	error = [PNError errorWithHTTPStatusCode: 402];
	STAssertTrue( error.code == kPNAPINotAvailableOrNotEnabledError, @"");
}

-(void)testErrorWithResponseErrorMessage {
	PNError *error = [PNError errorWithResponseErrorMessage: @""];
	STAssertTrue( error.code == kPNUnknownError, @"");

	error = [PNError errorWithResponseErrorMessage: @"Presence"];
	STAssertTrue( error.code == kPNPresenceAPINotAvailableError, @"");

	error = [PNError errorWithResponseErrorMessage: @"Invalid JSON"];
	STAssertTrue( error.code == kPNInvalidJSONError, @"");

	error = [PNError errorWithResponseErrorMessage: @"Invalid Character Channel"];
	STAssertTrue( error.code == kPNRestrictedCharacterInChannelNameError, @"");

	error = [PNError errorWithResponseErrorMessage: @"Invalid Key"];
	STAssertTrue( error.code == kPNInvalidSubscribeOrPublishKeyError, @"");

	error = [PNError errorWithResponseErrorMessage: @"Message Too Large"];
	STAssertTrue( error.code == kPNTooLongMessageError, @"");

	error = [PNError errorWithResponseErrorMessage: @"Push not enabled"];
	STAssertTrue( error.code == kPNPushNotificationsNotEnabledError, @"");
}

-(void)testErrorWithMessage {
	PNError *error = [PNError errorWithMessage: @"message" code: 123];
	STAssertTrue( error != nil, @"");
	STAssertTrue( error.code == 123, @"");
	STAssertTrue( [error.errorMessage isEqualToString: @"message"], @"");
}

-(void)testInitWithMessage {
	PNError *error = [[PNError alloc] initWithMessage: @"message" code: 123];
	STAssertTrue( error != nil, @"");
	STAssertTrue( error.code == 123, @"");
	STAssertTrue( [error.errorMessage isEqualToString: @"message"], @"");
}

-(void)testSetAssociatedObject {
	PNError *error = [[PNError alloc] initWithMessage: @"message" code: 123];
	id object = @"object";
	error.associatedObject = object;
	STAssertTrue( error.associatedObject == object, @"");
}

-(void)testDomainForError {
	PNError *error = [[PNError alloc] initWithMessage: @"message" code: 123];
	STAssertTrue( [[error domainForError:1] isEqualToString: kPNDefaultErrorDomain] == YES, @"");
	STAssertTrue( [[error domainForError:111] isEqualToString: kPNServiceErrorDomain] == YES, @"");
	STAssertTrue( [[error domainForError:112] isEqualToString: kPNServiceErrorDomain] == YES, @"");
	STAssertTrue( [[error domainForError:115] isEqualToString: kPNServiceErrorDomain] == YES, @"");
}

@end




