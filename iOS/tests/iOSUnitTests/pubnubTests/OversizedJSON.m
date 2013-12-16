//
//  OversizedJSON.m
//  pubnub
//
//  Created by Valentin Tuller on 11/25/13.
//  Copyright (c) 2013 PubNub Inc. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "PNBaseRequest.h"
#import "PNBaseRequest+Protected.h"

#import <OCMock/OCMock.h>

#import "PubNub.h"
#import "PubNub+Protected.h"
#import "PNConfiguration.h"
#import "PNWriteBuffer.h"
#import "PNConstants.h"
#import "TestSemaphor.h"
#import "Swizzler.h"
#import "PNConnection.h"

@interface OversizedJSON : SenTestCase <PNDelegate> {
	int _reconnectCount;
	SwizzleReceipt *receiptReconnect;
}

@end

@implementation OversizedJSON

- (void)setUp
{
    [super setUp];

	[PubNub disconnect];

	int64_t delayInSeconds = 2;
	dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
	dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
	dispatch_after(popTime, dispatch_get_main_queue(), ^(void) {

		[PubNub setDelegate:self];
		[PubNub setConfiguration:[PNConfiguration configurationForOrigin:@"pubsub.pubnub.com" publishKey: @"pub-c-bb4a4d9b-21b1-40e8-a30b-04a22f5ef154"  subscribeKey: @"sub-c-6b43405c-3694-11e3-a5ee-02ee2ddab7fe" secretKey: @"sec-c-ZmNlNzczNTEtOGUwNS00MmRjLWFkMjQtMjJiOTA2MjY2YjI5"]];

		[PubNub connectWithSuccessBlock:^(NSString *origin) {

			PNLog(PNLogGeneralLevel, nil, @"\n\n\n\n\n\n\n{BLOCK} PubNub client connected to: %@", origin);
			dispatch_semaphore_signal(semaphore);
		}
							 errorBlock:^(PNError *connectionError) {
								 PNLog(PNLogGeneralLevel, nil, @"connectionError %@", connectionError);
								 dispatch_semaphore_signal(semaphore);
								 STFail(@"connectionError %@", connectionError);
							 }];
	});
	while (dispatch_semaphore_wait(semaphore, DISPATCH_TIME_NOW))
		[[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
								 beforeDate:[NSDate dateWithTimeIntervalSinceNow:1]];

	[PubNub grantAllAccessRightsForApplicationAtPeriod: 10 andCompletionHandlingBlock:^(PNAccessRightsCollection *collection, PNError *error) {
		STAssertNil( error, @"grantAllAccessRightsForApplicationAtPeriod %@", error);
	}];
	for( int j=0; j<10; j++ )
		[[NSRunLoop currentRunLoop] runUntilDate: [NSDate dateWithTimeIntervalSinceNow: 1.0] ];

    semaphore = dispatch_semaphore_create(0);
	[PubNub subscribeOnChannels: [PNChannel channelsWithNames: @[@"channel"]]
	withCompletionHandlingBlock:^(PNSubscriptionProcessState state, NSArray *channels, PNError *subscriptionError)
	 {
		 dispatch_semaphore_signal(semaphore);
		 STAssertNil(subscriptionError, @"subscribeOnChannels subscriptionError %@", subscriptionError);
	 }];
    while (dispatch_semaphore_wait(semaphore, DISPATCH_TIME_NOW))
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                 beforeDate:[NSDate dateWithTimeIntervalSinceNow:1]];
}

- (void)tearDown {
	[super tearDown];
	[NSThread sleepForTimeInterval:1.0];
}

