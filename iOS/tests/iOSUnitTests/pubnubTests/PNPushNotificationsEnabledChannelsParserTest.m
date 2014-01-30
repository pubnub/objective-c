//
//  PNPushNotificationsEnabledChannelsParserTest.m
//  pubnub
//
//  Created by Valentin Tuller on 1/30/14.
//  Copyright (c) 2014 PubNub Inc. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "PNPushNotificationsEnabledChannelsParser.h"
#import "PNResponse.h"
#import "PNOperationStatusResponseParser.h"
#import "PNOperationStatus.h"
#import "PNError.h"

@interface PNError (test)
@property (nonatomic, copy) NSString *errorMessage;
@end

@interface PNResponse (test)

@property (nonatomic, strong) id response;
@property (nonatomic, assign) NSInteger statusCode;

@end


@interface PNPushNotificationsEnabledChannelsParser (test)

@property (nonatomic, strong) PNOperationStatus *operationStatus;
- (id)initWithResponse:(PNResponse *)response;

@end


@interface PNPushNotificationsEnabledChannelsParserTest : SenTestCase

@end

@implementation PNPushNotificationsEnabledChannelsParserTest

-(void)tearDown {
    [super tearDown];
	[NSThread sleepForTimeInterval:1.0];
}

-(void)testInit {
	PNResponse *response = [[PNResponse alloc] init];
	NSArray *channels = @[@"ch1", @"ch2"];
	response.response = channels;

	PNPushNotificationsEnabledChannelsParser *parser = [[PNPushNotificationsEnabledChannelsParser alloc] initWithResponse: response];
	STAssertTrue( parser != nil, @"");
	STAssertTrue( [[parser parsedData] isEqualToArray: channels] == YES, @"");
}

@end