-(void)test10SendMessage {
	NSDictionary *dic = @{@"channel": @"private:Kanav1.10",
						  @"msg": @"{\"battleId\":\"B147C90E-DA9C-44A7-AC7C-0A85FBE7E10A\",\"inviteeRole\":0,\"messageType\":0,\"battleInput\":{\"defenderPlayer\":{\"guildName\":\"Kanvid\",\"username\":\"Kanav1.10\",\"pgid\":\"70f162663246ab5070318f372dd7d0c0f5aa803c\",\"level\":7},\"battleBuildings\":[{\"expansionArea\":\"expansion_003\",\"identifier\":\"0\",\"objectType\":\"goldVault\",\"level\":0},{\"expansionArea\":\"expansion_001\",\"identifier\":\"1\",\"objectType\":\"stable\",\"level\":1},{\"expansionArea\":\"expansion_021\",\"identifier\":\"2\",\"objectType\":\"goldVault\",\"level\":0},{\"expansionArea\":\"expansion_014\",\"identifier\":\"3\",\"objectType\":\"goldVault\",\"level\":0},{\"expansionArea\":\"expansion_024\",\"identifier\":\"4\",\"objectType\":\"goldVault\",\"level\":0},{\"expansionArea\":\"expansion_026\",\"identifier\":\"5\",\"objectType\":\"goldVault\",\"level\":0},{\"expansionArea\":\"expansion_011\",\"identifier\":\"6\",\"objectType\":\"goldVault\",\"level\":0},{\"expansionArea\":\"expansion_039\",\"identifier\":\"7\",\"objectType\":\"goldVault\",\"level\":0},{\"expansionArea\":\"expansion_022\",\"identifier\":\"8\",\"objectType\":\"guild\",\"level\":1},{\"expansionArea\":\"expansion_018\",\"identifier\":\"9\",\"objectType\":\"archerTower\",\"level\":1},{\"expansionArea\":\"expansion_007\",\"identifier\":\"10\",\"objectType\":\"cannonTower\",\"level\":1},{\"expansionArea\":\"expansion_006\",\"identifier\":\"11\",\"objectType\":\"archerTower\",\"level\":1},{\"expansionArea\":\"expansion_015\",\"identifier\":\"12\",\"objectType\":\"archerTower\",\"level\":1},{\"expansionArea\":\"expansion_012\",\"identifier\":\"13\",\"objectType\":\"trebuchet\",\"level\":1}],\"battleId\":\"B147C90E-DA9C-44A7-AC7C-0A85FBE7E10A\",\"battleDragons\":[{\"dragonLevel\":1,\"identifier\":\"FCAC0449-D1A4-463F-B19F-9D728205CAAD\",\"dragonType\":\"redDragon\"}],\"colonyIdentifier\":\"level01\",\"currencyAmounts\":{\"food\":10,\"energy\":2,\"experience\":590,\"gold\":75,\"diamonds\":0,\"dragonSlot\":4},\"attackerPlayer\":{\"guildName\":\"Kanvid\",\"username\":\"Davidi23\",\"pgid\":\"49091c040dac8370bb907bd3bd670d168e1dcea8\",\"level\":8}},\"hostUsername\":\"Davidi23\",\"battleStartTimeMs\":1385168393497.332}",
						  @"msg_data_type": @"battle",
						  @"sender_chat_name": @"Davidi23",
						  @"sender_pgid": @"49091c040dac8370bb907bd3bd670d168e1dcea8",
						  @"ts": @(1385168393499) };

	_reconnectCount = 0;
	receiptReconnect = [self setReconnect];
	[PubNub sendMessage: dic toChannel: [PNChannel channelWithName: @"channel"]
	withCompletionBlock:^(PNMessageState messageSendingState, id data)
	 {
	 }];

	for( int j=0; j<10; j++ )
		[[NSRunLoop currentRunLoop] runUntilDate: [NSDate dateWithTimeIntervalSinceNow: 1.0] ];
	[Swizzler unswizzleFromReceipt:receiptReconnect];

	STAssertTrue(_reconnectCount == 0, @"excess reconnect, %d", _reconnectCount);
}

-(SwizzleReceipt*)setReconnect {
	return [Swizzler swizzleSelector:@selector(reconnect)
				 forInstancesOfClass:[PNConnection class]
						   withBlock:
			^(id object, SEL sel){
				PNLog(PNLogGeneralLevel, nil, @"PNConnection setReconnect");
				_reconnectCount++;
				[Swizzler unswizzleFromReceipt:receiptReconnect];
				[(PNConnection*)object reconnect];
				receiptReconnect = [self setReconnect];
			}];
}


@end
